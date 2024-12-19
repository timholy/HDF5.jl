# This file is a companion to `src/api.jl` --- it defines the raw ccall wrappers, while
# here small normalizations are made to make the calls more Julian.
# For instance, many property getters return values through pointer output arguments,
# so the methods here handle making the appropriate `Ref`s and return them (as tuples).

const H5F_LIBVER_LATEST = if _libhdf5_build_ver >= v"1.15"
    H5F_LIBVER_V116
elseif _libhdf5_build_ver >= v"1.14"
    H5F_LIBVER_V114
elseif _libhdf5_build_ver >= v"1.12"
    H5F_LIBVER_V112
elseif _libhdf5_build_ver >= v"1.10"
    H5F_LIBVER_V110
else
    H5F_LIBVER_V108
end

###
### HDF5 General library functions
###

function h5_get_libversion()
    majnum, minnum, relnum = Ref{Cuint}(), Ref{Cuint}(), Ref{Cuint}()
    h5_get_libversion(majnum, minnum, relnum)
    VersionNumber(majnum[], minnum[], relnum[])
end

function h5_is_library_threadsafe()
    is_ts = Ref{Cuchar}(0)
    h5_is_library_threadsafe(is_ts)
    return is_ts[] > 0
end

###
### HDF5 File Interface
###
function h5f_get_dset_no_attrs_hint(file_id)::Bool
    minimize = Ref{hbool_t}(false)
    h5f_get_dset_no_attrs_hint(file_id, minimize)
    return minimize[]
end

"""
    h5f_get_file_image(file_id)

Return a `Vector{UInt8}` containing the file image. Does not include the user block.
"""
function h5f_get_file_image(file_id)
    buffer_length = h5f_get_file_image(file_id, C_NULL, 0)
    buffer = Vector{UInt8}(undef, buffer_length)
    h5f_get_file_image(file_id, buffer, buffer_length)
    return buffer
end

"""
    h5f_get_file_image(file_id, buffer::Vector{UInt8})

Store the file image in the provided buffer.
"""
function h5f_get_file_image(file_id, buffer::Vector{UInt8})
    h5f_get_file_image(fild_id, buffer, length(buffer))
end

###
### Attribute Interface
###

function h5a_get_name(attr_id)
    len = h5a_get_name(attr_id, 0, C_NULL)
    buf = StringVector(len)
    h5a_get_name(attr_id, len + 1, buf)
    return String(buf)
end

function h5a_get_name_by_idx(loc_id, obj_name, idx_type, order, idx, lapl_id)
    len = h5a_get_name_by_idx(loc_id, obj_name, idx_type, order, idx, C_NULL, 0, lapl_id)
    buf = StringVector(len)
    h5a_get_name_by_idx(loc_id, obj_name, idx_type, order, idx, buf, len + 1, lapl_id)
    return String(buf)
end

# libhdf5 supports proper closure environments, so we use that support rather than
# emulating it with the less desirable form of creating closure handles directly in
# `@cfunction` with `$f`.
# This helper translates between the two preferred forms for each respective language.
function h5a_iterate_helper(
    loc_id::hid_t, attr_name::Ptr{Cchar}, ainfo::Ptr{H5A_info_t}, @nospecialize(data::Any)
)::herr_t
    f, err_ref = data
    try
        ret = herr_t(f(loc_id, attr_name, ainfo))
        @async @info "h5a_iterate_helper" ret
        return ret
    catch err
        @async @info "h5a_iterate_helper got an error" err
        err_ref[] = err
        return herr_t(-1)
    end
end

"""
    h5a_iterate(f, loc_id, idx_type, order, idx = 0) -> hsize_t

Executes [`h5a_iterate`](@ref h5a_iterate(::hid_t, ::Cint, ::Cint,
::Ptr{hsize_t}, ::Ptr{Cvoid}, ::Ptr{Cvoid})) with the user-provided callback
function `f`, returning the index where iteration ends.

The callback function must correspond to the signature
```
f(loc::HDF5.API.hid_t, name::Ptr{Cchar}, info::Ptr{HDF5.API.H5A_info_t}) -> Union{Bool, Integer}
```
where a negative return value halts iteration abnormally (triggering an error),
a `true` or a positive value halts iteration successfully, and `false` or zero
continues iteration.

# Examples
```julia-repl
julia> HDF5.API.h5a_iterate(obj, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC) do loc, name, info
           println(unsafe_string(name))
           return false
       end
```
"""
function h5a_iterate(@nospecialize(f), obj_id, idx_type, order, idx=0)
    err_ref = Ref{Any}(nothing)
    idxref = Ref{hsize_t}(idx)
    fptr = @cfunction(h5a_iterate_helper, herr_t, (hid_t, Ptr{Cchar}, Ptr{H5A_info_t}, Any))
    try
        h5a_iterate(obj_id, idx_type, order, idxref, fptr, (f, err_ref))
    catch h5err
        jlerr = err_ref[]
        if !isnothing(jlerr)
            rethrow(jlerr)
        end
        rethrow(h5err)
    end
    return idxref[]
end

###
### Dataset Interface
###

"""
    h5d_vlen_get_buf_size(dataset_id, type_id, space_id)

Helper method to determines the number of bytes required to store the variable length data from the dataset. Returns a value of type `HDF5.API.hsize_t`.
"""
function h5d_vlen_get_buf_size(dataset_id, type_id, space_id)
    sz = Ref{hsize_t}()
    h5d_vlen_get_buf_size(dataset_id, type_id, space_id, sz)
    return sz[]
end

"""
    h5d_get_chunk_info(dataset_id, fspace_id, index)
    h5d_get_chunk_info(dataset_id, index; fspace_id = HDF5.API.H5S_ALL)

Helper method to retrieve chunk information.

Returns a `NamedTuple{(:offset, :filter_mask, :addr, :size), Tuple{HDF5.API.hsize_t, UInt32, HDF5.API.haddr_t, HDF5.API.hsize_t}}`.
"""
function h5d_get_chunk_info(dataset_id, fspace_id, index)
    offset = Vector{hsize_t}(undef, ndims(dataset_id))
    filter_mask = Ref{UInt32}()
    addr = Ref{haddr_t}()
    size = Ref{hsize_t}()
    h5d_get_chunk_info(dataset_id, fspace_id, index, offset, filter_mask, addr, size)
    return (offset=offset, filter_mask=filter_mask[], addr=addr[], size=size[])
end
h5d_get_chunk_info(dataset_id, index; fspace_id=H5S_ALL) =
    h5d_get_chunk_info(dataset_id, fspace_id, index)

"""
    h5d_get_chunk_info_by_coord(dataset_id, offset)

Helper method to read chunk information by coordinate. Returns a `NamedTuple{(:filter_mask, :addr, :size), Tuple{UInt32, HDF5.API.haddr_t, HDF5.API.hsize_t}}`.
"""
function h5d_get_chunk_info_by_coord(dataset_id, offset)
    filter_mask = Ref{UInt32}()
    addr = Ref{haddr_t}()
    size = Ref{hsize_t}()
    h5d_get_chunk_info_by_coord(dataset_id, offset, filter_mask, addr, size)
    return (filter_mask=filter_mask[], addr=addr[], size=size[])
end

"""
    h5d_get_chunk_storage_size(dataset_id, offset)

Helper method to retrieve the chunk storage size in bytes. Returns an integer of type `HDF5.API.hsize_t`.
"""
function h5d_get_chunk_storage_size(dataset_id, offset)
    chunk_nbytes = Ref{hsize_t}()
    h5d_get_chunk_storage_size(dataset_id, offset, chunk_nbytes)
    return chunk_nbytes[]
end

@static if v"1.10.5" ≤ _libhdf5_build_ver
    """
        h5d_get_num_chunks(dataset_id, fspace_id = H5S_ALL)

    Helper method to retrieve the number of chunks. Returns an integer of type `HDF5.API.hsize_t`.
    """
    function h5d_get_num_chunks(dataset_id, fspace_id=H5S_ALL)
        nchunks = Ref{hsize_t}()
        h5d_get_num_chunks(dataset_id, fspace_id, nchunks)
        return nchunks[]
    end
end

"""
    h5d_chunk_iter(f, dataset, [dxpl_id=H5P_DEFAULT])

Call `f(offset::Ptr{hsize_t}, filter_mask::Cuint, addr::haddr_t, size::hsize_t)` for each chunk.
`dataset` maybe a `HDF5.Dataset` or a dataset id.
`dxpl_id` is the the dataset transfer property list and is optional.

Available only for HDF5 1.10.x series for 1.10.9 and greater or for version HDF5 1.12.3 or greater.
"""
h5d_chunk_iter() = nothing

@static if v"1.12.3" ≤ _libhdf5_build_ver ||
    (_libhdf5_build_ver.minor == 10 && _libhdf5_build_ver.patch >= 10)
    # H5Dchunk_iter is first available in 1.10.10, 1.12.3, and 1.14.0 in the 1.10, 1.12, and 1.14 minor version series, respectively
    function h5d_chunk_iter_helper(
        offset::Ptr{hsize_t},
        filter_mask::Cuint,
        addr::haddr_t,
        size::hsize_t,
        @nospecialize(data::Any)
    )::H5_iter_t
        func, err_ref = data
        try
            return convert(H5_iter_t, func(offset, filter_mask, addr, size))
        catch err
            err_ref[] = err
            return H5_ITER_ERROR
        end
    end
    function h5d_chunk_iter(@nospecialize(f), dset_id, dxpl_id=H5P_DEFAULT)
        err_ref = Ref{Any}(nothing)
        fptr = @cfunction(
            h5d_chunk_iter_helper, H5_iter_t, (Ptr{hsize_t}, Cuint, haddr_t, hsize_t, Any)
        )
        try
            return h5d_chunk_iter(dset_id, dxpl_id, fptr, (f, err_ref))
        catch h5err
            jlerr = err_ref[]
            if !isnothing(jlerr)
                rethrow(jlerr)
            end
            rethrow(h5err)
        end
    end
end

"""
    h5d_get_space_status(dataset_id)

Helper method to retrieve the status of the dataset space.
Returns a `HDF5.API.H5D_space_status_t` (`Cint`) indicating the status, see `HDF5.API.H5D_SPACE_STATUS_`* constants.
"""
function h5d_get_space_status(dataset_id)
    r = Ref{H5D_space_status_t}()
    h5d_get_space_status(dataset_id, r)
    return r[]
end

###
### Error Interface
###

function h5e_get_auto(estack_id)
    func = Ref{Ptr{Cvoid}}()
    client_data = Ref{Ptr{Cvoid}}()
    h5e_get_auto(estack_id, func, client_data)
    return func[], client_data[]
end

"""
    mesg_type, mesg = h5e_get_msg(meshg_id)

"""
function h5e_get_msg(mesg_id)
    mesg_type = Ref{Cint}()
    mesg_len = h5e_get_msg(mesg_id, mesg_type, C_NULL, 0)
    buffer = StringVector(mesg_len)
    h5e_get_msg(mesg_id, mesg_type, buffer, mesg_len + 1)
    resize!(buffer, mesg_len)
    return mesg_type[], String(buffer)
end

# See explanation for h5a_iterate above.
function h5e_walk_helper(
    n::Cuint, err_desc::Ptr{H5E_error2_t}, @nospecialize(data::Any)
)::herr_t
    f, err_ref = data
    try
        return herr_t(f(n, err_desc))
    catch err
        err_ref[] = err
        return herr_t(-1)
    end
end
function h5e_walk(f::Function, stack_id, direction)
    err_ref = Ref{Any}(nothing)
    fptr = @cfunction(h5e_walk_helper, herr_t, (Cuint, Ptr{H5E_error2_t}, Any))
    try
        h5e_walk(stack_id, direction, fptr, (f, err_ref))
    catch h5err
        jlerr = err_ref[]
        if !isnothing(jlerr)
            rethrow(jlerr)
        end
        rethrow(h5err)
    end
end

###
### File Interface
###

function h5f_get_intent(file_id)
    intent = Ref{Cuint}()
    h5f_get_intent(file_id, intent)
    return intent[]
end

function h5f_get_name(loc_id)
    len = h5f_get_name(loc_id, C_NULL, 0)
    buf = StringVector(len)
    h5f_get_name(loc_id, buf, len + 1)
    return String(buf)
end

function h5f_get_obj_ids(file_id, types)
    sz = h5f_get_obj_count(file_id, types)
    hids = Vector{hid_t}(undef, sz)
    sz2 = h5f_get_obj_ids(file_id, types, sz, hids)
    sz2 != sz && resize!(hids, sz2)
    return hids
end

function h5f_get_vfd_handle(file_id, fapl)
    file_handle = Ref{Ptr{Cvoid}}()
    h5f_get_vfd_handle(file_id, fapl, file_handle)
    return file_handle[]
end

"""
    h5f_get_free_sections(file_id, type, [sect_info::AbstractVector{H5F_sect_info_t}])::AbstractVector{H5F_sect_info_t}

Return an `AbstractVector` of the free section information. If `sect_info` is not provided a new `Vector` will be allocated and returned.
If `sect_info` is provided, a view, a `SubArray`, will be returned.
"""
function h5f_get_free_sections(file_id, type)
    nsects = h5f_get_free_sections(file_id, type, 0, C_NULL)
    sect_info = Vector{H5F_sect_info_t}(undef, nsects)
    if nsects > 0
        h5f_get_free_sections(file_id, type, nsects, sect_info)
    end
    return sect_info
end

function h5f_get_free_sections(file_id, type, sect_info::AbstractVector{H5F_sect_info_t})
    nsects = length(sect_info)
    nsects = h5f_get_free_sections(file_id, type, nsects, sect_info)
    return @view(sect_info[1:nsects])
end

function h5p_get_file_locking(fapl)
    use_file_locking = Ref{API.hbool_t}(0)
    ignore_when_disabled = Ref{API.hbool_t}(0)
    h5p_get_file_locking(fapl, use_file_locking, ignore_when_disabled)
    return (
        use_file_locking     = Bool(use_file_locking[]),
        ignore_when_disabled = Bool(ignore_when_disabled[])
    )
end

# Check to see if h5p_set_file_locking should exist
const _has_h5p_set_file_locking = _has_symbol(:H5Pset_file_locking)
function has_h5p_set_file_locking()
    return _has_h5p_set_file_locking
    #=
    h5_version = h5_get_libversion()
    if (h5_version >= v"1.10" && h5_version < v"1.10.7") ||
       (h5_version >= v"1.12" && h5_version < v"1.12.1") ||
       (h5_version < v"1.10")
       return false
    else
       return true
    end
    =#
end

function h5p_get_file_space_strategy(plist_id)
    strategy = Ref{H5F_fspace_strategy_t}()
    persist = Ref{hbool_t}(0)
    threshold = Ref{hsize_t}()
    h5p_get_file_space_strategy(plist_id, strategy, persist, threshold)
    return (strategy=strategy[], persist=persist[], threshold=threshold[])
end

function h5p_get_file_space_page_size(plist_id)
    fsp_size = Ref{hsize_t}()
    h5p_get_file_space_page_size(plist_id, fsp_size)
    return fsp_size[]
end

function h5p_set_file_space_strategy(
    plist_id; strategy=nothing, persist=nothing, threshold=nothing
)
    current = h5p_get_file_space_strategy(plist_id)
    strategy = isnothing(strategy) ? current[:strategy] : strategy
    persist = isnothing(persist) ? current[:persist] : persist
    threshold = isnothing(threshold) ? current[:threshold] : threshold
    return h5p_set_file_space_strategy(plist_id, strategy, persist, threshold)
end

###
### Group Interface
###

function h5g_get_info(loc_id)
    ginfo = Ref{H5G_info_t}()
    h5g_get_info(loc_id, ginfo)
    return ginfo[]
end

function h5g_get_num_objs(loc_id)
    num_objs = Ref{hsize_t}()
    h5g_get_num_objs(loc_id, num_objs)
    return num_objs[]
end

###
### Identifier Interface
###

function h5i_get_name(loc_id)
    len = h5i_get_name(loc_id, C_NULL, 0)
    buf = StringVector(len)
    h5i_get_name(loc_id, buf, len + 1)
    return String(buf)
end

###
### Link Interface
###

function h5l_get_info(link_loc_id, link_name, lapl_id)
    info = Ref{H5L_info_t}()
    h5l_get_info(link_loc_id, link_name, info, lapl_id)
    return info[]
end

function h5l_get_name_by_idx(loc_id, group_name, idx_type, order, idx, lapl_id)
    len = h5l_get_name_by_idx(loc_id, group_name, idx_type, order, idx, C_NULL, 0, lapl_id)
    buf = StringVector(len)
    h5l_get_name_by_idx(loc_id, group_name, idx_type, order, idx, buf, len + 1, lapl_id)
    return String(buf)
end

# See explanation for h5a_iterate above.
function h5l_iterate_helper(
    group::hid_t, name::Ptr{Cchar}, info::Ptr{H5L_info_t}, @nospecialize(data::Any)
)::herr_t
    f, err_ref = data
    try
        ret = herr_t(f(group, name, info))
        @async @info "h5l_iterate_helper" ret
        return ret
    catch err
        @async @info "h5l_iterate_helper got an error" err
        err_ref[] = err
        return herr_t(-1)
    end
end
"""
    h5l_iterate(f, group_id, idx_type, order, idx = 0) -> hsize_t

Executes [`h5l_iterate`](@ref h5l_iterate(::hid_t, ::Cint, ::Cint,
::Ptr{hsize_t}, ::Ptr{Cvoid}, ::Ptr{Cvoid})) with the user-provided callback
function `f`, returning the index where iteration ends.

The callback function must correspond to the signature
```
f(group::HDF5.API.hid_t, name::Ptr{Cchar}, info::Ptr{HDF5.API.H5L_info_t}) -> Union{Bool, Integer}
```
where a negative return value halts iteration abnormally, `true` or a positive
value halts iteration successfully, and `false` or zero continues iteration.

# Examples
```julia-repl
julia> HDF5.API.h5l_iterate(hfile, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC) do group, name, info
           println(unsafe_string(name))
           return HDF5.API.herr_t(0)
       end
```
"""
function h5l_iterate(@nospecialize(f), group_id, idx_type, order, idx=0)
    err_ref = Ref{Any}(nothing)
    idxref = Ref{hsize_t}(idx)
    fptr = @cfunction(h5l_iterate_helper, herr_t, (hid_t, Ptr{Cchar}, Ptr{H5L_info_t}, Any))
    try
        h5l_iterate(group_id, idx_type, order, idxref, fptr, (f, err_ref))
    catch h5err
        jlerr = err_ref[]
        if !isnothing(jlerr)
            rethrow(jlerr)
        end
        rethrow(h5err)
    end
    return idxref[]
end

###
### Object Interface
###

@static if _libhdf5_build_ver < v"1.10.3"

    # H5Oget_info1
    function h5o_get_info(loc_id)
        oinfo = Ref{H5O_info1_t}()
        h5o_get_info(loc_id, oinfo)
        return oinfo[]
    end

    # H5Oget_info_by_name1
    function h5o_get_info_by_name(loc_id, name, lapl=H5P_DEFAULT)
        oinfo = Ref{H5O_info1_t}()
        h5o_get_info_by_name(loc_id, name, oinfo, lapl)
        return oinfo[]
    end

    # H5Oget_info_by_idx1
    function h5o_get_info_by_idx(loc_id, group_name, idx_type, order, n, lapl=H5P_DEFAULT)
        oinfo = Ref{H5O_info1_t}()
        h5o_get_info_by_idx(loc_id, group_name, idx_type, order, n, oinfo, lapl)
        return oinfo[]
    end

elseif _libhdf5_build_ver >= v"1.10.3" && _libhdf5_build_ver < v"1.12.0"

    # H5Oget_info2
    function h5o_get_info(loc_id, fields=H5O_INFO_ALL)
        oinfo = Ref{H5O_info1_t}()
        h5o_get_info(loc_id, oinfo, fields)
        return oinfo[]
    end

    # H5Oget_info_by_name2
    function h5o_get_info_by_name(loc_id, name, fields=H5O_INFO_ALL, lapl=H5P_DEFAULT)
        oinfo = Ref{H5O_info1_t}()
        h5o_get_info_by_name(loc_id, name, oinfo, fields, lapl)
        return oinfo[]
    end

    # H5Oget_info_by_idx2
    function h5o_get_info_by_idx(
        loc_id, group_name, idx_type, order, n, fields=H5O_INFO_ALL, lapl=H5P_DEFAULT
    )
        oinfo = Ref{H5O_info1_t}()
        h5o_get_info_by_idx(loc_id, group_name, idx_type, order, n, oinfo, fields, lapl)
        return oinfo[]
    end

else # _libhdf5_build_ver >= v"1.12.0"

    # H5Oget_info3
    function h5o_get_info(loc_id, fields=H5O_INFO_ALL)
        oinfo = Ref{H5O_info2_t}()
        h5o_get_info(loc_id, oinfo, fields)
        return oinfo[]
    end

    # H5Oget_info_by_name3
    function h5o_get_info_by_name(loc_id, name, fields=H5O_INFO_ALL, lapl=H5P_DEFAULT)
        oinfo = Ref{H5O_info2_t}()
        h5o_get_info_by_name(loc_id, name, oinfo, fields, lapl)
        return oinfo[]
    end

    # H5Oget_info_by_idx3
    function h5o_get_info_by_idx(
        loc_id, group_name, idx_type, order, n, fields=H5O_INFO_ALL, lapl=H5P_DEFAULT
    )
        oinfo = Ref{H5O_info2_t}()
        h5o_get_info_by_idx(loc_id, group_name, idx_type, order, n, oinfo, fields, lapl)
        return oinfo[]
    end

    function h5o_get_native_info(loc_id, fields=H5O_NATIVE_INFO_ALL)
        oinfo = Ref{H5O_native_info_t}()
        h5o_get_native_info(loc_id, oinfo, fields)
        return oinfo[]
    end

    function h5o_get_native_info_by_idx(
        loc_id, group_name, idx_type, order, n, fields=H5O_NATIVE_INFO_ALL, lapl=H5P_DEFAULT
    )
        oinfo = Ref{H5O_native_info_t}()
        h5o_get_native_info_by_idx(
            loc_id, group_name, idx_type, order, n, oinfo, fields, lapl
        )
        return oinfo[]
    end

    function h5o_get_native_info_by_name(
        loc_id, name, fields=H5O_NATIVE_INFO_ALL, lapl=H5P_DEFAULT
    )
        oinfo = Ref{H5O_native_info_t}()
        h5o_get_native_info_by_name(loc_id, name, oinfo, fields, lapl)
        return oinfo[]
    end
end # @static if _libhdf5_build_ver < v"1.12.0"

# Add a default link access property list if not specified
function h5o_exists_by_name(loc_id, name)
    return h5o_exists_by_name(loc_id, name, H5P_DEFAULT)
end

# Legacy h5o_get_info1 interface, for compat with pre-1.12.0
# Used by deprecated object_info function
"""
    h5o_get_info1(object_id, [buf])

Deprecated HDF5 function. Use [`h5o_get_info`](@ref) or [`h5o_get_native_info`](@ref) if possible.

See `libhdf5` documentation for [`H5Oget_info1`](https://portal.hdfgroup.org/display/HDF5/H5O_GET_INFO1).
"""
function h5o_get_info1(object_id, buf)
    lock(liblock)
    var"#status#" = try
        ccall((:H5Oget_info1, libhdf5), herr_t, (hid_t, Ptr{H5O_info_t}), object_id, buf)
    finally
        unlock(liblock)
    end
    var"#status#" < 0 && @h5error("Error getting object info")
    return nothing
end
function h5o_get_info1(loc_id)
    oinfo = Ref{H5O_info1_t}()
    h5o_get_info1(loc_id, oinfo)
    return oinfo[]
end

###
### Property Interface
###

function h5p_get_alignment(fapl_id)
    threshold = Ref{hsize_t}()
    alignment = Ref{hsize_t}()
    h5p_get_alignment(fapl_id, threshold, alignment)
    return threshold[], alignment[]
end

function h5p_get_alloc_time(plist_id)
    alloc_time = Ref{Cint}()
    h5p_get_alloc_time(plist_id, alloc_time)
    return alloc_time[]
end

function h5p_get_char_encoding(plist_id)
    encoding = Ref{Cint}()
    h5p_get_char_encoding(plist_id, encoding)
    return encoding[]
end

function h5p_get_chunk(plist_id)
    ndims = h5p_get_chunk(plist_id, 0, C_NULL)
    dims = Vector{hsize_t}(undef, ndims)
    h5p_get_chunk(plist_id, ndims, dims)
    return dims, ndims
end

function h5p_get_chunk_cache(dapl_id)
    nslots = Ref{Csize_t}()
    nbytes = Ref{Csize_t}()
    w0 = Ref{Cdouble}()
    h5p_get_chunk_cache(dapl_id, nslots, nbytes, w0)
    return (nslots=nslots[], nbytes=nbytes[], w0=w0[])
end

function h5p_get_create_intermediate_group(plist_id)
    cig = Ref{Cuint}()
    h5p_get_create_intermediate_group(plist_id, cig)
    return cig[]
end

function h5p_get_dxpl_mpio(dxpl_id)
    xfer_mode = Ref{Cint}()
    h5p_get_dxpl_mpio(dxpl_id, xfer_mode)
    return xfer_mode[]
end

function h5p_get_efile_prefix(plist)
    efile_len = h5p_get_efile_prefix(plist, C_NULL, 0)
    buffer = StringVector(efile_len)
    prefix_size = h5p_get_efile_prefix(plist, buffer, efile_len + 1)
    return String(buffer)
end

function h5p_set_efile_prefix(plist, sym::Symbol)
    if sym === :origin
        h5p_set_efile_prefix(plist, raw"$ORIGIN")
    else
        throw(
            ArgumentError(
                "The only valid `Symbol` argument for `h5p_set_efile_prefix` is `:origin`. Got `$sym`."
            )
        )
    end
end

function h5p_get_external(plist, idx=0)
    offset = Ref{off_t}(0)
    sz = Ref{hsize_t}(0)
    name_size = 64
    name = Base.StringVector(name_size)
    while true
        h5p_get_external(plist, idx, name_size, name, offset, sz)
        null_id = findfirst(==(0x00), name)
        if isnothing(null_id)
            name_size *= 2
            resize!(name, name_size)
        else
            resize!(name, null_id - 1)
            break
        end
    end
    # Heuristic for 32-bit Windows bug
    # Possibly related:
    # https://github.com/HDFGroup/hdf5/pull/1821
    # Quote:
    # The offset parameter is of type off_t and the offset field of H5O_efl_entry_t
    # is HDoff_t which is a different type on Windows (off_t is a 32-bit long,
    # HDoff_t is __int64, a 64-bit type).
    @static if Sys.iswindows() && sizeof(Int) == 4
        lower = 0xffffffff & sz[]
        upper = 0xffffffff & (sz[] >> 32)
        # Scenario 1: The size is in the lower 32 bits, upper 32 bits contains garbage v1.12.2
        # Scenario 2: The size is in the upper 32 bits, lower 32 bits is 0 as of HDF5 v1.12.1
        sz[] = lower == 0 && upper != 0xffffffff ? upper : lower
    end
    return (name=String(name), offset=offset[], size=sz[])
end

function h5p_get_fclose_degree(fapl_id)
    out = Ref{Cint}()
    h5p_get_fclose_degree(fapl_id, out)
    return out[]
end

function h5p_get_fill_time(plist_id)
    out = Ref{H5D_fill_time_t}()
    h5p_get_fill_time(plist_id, out)
    return out[]
end

function h5p_get_libver_bounds(plist_id)
    low = Ref{Cint}()
    high = Ref{Cint}()
    h5p_get_libver_bounds(plist_id, low, high)
    return low[], high[]
end

function h5p_get_local_heap_size_hint(plist_id)
    size_hint = Ref{Csize_t}()
    h5p_get_local_heap_size_hint(plist_id, size_hint)
    return size_hint[]
end

function h5p_get_meta_block_size(fapl_id)
    sz = Ref{hsize_t}(0)
    h5p_get_meta_block_size(fapl_id, sz)
    return sz[]
end

function h5p_get_obj_track_times(plist_id)
    track_times = Ref{UInt8}()
    h5p_get_obj_track_times(plist_id, track_times)
    return track_times[] != 0x0
end

function h5p_get_userblock(plist_id)
    len = Ref{hsize_t}()
    h5p_get_userblock(plist_id, len)
    return len[]
end

function h5p_get_virtual_count(dcpl_id)
    count = Ref{Csize_t}()
    h5p_get_virtual_count(dcpl_id, count)
    return count[]
end

function h5p_get_virtual_dsetname(dcpl_id, index)
    len = h5p_get_virtual_dsetname(dcpl_id, index, C_NULL, 0)
    buffer = StringVector(len)
    h5p_get_virtual_dsetname(dcpl_id, index, buffer, len + 1)
    return String(buffer)
end
function h5p_get_virtual_filename(dcpl_id, index)
    len = h5p_get_virtual_filename(dcpl_id, index, C_NULL, 0)
    buffer = StringVector(len)
    h5p_get_virtual_filename(dcpl_id, index, buffer, len + 1)
    return String(buffer)
end

function h5p_get_virtual_prefix(dapl_id)
    virtual_file_len = h5p_get_virtual_prefix(dapl_id, C_NULL, 0)
    buffer = StringVector(virtual_file_len)
    prefix_size = h5p_get_virtual_prefix(dapl_id, buffer, virtual_file_len + 1)
    return String(buffer)
end

function h5p_get_virtual_printf_gap(dapl_id)
    gap = Ref{hsize_t}()
    h5p_get_virtual_printf_gap(dapl_id, gap)
    return gap[]
end

function h5p_get_virtual_view(dapl_id)
    view = Ref{H5D_vds_view_t}()
    h5p_get_virtual_view(dapl_id, view)
    return view[]
end

"""
    h5p_get_file_image(fapl_id)::Vector{UInt8}

Retrieve a file image of the appropriate size in a `Vector{UInt8}`.
"""
function h5p_get_file_image(fapl_id)::Vector{UInt8}
    cb = h5p_get_file_image_callbacks(fapl_id)
    if cb.image_free != C_NULL
        # The user has configured their own memory deallocation routines.
        # The user should use a lower level call to properly handle deallocation
        error(
            "File image callback image_free is not C_NULL. Use the three argument method of h5p_get_file_image when setting file image callbacks."
        )
    end
    buf_ptr_ref = Ref{Ptr{Nothing}}()
    buf_len_ref = Ref{Csize_t}(0)
    h5p_get_file_image(fapl_id, buf_ptr_ref, buf_len_ref)
    image = unsafe_wrap(Array{UInt8}, Ptr{UInt8}(buf_ptr_ref[]), buf_len_ref[]; own=false)
    finalizer(image) do image
        # Use h5_free_memory to ensure we are using the correct free
        h5_free_memory(image)
    end
    return image
end

"""
    h5p_set_file_image(fapl_id, image::Vector{UInt8})

Set the file image from a `Vector{UInt8}`.
"""
function h5p_set_file_image(fapl_id, image::Vector{UInt8})
    h5p_set_file_image(fapl_id, image, length(image))
end

"""
    h5p_get_file_image_callbacks(fapl_id)

Retrieve the file image callbacks for memory operations
"""
function h5p_get_file_image_callbacks(fapl_id)
    cb = H5FD_file_image_callbacks_t(C_NULL, C_NULL, C_NULL, C_NULL, C_NULL, C_NULL, C_NULL)
    r = Ref(cb)
    h5p_get_file_image_callbacks(fapl_id, r)
    return r[]
end

# Note: The following function(s) implement direct ccalls because the binding generator
# cannot (yet) do the string wrapping and memory freeing.

"""
    h5p_get_class_name(pcid::hid_t) -> String

See `libhdf5` documentation for [`H5P_GET_CLASS_NAME`](https://portal.hdfgroup.org/display/HDF5/H5P_GET_CLASS_NAME).
"""
function h5p_get_class_name(pcid)
    lock(liblock)
    pc = try
        ccall((:H5Pget_class_name, libhdf5), Ptr{UInt8}, (hid_t,), pcid)
    finally
        unlock(liblock)
    end
    if pc == C_NULL
        @h5error("Error getting class name")
    end
    s = unsafe_string(pc)
    h5_free_memory(pc)
    return s
end

function h5p_get_attr_creation_order(p)
    attr = Ref{UInt32}()
    h5p_get_attr_creation_order(p, attr)
    return attr[]
end

function h5p_get_link_creation_order(p)
    link = Ref{UInt32}()
    h5p_get_link_creation_order(p, link)
    return link[]
end

function h5p_get_dset_no_attrs_hint(dcpl)::hbool_t
    minimize = Ref{hbool_t}(false)
    h5p_get_dset_no_attrs_hint(dcpl, minimize)
    return minimize[] > 0
end

###
### Plugin Interface
###

function h5pl_get_loading_state()
    plugin_control_mask = Ref{Cuint}()
    h5pl_get_loading_state(plugin_control_mask)
    plugin_control_mask[]
end

function h5pl_get(index=0)
    buf_size = Csize_t(1024)
    path_buf = Vector{Cchar}(undef, buf_size)
    h5pl_get(index, path_buf, buf_size)
    unsafe_string(pointer(path_buf))
end

function h5pl_size()
    num_paths = Ref{Cuint}()
    h5pl_size(num_paths)
    num_paths[]
end

###
### Reference Interface
###

###
### Dataspace Interface
###

function h5s_get_regular_hyperslab(space_id)
    n      = h5s_get_simple_extent_ndims(space_id)
    start  = Vector{hsize_t}(undef, n)
    stride = Vector{hsize_t}(undef, n)
    count  = Vector{hsize_t}(undef, n)
    block  = Vector{hsize_t}(undef, n)
    h5s_get_regular_hyperslab(space_id, start, stride, count, block)
    return start, stride, count, block
end

function h5s_get_simple_extent_dims(space_id)
    n = h5s_get_simple_extent_ndims(space_id)
    dims = Vector{hsize_t}(undef, n)
    maxdims = Vector{hsize_t}(undef, n)
    h5s_get_simple_extent_dims(space_id, dims, maxdims)
    return dims, maxdims
end
function h5s_get_simple_extent_dims(space_id, ::Nothing)
    n = h5s_get_simple_extent_ndims(space_id)
    dims = Vector{hsize_t}(undef, n)
    h5s_get_simple_extent_dims(space_id, dims, C_NULL)
    return dims
end

###
### Datatype Interface
###

function h5t_get_array_dims(type_id)
    nd = h5t_get_array_ndims(type_id)
    dims = Vector{hsize_t}(undef, nd)
    h5t_get_array_dims(type_id, dims)
    return dims
end

function h5t_get_fields(type_id)
    spos = Ref{Csize_t}()
    epos = Ref{Csize_t}()
    esize = Ref{Csize_t}()
    mpos = Ref{Csize_t}()
    msize = Ref{Csize_t}()
    h5t_get_fields(type_id, spos, epos, esize, mpos, msize)
    return (spos[], epos[], esize[], mpos[], msize[])
end

# Note: The following two functions implement direct ccalls because the binding generator
# cannot (yet) do the string wrapping and memory freeing.
"""
    h5t_get_member_name(type_id::hid_t, index::Cuint) -> String

See `libhdf5` documentation for [`H5Oopen`](https://portal.hdfgroup.org/display/HDF5/H5T_GET_MEMBER_NAME).
"""
function h5t_get_member_name(type_id, index)
    lock(liblock)
    pn = try
        ccall((:H5Tget_member_name, libhdf5), Ptr{UInt8}, (hid_t, Cuint), type_id, index)
    finally
        unlock(liblock)
    end
    if pn == C_NULL
        @h5error("Error getting name of compound datatype member #$index")
    end
    s = unsafe_string(pn)
    h5_free_memory(pn)
    return s
end

"""
    h5t_get_tag(type_id::hid_t) -> String

See `libhdf5` documentation for [`H5Oopen`](https://portal.hdfgroup.org/display/HDF5/H5T_GET_TAG).
"""
function h5t_get_tag(type_id)
    lock(liblock)
    pc = try
        ccall((:H5Tget_tag, libhdf5), Ptr{UInt8}, (hid_t,), type_id)
    finally
        unlock(liblock)
    end
    if pc == C_NULL
        @h5error("Error getting opaque tag")
    end
    s = unsafe_string(pc)
    h5_free_memory(pc)
    return s
end

h5t_get_native_type(type_id) = h5t_get_native_type(type_id, H5T_DIR_ASCEND)

###
### Optimized Functions Interface
###

###
### HDF5 Lite Interface
###

function h5lt_dtype_to_text(dtype_id)
    len = Ref{Csize_t}()
    h5lt_dtype_to_text(dtype_id, C_NULL, 0, len)
    buf = StringVector(len[] - 1)
    h5lt_dtype_to_text(dtype_id, buf, 0, len)
    return String(buf)
end

###
### Table Interface
###

function h5tb_get_table_info(loc_id, table_name)
    nfields = Ref{hsize_t}()
    nrecords = Ref{hsize_t}()
    h5tb_get_table_info(loc_id, table_name, nfields, nrecords)
    return nfields[], nrecords[]
end

function h5tb_get_field_info(loc_id, table_name)
    nfields, = h5tb_get_table_info(loc_id, table_name)
    field_sizes = Vector{Csize_t}(undef, nfields)
    field_offsets = Vector{Csize_t}(undef, nfields)
    type_size = Ref{Csize_t}()
    # pass C_NULL to field_names argument since libhdf5 does not provide a way to determine if the
    # allocated buffer is the correct length, which is thus susceptible to a buffer overflow if
    # an incorrect buffer length is passed. Instead, we manually compute the column names using the
    # same calls that h5tb_get_field_info internally uses.
    h5tb_get_field_info(loc_id, table_name, C_NULL, field_sizes, field_offsets, type_size)
    did = h5d_open(loc_id, table_name, H5P_DEFAULT)
    tid = h5d_get_type(did)
    h5d_close(did)
    field_names = [h5t_get_member_name(tid, i - 1) for i in 1:nfields]
    h5t_close(tid)
    return field_names, field_sizes, field_offsets, type_size[]
end

###
### Filter Interface
###

function h5z_get_filter_info(filter)
    ref = Ref{Cuint}()
    h5z_get_filter_info(filter, ref)
    ref[]
end

###
### MPIO
###

# define these stubs, but can't define the methods as the types aren't
# known until MPI.jl is loaded.

"""
    h5p_get_fapl_mpio(fapl_id::hid_t, comm::Ptr{MPI.MPI_Comm}, info::Ptr{MPI.MPI_Info})

See `libhdf5` documentation for [`H5Pget_fapl_mpio`](https://portal.hdfgroup.org/display/HDF5/H5P_GET_FAPL_MPIO32).
"""
function h5p_get_fapl_mpio end

"""
    h5p_set_fapl_mpio(fapl_id::hid_t, comm::MPI.MPI_Comm, info::MPI.MPI_Info)

See `libhdf5` documentation for [`H5Pset_fapl_mpio`](https://portal.hdfgroup.org/display/HDF5/H5P_SET_FAPL_MPIO32).
"""
function h5p_set_fapl_mpio end
