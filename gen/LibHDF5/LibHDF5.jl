module LibHDF5

using HDF5_jll
export HDF5_jll

using CEnum

const __time64_t = Clonglong

const time_t = __time64_t

const off32_t = Clong

const off_t = off32_t

const hid_t = Int64

function H5Acreate2(loc_id, attr_name, type_id, space_id, acpl_id, aapl_id)
    ccall((:H5Acreate2, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t), loc_id, attr_name, type_id, space_id, acpl_id, aapl_id)
end

@cenum H5_index_t::Int32 begin
    H5_INDEX_UNKNOWN = -1
    H5_INDEX_NAME = 0
    H5_INDEX_CRT_ORDER = 1
    H5_INDEX_N = 2
end

@cenum H5_iter_order_t::Int32 begin
    H5_ITER_UNKNOWN = -1
    H5_ITER_INC = 0
    H5_ITER_DEC = 1
    H5_ITER_NATIVE = 2
    H5_ITER_N = 3
end

const hsize_t = Culonglong

# typedef herr_t ( * H5A_operator2_t ) ( hid_t location_id /*in*/ , const char * attr_name /*in*/ , const H5A_info_t * ainfo /*in*/ , void * op_data /*in,out*/ )
const H5A_operator2_t = Ptr{Cvoid}

const herr_t = Cint

function H5Aiterate2(loc_id, idx_type, order, idx, op, op_data)
    ccall((:H5Aiterate2, libhdf5), herr_t, (hid_t, H5_index_t, H5_iter_order_t, Ptr{hsize_t}, H5A_operator2_t, Ptr{Cvoid}), loc_id, idx_type, order, idx, op, op_data)
end

function H5Dcreate2(loc_id, name, type_id, space_id, lcpl_id, dcpl_id, dapl_id)
    ccall((:H5Dcreate2, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t, hid_t), loc_id, name, type_id, space_id, lcpl_id, dcpl_id, dapl_id)
end

function H5Dopen2(loc_id, name, dapl_id)
    ccall((:H5Dopen2, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t), loc_id, name, dapl_id)
end

function H5Eclear2(err_stack)
    ccall((:H5Eclear2, libhdf5), herr_t, (hid_t,), err_stack)
end

# typedef herr_t ( * H5E_auto2_t ) ( hid_t estack , void * client_data )
const H5E_auto2_t = Ptr{Cvoid}

function H5Eget_auto2(estack_id, func, client_data)
    ccall((:H5Eget_auto2, libhdf5), herr_t, (hid_t, Ptr{H5E_auto2_t}, Ptr{Ptr{Cvoid}}), estack_id, func, client_data)
end

function H5Eprint2(err_stack, stream)
    ccall((:H5Eprint2, libhdf5), herr_t, (hid_t, Ptr{Libc.FILE}), err_stack, stream)
end

function H5Eset_auto2(estack_id, func, client_data)
    ccall((:H5Eset_auto2, libhdf5), herr_t, (hid_t, H5E_auto2_t, Ptr{Cvoid}), estack_id, func, client_data)
end

@cenum H5E_direction_t::UInt32 begin
    H5E_WALK_UPWARD = 0
    H5E_WALK_DOWNWARD = 1
end

# typedef herr_t ( * H5E_walk2_t ) ( unsigned n , const H5E_error2_t * err_desc , void * client_data )
const H5E_walk2_t = Ptr{Cvoid}

function H5Ewalk2(err_stack, direction, func, client_data)
    ccall((:H5Ewalk2, libhdf5), herr_t, (hid_t, H5E_direction_t, H5E_walk2_t, Ptr{Cvoid}), err_stack, direction, func, client_data)
end

struct H5E_error2_t
    cls_id::hid_t
    maj_num::hid_t
    min_num::hid_t
    line::Cuint
    func_name::Ptr{Cchar}
    file_name::Ptr{Cchar}
    desc::Ptr{Cchar}
end

struct var"##Ctag#297"
    version::Cuint
    super_size::hsize_t
    super_ext_size::hsize_t
end
function Base.getproperty(x::Ptr{var"##Ctag#297"}, f::Symbol)
    f === :version && return Ptr{Cuint}(x + 0)
    f === :super_size && return Ptr{hsize_t}(x + 8)
    f === :super_ext_size && return Ptr{hsize_t}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#297", f::Symbol)
    r = Ref{var"##Ctag#297"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#297"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#297"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct var"##Ctag#298"
    version::Cuint
    meta_size::hsize_t
    tot_space::hsize_t
end
function Base.getproperty(x::Ptr{var"##Ctag#298"}, f::Symbol)
    f === :version && return Ptr{Cuint}(x + 0)
    f === :meta_size && return Ptr{hsize_t}(x + 8)
    f === :tot_space && return Ptr{hsize_t}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#298", f::Symbol)
    r = Ref{var"##Ctag#298"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#298"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#298"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct H5_ih_info_t
    index_size::hsize_t
    heap_size::hsize_t
end

struct var"##Ctag#299"
    version::Cuint
    hdr_size::hsize_t
    msgs_info::H5_ih_info_t
end
function Base.getproperty(x::Ptr{var"##Ctag#299"}, f::Symbol)
    f === :version && return Ptr{Cuint}(x + 0)
    f === :hdr_size && return Ptr{hsize_t}(x + 8)
    f === :msgs_info && return Ptr{H5_ih_info_t}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#299", f::Symbol)
    r = Ref{var"##Ctag#299"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#299"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#299"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct H5F_info2_t
    data::NTuple{80, UInt8}
end

function Base.getproperty(x::Ptr{H5F_info2_t}, f::Symbol)
    f === :super && return Ptr{var"##Ctag#297"}(x + 0)
    f === :free && return Ptr{var"##Ctag#298"}(x + 24)
    f === :sohm && return Ptr{var"##Ctag#299"}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::H5F_info2_t, f::Symbol)
    r = Ref{H5F_info2_t}(x)
    ptr = Base.unsafe_convert(Ptr{H5F_info2_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{H5F_info2_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function H5Fget_info2(obj_id, file_info)
    ccall((:H5Fget_info2, libhdf5), herr_t, (hid_t, Ptr{H5F_info2_t}), obj_id, file_info)
end

function H5Gcreate2(loc_id, name, lcpl_id, gcpl_id, gapl_id)
    ccall((:H5Gcreate2, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t), loc_id, name, lcpl_id, gcpl_id, gapl_id)
end

function H5Gopen2(loc_id, name, gapl_id)
    ccall((:H5Gopen2, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t), loc_id, name, gapl_id)
end

@cenum H5L_type_t::Int32 begin
    H5L_TYPE_ERROR = -1
    H5L_TYPE_HARD = 0
    H5L_TYPE_SOFT = 1
    H5L_TYPE_EXTERNAL = 64
    H5L_TYPE_MAX = 255
end

const hbool_t = Bool

@cenum H5T_cset_t::Int32 begin
    H5T_CSET_ERROR = -1
    H5T_CSET_ASCII = 0
    H5T_CSET_UTF8 = 1
    H5T_CSET_RESERVED_2 = 2
    H5T_CSET_RESERVED_3 = 3
    H5T_CSET_RESERVED_4 = 4
    H5T_CSET_RESERVED_5 = 5
    H5T_CSET_RESERVED_6 = 6
    H5T_CSET_RESERVED_7 = 7
    H5T_CSET_RESERVED_8 = 8
    H5T_CSET_RESERVED_9 = 9
    H5T_CSET_RESERVED_10 = 10
    H5T_CSET_RESERVED_11 = 11
    H5T_CSET_RESERVED_12 = 12
    H5T_CSET_RESERVED_13 = 13
    H5T_CSET_RESERVED_14 = 14
    H5T_CSET_RESERVED_15 = 15
end

struct var"##Ctag#300"
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#300"}, f::Symbol)
    f === :token && return Ptr{H5O_token_t}(x + 0)
    f === :val_size && return Ptr{Csize_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#300", f::Symbol)
    r = Ref{var"##Ctag#300"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#300"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#300"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct H5L_info2_t
    type::H5L_type_t
    corder_valid::hbool_t
    corder::Int64
    cset::H5T_cset_t
    u::var"##Ctag#300"
end

function H5Lget_info2(loc_id, name, linfo, lapl_id)
    ccall((:H5Lget_info2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{H5L_info2_t}, hid_t), loc_id, name, linfo, lapl_id)
end

function H5Lget_info_by_idx2(loc_id, group_name, idx_type, order, n, linfo, lapl_id)
    ccall((:H5Lget_info_by_idx2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{H5L_info2_t}, hid_t), loc_id, group_name, idx_type, order, n, linfo, lapl_id)
end

# typedef herr_t ( * H5L_iterate2_t ) ( hid_t group , const char * name , const H5L_info2_t * info , void * op_data )
const H5L_iterate2_t = Ptr{Cvoid}

function H5Literate2(grp_id, idx_type, order, idx, op, op_data)
    ccall((:H5Literate2, libhdf5), herr_t, (hid_t, H5_index_t, H5_iter_order_t, Ptr{hsize_t}, H5L_iterate2_t, Ptr{Cvoid}), grp_id, idx_type, order, idx, op, op_data)
end

function H5Literate_by_name2(loc_id, group_name, idx_type, order, idx, op, op_data, lapl_id)
    ccall((:H5Literate_by_name2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, Ptr{hsize_t}, H5L_iterate2_t, Ptr{Cvoid}, hid_t), loc_id, group_name, idx_type, order, idx, op, op_data, lapl_id)
end

function H5Lvisit2(grp_id, idx_type, order, op, op_data)
    ccall((:H5Lvisit2, libhdf5), herr_t, (hid_t, H5_index_t, H5_iter_order_t, H5L_iterate2_t, Ptr{Cvoid}), grp_id, idx_type, order, op, op_data)
end

function H5Lvisit_by_name2(loc_id, group_name, idx_type, order, op, op_data, lapl_id)
    ccall((:H5Lvisit_by_name2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, H5L_iterate2_t, Ptr{Cvoid}, hid_t), loc_id, group_name, idx_type, order, op, op_data, lapl_id)
end

struct H5O_token_t
    __data::NTuple{16, UInt8}
end

@cenum H5O_type_t::Int32 begin
    H5O_TYPE_UNKNOWN = -1
    H5O_TYPE_GROUP = 0
    H5O_TYPE_DATASET = 1
    H5O_TYPE_NAMED_DATATYPE = 2
    H5O_TYPE_MAP = 3
    H5O_TYPE_NTYPES = 4
end

struct H5O_info2_t
    fileno::Culong
    token::H5O_token_t
    type::H5O_type_t
    rc::Cuint
    atime::time_t
    mtime::time_t
    ctime::time_t
    btime::time_t
    num_attrs::hsize_t
end

function H5Oget_info3(loc_id, oinfo, fields)
    ccall((:H5Oget_info3, libhdf5), herr_t, (hid_t, Ptr{H5O_info2_t}, Cuint), loc_id, oinfo, fields)
end

function H5Oget_info_by_idx3(loc_id, group_name, idx_type, order, n, oinfo, fields, lapl_id)
    ccall((:H5Oget_info_by_idx3, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{H5O_info2_t}, Cuint, hid_t), loc_id, group_name, idx_type, order, n, oinfo, fields, lapl_id)
end

function H5Oget_info_by_name3(loc_id, name, oinfo, fields, lapl_id)
    ccall((:H5Oget_info_by_name3, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{H5O_info2_t}, Cuint, hid_t), loc_id, name, oinfo, fields, lapl_id)
end

# typedef herr_t ( * H5O_iterate2_t ) ( hid_t obj , const char * name , const H5O_info2_t * info , void * op_data )
const H5O_iterate2_t = Ptr{Cvoid}

function H5Ovisit3(obj_id, idx_type, order, op, op_data, fields)
    ccall((:H5Ovisit3, libhdf5), herr_t, (hid_t, H5_index_t, H5_iter_order_t, H5O_iterate2_t, Ptr{Cvoid}, Cuint), obj_id, idx_type, order, op, op_data, fields)
end

function H5Ovisit_by_name3(loc_id, obj_name, idx_type, order, op, op_data, fields, lapl_id)
    ccall((:H5Ovisit_by_name3, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, H5O_iterate2_t, Ptr{Cvoid}, Cuint, hid_t), loc_id, obj_name, idx_type, order, op, op_data, fields, lapl_id)
end

function H5Pencode2(plist_id, buf, nalloc, fapl_id)
    ccall((:H5Pencode2, libhdf5), herr_t, (hid_t, Ptr{Cvoid}, Ptr{Csize_t}, hid_t), plist_id, buf, nalloc, fapl_id)
end

const H5Z_filter_t = Cint

function H5Pget_filter2(plist_id, idx, flags, cd_nelmts, cd_values, namelen, name, filter_config)
    ccall((:H5Pget_filter2, libhdf5), H5Z_filter_t, (hid_t, Cuint, Ptr{Cuint}, Ptr{Csize_t}, Ptr{Cuint}, Csize_t, Ptr{Cchar}, Ptr{Cuint}), plist_id, idx, flags, cd_nelmts, cd_values, namelen, name, filter_config)
end

function H5Pget_filter_by_id2(plist_id, filter_id, flags, cd_nelmts, cd_values, namelen, name, filter_config)
    ccall((:H5Pget_filter_by_id2, libhdf5), herr_t, (hid_t, H5Z_filter_t, Ptr{Cuint}, Ptr{Csize_t}, Ptr{Cuint}, Csize_t, Ptr{Cchar}, Ptr{Cuint}), plist_id, filter_id, flags, cd_nelmts, cd_values, namelen, name, filter_config)
end

# typedef herr_t ( * H5P_prp_cb2_t ) ( hid_t prop_id , const char * name , size_t size , void * value )
const H5P_prp_cb2_t = Ptr{Cvoid}

const H5P_prp_set_func_t = H5P_prp_cb2_t

const H5P_prp_get_func_t = H5P_prp_cb2_t

const H5P_prp_delete_func_t = H5P_prp_cb2_t

# typedef herr_t ( * H5P_prp_cb1_t ) ( const char * name , size_t size , void * value )
const H5P_prp_cb1_t = Ptr{Cvoid}

const H5P_prp_copy_func_t = H5P_prp_cb1_t

# typedef int ( * H5P_prp_compare_func_t ) ( const void * value1 , const void * value2 , size_t size )
const H5P_prp_compare_func_t = Ptr{Cvoid}

const H5P_prp_close_func_t = H5P_prp_cb1_t

function H5Pinsert2(plist_id, name, size, value, set, get, prp_del, copy, compare, close)
    ccall((:H5Pinsert2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Csize_t, Ptr{Cvoid}, H5P_prp_set_func_t, H5P_prp_get_func_t, H5P_prp_delete_func_t, H5P_prp_copy_func_t, H5P_prp_compare_func_t, H5P_prp_close_func_t), plist_id, name, size, value, set, get, prp_del, copy, compare, close)
end

const H5P_prp_create_func_t = H5P_prp_cb1_t

function H5Pregister2(cls_id, name, size, def_value, create, set, get, prp_del, copy, compare, close)
    ccall((:H5Pregister2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Csize_t, Ptr{Cvoid}, H5P_prp_create_func_t, H5P_prp_set_func_t, H5P_prp_get_func_t, H5P_prp_delete_func_t, H5P_prp_copy_func_t, H5P_prp_compare_func_t, H5P_prp_close_func_t), cls_id, name, size, def_value, create, set, get, prp_del, copy, compare, close)
end

@cenum H5R_type_t::Int32 begin
    H5R_BADTYPE = -1
    H5R_OBJECT1 = 0
    H5R_DATASET_REGION1 = 1
    H5R_OBJECT2 = 2
    H5R_DATASET_REGION2 = 3
    H5R_ATTR = 4
    H5R_MAXTYPE = 5
end

function H5Rdereference2(obj_id, oapl_id, ref_type, ref)
    ccall((:H5Rdereference2, libhdf5), hid_t, (hid_t, hid_t, H5R_type_t, Ptr{Cvoid}), obj_id, oapl_id, ref_type, ref)
end

function H5Rget_obj_type2(id, ref_type, ref, obj_type)
    ccall((:H5Rget_obj_type2, libhdf5), herr_t, (hid_t, H5R_type_t, Ptr{Cvoid}, Ptr{H5O_type_t}), id, ref_type, ref, obj_type)
end

function H5Sencode2(obj_id, buf, nalloc, fapl)
    ccall((:H5Sencode2, libhdf5), herr_t, (hid_t, Ptr{Cvoid}, Ptr{Csize_t}, hid_t), obj_id, buf, nalloc, fapl)
end

function H5Tarray_create2(base_id, ndims, dim)
    ccall((:H5Tarray_create2, libhdf5), hid_t, (hid_t, Cuint, Ptr{hsize_t}), base_id, ndims, dim)
end

function H5Tcommit2(loc_id, name, type_id, lcpl_id, tcpl_id, tapl_id)
    ccall((:H5Tcommit2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t), loc_id, name, type_id, lcpl_id, tcpl_id, tapl_id)
end

function H5Tget_array_dims2(type_id, dims)
    ccall((:H5Tget_array_dims2, libhdf5), Cint, (hid_t, Ptr{hsize_t}), type_id, dims)
end

function H5Topen2(loc_id, name, tapl_id)
    ccall((:H5Topen2, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t), loc_id, name, tapl_id)
end

# typedef htri_t ( * H5Z_can_apply_func_t ) ( hid_t dcpl_id , hid_t type_id , hid_t space_id )
const H5Z_can_apply_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5Z_set_local_func_t ) ( hid_t dcpl_id , hid_t type_id , hid_t space_id )
const H5Z_set_local_func_t = Ptr{Cvoid}

# typedef size_t ( * H5Z_func_t ) ( unsigned int flags , size_t cd_nelmts , const unsigned int cd_values [ ] , size_t nbytes , size_t * buf_size , void * * buf )
const H5Z_func_t = Ptr{Cvoid}

struct H5Z_class2_t
    version::Cint
    id::H5Z_filter_t
    encoder_present::Cuint
    decoder_present::Cuint
    name::Ptr{Cchar}
    can_apply::H5Z_can_apply_func_t
    set_local::H5Z_set_local_func_t
    filter::H5Z_func_t
end

function H5check_version(majnum, minnum, relnum)
    ccall((:H5check_version, libhdf5), herr_t, (Cuint, Cuint, Cuint), majnum, minnum, relnum)
end

function H5open()
    ccall((:H5open, libhdf5), herr_t, ())
end

# typedef herr_t ( * H5E_auto1_t ) ( void * client_data )
const H5E_auto1_t = Ptr{Cvoid}

function H5Eauto_is_v2(err_stack, is_stack)
    ccall((:H5Eauto_is_v2, libhdf5), herr_t, (hid_t, Ptr{Cuint}), err_stack, is_stack)
end

function H5Eget_auto1(func, client_data)
    ccall((:H5Eget_auto1, libhdf5), herr_t, (Ptr{H5E_auto1_t}, Ptr{Ptr{Cvoid}}), func, client_data)
end

function H5Eset_auto1(func, client_data)
    ccall((:H5Eset_auto1, libhdf5), herr_t, (H5E_auto1_t, Ptr{Cvoid}), func, client_data)
end

const haddr_t = Culonglong

function H5VL_native_register()
    ccall((:H5VL_native_register, libhdf5), hid_t, ())
end

function H5FD_core_init()
    ccall((:H5FD_core_init, libhdf5), hid_t, ())
end

function H5FD_family_init()
    ccall((:H5FD_family_init, libhdf5), hid_t, ())
end

function H5FD_log_init()
    ccall((:H5FD_log_init, libhdf5), hid_t, ())
end

function H5FD_multi_init()
    ccall((:H5FD_multi_init, libhdf5), hid_t, ())
end

function H5FD_sec2_init()
    ccall((:H5FD_sec2_init, libhdf5), hid_t, ())
end

function H5FD_splitter_init()
    ccall((:H5FD_splitter_init, libhdf5), hid_t, ())
end

function H5FD_stdio_init()
    ccall((:H5FD_stdio_init, libhdf5), hid_t, ())
end

function H5VL_pass_through_register()
    ccall((:H5VL_pass_through_register, libhdf5), hid_t, ())
end

const htri_t = Cint

const hssize_t = Clonglong

struct H5_alloc_stats_t
    total_alloc_bytes::Culonglong
    curr_alloc_bytes::Csize_t
    peak_alloc_bytes::Csize_t
    max_block_size::Csize_t
    total_alloc_blocks_count::Csize_t
    curr_alloc_blocks_count::Csize_t
    peak_alloc_blocks_count::Csize_t
end

function H5close()
    ccall((:H5close, libhdf5), herr_t, ())
end

function H5dont_atexit()
    ccall((:H5dont_atexit, libhdf5), herr_t, ())
end

function H5garbage_collect()
    ccall((:H5garbage_collect, libhdf5), herr_t, ())
end

function H5set_free_list_limits(reg_global_lim, reg_list_lim, arr_global_lim, arr_list_lim, blk_global_lim, blk_list_lim)
    ccall((:H5set_free_list_limits, libhdf5), herr_t, (Cint, Cint, Cint, Cint, Cint, Cint), reg_global_lim, reg_list_lim, arr_global_lim, arr_list_lim, blk_global_lim, blk_list_lim)
end

function H5get_free_list_sizes(reg_size, arr_size, blk_size, fac_size)
    ccall((:H5get_free_list_sizes, libhdf5), herr_t, (Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}), reg_size, arr_size, blk_size, fac_size)
end

function H5get_alloc_stats(stats)
    ccall((:H5get_alloc_stats, libhdf5), herr_t, (Ptr{H5_alloc_stats_t},), stats)
end

function H5get_libversion(majnum, minnum, relnum)
    ccall((:H5get_libversion, libhdf5), herr_t, (Ptr{Cuint}, Ptr{Cuint}, Ptr{Cuint}), majnum, minnum, relnum)
end

function H5is_library_threadsafe(is_ts)
    ccall((:H5is_library_threadsafe, libhdf5), herr_t, (Ptr{hbool_t},), is_ts)
end

function H5free_memory(mem)
    ccall((:H5free_memory, libhdf5), herr_t, (Ptr{Cvoid},), mem)
end

function H5allocate_memory(size, clear)
    ccall((:H5allocate_memory, libhdf5), Ptr{Cvoid}, (Csize_t, hbool_t), size, clear)
end

function H5resize_memory(mem, size)
    ccall((:H5resize_memory, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Csize_t), mem, size)
end

@cenum H5I_type_t::Int32 begin
    H5I_UNINIT = -2
    H5I_BADID = -1
    H5I_FILE = 1
    H5I_GROUP = 2
    H5I_DATATYPE = 3
    H5I_DATASPACE = 4
    H5I_DATASET = 5
    H5I_MAP = 6
    H5I_ATTR = 7
    H5I_VFL = 8
    H5I_VOL = 9
    H5I_GENPROP_CLS = 10
    H5I_GENPROP_LST = 11
    H5I_ERROR_CLASS = 12
    H5I_ERROR_MSG = 13
    H5I_ERROR_STACK = 14
    H5I_SPACE_SEL_ITER = 15
    H5I_NTYPES = 16
end

# typedef herr_t ( * H5I_free_t ) ( void * )
const H5I_free_t = Ptr{Cvoid}

# typedef int ( * H5I_search_func_t ) ( void * obj , hid_t id , void * key )
const H5I_search_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5I_iterate_func_t ) ( hid_t id , void * udata )
const H5I_iterate_func_t = Ptr{Cvoid}

function H5Iregister(type, object)
    ccall((:H5Iregister, libhdf5), hid_t, (H5I_type_t, Ptr{Cvoid}), type, object)
end

function H5Iobject_verify(id, type)
    ccall((:H5Iobject_verify, libhdf5), Ptr{Cvoid}, (hid_t, H5I_type_t), id, type)
end

function H5Iremove_verify(id, type)
    ccall((:H5Iremove_verify, libhdf5), Ptr{Cvoid}, (hid_t, H5I_type_t), id, type)
end

function H5Iget_type(id)
    ccall((:H5Iget_type, libhdf5), H5I_type_t, (hid_t,), id)
end

function H5Iget_file_id(id)
    ccall((:H5Iget_file_id, libhdf5), hid_t, (hid_t,), id)
end

function H5Iget_name(id, name, size)
    ccall((:H5Iget_name, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), id, name, size)
end

function H5Iinc_ref(id)
    ccall((:H5Iinc_ref, libhdf5), Cint, (hid_t,), id)
end

function H5Idec_ref(id)
    ccall((:H5Idec_ref, libhdf5), Cint, (hid_t,), id)
end

function H5Iget_ref(id)
    ccall((:H5Iget_ref, libhdf5), Cint, (hid_t,), id)
end

function H5Iregister_type(hash_size, reserved, free_func)
    ccall((:H5Iregister_type, libhdf5), H5I_type_t, (Csize_t, Cuint, H5I_free_t), hash_size, reserved, free_func)
end

function H5Iclear_type(type, force)
    ccall((:H5Iclear_type, libhdf5), herr_t, (H5I_type_t, hbool_t), type, force)
end

function H5Idestroy_type(type)
    ccall((:H5Idestroy_type, libhdf5), herr_t, (H5I_type_t,), type)
end

function H5Iinc_type_ref(type)
    ccall((:H5Iinc_type_ref, libhdf5), Cint, (H5I_type_t,), type)
end

function H5Idec_type_ref(type)
    ccall((:H5Idec_type_ref, libhdf5), Cint, (H5I_type_t,), type)
end

function H5Iget_type_ref(type)
    ccall((:H5Iget_type_ref, libhdf5), Cint, (H5I_type_t,), type)
end

function H5Isearch(type, func, key)
    ccall((:H5Isearch, libhdf5), Ptr{Cvoid}, (H5I_type_t, H5I_search_func_t, Ptr{Cvoid}), type, func, key)
end

function H5Iiterate(type, op, op_data)
    ccall((:H5Iiterate, libhdf5), herr_t, (H5I_type_t, H5I_iterate_func_t, Ptr{Cvoid}), type, op, op_data)
end

function H5Inmembers(type, num_members)
    ccall((:H5Inmembers, libhdf5), herr_t, (H5I_type_t, Ptr{hsize_t}), type, num_members)
end

function H5Itype_exists(type)
    ccall((:H5Itype_exists, libhdf5), htri_t, (H5I_type_t,), type)
end

function H5Iis_valid(id)
    ccall((:H5Iis_valid, libhdf5), htri_t, (hid_t,), id)
end

@cenum H5T_class_t::Int32 begin
    H5T_NO_CLASS = -1
    H5T_INTEGER = 0
    H5T_FLOAT = 1
    H5T_TIME = 2
    H5T_STRING = 3
    H5T_BITFIELD = 4
    H5T_OPAQUE = 5
    H5T_COMPOUND = 6
    H5T_REFERENCE = 7
    H5T_ENUM = 8
    H5T_VLEN = 9
    H5T_ARRAY = 10
    H5T_NCLASSES = 11
end

@cenum H5T_order_t::Int32 begin
    H5T_ORDER_ERROR = -1
    H5T_ORDER_LE = 0
    H5T_ORDER_BE = 1
    H5T_ORDER_VAX = 2
    H5T_ORDER_MIXED = 3
    H5T_ORDER_NONE = 4
end

@cenum H5T_sign_t::Int32 begin
    H5T_SGN_ERROR = -1
    H5T_SGN_NONE = 0
    H5T_SGN_2 = 1
    H5T_NSGN = 2
end

@cenum H5T_norm_t::Int32 begin
    H5T_NORM_ERROR = -1
    H5T_NORM_IMPLIED = 0
    H5T_NORM_MSBSET = 1
    H5T_NORM_NONE = 2
end

@cenum H5T_str_t::Int32 begin
    H5T_STR_ERROR = -1
    H5T_STR_NULLTERM = 0
    H5T_STR_NULLPAD = 1
    H5T_STR_SPACEPAD = 2
    H5T_STR_RESERVED_3 = 3
    H5T_STR_RESERVED_4 = 4
    H5T_STR_RESERVED_5 = 5
    H5T_STR_RESERVED_6 = 6
    H5T_STR_RESERVED_7 = 7
    H5T_STR_RESERVED_8 = 8
    H5T_STR_RESERVED_9 = 9
    H5T_STR_RESERVED_10 = 10
    H5T_STR_RESERVED_11 = 11
    H5T_STR_RESERVED_12 = 12
    H5T_STR_RESERVED_13 = 13
    H5T_STR_RESERVED_14 = 14
    H5T_STR_RESERVED_15 = 15
end

@cenum H5T_pad_t::Int32 begin
    H5T_PAD_ERROR = -1
    H5T_PAD_ZERO = 0
    H5T_PAD_ONE = 1
    H5T_PAD_BACKGROUND = 2
    H5T_NPAD = 3
end

@cenum H5T_cmd_t::UInt32 begin
    H5T_CONV_INIT = 0
    H5T_CONV_CONV = 1
    H5T_CONV_FREE = 2
end

@cenum H5T_bkg_t::UInt32 begin
    H5T_BKG_NO = 0
    H5T_BKG_TEMP = 1
    H5T_BKG_YES = 2
end

struct H5T_cdata_t
    command::H5T_cmd_t
    need_bkg::H5T_bkg_t
    recalc::hbool_t
    priv::Ptr{Cvoid}
end

@cenum H5T_pers_t::Int32 begin
    H5T_PERS_DONTCARE = -1
    H5T_PERS_HARD = 0
    H5T_PERS_SOFT = 1
end

@cenum H5T_direction_t::UInt32 begin
    H5T_DIR_DEFAULT = 0
    H5T_DIR_ASCEND = 1
    H5T_DIR_DESCEND = 2
end

@cenum H5T_conv_except_t::UInt32 begin
    H5T_CONV_EXCEPT_RANGE_HI = 0
    H5T_CONV_EXCEPT_RANGE_LOW = 1
    H5T_CONV_EXCEPT_PRECISION = 2
    H5T_CONV_EXCEPT_TRUNCATE = 3
    H5T_CONV_EXCEPT_PINF = 4
    H5T_CONV_EXCEPT_NINF = 5
    H5T_CONV_EXCEPT_NAN = 6
end

@cenum H5T_conv_ret_t::Int32 begin
    H5T_CONV_ABORT = -1
    H5T_CONV_UNHANDLED = 0
    H5T_CONV_HANDLED = 1
end

struct hvl_t
    len::Csize_t
    p::Ptr{Cvoid}
end

# typedef herr_t ( * H5T_conv_t ) ( hid_t src_id , hid_t dst_id , H5T_cdata_t * cdata , size_t nelmts , size_t buf_stride , size_t bkg_stride , void * buf , void * bkg , hid_t dset_xfer_plist )
const H5T_conv_t = Ptr{Cvoid}

# typedef H5T_conv_ret_t ( * H5T_conv_except_func_t ) ( H5T_conv_except_t except_type , hid_t src_id , hid_t dst_id , void * src_buf , void * dst_buf , void * user_data )
const H5T_conv_except_func_t = Ptr{Cvoid}

function H5Tcreate(type, size)
    ccall((:H5Tcreate, libhdf5), hid_t, (H5T_class_t, Csize_t), type, size)
end

function H5Tcopy(type_id)
    ccall((:H5Tcopy, libhdf5), hid_t, (hid_t,), type_id)
end

function H5Tclose(type_id)
    ccall((:H5Tclose, libhdf5), herr_t, (hid_t,), type_id)
end

function H5Tequal(type1_id, type2_id)
    ccall((:H5Tequal, libhdf5), htri_t, (hid_t, hid_t), type1_id, type2_id)
end

function H5Tlock(type_id)
    ccall((:H5Tlock, libhdf5), herr_t, (hid_t,), type_id)
end

function H5Tcommit_anon(loc_id, type_id, tcpl_id, tapl_id)
    ccall((:H5Tcommit_anon, libhdf5), herr_t, (hid_t, hid_t, hid_t, hid_t), loc_id, type_id, tcpl_id, tapl_id)
end

function H5Tget_create_plist(type_id)
    ccall((:H5Tget_create_plist, libhdf5), hid_t, (hid_t,), type_id)
end

function H5Tcommitted(type_id)
    ccall((:H5Tcommitted, libhdf5), htri_t, (hid_t,), type_id)
end

function H5Tencode(obj_id, buf, nalloc)
    ccall((:H5Tencode, libhdf5), herr_t, (hid_t, Ptr{Cvoid}, Ptr{Csize_t}), obj_id, buf, nalloc)
end

function H5Tdecode(buf)
    ccall((:H5Tdecode, libhdf5), hid_t, (Ptr{Cvoid},), buf)
end

function H5Tflush(type_id)
    ccall((:H5Tflush, libhdf5), herr_t, (hid_t,), type_id)
end

function H5Trefresh(type_id)
    ccall((:H5Trefresh, libhdf5), herr_t, (hid_t,), type_id)
end

function H5Tinsert(parent_id, name, offset, member_id)
    ccall((:H5Tinsert, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Csize_t, hid_t), parent_id, name, offset, member_id)
end

function H5Tpack(type_id)
    ccall((:H5Tpack, libhdf5), herr_t, (hid_t,), type_id)
end

function H5Tenum_create(base_id)
    ccall((:H5Tenum_create, libhdf5), hid_t, (hid_t,), base_id)
end

function H5Tenum_insert(type, name, value)
    ccall((:H5Tenum_insert, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cvoid}), type, name, value)
end

function H5Tenum_nameof(type, value, name, size)
    ccall((:H5Tenum_nameof, libhdf5), herr_t, (hid_t, Ptr{Cvoid}, Ptr{Cchar}, Csize_t), type, value, name, size)
end

function H5Tenum_valueof(type, name, value)
    ccall((:H5Tenum_valueof, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cvoid}), type, name, value)
end

function H5Tvlen_create(base_id)
    ccall((:H5Tvlen_create, libhdf5), hid_t, (hid_t,), base_id)
end

function H5Tget_array_ndims(type_id)
    ccall((:H5Tget_array_ndims, libhdf5), Cint, (hid_t,), type_id)
end

function H5Tset_tag(type, tag)
    ccall((:H5Tset_tag, libhdf5), herr_t, (hid_t, Ptr{Cchar}), type, tag)
end

function H5Tget_tag(type)
    ccall((:H5Tget_tag, libhdf5), Ptr{Cchar}, (hid_t,), type)
end

function H5Tget_super(type)
    ccall((:H5Tget_super, libhdf5), hid_t, (hid_t,), type)
end

function H5Tget_class(type_id)
    ccall((:H5Tget_class, libhdf5), H5T_class_t, (hid_t,), type_id)
end

function H5Tdetect_class(type_id, cls)
    ccall((:H5Tdetect_class, libhdf5), htri_t, (hid_t, H5T_class_t), type_id, cls)
end

function H5Tget_size(type_id)
    ccall((:H5Tget_size, libhdf5), Csize_t, (hid_t,), type_id)
end

function H5Tget_order(type_id)
    ccall((:H5Tget_order, libhdf5), H5T_order_t, (hid_t,), type_id)
end

function H5Tget_precision(type_id)
    ccall((:H5Tget_precision, libhdf5), Csize_t, (hid_t,), type_id)
end

function H5Tget_offset(type_id)
    ccall((:H5Tget_offset, libhdf5), Cint, (hid_t,), type_id)
end

function H5Tget_pad(type_id, lsb, msb)
    ccall((:H5Tget_pad, libhdf5), herr_t, (hid_t, Ptr{H5T_pad_t}, Ptr{H5T_pad_t}), type_id, lsb, msb)
end

function H5Tget_sign(type_id)
    ccall((:H5Tget_sign, libhdf5), H5T_sign_t, (hid_t,), type_id)
end

function H5Tget_fields(type_id, spos, epos, esize, mpos, msize)
    ccall((:H5Tget_fields, libhdf5), herr_t, (hid_t, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}), type_id, spos, epos, esize, mpos, msize)
end

function H5Tget_ebias(type_id)
    ccall((:H5Tget_ebias, libhdf5), Csize_t, (hid_t,), type_id)
end

function H5Tget_norm(type_id)
    ccall((:H5Tget_norm, libhdf5), H5T_norm_t, (hid_t,), type_id)
end

function H5Tget_inpad(type_id)
    ccall((:H5Tget_inpad, libhdf5), H5T_pad_t, (hid_t,), type_id)
end

function H5Tget_strpad(type_id)
    ccall((:H5Tget_strpad, libhdf5), H5T_str_t, (hid_t,), type_id)
end

function H5Tget_nmembers(type_id)
    ccall((:H5Tget_nmembers, libhdf5), Cint, (hid_t,), type_id)
end

function H5Tget_member_name(type_id, membno)
    ccall((:H5Tget_member_name, libhdf5), Ptr{Cchar}, (hid_t, Cuint), type_id, membno)
end

function H5Tget_member_index(type_id, name)
    ccall((:H5Tget_member_index, libhdf5), Cint, (hid_t, Ptr{Cchar}), type_id, name)
end

function H5Tget_member_offset(type_id, membno)
    ccall((:H5Tget_member_offset, libhdf5), Csize_t, (hid_t, Cuint), type_id, membno)
end

function H5Tget_member_class(type_id, membno)
    ccall((:H5Tget_member_class, libhdf5), H5T_class_t, (hid_t, Cuint), type_id, membno)
end

function H5Tget_member_type(type_id, membno)
    ccall((:H5Tget_member_type, libhdf5), hid_t, (hid_t, Cuint), type_id, membno)
end

function H5Tget_member_value(type_id, membno, value)
    ccall((:H5Tget_member_value, libhdf5), herr_t, (hid_t, Cuint, Ptr{Cvoid}), type_id, membno, value)
end

function H5Tget_cset(type_id)
    ccall((:H5Tget_cset, libhdf5), H5T_cset_t, (hid_t,), type_id)
end

function H5Tis_variable_str(type_id)
    ccall((:H5Tis_variable_str, libhdf5), htri_t, (hid_t,), type_id)
end

function H5Tget_native_type(type_id, direction)
    ccall((:H5Tget_native_type, libhdf5), hid_t, (hid_t, H5T_direction_t), type_id, direction)
end

function H5Tset_size(type_id, size)
    ccall((:H5Tset_size, libhdf5), herr_t, (hid_t, Csize_t), type_id, size)
end

function H5Tset_order(type_id, order)
    ccall((:H5Tset_order, libhdf5), herr_t, (hid_t, H5T_order_t), type_id, order)
end

function H5Tset_precision(type_id, prec)
    ccall((:H5Tset_precision, libhdf5), herr_t, (hid_t, Csize_t), type_id, prec)
end

function H5Tset_offset(type_id, offset)
    ccall((:H5Tset_offset, libhdf5), herr_t, (hid_t, Csize_t), type_id, offset)
end

function H5Tset_pad(type_id, lsb, msb)
    ccall((:H5Tset_pad, libhdf5), herr_t, (hid_t, H5T_pad_t, H5T_pad_t), type_id, lsb, msb)
end

function H5Tset_sign(type_id, sign)
    ccall((:H5Tset_sign, libhdf5), herr_t, (hid_t, H5T_sign_t), type_id, sign)
end

function H5Tset_fields(type_id, spos, epos, esize, mpos, msize)
    ccall((:H5Tset_fields, libhdf5), herr_t, (hid_t, Csize_t, Csize_t, Csize_t, Csize_t, Csize_t), type_id, spos, epos, esize, mpos, msize)
end

function H5Tset_ebias(type_id, ebias)
    ccall((:H5Tset_ebias, libhdf5), herr_t, (hid_t, Csize_t), type_id, ebias)
end

function H5Tset_norm(type_id, norm)
    ccall((:H5Tset_norm, libhdf5), herr_t, (hid_t, H5T_norm_t), type_id, norm)
end

function H5Tset_inpad(type_id, pad)
    ccall((:H5Tset_inpad, libhdf5), herr_t, (hid_t, H5T_pad_t), type_id, pad)
end

function H5Tset_cset(type_id, cset)
    ccall((:H5Tset_cset, libhdf5), herr_t, (hid_t, H5T_cset_t), type_id, cset)
end

function H5Tset_strpad(type_id, strpad)
    ccall((:H5Tset_strpad, libhdf5), herr_t, (hid_t, H5T_str_t), type_id, strpad)
end

function H5Tregister(pers, name, src_id, dst_id, func)
    ccall((:H5Tregister, libhdf5), herr_t, (H5T_pers_t, Ptr{Cchar}, hid_t, hid_t, H5T_conv_t), pers, name, src_id, dst_id, func)
end

function H5Tunregister(pers, name, src_id, dst_id, func)
    ccall((:H5Tunregister, libhdf5), herr_t, (H5T_pers_t, Ptr{Cchar}, hid_t, hid_t, H5T_conv_t), pers, name, src_id, dst_id, func)
end

function H5Tfind(src_id, dst_id, pcdata)
    ccall((:H5Tfind, libhdf5), H5T_conv_t, (hid_t, hid_t, Ptr{Ptr{H5T_cdata_t}}), src_id, dst_id, pcdata)
end

function H5Tcompiler_conv(src_id, dst_id)
    ccall((:H5Tcompiler_conv, libhdf5), htri_t, (hid_t, hid_t), src_id, dst_id)
end

function H5Tconvert(src_id, dst_id, nelmts, buf, background, plist_id)
    ccall((:H5Tconvert, libhdf5), herr_t, (hid_t, hid_t, Csize_t, Ptr{Cvoid}, Ptr{Cvoid}, hid_t), src_id, dst_id, nelmts, buf, background, plist_id)
end

function H5Treclaim(type_id, space_id, plist_id, buf)
    ccall((:H5Treclaim, libhdf5), herr_t, (hid_t, hid_t, hid_t, Ptr{Cvoid}), type_id, space_id, plist_id, buf)
end

function H5Tcommit1(loc_id, name, type_id)
    ccall((:H5Tcommit1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t), loc_id, name, type_id)
end

function H5Topen1(loc_id, name)
    ccall((:H5Topen1, libhdf5), hid_t, (hid_t, Ptr{Cchar}), loc_id, name)
end

function H5Tarray_create1(base_id, ndims, dim, perm)
    ccall((:H5Tarray_create1, libhdf5), hid_t, (hid_t, Cint, Ptr{hsize_t}, Ptr{Cint}), base_id, ndims, dim, perm)
end

function H5Tget_array_dims1(type_id, dims, perm)
    ccall((:H5Tget_array_dims1, libhdf5), Cint, (hid_t, Ptr{hsize_t}, Ptr{Cint}), type_id, dims, perm)
end

# typedef herr_t ( * H5L_create_func_t ) ( const char * link_name , hid_t loc_group , const void * lnkdata , size_t lnkdata_size , hid_t lcpl_id )
const H5L_create_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5L_move_func_t ) ( const char * new_name , hid_t new_loc , const void * lnkdata , size_t lnkdata_size )
const H5L_move_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5L_copy_func_t ) ( const char * new_name , hid_t new_loc , const void * lnkdata , size_t lnkdata_size )
const H5L_copy_func_t = Ptr{Cvoid}

# typedef hid_t ( * H5L_traverse_func_t ) ( const char * link_name , hid_t cur_group , const void * lnkdata , size_t lnkdata_size , hid_t lapl_id , hid_t dxpl_id )
const H5L_traverse_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5L_delete_func_t ) ( const char * link_name , hid_t file , const void * lnkdata , size_t lnkdata_size )
const H5L_delete_func_t = Ptr{Cvoid}

# typedef ssize_t ( * H5L_query_func_t ) ( const char * link_name , const void * lnkdata , size_t lnkdata_size , void * buf /*out*/ , size_t buf_size )
const H5L_query_func_t = Ptr{Cvoid}

struct H5L_class_t
    version::Cint
    id::H5L_type_t
    comment::Ptr{Cchar}
    create_func::H5L_create_func_t
    move_func::H5L_move_func_t
    copy_func::H5L_copy_func_t
    trav_func::H5L_traverse_func_t
    del_func::H5L_delete_func_t
    query_func::H5L_query_func_t
end

# typedef herr_t ( * H5L_elink_traverse_t ) ( const char * parent_file_name , const char * parent_group_name , const char * child_file_name , const char * child_object_name , unsigned * acc_flags , hid_t fapl_id , void * op_data )
const H5L_elink_traverse_t = Ptr{Cvoid}

function H5Lmove(src_loc, src_name, dst_loc, dst_name, lcpl_id, lapl_id)
    ccall((:H5Lmove, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, Ptr{Cchar}, hid_t, hid_t), src_loc, src_name, dst_loc, dst_name, lcpl_id, lapl_id)
end

function H5Lcopy(src_loc, src_name, dst_loc, dst_name, lcpl_id, lapl_id)
    ccall((:H5Lcopy, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, Ptr{Cchar}, hid_t, hid_t), src_loc, src_name, dst_loc, dst_name, lcpl_id, lapl_id)
end

function H5Lcreate_hard(cur_loc, cur_name, dst_loc, dst_name, lcpl_id, lapl_id)
    ccall((:H5Lcreate_hard, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, Ptr{Cchar}, hid_t, hid_t), cur_loc, cur_name, dst_loc, dst_name, lcpl_id, lapl_id)
end

function H5Lcreate_soft(link_target, link_loc_id, link_name, lcpl_id, lapl_id)
    ccall((:H5Lcreate_soft, libhdf5), herr_t, (Ptr{Cchar}, hid_t, Ptr{Cchar}, hid_t, hid_t), link_target, link_loc_id, link_name, lcpl_id, lapl_id)
end

function H5Ldelete(loc_id, name, lapl_id)
    ccall((:H5Ldelete, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t), loc_id, name, lapl_id)
end

function H5Ldelete_by_idx(loc_id, group_name, idx_type, order, n, lapl_id)
    ccall((:H5Ldelete_by_idx, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, hid_t), loc_id, group_name, idx_type, order, n, lapl_id)
end

function H5Lget_val(loc_id, name, buf, size, lapl_id)
    ccall((:H5Lget_val, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cvoid}, Csize_t, hid_t), loc_id, name, buf, size, lapl_id)
end

function H5Lget_val_by_idx(loc_id, group_name, idx_type, order, n, buf, size, lapl_id)
    ccall((:H5Lget_val_by_idx, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{Cvoid}, Csize_t, hid_t), loc_id, group_name, idx_type, order, n, buf, size, lapl_id)
end

function H5Lexists(loc_id, name, lapl_id)
    ccall((:H5Lexists, libhdf5), htri_t, (hid_t, Ptr{Cchar}, hid_t), loc_id, name, lapl_id)
end

function H5Lget_name_by_idx(loc_id, group_name, idx_type, order, n, name, size, lapl_id)
    ccall((:H5Lget_name_by_idx, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{Cchar}, Csize_t, hid_t), loc_id, group_name, idx_type, order, n, name, size, lapl_id)
end

function H5Lcreate_ud(link_loc_id, link_name, link_type, udata, udata_size, lcpl_id, lapl_id)
    ccall((:H5Lcreate_ud, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5L_type_t, Ptr{Cvoid}, Csize_t, hid_t, hid_t), link_loc_id, link_name, link_type, udata, udata_size, lcpl_id, lapl_id)
end

function H5Lregister(cls)
    ccall((:H5Lregister, libhdf5), herr_t, (Ptr{H5L_class_t},), cls)
end

function H5Lunregister(id)
    ccall((:H5Lunregister, libhdf5), herr_t, (H5L_type_t,), id)
end

function H5Lis_registered(id)
    ccall((:H5Lis_registered, libhdf5), htri_t, (H5L_type_t,), id)
end

function H5Lunpack_elink_val(ext_linkval, link_size, flags, filename, obj_path)
    ccall((:H5Lunpack_elink_val, libhdf5), herr_t, (Ptr{Cvoid}, Csize_t, Ptr{Cuint}, Ptr{Ptr{Cchar}}, Ptr{Ptr{Cchar}}), ext_linkval, link_size, flags, filename, obj_path)
end

function H5Lcreate_external(file_name, obj_name, link_loc_id, link_name, lcpl_id, lapl_id)
    ccall((:H5Lcreate_external, libhdf5), herr_t, (Ptr{Cchar}, Ptr{Cchar}, hid_t, Ptr{Cchar}, hid_t, hid_t), file_name, obj_name, link_loc_id, link_name, lcpl_id, lapl_id)
end

struct var"##Ctag#296"
    data::NTuple{8, UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#296"}, f::Symbol)
    f === :address && return Ptr{haddr_t}(x + 0)
    f === :val_size && return Ptr{Csize_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#296", f::Symbol)
    r = Ref{var"##Ctag#296"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#296"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#296"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct H5L_info1_t
    type::H5L_type_t
    corder_valid::hbool_t
    corder::Int64
    cset::H5T_cset_t
    u::var"##Ctag#296"
end

# typedef hid_t ( * H5L_traverse_0_func_t ) ( const char * link_name , hid_t cur_group , const void * lnkdata , size_t lnkdata_size , hid_t lapl_id )
const H5L_traverse_0_func_t = Ptr{Cvoid}

struct H5L_class_0_t
    version::Cint
    id::H5L_type_t
    comment::Ptr{Cchar}
    create_func::H5L_create_func_t
    move_func::H5L_move_func_t
    copy_func::H5L_copy_func_t
    trav_func::H5L_traverse_0_func_t
    del_func::H5L_delete_func_t
    query_func::H5L_query_func_t
end

# typedef herr_t ( * H5L_iterate1_t ) ( hid_t group , const char * name , const H5L_info1_t * info , void * op_data )
const H5L_iterate1_t = Ptr{Cvoid}

function H5Lget_info1(loc_id, name, linfo, lapl_id)
    ccall((:H5Lget_info1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{H5L_info1_t}, hid_t), loc_id, name, linfo, lapl_id)
end

function H5Lget_info_by_idx1(loc_id, group_name, idx_type, order, n, linfo, lapl_id)
    ccall((:H5Lget_info_by_idx1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{H5L_info1_t}, hid_t), loc_id, group_name, idx_type, order, n, linfo, lapl_id)
end

function H5Literate1(grp_id, idx_type, order, idx, op, op_data)
    ccall((:H5Literate1, libhdf5), herr_t, (hid_t, H5_index_t, H5_iter_order_t, Ptr{hsize_t}, H5L_iterate1_t, Ptr{Cvoid}), grp_id, idx_type, order, idx, op, op_data)
end

function H5Literate_by_name1(loc_id, group_name, idx_type, order, idx, op, op_data, lapl_id)
    ccall((:H5Literate_by_name1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, Ptr{hsize_t}, H5L_iterate1_t, Ptr{Cvoid}, hid_t), loc_id, group_name, idx_type, order, idx, op, op_data, lapl_id)
end

function H5Lvisit1(grp_id, idx_type, order, op, op_data)
    ccall((:H5Lvisit1, libhdf5), herr_t, (hid_t, H5_index_t, H5_iter_order_t, H5L_iterate1_t, Ptr{Cvoid}), grp_id, idx_type, order, op, op_data)
end

function H5Lvisit_by_name1(loc_id, group_name, idx_type, order, op, op_data, lapl_id)
    ccall((:H5Lvisit_by_name1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, H5L_iterate1_t, Ptr{Cvoid}, hid_t), loc_id, group_name, idx_type, order, op, op_data, lapl_id)
end

struct var"##Ctag#291"
    total::hsize_t
    meta::hsize_t
    mesg::hsize_t
    free::hsize_t
end
function Base.getproperty(x::Ptr{var"##Ctag#291"}, f::Symbol)
    f === :total && return Ptr{hsize_t}(x + 0)
    f === :meta && return Ptr{hsize_t}(x + 8)
    f === :mesg && return Ptr{hsize_t}(x + 16)
    f === :free && return Ptr{hsize_t}(x + 24)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#291", f::Symbol)
    r = Ref{var"##Ctag#291"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#291"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#291"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct var"##Ctag#292"
    present::UInt64
    shared::UInt64
end
function Base.getproperty(x::Ptr{var"##Ctag#292"}, f::Symbol)
    f === :present && return Ptr{UInt64}(x + 0)
    f === :shared && return Ptr{UInt64}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#292", f::Symbol)
    r = Ref{var"##Ctag#292"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#292"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#292"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct H5O_hdr_info_t
    data::NTuple{64, UInt8}
end

function Base.getproperty(x::Ptr{H5O_hdr_info_t}, f::Symbol)
    f === :version && return Ptr{Cuint}(x + 0)
    f === :nmesgs && return Ptr{Cuint}(x + 4)
    f === :nchunks && return Ptr{Cuint}(x + 8)
    f === :flags && return Ptr{Cuint}(x + 12)
    f === :space && return Ptr{var"##Ctag#291"}(x + 16)
    f === :mesg && return Ptr{var"##Ctag#292"}(x + 48)
    return getfield(x, f)
end

function Base.getproperty(x::H5O_hdr_info_t, f::Symbol)
    r = Ref{H5O_hdr_info_t}(x)
    ptr = Base.unsafe_convert(Ptr{H5O_hdr_info_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{H5O_hdr_info_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct var"##Ctag#290"
    obj::H5_ih_info_t
    attr::H5_ih_info_t
end
function Base.getproperty(x::Ptr{var"##Ctag#290"}, f::Symbol)
    f === :obj && return Ptr{H5_ih_info_t}(x + 0)
    f === :attr && return Ptr{H5_ih_info_t}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#290", f::Symbol)
    r = Ref{var"##Ctag#290"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#290"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#290"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct H5O_native_info_t
    data::NTuple{96, UInt8}
end

function Base.getproperty(x::Ptr{H5O_native_info_t}, f::Symbol)
    f === :hdr && return Ptr{H5O_hdr_info_t}(x + 0)
    f === :meta_size && return Ptr{var"##Ctag#290"}(x + 64)
    return getfield(x, f)
end

function Base.getproperty(x::H5O_native_info_t, f::Symbol)
    r = Ref{H5O_native_info_t}(x)
    ptr = Base.unsafe_convert(Ptr{H5O_native_info_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{H5O_native_info_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const H5O_msg_crt_idx_t = UInt32

@cenum H5O_mcdt_search_ret_t::Int32 begin
    H5O_MCDT_SEARCH_ERROR = -1
    H5O_MCDT_SEARCH_CONT = 0
    H5O_MCDT_SEARCH_STOP = 1
end

# typedef H5O_mcdt_search_ret_t ( * H5O_mcdt_search_cb_t ) ( void * op_data )
const H5O_mcdt_search_cb_t = Ptr{Cvoid}

function H5Oopen(loc_id, name, lapl_id)
    ccall((:H5Oopen, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t), loc_id, name, lapl_id)
end

function H5Oopen_by_token(loc_id, token)
    ccall((:H5Oopen_by_token, libhdf5), hid_t, (hid_t, H5O_token_t), loc_id, token)
end

function H5Oopen_by_idx(loc_id, group_name, idx_type, order, n, lapl_id)
    ccall((:H5Oopen_by_idx, libhdf5), hid_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, hid_t), loc_id, group_name, idx_type, order, n, lapl_id)
end

function H5Oexists_by_name(loc_id, name, lapl_id)
    ccall((:H5Oexists_by_name, libhdf5), htri_t, (hid_t, Ptr{Cchar}, hid_t), loc_id, name, lapl_id)
end

function H5Oget_native_info(loc_id, oinfo, fields)
    ccall((:H5Oget_native_info, libhdf5), herr_t, (hid_t, Ptr{H5O_native_info_t}, Cuint), loc_id, oinfo, fields)
end

function H5Oget_native_info_by_name(loc_id, name, oinfo, fields, lapl_id)
    ccall((:H5Oget_native_info_by_name, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{H5O_native_info_t}, Cuint, hid_t), loc_id, name, oinfo, fields, lapl_id)
end

function H5Oget_native_info_by_idx(loc_id, group_name, idx_type, order, n, oinfo, fields, lapl_id)
    ccall((:H5Oget_native_info_by_idx, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{H5O_native_info_t}, Cuint, hid_t), loc_id, group_name, idx_type, order, n, oinfo, fields, lapl_id)
end

function H5Olink(obj_id, new_loc_id, new_name, lcpl_id, lapl_id)
    ccall((:H5Olink, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cchar}, hid_t, hid_t), obj_id, new_loc_id, new_name, lcpl_id, lapl_id)
end

function H5Oincr_refcount(object_id)
    ccall((:H5Oincr_refcount, libhdf5), herr_t, (hid_t,), object_id)
end

function H5Odecr_refcount(object_id)
    ccall((:H5Odecr_refcount, libhdf5), herr_t, (hid_t,), object_id)
end

function H5Ocopy(src_loc_id, src_name, dst_loc_id, dst_name, ocpypl_id, lcpl_id)
    ccall((:H5Ocopy, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, Ptr{Cchar}, hid_t, hid_t), src_loc_id, src_name, dst_loc_id, dst_name, ocpypl_id, lcpl_id)
end

function H5Oset_comment(obj_id, comment)
    ccall((:H5Oset_comment, libhdf5), herr_t, (hid_t, Ptr{Cchar}), obj_id, comment)
end

function H5Oset_comment_by_name(loc_id, name, comment, lapl_id)
    ccall((:H5Oset_comment_by_name, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, hid_t), loc_id, name, comment, lapl_id)
end

function H5Oget_comment(obj_id, comment, bufsize)
    ccall((:H5Oget_comment, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), obj_id, comment, bufsize)
end

function H5Oget_comment_by_name(loc_id, name, comment, bufsize, lapl_id)
    ccall((:H5Oget_comment_by_name, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, Csize_t, hid_t), loc_id, name, comment, bufsize, lapl_id)
end

function H5Oclose(object_id)
    ccall((:H5Oclose, libhdf5), herr_t, (hid_t,), object_id)
end

function H5Oflush(obj_id)
    ccall((:H5Oflush, libhdf5), herr_t, (hid_t,), obj_id)
end

function H5Orefresh(oid)
    ccall((:H5Orefresh, libhdf5), herr_t, (hid_t,), oid)
end

function H5Odisable_mdc_flushes(object_id)
    ccall((:H5Odisable_mdc_flushes, libhdf5), herr_t, (hid_t,), object_id)
end

function H5Oenable_mdc_flushes(object_id)
    ccall((:H5Oenable_mdc_flushes, libhdf5), herr_t, (hid_t,), object_id)
end

function H5Oare_mdc_flushes_disabled(object_id, are_disabled)
    ccall((:H5Oare_mdc_flushes_disabled, libhdf5), herr_t, (hid_t, Ptr{hbool_t}), object_id, are_disabled)
end

function H5Otoken_cmp(loc_id, token1, token2, cmp_value)
    ccall((:H5Otoken_cmp, libhdf5), herr_t, (hid_t, Ptr{H5O_token_t}, Ptr{H5O_token_t}, Ptr{Cint}), loc_id, token1, token2, cmp_value)
end

function H5Otoken_to_str(loc_id, token, token_str)
    ccall((:H5Otoken_to_str, libhdf5), herr_t, (hid_t, Ptr{H5O_token_t}, Ptr{Ptr{Cchar}}), loc_id, token, token_str)
end

function H5Otoken_from_str(loc_id, token_str, token)
    ccall((:H5Otoken_from_str, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{H5O_token_t}), loc_id, token_str, token)
end

struct H5O_stat_t
    size::hsize_t
    free::hsize_t
    nmesgs::Cuint
    nchunks::Cuint
end

struct var"##Ctag#294"
    obj::H5_ih_info_t
    attr::H5_ih_info_t
end
function Base.getproperty(x::Ptr{var"##Ctag#294"}, f::Symbol)
    f === :obj && return Ptr{H5_ih_info_t}(x + 0)
    f === :attr && return Ptr{H5_ih_info_t}(x + 16)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#294", f::Symbol)
    r = Ref{var"##Ctag#294"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#294"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#294"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct H5O_info1_t
    data::NTuple{160, UInt8}
end

function Base.getproperty(x::Ptr{H5O_info1_t}, f::Symbol)
    f === :fileno && return Ptr{Culong}(x + 0)
    f === :addr && return Ptr{haddr_t}(x + 8)
    f === :type && return Ptr{H5O_type_t}(x + 16)
    f === :rc && return Ptr{Cuint}(x + 20)
    f === :atime && return Ptr{time_t}(x + 24)
    f === :mtime && return Ptr{time_t}(x + 32)
    f === :ctime && return Ptr{time_t}(x + 40)
    f === :btime && return Ptr{time_t}(x + 48)
    f === :num_attrs && return Ptr{hsize_t}(x + 56)
    f === :hdr && return Ptr{H5O_hdr_info_t}(x + 64)
    f === :meta_size && return Ptr{var"##Ctag#294"}(x + 128)
    return getfield(x, f)
end

function Base.getproperty(x::H5O_info1_t, f::Symbol)
    r = Ref{H5O_info1_t}(x)
    ptr = Base.unsafe_convert(Ptr{H5O_info1_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{H5O_info1_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

# typedef herr_t ( * H5O_iterate1_t ) ( hid_t obj , const char * name , const H5O_info1_t * info , void * op_data )
const H5O_iterate1_t = Ptr{Cvoid}

function H5Oopen_by_addr(loc_id, addr)
    ccall((:H5Oopen_by_addr, libhdf5), hid_t, (hid_t, haddr_t), loc_id, addr)
end

function H5Oget_info1(loc_id, oinfo)
    ccall((:H5Oget_info1, libhdf5), herr_t, (hid_t, Ptr{H5O_info1_t}), loc_id, oinfo)
end

function H5Oget_info_by_name1(loc_id, name, oinfo, lapl_id)
    ccall((:H5Oget_info_by_name1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{H5O_info1_t}, hid_t), loc_id, name, oinfo, lapl_id)
end

function H5Oget_info_by_idx1(loc_id, group_name, idx_type, order, n, oinfo, lapl_id)
    ccall((:H5Oget_info_by_idx1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{H5O_info1_t}, hid_t), loc_id, group_name, idx_type, order, n, oinfo, lapl_id)
end

function H5Oget_info2(loc_id, oinfo, fields)
    ccall((:H5Oget_info2, libhdf5), herr_t, (hid_t, Ptr{H5O_info1_t}, Cuint), loc_id, oinfo, fields)
end

function H5Oget_info_by_name2(loc_id, name, oinfo, fields, lapl_id)
    ccall((:H5Oget_info_by_name2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{H5O_info1_t}, Cuint, hid_t), loc_id, name, oinfo, fields, lapl_id)
end

function H5Oget_info_by_idx2(loc_id, group_name, idx_type, order, n, oinfo, fields, lapl_id)
    ccall((:H5Oget_info_by_idx2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{H5O_info1_t}, Cuint, hid_t), loc_id, group_name, idx_type, order, n, oinfo, fields, lapl_id)
end

function H5Ovisit1(obj_id, idx_type, order, op, op_data)
    ccall((:H5Ovisit1, libhdf5), herr_t, (hid_t, H5_index_t, H5_iter_order_t, H5O_iterate1_t, Ptr{Cvoid}), obj_id, idx_type, order, op, op_data)
end

function H5Ovisit_by_name1(loc_id, obj_name, idx_type, order, op, op_data, lapl_id)
    ccall((:H5Ovisit_by_name1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, H5O_iterate1_t, Ptr{Cvoid}, hid_t), loc_id, obj_name, idx_type, order, op, op_data, lapl_id)
end

function H5Ovisit2(obj_id, idx_type, order, op, op_data, fields)
    ccall((:H5Ovisit2, libhdf5), herr_t, (hid_t, H5_index_t, H5_iter_order_t, H5O_iterate1_t, Ptr{Cvoid}, Cuint), obj_id, idx_type, order, op, op_data, fields)
end

function H5Ovisit_by_name2(loc_id, obj_name, idx_type, order, op, op_data, fields, lapl_id)
    ccall((:H5Ovisit_by_name2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, H5O_iterate1_t, Ptr{Cvoid}, Cuint, hid_t), loc_id, obj_name, idx_type, order, op, op_data, fields, lapl_id)
end

struct H5A_info_t
    corder_valid::hbool_t
    corder::H5O_msg_crt_idx_t
    cset::H5T_cset_t
    data_size::hsize_t
end

function H5Aclose(attr_id)
    ccall((:H5Aclose, libhdf5), herr_t, (hid_t,), attr_id)
end

function H5Acreate_by_name(loc_id, obj_name, attr_name, type_id, space_id, acpl_id, aapl_id, lapl_id)
    ccall((:H5Acreate_by_name, libhdf5), hid_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t, hid_t), loc_id, obj_name, attr_name, type_id, space_id, acpl_id, aapl_id, lapl_id)
end

function H5Adelete(loc_id, attr_name)
    ccall((:H5Adelete, libhdf5), herr_t, (hid_t, Ptr{Cchar}), loc_id, attr_name)
end

function H5Adelete_by_idx(loc_id, obj_name, idx_type, order, n, lapl_id)
    ccall((:H5Adelete_by_idx, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, hid_t), loc_id, obj_name, idx_type, order, n, lapl_id)
end

function H5Adelete_by_name(loc_id, obj_name, attr_name, lapl_id)
    ccall((:H5Adelete_by_name, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, hid_t), loc_id, obj_name, attr_name, lapl_id)
end

function H5Aexists(obj_id, attr_name)
    ccall((:H5Aexists, libhdf5), htri_t, (hid_t, Ptr{Cchar}), obj_id, attr_name)
end

function H5Aexists_by_name(obj_id, obj_name, attr_name, lapl_id)
    ccall((:H5Aexists_by_name, libhdf5), htri_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, hid_t), obj_id, obj_name, attr_name, lapl_id)
end

function H5Aget_create_plist(attr_id)
    ccall((:H5Aget_create_plist, libhdf5), hid_t, (hid_t,), attr_id)
end

function H5Aget_info(attr_id, ainfo)
    ccall((:H5Aget_info, libhdf5), herr_t, (hid_t, Ptr{H5A_info_t}), attr_id, ainfo)
end

function H5Aget_info_by_idx(loc_id, obj_name, idx_type, order, n, ainfo, lapl_id)
    ccall((:H5Aget_info_by_idx, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{H5A_info_t}, hid_t), loc_id, obj_name, idx_type, order, n, ainfo, lapl_id)
end

function H5Aget_info_by_name(loc_id, obj_name, attr_name, ainfo, lapl_id)
    ccall((:H5Aget_info_by_name, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, Ptr{H5A_info_t}, hid_t), loc_id, obj_name, attr_name, ainfo, lapl_id)
end

function H5Aget_name(attr_id, buf_size, buf)
    ccall((:H5Aget_name, libhdf5), Cssize_t, (hid_t, Csize_t, Ptr{Cchar}), attr_id, buf_size, buf)
end

function H5Aget_name_by_idx(loc_id, obj_name, idx_type, order, n, name, size, lapl_id)
    ccall((:H5Aget_name_by_idx, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{Cchar}, Csize_t, hid_t), loc_id, obj_name, idx_type, order, n, name, size, lapl_id)
end

function H5Aget_space(attr_id)
    ccall((:H5Aget_space, libhdf5), hid_t, (hid_t,), attr_id)
end

function H5Aget_storage_size(attr_id)
    ccall((:H5Aget_storage_size, libhdf5), hsize_t, (hid_t,), attr_id)
end

function H5Aget_type(attr_id)
    ccall((:H5Aget_type, libhdf5), hid_t, (hid_t,), attr_id)
end

function H5Aiterate_by_name(loc_id, obj_name, idx_type, order, idx, op, op_data, lapl_id)
    ccall((:H5Aiterate_by_name, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, Ptr{hsize_t}, H5A_operator2_t, Ptr{Cvoid}, hid_t), loc_id, obj_name, idx_type, order, idx, op, op_data, lapl_id)
end

function H5Aopen(obj_id, attr_name, aapl_id)
    ccall((:H5Aopen, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t), obj_id, attr_name, aapl_id)
end

function H5Aopen_by_idx(loc_id, obj_name, idx_type, order, n, aapl_id, lapl_id)
    ccall((:H5Aopen_by_idx, libhdf5), hid_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, hid_t, hid_t), loc_id, obj_name, idx_type, order, n, aapl_id, lapl_id)
end

function H5Aopen_by_name(loc_id, obj_name, attr_name, aapl_id, lapl_id)
    ccall((:H5Aopen_by_name, libhdf5), hid_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, hid_t, hid_t), loc_id, obj_name, attr_name, aapl_id, lapl_id)
end

function H5Aread(attr_id, type_id, buf)
    ccall((:H5Aread, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cvoid}), attr_id, type_id, buf)
end

function H5Arename(loc_id, old_name, new_name)
    ccall((:H5Arename, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}), loc_id, old_name, new_name)
end

function H5Awrite(attr_id, type_id, buf)
    ccall((:H5Awrite, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cvoid}), attr_id, type_id, buf)
end

function H5Arename_by_name(loc_id, obj_name, old_attr_name, new_attr_name, lapl_id)
    ccall((:H5Arename_by_name, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, hid_t), loc_id, obj_name, old_attr_name, new_attr_name, lapl_id)
end

# typedef herr_t ( * H5A_operator1_t ) ( hid_t location_id /*in*/ , const char * attr_name /*in*/ , void * operator_data /*in,out*/ )
const H5A_operator1_t = Ptr{Cvoid}

function H5Acreate1(loc_id, name, type_id, space_id, acpl_id)
    ccall((:H5Acreate1, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t), loc_id, name, type_id, space_id, acpl_id)
end

function H5Aget_num_attrs(loc_id)
    ccall((:H5Aget_num_attrs, libhdf5), Cint, (hid_t,), loc_id)
end

function H5Aiterate1(loc_id, idx, op, op_data)
    ccall((:H5Aiterate1, libhdf5), herr_t, (hid_t, Ptr{Cuint}, H5A_operator1_t, Ptr{Cvoid}), loc_id, idx, op, op_data)
end

function H5Aopen_idx(loc_id, idx)
    ccall((:H5Aopen_idx, libhdf5), hid_t, (hid_t, Cuint), loc_id, idx)
end

function H5Aopen_name(loc_id, name)
    ccall((:H5Aopen_name, libhdf5), hid_t, (hid_t, Ptr{Cchar}), loc_id, name)
end

@cenum H5C_cache_incr_mode::UInt32 begin
    H5C_incr__off = 0
    H5C_incr__threshold = 1
end

@cenum H5C_cache_flash_incr_mode::UInt32 begin
    H5C_flash_incr__off = 0
    H5C_flash_incr__add_space = 1
end

@cenum H5C_cache_decr_mode::UInt32 begin
    H5C_decr__off = 0
    H5C_decr__threshold = 1
    H5C_decr__age_out = 2
    H5C_decr__age_out_with_threshold = 3
end

struct H5AC_cache_config_t
    version::Cint
    rpt_fcn_enabled::hbool_t
    open_trace_file::hbool_t
    close_trace_file::hbool_t
    trace_file_name::NTuple{1025, Cchar}
    evictions_enabled::hbool_t
    set_initial_size::hbool_t
    initial_size::Csize_t
    min_clean_fraction::Cdouble
    max_size::Csize_t
    min_size::Csize_t
    epoch_length::Clong
    incr_mode::H5C_cache_incr_mode
    lower_hr_threshold::Cdouble
    increment::Cdouble
    apply_max_increment::hbool_t
    max_increment::Csize_t
    flash_incr_mode::H5C_cache_flash_incr_mode
    flash_multiple::Cdouble
    flash_threshold::Cdouble
    decr_mode::H5C_cache_decr_mode
    upper_hr_threshold::Cdouble
    decrement::Cdouble
    apply_max_decrement::hbool_t
    max_decrement::Csize_t
    epochs_before_eviction::Cint
    apply_empty_reserve::hbool_t
    empty_reserve::Cdouble
    dirty_bytes_threshold::Csize_t
    metadata_write_strategy::Cint
end

struct H5AC_cache_image_config_t
    version::Cint
    generate_image::hbool_t
    save_resize_status::hbool_t
    entry_ageout::Cint
end

@cenum H5D_layout_t::Int32 begin
    H5D_LAYOUT_ERROR = -1
    H5D_COMPACT = 0
    H5D_CONTIGUOUS = 1
    H5D_CHUNKED = 2
    H5D_VIRTUAL = 3
    H5D_NLAYOUTS = 4
end

@cenum H5D_chunk_index_t::UInt32 begin
    H5D_CHUNK_IDX_BTREE = 0
    H5D_CHUNK_IDX_SINGLE = 1
    H5D_CHUNK_IDX_NONE = 2
    H5D_CHUNK_IDX_FARRAY = 3
    H5D_CHUNK_IDX_EARRAY = 4
    H5D_CHUNK_IDX_BT2 = 5
    H5D_CHUNK_IDX_NTYPES = 6
end

@cenum H5D_alloc_time_t::Int32 begin
    H5D_ALLOC_TIME_ERROR = -1
    H5D_ALLOC_TIME_DEFAULT = 0
    H5D_ALLOC_TIME_EARLY = 1
    H5D_ALLOC_TIME_LATE = 2
    H5D_ALLOC_TIME_INCR = 3
end

@cenum H5D_space_status_t::Int32 begin
    H5D_SPACE_STATUS_ERROR = -1
    H5D_SPACE_STATUS_NOT_ALLOCATED = 0
    H5D_SPACE_STATUS_PART_ALLOCATED = 1
    H5D_SPACE_STATUS_ALLOCATED = 2
end

@cenum H5D_fill_time_t::Int32 begin
    H5D_FILL_TIME_ERROR = -1
    H5D_FILL_TIME_ALLOC = 0
    H5D_FILL_TIME_NEVER = 1
    H5D_FILL_TIME_IFSET = 2
end

@cenum H5D_fill_value_t::Int32 begin
    H5D_FILL_VALUE_ERROR = -1
    H5D_FILL_VALUE_UNDEFINED = 0
    H5D_FILL_VALUE_DEFAULT = 1
    H5D_FILL_VALUE_USER_DEFINED = 2
end

@cenum H5D_vds_view_t::Int32 begin
    H5D_VDS_ERROR = -1
    H5D_VDS_FIRST_MISSING = 0
    H5D_VDS_LAST_AVAILABLE = 1
end

# typedef herr_t ( * H5D_append_cb_t ) ( hid_t dataset_id , hsize_t * cur_dims , void * op_data )
const H5D_append_cb_t = Ptr{Cvoid}

# typedef herr_t ( * H5D_operator_t ) ( void * elem , hid_t type_id , unsigned ndim , const hsize_t * point , void * operator_data )
const H5D_operator_t = Ptr{Cvoid}

# typedef herr_t ( * H5D_scatter_func_t ) ( const void * * src_buf /*out*/ , size_t * src_buf_bytes_used /*out*/ , void * op_data )
const H5D_scatter_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5D_gather_func_t ) ( const void * dst_buf , size_t dst_buf_bytes_used , void * op_data )
const H5D_gather_func_t = Ptr{Cvoid}

function H5Dcreate_anon(loc_id, type_id, space_id, dcpl_id, dapl_id)
    ccall((:H5Dcreate_anon, libhdf5), hid_t, (hid_t, hid_t, hid_t, hid_t, hid_t), loc_id, type_id, space_id, dcpl_id, dapl_id)
end

function H5Dget_space(dset_id)
    ccall((:H5Dget_space, libhdf5), hid_t, (hid_t,), dset_id)
end

function H5Dget_space_status(dset_id, allocation)
    ccall((:H5Dget_space_status, libhdf5), herr_t, (hid_t, Ptr{H5D_space_status_t}), dset_id, allocation)
end

function H5Dget_type(dset_id)
    ccall((:H5Dget_type, libhdf5), hid_t, (hid_t,), dset_id)
end

function H5Dget_create_plist(dset_id)
    ccall((:H5Dget_create_plist, libhdf5), hid_t, (hid_t,), dset_id)
end

function H5Dget_access_plist(dset_id)
    ccall((:H5Dget_access_plist, libhdf5), hid_t, (hid_t,), dset_id)
end

function H5Dget_storage_size(dset_id)
    ccall((:H5Dget_storage_size, libhdf5), hsize_t, (hid_t,), dset_id)
end

function H5Dget_chunk_storage_size(dset_id, offset, chunk_bytes)
    ccall((:H5Dget_chunk_storage_size, libhdf5), herr_t, (hid_t, Ptr{hsize_t}, Ptr{hsize_t}), dset_id, offset, chunk_bytes)
end

function H5Dget_num_chunks(dset_id, fspace_id, nchunks)
    ccall((:H5Dget_num_chunks, libhdf5), herr_t, (hid_t, hid_t, Ptr{hsize_t}), dset_id, fspace_id, nchunks)
end

function H5Dget_chunk_info_by_coord(dset_id, offset, filter_mask, addr, size)
    ccall((:H5Dget_chunk_info_by_coord, libhdf5), herr_t, (hid_t, Ptr{hsize_t}, Ptr{Cuint}, Ptr{haddr_t}, Ptr{hsize_t}), dset_id, offset, filter_mask, addr, size)
end

function H5Dget_chunk_info(dset_id, fspace_id, chk_idx, offset, filter_mask, addr, size)
    ccall((:H5Dget_chunk_info, libhdf5), herr_t, (hid_t, hid_t, hsize_t, Ptr{hsize_t}, Ptr{Cuint}, Ptr{haddr_t}, Ptr{hsize_t}), dset_id, fspace_id, chk_idx, offset, filter_mask, addr, size)
end

function H5Dget_offset(dset_id)
    ccall((:H5Dget_offset, libhdf5), haddr_t, (hid_t,), dset_id)
end

function H5Dread(dset_id, mem_type_id, mem_space_id, file_space_id, dxpl_id, buf)
    ccall((:H5Dread, libhdf5), herr_t, (hid_t, hid_t, hid_t, hid_t, hid_t, Ptr{Cvoid}), dset_id, mem_type_id, mem_space_id, file_space_id, dxpl_id, buf)
end

function H5Dwrite(dset_id, mem_type_id, mem_space_id, file_space_id, dxpl_id, buf)
    ccall((:H5Dwrite, libhdf5), herr_t, (hid_t, hid_t, hid_t, hid_t, hid_t, Ptr{Cvoid}), dset_id, mem_type_id, mem_space_id, file_space_id, dxpl_id, buf)
end

function H5Dwrite_chunk(dset_id, dxpl_id, filters, offset, data_size, buf)
    ccall((:H5Dwrite_chunk, libhdf5), herr_t, (hid_t, hid_t, UInt32, Ptr{hsize_t}, Csize_t, Ptr{Cvoid}), dset_id, dxpl_id, filters, offset, data_size, buf)
end

function H5Dread_chunk(dset_id, dxpl_id, offset, filters, buf)
    ccall((:H5Dread_chunk, libhdf5), herr_t, (hid_t, hid_t, Ptr{hsize_t}, Ptr{UInt32}, Ptr{Cvoid}), dset_id, dxpl_id, offset, filters, buf)
end

function H5Diterate(buf, type_id, space_id, op, operator_data)
    ccall((:H5Diterate, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, H5D_operator_t, Ptr{Cvoid}), buf, type_id, space_id, op, operator_data)
end

function H5Dvlen_get_buf_size(dset_id, type_id, space_id, size)
    ccall((:H5Dvlen_get_buf_size, libhdf5), herr_t, (hid_t, hid_t, hid_t, Ptr{hsize_t}), dset_id, type_id, space_id, size)
end

function H5Dfill(fill, fill_type_id, buf, buf_type_id, space_id)
    ccall((:H5Dfill, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, Ptr{Cvoid}, hid_t, hid_t), fill, fill_type_id, buf, buf_type_id, space_id)
end

function H5Dset_extent(dset_id, size)
    ccall((:H5Dset_extent, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), dset_id, size)
end

function H5Dflush(dset_id)
    ccall((:H5Dflush, libhdf5), herr_t, (hid_t,), dset_id)
end

function H5Drefresh(dset_id)
    ccall((:H5Drefresh, libhdf5), herr_t, (hid_t,), dset_id)
end

function H5Dscatter(op, op_data, type_id, dst_space_id, dst_buf)
    ccall((:H5Dscatter, libhdf5), herr_t, (H5D_scatter_func_t, Ptr{Cvoid}, hid_t, hid_t, Ptr{Cvoid}), op, op_data, type_id, dst_space_id, dst_buf)
end

function H5Dgather(src_space_id, src_buf, type_id, dst_buf_size, dst_buf, op, op_data)
    ccall((:H5Dgather, libhdf5), herr_t, (hid_t, Ptr{Cvoid}, hid_t, Csize_t, Ptr{Cvoid}, H5D_gather_func_t, Ptr{Cvoid}), src_space_id, src_buf, type_id, dst_buf_size, dst_buf, op, op_data)
end

function H5Dclose(dset_id)
    ccall((:H5Dclose, libhdf5), herr_t, (hid_t,), dset_id)
end

function H5Ddebug(dset_id)
    ccall((:H5Ddebug, libhdf5), herr_t, (hid_t,), dset_id)
end

function H5Dformat_convert(dset_id)
    ccall((:H5Dformat_convert, libhdf5), herr_t, (hid_t,), dset_id)
end

function H5Dget_chunk_index_type(did, idx_type)
    ccall((:H5Dget_chunk_index_type, libhdf5), herr_t, (hid_t, Ptr{H5D_chunk_index_t}), did, idx_type)
end

function H5Dcreate1(loc_id, name, type_id, space_id, dcpl_id)
    ccall((:H5Dcreate1, libhdf5), hid_t, (hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t), loc_id, name, type_id, space_id, dcpl_id)
end

function H5Dopen1(loc_id, name)
    ccall((:H5Dopen1, libhdf5), hid_t, (hid_t, Ptr{Cchar}), loc_id, name)
end

function H5Dextend(dset_id, size)
    ccall((:H5Dextend, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), dset_id, size)
end

function H5Dvlen_reclaim(type_id, space_id, dxpl_id, buf)
    ccall((:H5Dvlen_reclaim, libhdf5), herr_t, (hid_t, hid_t, hid_t, Ptr{Cvoid}), type_id, space_id, dxpl_id, buf)
end

@cenum H5E_type_t::UInt32 begin
    H5E_MAJOR = 0
    H5E_MINOR = 1
end

function H5Eregister_class(cls_name, lib_name, version)
    ccall((:H5Eregister_class, libhdf5), hid_t, (Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}), cls_name, lib_name, version)
end

function H5Eunregister_class(class_id)
    ccall((:H5Eunregister_class, libhdf5), herr_t, (hid_t,), class_id)
end

function H5Eclose_msg(err_id)
    ccall((:H5Eclose_msg, libhdf5), herr_t, (hid_t,), err_id)
end

function H5Ecreate_msg(cls, msg_type, msg)
    ccall((:H5Ecreate_msg, libhdf5), hid_t, (hid_t, H5E_type_t, Ptr{Cchar}), cls, msg_type, msg)
end

function H5Ecreate_stack()
    ccall((:H5Ecreate_stack, libhdf5), hid_t, ())
end

function H5Eget_current_stack()
    ccall((:H5Eget_current_stack, libhdf5), hid_t, ())
end

function H5Eclose_stack(stack_id)
    ccall((:H5Eclose_stack, libhdf5), herr_t, (hid_t,), stack_id)
end

function H5Eget_class_name(class_id, name, size)
    ccall((:H5Eget_class_name, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), class_id, name, size)
end

function H5Eset_current_stack(err_stack_id)
    ccall((:H5Eset_current_stack, libhdf5), herr_t, (hid_t,), err_stack_id)
end

function H5Epop(err_stack, count)
    ccall((:H5Epop, libhdf5), herr_t, (hid_t, Csize_t), err_stack, count)
end

function H5Eget_msg(msg_id, type, msg, size)
    ccall((:H5Eget_msg, libhdf5), Cssize_t, (hid_t, Ptr{H5E_type_t}, Ptr{Cchar}, Csize_t), msg_id, type, msg, size)
end

function H5Eget_num(error_stack_id)
    ccall((:H5Eget_num, libhdf5), Cssize_t, (hid_t,), error_stack_id)
end

const H5E_major_t = hid_t

const H5E_minor_t = hid_t

struct H5E_error1_t
    maj_num::H5E_major_t
    min_num::H5E_minor_t
    func_name::Ptr{Cchar}
    file_name::Ptr{Cchar}
    line::Cuint
    desc::Ptr{Cchar}
end

# typedef herr_t ( * H5E_walk1_t ) ( int n , H5E_error1_t * err_desc , void * client_data )
const H5E_walk1_t = Ptr{Cvoid}

function H5Eclear1()
    ccall((:H5Eclear1, libhdf5), herr_t, ())
end

function H5Epush1(file, func, line, maj, min, str)
    ccall((:H5Epush1, libhdf5), herr_t, (Ptr{Cchar}, Ptr{Cchar}, Cuint, H5E_major_t, H5E_minor_t, Ptr{Cchar}), file, func, line, maj, min, str)
end

function H5Eprint1(stream)
    ccall((:H5Eprint1, libhdf5), herr_t, (Ptr{Libc.FILE},), stream)
end

function H5Ewalk1(direction, func, client_data)
    ccall((:H5Ewalk1, libhdf5), herr_t, (H5E_direction_t, H5E_walk1_t, Ptr{Cvoid}), direction, func, client_data)
end

function H5Eget_major(maj)
    ccall((:H5Eget_major, libhdf5), Ptr{Cchar}, (H5E_major_t,), maj)
end

function H5Eget_minor(min)
    ccall((:H5Eget_minor, libhdf5), Ptr{Cchar}, (H5E_minor_t,), min)
end

@cenum H5F_scope_t::UInt32 begin
    H5F_SCOPE_LOCAL = 0
    H5F_SCOPE_GLOBAL = 1
end

@cenum H5F_close_degree_t::UInt32 begin
    H5F_CLOSE_DEFAULT = 0
    H5F_CLOSE_WEAK = 1
    H5F_CLOSE_SEMI = 2
    H5F_CLOSE_STRONG = 3
end

@cenum H5F_mem_t::Int32 begin
    H5FD_MEM_NOLIST = -1
    H5FD_MEM_DEFAULT = 0
    H5FD_MEM_SUPER = 1
    H5FD_MEM_BTREE = 2
    H5FD_MEM_DRAW = 3
    H5FD_MEM_GHEAP = 4
    H5FD_MEM_LHEAP = 5
    H5FD_MEM_OHDR = 6
    H5FD_MEM_NTYPES = 7
end

struct H5F_sect_info_t
    addr::haddr_t
    size::hsize_t
end

@cenum H5F_libver_t::Int32 begin
    H5F_LIBVER_ERROR = -1
    H5F_LIBVER_EARLIEST = 0
    H5F_LIBVER_V18 = 1
    H5F_LIBVER_V110 = 2
    H5F_LIBVER_V112 = 3
    H5F_LIBVER_NBOUNDS = 4
end

@cenum H5F_fspace_strategy_t::UInt32 begin
    H5F_FSPACE_STRATEGY_FSM_AGGR = 0
    H5F_FSPACE_STRATEGY_PAGE = 1
    H5F_FSPACE_STRATEGY_AGGR = 2
    H5F_FSPACE_STRATEGY_NONE = 3
    H5F_FSPACE_STRATEGY_NTYPES = 4
end

@cenum H5F_file_space_type_t::UInt32 begin
    H5F_FILE_SPACE_DEFAULT = 0
    H5F_FILE_SPACE_ALL_PERSIST = 1
    H5F_FILE_SPACE_ALL = 2
    H5F_FILE_SPACE_AGGR_VFD = 3
    H5F_FILE_SPACE_VFD = 4
    H5F_FILE_SPACE_NTYPES = 5
end

struct H5F_retry_info_t
    nbins::Cuint
    retries::NTuple{21, Ptr{UInt32}}
end

# typedef herr_t ( * H5F_flush_cb_t ) ( hid_t object_id , void * udata )
const H5F_flush_cb_t = Ptr{Cvoid}

function H5Fis_accessible(container_name, fapl_id)
    ccall((:H5Fis_accessible, libhdf5), htri_t, (Ptr{Cchar}, hid_t), container_name, fapl_id)
end

function H5Fcreate(filename, flags, fcpl_id, fapl_id)
    ccall((:H5Fcreate, libhdf5), hid_t, (Ptr{Cchar}, Cuint, hid_t, hid_t), filename, flags, fcpl_id, fapl_id)
end

function H5Fopen(filename, flags, fapl_id)
    ccall((:H5Fopen, libhdf5), hid_t, (Ptr{Cchar}, Cuint, hid_t), filename, flags, fapl_id)
end

function H5Freopen(file_id)
    ccall((:H5Freopen, libhdf5), hid_t, (hid_t,), file_id)
end

function H5Fflush(object_id, scope)
    ccall((:H5Fflush, libhdf5), herr_t, (hid_t, H5F_scope_t), object_id, scope)
end

function H5Fclose(file_id)
    ccall((:H5Fclose, libhdf5), herr_t, (hid_t,), file_id)
end

function H5Fdelete(filename, fapl_id)
    ccall((:H5Fdelete, libhdf5), herr_t, (Ptr{Cchar}, hid_t), filename, fapl_id)
end

function H5Fget_create_plist(file_id)
    ccall((:H5Fget_create_plist, libhdf5), hid_t, (hid_t,), file_id)
end

function H5Fget_access_plist(file_id)
    ccall((:H5Fget_access_plist, libhdf5), hid_t, (hid_t,), file_id)
end

function H5Fget_intent(file_id, intent)
    ccall((:H5Fget_intent, libhdf5), herr_t, (hid_t, Ptr{Cuint}), file_id, intent)
end

function H5Fget_fileno(file_id, fileno)
    ccall((:H5Fget_fileno, libhdf5), herr_t, (hid_t, Ptr{Culong}), file_id, fileno)
end

function H5Fget_obj_count(file_id, types)
    ccall((:H5Fget_obj_count, libhdf5), Cssize_t, (hid_t, Cuint), file_id, types)
end

function H5Fget_obj_ids(file_id, types, max_objs, obj_id_list)
    ccall((:H5Fget_obj_ids, libhdf5), Cssize_t, (hid_t, Cuint, Csize_t, Ptr{hid_t}), file_id, types, max_objs, obj_id_list)
end

function H5Fget_vfd_handle(file_id, fapl, file_handle)
    ccall((:H5Fget_vfd_handle, libhdf5), herr_t, (hid_t, hid_t, Ptr{Ptr{Cvoid}}), file_id, fapl, file_handle)
end

function H5Fmount(loc, name, child, plist)
    ccall((:H5Fmount, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, hid_t), loc, name, child, plist)
end

function H5Funmount(loc, name)
    ccall((:H5Funmount, libhdf5), herr_t, (hid_t, Ptr{Cchar}), loc, name)
end

function H5Fget_freespace(file_id)
    ccall((:H5Fget_freespace, libhdf5), hssize_t, (hid_t,), file_id)
end

function H5Fget_filesize(file_id, size)
    ccall((:H5Fget_filesize, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), file_id, size)
end

function H5Fget_eoa(file_id, eoa)
    ccall((:H5Fget_eoa, libhdf5), herr_t, (hid_t, Ptr{haddr_t}), file_id, eoa)
end

function H5Fincrement_filesize(file_id, increment)
    ccall((:H5Fincrement_filesize, libhdf5), herr_t, (hid_t, hsize_t), file_id, increment)
end

function H5Fget_file_image(file_id, buf_ptr, buf_len)
    ccall((:H5Fget_file_image, libhdf5), Cssize_t, (hid_t, Ptr{Cvoid}, Csize_t), file_id, buf_ptr, buf_len)
end

function H5Fget_mdc_config(file_id, config_ptr)
    ccall((:H5Fget_mdc_config, libhdf5), herr_t, (hid_t, Ptr{H5AC_cache_config_t}), file_id, config_ptr)
end

function H5Fset_mdc_config(file_id, config_ptr)
    ccall((:H5Fset_mdc_config, libhdf5), herr_t, (hid_t, Ptr{H5AC_cache_config_t}), file_id, config_ptr)
end

function H5Fget_mdc_hit_rate(file_id, hit_rate_ptr)
    ccall((:H5Fget_mdc_hit_rate, libhdf5), herr_t, (hid_t, Ptr{Cdouble}), file_id, hit_rate_ptr)
end

function H5Fget_mdc_size(file_id, max_size_ptr, min_clean_size_ptr, cur_size_ptr, cur_num_entries_ptr)
    ccall((:H5Fget_mdc_size, libhdf5), herr_t, (hid_t, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Cint}), file_id, max_size_ptr, min_clean_size_ptr, cur_size_ptr, cur_num_entries_ptr)
end

function H5Freset_mdc_hit_rate_stats(file_id)
    ccall((:H5Freset_mdc_hit_rate_stats, libhdf5), herr_t, (hid_t,), file_id)
end

function H5Fget_name(obj_id, name, size)
    ccall((:H5Fget_name, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), obj_id, name, size)
end

function H5Fget_metadata_read_retry_info(file_id, info)
    ccall((:H5Fget_metadata_read_retry_info, libhdf5), herr_t, (hid_t, Ptr{H5F_retry_info_t}), file_id, info)
end

function H5Fstart_swmr_write(file_id)
    ccall((:H5Fstart_swmr_write, libhdf5), herr_t, (hid_t,), file_id)
end

function H5Fget_free_sections(file_id, type, nsects, sect_info)
    ccall((:H5Fget_free_sections, libhdf5), Cssize_t, (hid_t, H5F_mem_t, Csize_t, Ptr{H5F_sect_info_t}), file_id, type, nsects, sect_info)
end

function H5Fclear_elink_file_cache(file_id)
    ccall((:H5Fclear_elink_file_cache, libhdf5), herr_t, (hid_t,), file_id)
end

function H5Fset_libver_bounds(file_id, low, high)
    ccall((:H5Fset_libver_bounds, libhdf5), herr_t, (hid_t, H5F_libver_t, H5F_libver_t), file_id, low, high)
end

function H5Fstart_mdc_logging(file_id)
    ccall((:H5Fstart_mdc_logging, libhdf5), herr_t, (hid_t,), file_id)
end

function H5Fstop_mdc_logging(file_id)
    ccall((:H5Fstop_mdc_logging, libhdf5), herr_t, (hid_t,), file_id)
end

function H5Fget_mdc_logging_status(file_id, is_enabled, is_currently_logging)
    ccall((:H5Fget_mdc_logging_status, libhdf5), herr_t, (hid_t, Ptr{hbool_t}, Ptr{hbool_t}), file_id, is_enabled, is_currently_logging)
end

function H5Fformat_convert(fid)
    ccall((:H5Fformat_convert, libhdf5), herr_t, (hid_t,), fid)
end

function H5Freset_page_buffering_stats(file_id)
    ccall((:H5Freset_page_buffering_stats, libhdf5), herr_t, (hid_t,), file_id)
end

function H5Fget_page_buffering_stats(file_id, accesses, hits, misses, evictions, bypasses)
    ccall((:H5Fget_page_buffering_stats, libhdf5), herr_t, (hid_t, Ptr{Cuint}, Ptr{Cuint}, Ptr{Cuint}, Ptr{Cuint}, Ptr{Cuint}), file_id, accesses, hits, misses, evictions, bypasses)
end

function H5Fget_mdc_image_info(file_id, image_addr, image_size)
    ccall((:H5Fget_mdc_image_info, libhdf5), herr_t, (hid_t, Ptr{haddr_t}, Ptr{hsize_t}), file_id, image_addr, image_size)
end

function H5Fget_dset_no_attrs_hint(file_id, minimize)
    ccall((:H5Fget_dset_no_attrs_hint, libhdf5), herr_t, (hid_t, Ptr{hbool_t}), file_id, minimize)
end

function H5Fset_dset_no_attrs_hint(file_id, minimize)
    ccall((:H5Fset_dset_no_attrs_hint, libhdf5), herr_t, (hid_t, hbool_t), file_id, minimize)
end

struct var"##Ctag#293"
    hdr_size::hsize_t
    msgs_info::H5_ih_info_t
end
function Base.getproperty(x::Ptr{var"##Ctag#293"}, f::Symbol)
    f === :hdr_size && return Ptr{hsize_t}(x + 0)
    f === :msgs_info && return Ptr{H5_ih_info_t}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#293", f::Symbol)
    r = Ref{var"##Ctag#293"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#293"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#293"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end


struct H5F_info1_t
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{H5F_info1_t}, f::Symbol)
    f === :super_ext_size && return Ptr{hsize_t}(x + 0)
    f === :sohm && return Ptr{var"##Ctag#293"}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::H5F_info1_t, f::Symbol)
    r = Ref{H5F_info1_t}(x)
    ptr = Base.unsafe_convert(Ptr{H5F_info1_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{H5F_info1_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function H5Fget_info1(obj_id, file_info)
    ccall((:H5Fget_info1, libhdf5), herr_t, (hid_t, Ptr{H5F_info1_t}), obj_id, file_info)
end

function H5Fset_latest_format(file_id, latest_format)
    ccall((:H5Fset_latest_format, libhdf5), herr_t, (hid_t, hbool_t), file_id, latest_format)
end

function H5Fis_hdf5(file_name)
    ccall((:H5Fis_hdf5, libhdf5), htri_t, (Ptr{Cchar},), file_name)
end

const H5FD_mem_t = H5F_mem_t

struct H5FD_class_t
    name::Ptr{Cchar}
    maxaddr::haddr_t
    fc_degree::H5F_close_degree_t
    terminate::Ptr{Cvoid}
    sb_size::Ptr{Cvoid}
    sb_encode::Ptr{Cvoid}
    sb_decode::Ptr{Cvoid}
    fapl_size::Csize_t
    fapl_get::Ptr{Cvoid}
    fapl_copy::Ptr{Cvoid}
    fapl_free::Ptr{Cvoid}
    dxpl_size::Csize_t
    dxpl_copy::Ptr{Cvoid}
    dxpl_free::Ptr{Cvoid}
    open::Ptr{Cvoid}
    close::Ptr{Cvoid}
    cmp::Ptr{Cvoid}
    query::Ptr{Cvoid}
    get_type_map::Ptr{Cvoid}
    alloc::Ptr{Cvoid}
    free::Ptr{Cvoid}
    get_eoa::Ptr{Cvoid}
    set_eoa::Ptr{Cvoid}
    get_eof::Ptr{Cvoid}
    get_handle::Ptr{Cvoid}
    read::Ptr{Cvoid}
    write::Ptr{Cvoid}
    flush::Ptr{Cvoid}
    truncate::Ptr{Cvoid}
    lock::Ptr{Cvoid}
    unlock::Ptr{Cvoid}
    fl_map::NTuple{7, H5FD_mem_t}
end

struct H5FD_t
    driver_id::hid_t
    cls::Ptr{H5FD_class_t}
    fileno::Culong
    access_flags::Cuint
    feature_flags::Culong
    maxaddr::haddr_t
    base_addr::haddr_t
    threshold::hsize_t
    alignment::hsize_t
    paged_aggr::hbool_t
end

struct H5FD_free_t
    addr::haddr_t
    size::hsize_t
    next::Ptr{H5FD_free_t}
end

@cenum H5FD_file_image_op_t::UInt32 begin
    H5FD_FILE_IMAGE_OP_NO_OP = 0
    H5FD_FILE_IMAGE_OP_PROPERTY_LIST_SET = 1
    H5FD_FILE_IMAGE_OP_PROPERTY_LIST_COPY = 2
    H5FD_FILE_IMAGE_OP_PROPERTY_LIST_GET = 3
    H5FD_FILE_IMAGE_OP_PROPERTY_LIST_CLOSE = 4
    H5FD_FILE_IMAGE_OP_FILE_OPEN = 5
    H5FD_FILE_IMAGE_OP_FILE_RESIZE = 6
    H5FD_FILE_IMAGE_OP_FILE_CLOSE = 7
end

struct H5FD_file_image_callbacks_t
    image_malloc::Ptr{Cvoid}
    image_memcpy::Ptr{Cvoid}
    image_realloc::Ptr{Cvoid}
    image_free::Ptr{Cvoid}
    udata_copy::Ptr{Cvoid}
    udata_free::Ptr{Cvoid}
    udata::Ptr{Cvoid}
end

function H5FDregister(cls)
    ccall((:H5FDregister, libhdf5), hid_t, (Ptr{H5FD_class_t},), cls)
end

function H5FDunregister(driver_id)
    ccall((:H5FDunregister, libhdf5), herr_t, (hid_t,), driver_id)
end

function H5FDopen(name, flags, fapl_id, maxaddr)
    ccall((:H5FDopen, libhdf5), Ptr{H5FD_t}, (Ptr{Cchar}, Cuint, hid_t, haddr_t), name, flags, fapl_id, maxaddr)
end

function H5FDclose(file)
    ccall((:H5FDclose, libhdf5), herr_t, (Ptr{H5FD_t},), file)
end

function H5FDcmp(f1, f2)
    ccall((:H5FDcmp, libhdf5), Cint, (Ptr{H5FD_t}, Ptr{H5FD_t}), f1, f2)
end

function H5FDquery(f, flags)
    ccall((:H5FDquery, libhdf5), Cint, (Ptr{H5FD_t}, Ptr{Culong}), f, flags)
end

function H5FDalloc(file, type, dxpl_id, size)
    ccall((:H5FDalloc, libhdf5), haddr_t, (Ptr{H5FD_t}, H5FD_mem_t, hid_t, hsize_t), file, type, dxpl_id, size)
end

function H5FDfree(file, type, dxpl_id, addr, size)
    ccall((:H5FDfree, libhdf5), herr_t, (Ptr{H5FD_t}, H5FD_mem_t, hid_t, haddr_t, hsize_t), file, type, dxpl_id, addr, size)
end

function H5FDget_eoa(file, type)
    ccall((:H5FDget_eoa, libhdf5), haddr_t, (Ptr{H5FD_t}, H5FD_mem_t), file, type)
end

function H5FDset_eoa(file, type, eoa)
    ccall((:H5FDset_eoa, libhdf5), herr_t, (Ptr{H5FD_t}, H5FD_mem_t, haddr_t), file, type, eoa)
end

function H5FDget_eof(file, type)
    ccall((:H5FDget_eof, libhdf5), haddr_t, (Ptr{H5FD_t}, H5FD_mem_t), file, type)
end

function H5FDget_vfd_handle(file, fapl, file_handle)
    ccall((:H5FDget_vfd_handle, libhdf5), herr_t, (Ptr{H5FD_t}, hid_t, Ptr{Ptr{Cvoid}}), file, fapl, file_handle)
end

function H5FDread(file, type, dxpl_id, addr, size, buf)
    ccall((:H5FDread, libhdf5), herr_t, (Ptr{H5FD_t}, H5FD_mem_t, hid_t, haddr_t, Csize_t, Ptr{Cvoid}), file, type, dxpl_id, addr, size, buf)
end

function H5FDwrite(file, type, dxpl_id, addr, size, buf)
    ccall((:H5FDwrite, libhdf5), herr_t, (Ptr{H5FD_t}, H5FD_mem_t, hid_t, haddr_t, Csize_t, Ptr{Cvoid}), file, type, dxpl_id, addr, size, buf)
end

function H5FDflush(file, dxpl_id, closing)
    ccall((:H5FDflush, libhdf5), herr_t, (Ptr{H5FD_t}, hid_t, hbool_t), file, dxpl_id, closing)
end

function H5FDtruncate(file, dxpl_id, closing)
    ccall((:H5FDtruncate, libhdf5), herr_t, (Ptr{H5FD_t}, hid_t, hbool_t), file, dxpl_id, closing)
end

function H5FDlock(file, rw)
    ccall((:H5FDlock, libhdf5), herr_t, (Ptr{H5FD_t}, hbool_t), file, rw)
end

function H5FDunlock(file)
    ccall((:H5FDunlock, libhdf5), herr_t, (Ptr{H5FD_t},), file)
end

function H5FDdriver_query(driver_id, flags)
    ccall((:H5FDdriver_query, libhdf5), herr_t, (hid_t, Ptr{Culong}), driver_id, flags)
end

@cenum H5G_storage_type_t::Int32 begin
    H5G_STORAGE_TYPE_UNKNOWN = -1
    H5G_STORAGE_TYPE_SYMBOL_TABLE = 0
    H5G_STORAGE_TYPE_COMPACT = 1
    H5G_STORAGE_TYPE_DENSE = 2
end

struct H5G_info_t
    storage_type::H5G_storage_type_t
    nlinks::hsize_t
    max_corder::Int64
    mounted::hbool_t
end

function H5Gcreate_anon(loc_id, gcpl_id, gapl_id)
    ccall((:H5Gcreate_anon, libhdf5), hid_t, (hid_t, hid_t, hid_t), loc_id, gcpl_id, gapl_id)
end

function H5Gget_create_plist(group_id)
    ccall((:H5Gget_create_plist, libhdf5), hid_t, (hid_t,), group_id)
end

function H5Gget_info(loc_id, ginfo)
    ccall((:H5Gget_info, libhdf5), herr_t, (hid_t, Ptr{H5G_info_t}), loc_id, ginfo)
end

function H5Gget_info_by_name(loc_id, name, ginfo, lapl_id)
    ccall((:H5Gget_info_by_name, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{H5G_info_t}, hid_t), loc_id, name, ginfo, lapl_id)
end

function H5Gget_info_by_idx(loc_id, group_name, idx_type, order, n, ginfo, lapl_id)
    ccall((:H5Gget_info_by_idx, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5_index_t, H5_iter_order_t, hsize_t, Ptr{H5G_info_t}, hid_t), loc_id, group_name, idx_type, order, n, ginfo, lapl_id)
end

function H5Gflush(group_id)
    ccall((:H5Gflush, libhdf5), herr_t, (hid_t,), group_id)
end

function H5Grefresh(group_id)
    ccall((:H5Grefresh, libhdf5), herr_t, (hid_t,), group_id)
end

function H5Gclose(group_id)
    ccall((:H5Gclose, libhdf5), herr_t, (hid_t,), group_id)
end

@cenum H5G_obj_t::Int32 begin
    H5G_UNKNOWN = -1
    H5G_GROUP = 0
    H5G_DATASET = 1
    H5G_TYPE = 2
    H5G_LINK = 3
    H5G_UDLINK = 4
    H5G_RESERVED_5 = 5
    H5G_RESERVED_6 = 6
    H5G_RESERVED_7 = 7
end

# typedef herr_t ( * H5G_iterate_t ) ( hid_t group , const char * name , void * op_data )
const H5G_iterate_t = Ptr{Cvoid}

struct H5G_stat_t
    fileno::NTuple{2, Culong}
    objno::NTuple{2, Culong}
    nlink::Cuint
    type::H5G_obj_t
    mtime::time_t
    linklen::Csize_t
    ohdr::H5O_stat_t
end

function H5Gcreate1(loc_id, name, size_hint)
    ccall((:H5Gcreate1, libhdf5), hid_t, (hid_t, Ptr{Cchar}, Csize_t), loc_id, name, size_hint)
end

function H5Gopen1(loc_id, name)
    ccall((:H5Gopen1, libhdf5), hid_t, (hid_t, Ptr{Cchar}), loc_id, name)
end

function H5Glink(cur_loc_id, type, cur_name, new_name)
    ccall((:H5Glink, libhdf5), herr_t, (hid_t, H5L_type_t, Ptr{Cchar}, Ptr{Cchar}), cur_loc_id, type, cur_name, new_name)
end

function H5Glink2(cur_loc_id, cur_name, type, new_loc_id, new_name)
    ccall((:H5Glink2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, H5L_type_t, hid_t, Ptr{Cchar}), cur_loc_id, cur_name, type, new_loc_id, new_name)
end

function H5Gmove(src_loc_id, src_name, dst_name)
    ccall((:H5Gmove, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}), src_loc_id, src_name, dst_name)
end

function H5Gmove2(src_loc_id, src_name, dst_loc_id, dst_name)
    ccall((:H5Gmove2, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, Ptr{Cchar}), src_loc_id, src_name, dst_loc_id, dst_name)
end

function H5Gunlink(loc_id, name)
    ccall((:H5Gunlink, libhdf5), herr_t, (hid_t, Ptr{Cchar}), loc_id, name)
end

function H5Gget_linkval(loc_id, name, size, buf)
    ccall((:H5Gget_linkval, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Csize_t, Ptr{Cchar}), loc_id, name, size, buf)
end

function H5Gset_comment(loc_id, name, comment)
    ccall((:H5Gset_comment, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}), loc_id, name, comment)
end

function H5Gget_comment(loc_id, name, bufsize, buf)
    ccall((:H5Gget_comment, libhdf5), Cint, (hid_t, Ptr{Cchar}, Csize_t, Ptr{Cchar}), loc_id, name, bufsize, buf)
end

function H5Giterate(loc_id, name, idx, op, op_data)
    ccall((:H5Giterate, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cint}, H5G_iterate_t, Ptr{Cvoid}), loc_id, name, idx, op, op_data)
end

function H5Gget_num_objs(loc_id, num_objs)
    ccall((:H5Gget_num_objs, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), loc_id, num_objs)
end

function H5Gget_objinfo(loc_id, name, follow_link, statbuf)
    ccall((:H5Gget_objinfo, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hbool_t, Ptr{H5G_stat_t}), loc_id, name, follow_link, statbuf)
end

function H5Gget_objname_by_idx(loc_id, idx, name, size)
    ccall((:H5Gget_objname_by_idx, libhdf5), Cssize_t, (hid_t, hsize_t, Ptr{Cchar}, Csize_t), loc_id, idx, name, size)
end

function H5Gget_objtype_by_idx(loc_id, idx)
    ccall((:H5Gget_objtype_by_idx, libhdf5), H5G_obj_t, (hid_t, hsize_t), loc_id, idx)
end

@cenum H5VL_map_get_t::UInt32 begin
    H5VL_MAP_GET_MAPL = 0
    H5VL_MAP_GET_MCPL = 1
    H5VL_MAP_GET_KEY_TYPE = 2
    H5VL_MAP_GET_VAL_TYPE = 3
    H5VL_MAP_GET_COUNT = 4
end

@cenum H5VL_map_specific_t::UInt32 begin
    H5VL_MAP_ITER = 0
    H5VL_MAP_DELETE = 1
end

# typedef herr_t ( * H5M_iterate_t ) ( hid_t map_id , const void * key , void * op_data )
const H5M_iterate_t = Ptr{Cvoid}

# typedef void * ( * H5MM_allocate_t ) ( size_t size , void * alloc_info )
const H5MM_allocate_t = Ptr{Cvoid}

# typedef void ( * H5MM_free_t ) ( void * mem , void * free_info )
const H5MM_free_t = Ptr{Cvoid}

@cenum H5Z_SO_scale_type_t::UInt32 begin
    H5Z_SO_FLOAT_DSCALE = 0
    H5Z_SO_FLOAT_ESCALE = 1
    H5Z_SO_INT = 2
end

@cenum H5Z_EDC_t::Int32 begin
    H5Z_ERROR_EDC = -1
    H5Z_DISABLE_EDC = 0
    H5Z_ENABLE_EDC = 1
    H5Z_NO_EDC = 2
end

@cenum H5Z_cb_return_t::Int32 begin
    H5Z_CB_ERROR = -1
    H5Z_CB_FAIL = 0
    H5Z_CB_CONT = 1
    H5Z_CB_NO = 2
end

# typedef H5Z_cb_return_t ( * H5Z_filter_func_t ) ( H5Z_filter_t filter , void * buf , size_t buf_size , void * op_data )
const H5Z_filter_func_t = Ptr{Cvoid}

struct H5Z_cb_t
    func::H5Z_filter_func_t
    op_data::Ptr{Cvoid}
end

function H5Zregister(cls)
    ccall((:H5Zregister, libhdf5), herr_t, (Ptr{Cvoid},), cls)
end

function H5Zunregister(id)
    ccall((:H5Zunregister, libhdf5), herr_t, (H5Z_filter_t,), id)
end

function H5Zfilter_avail(id)
    ccall((:H5Zfilter_avail, libhdf5), htri_t, (H5Z_filter_t,), id)
end

function H5Zget_filter_info(filter, filter_config_flags)
    ccall((:H5Zget_filter_info, libhdf5), herr_t, (H5Z_filter_t, Ptr{Cuint}), filter, filter_config_flags)
end

struct H5Z_class1_t
    id::H5Z_filter_t
    name::Ptr{Cchar}
    can_apply::H5Z_can_apply_func_t
    set_local::H5Z_set_local_func_t
    filter::H5Z_func_t
end

# typedef herr_t ( * H5P_cls_create_func_t ) ( hid_t prop_id , void * create_data )
const H5P_cls_create_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5P_cls_copy_func_t ) ( hid_t new_prop_id , hid_t old_prop_id , void * copy_data )
const H5P_cls_copy_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5P_cls_close_func_t ) ( hid_t prop_id , void * close_data )
const H5P_cls_close_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5P_prp_encode_func_t ) ( const void * value , void * * buf , size_t * size )
const H5P_prp_encode_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5P_prp_decode_func_t ) ( const void * * buf , void * value )
const H5P_prp_decode_func_t = Ptr{Cvoid}

# typedef herr_t ( * H5P_iterate_t ) ( hid_t id , const char * name , void * iter_data )
const H5P_iterate_t = Ptr{Cvoid}

@cenum H5D_mpio_actual_chunk_opt_mode_t::UInt32 begin
    H5D_MPIO_NO_CHUNK_OPTIMIZATION = 0
    H5D_MPIO_LINK_CHUNK = 1
    H5D_MPIO_MULTI_CHUNK = 2
end

@cenum H5D_mpio_actual_io_mode_t::UInt32 begin
    H5D_MPIO_NO_COLLECTIVE = 0
    H5D_MPIO_CHUNK_INDEPENDENT = 1
    H5D_MPIO_CHUNK_COLLECTIVE = 2
    H5D_MPIO_CHUNK_MIXED = 3
    H5D_MPIO_CONTIGUOUS_COLLECTIVE = 4
end

@cenum H5D_mpio_no_collective_cause_t::UInt32 begin
    H5D_MPIO_COLLECTIVE = 0
    H5D_MPIO_SET_INDEPENDENT = 1
    H5D_MPIO_DATATYPE_CONVERSION = 2
    H5D_MPIO_DATA_TRANSFORMS = 4
    H5D_MPIO_MPI_OPT_TYPES_ENV_VAR_DISABLED = 8
    H5D_MPIO_NOT_SIMPLE_OR_SCALAR_DATASPACES = 16
    H5D_MPIO_NOT_CONTIGUOUS_OR_CHUNKED_DATASET = 32
    H5D_MPIO_PARALLEL_FILTERED_WRITES_DISABLED = 64
    H5D_MPIO_ERROR_WHILE_CHECKING_COLLECTIVE_POSSIBLE = 128
    H5D_MPIO_NO_COLLECTIVE_MAX_CAUSE = 256
end

function H5Pclose(plist_id)
    ccall((:H5Pclose, libhdf5), herr_t, (hid_t,), plist_id)
end

function H5Pclose_class(plist_id)
    ccall((:H5Pclose_class, libhdf5), herr_t, (hid_t,), plist_id)
end

function H5Pcopy(plist_id)
    ccall((:H5Pcopy, libhdf5), hid_t, (hid_t,), plist_id)
end

function H5Pcopy_prop(dst_id, src_id, name)
    ccall((:H5Pcopy_prop, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cchar}), dst_id, src_id, name)
end

function H5Pcreate(cls_id)
    ccall((:H5Pcreate, libhdf5), hid_t, (hid_t,), cls_id)
end

function H5Pcreate_class(parent, name, create, create_data, copy, copy_data, close, close_data)
    ccall((:H5Pcreate_class, libhdf5), hid_t, (hid_t, Ptr{Cchar}, H5P_cls_create_func_t, Ptr{Cvoid}, H5P_cls_copy_func_t, Ptr{Cvoid}, H5P_cls_close_func_t, Ptr{Cvoid}), parent, name, create, create_data, copy, copy_data, close, close_data)
end

function H5Pdecode(buf)
    ccall((:H5Pdecode, libhdf5), hid_t, (Ptr{Cvoid},), buf)
end

function H5Pequal(id1, id2)
    ccall((:H5Pequal, libhdf5), htri_t, (hid_t, hid_t), id1, id2)
end

function H5Pexist(plist_id, name)
    ccall((:H5Pexist, libhdf5), htri_t, (hid_t, Ptr{Cchar}), plist_id, name)
end

function H5Pget(plist_id, name, value)
    ccall((:H5Pget, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cvoid}), plist_id, name, value)
end

function H5Pget_class(plist_id)
    ccall((:H5Pget_class, libhdf5), hid_t, (hid_t,), plist_id)
end

function H5Pget_class_name(pclass_id)
    ccall((:H5Pget_class_name, libhdf5), Ptr{Cchar}, (hid_t,), pclass_id)
end

function H5Pget_class_parent(pclass_id)
    ccall((:H5Pget_class_parent, libhdf5), hid_t, (hid_t,), pclass_id)
end

function H5Pget_nprops(id, nprops)
    ccall((:H5Pget_nprops, libhdf5), herr_t, (hid_t, Ptr{Csize_t}), id, nprops)
end

function H5Pget_size(id, name, size)
    ccall((:H5Pget_size, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Csize_t}), id, name, size)
end

function H5Pisa_class(plist_id, pclass_id)
    ccall((:H5Pisa_class, libhdf5), htri_t, (hid_t, hid_t), plist_id, pclass_id)
end

function H5Piterate(id, idx, iter_func, iter_data)
    ccall((:H5Piterate, libhdf5), Cint, (hid_t, Ptr{Cint}, H5P_iterate_t, Ptr{Cvoid}), id, idx, iter_func, iter_data)
end

function H5Premove(plist_id, name)
    ccall((:H5Premove, libhdf5), herr_t, (hid_t, Ptr{Cchar}), plist_id, name)
end

function H5Pset(plist_id, name, value)
    ccall((:H5Pset, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cvoid}), plist_id, name, value)
end

function H5Punregister(pclass_id, name)
    ccall((:H5Punregister, libhdf5), herr_t, (hid_t, Ptr{Cchar}), pclass_id, name)
end

function H5Pall_filters_avail(plist_id)
    ccall((:H5Pall_filters_avail, libhdf5), htri_t, (hid_t,), plist_id)
end

function H5Pget_attr_creation_order(plist_id, crt_order_flags)
    ccall((:H5Pget_attr_creation_order, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, crt_order_flags)
end

function H5Pget_attr_phase_change(plist_id, max_compact, min_dense)
    ccall((:H5Pget_attr_phase_change, libhdf5), herr_t, (hid_t, Ptr{Cuint}, Ptr{Cuint}), plist_id, max_compact, min_dense)
end

function H5Pget_nfilters(plist_id)
    ccall((:H5Pget_nfilters, libhdf5), Cint, (hid_t,), plist_id)
end

function H5Pget_obj_track_times(plist_id, track_times)
    ccall((:H5Pget_obj_track_times, libhdf5), herr_t, (hid_t, Ptr{hbool_t}), plist_id, track_times)
end

function H5Pmodify_filter(plist_id, filter, flags, cd_nelmts, cd_values)
    ccall((:H5Pmodify_filter, libhdf5), herr_t, (hid_t, H5Z_filter_t, Cuint, Csize_t, Ptr{Cuint}), plist_id, filter, flags, cd_nelmts, cd_values)
end

function H5Premove_filter(plist_id, filter)
    ccall((:H5Premove_filter, libhdf5), herr_t, (hid_t, H5Z_filter_t), plist_id, filter)
end

function H5Pset_attr_creation_order(plist_id, crt_order_flags)
    ccall((:H5Pset_attr_creation_order, libhdf5), herr_t, (hid_t, Cuint), plist_id, crt_order_flags)
end

function H5Pset_attr_phase_change(plist_id, max_compact, min_dense)
    ccall((:H5Pset_attr_phase_change, libhdf5), herr_t, (hid_t, Cuint, Cuint), plist_id, max_compact, min_dense)
end

function H5Pset_deflate(plist_id, level)
    ccall((:H5Pset_deflate, libhdf5), herr_t, (hid_t, Cuint), plist_id, level)
end

function H5Pset_filter(plist_id, filter, flags, cd_nelmts, c_values)
    ccall((:H5Pset_filter, libhdf5), herr_t, (hid_t, H5Z_filter_t, Cuint, Csize_t, Ptr{Cuint}), plist_id, filter, flags, cd_nelmts, c_values)
end

function H5Pset_fletcher32(plist_id)
    ccall((:H5Pset_fletcher32, libhdf5), herr_t, (hid_t,), plist_id)
end

function H5Pset_obj_track_times(plist_id, track_times)
    ccall((:H5Pset_obj_track_times, libhdf5), herr_t, (hid_t, hbool_t), plist_id, track_times)
end

function H5Pget_file_space_page_size(plist_id, fsp_size)
    ccall((:H5Pget_file_space_page_size, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), plist_id, fsp_size)
end

function H5Pget_file_space_strategy(plist_id, strategy, persist, threshold)
    ccall((:H5Pget_file_space_strategy, libhdf5), herr_t, (hid_t, Ptr{H5F_fspace_strategy_t}, Ptr{hbool_t}, Ptr{hsize_t}), plist_id, strategy, persist, threshold)
end

function H5Pget_istore_k(plist_id, ik)
    ccall((:H5Pget_istore_k, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, ik)
end

function H5Pget_shared_mesg_index(plist_id, index_num, mesg_type_flags, min_mesg_size)
    ccall((:H5Pget_shared_mesg_index, libhdf5), herr_t, (hid_t, Cuint, Ptr{Cuint}, Ptr{Cuint}), plist_id, index_num, mesg_type_flags, min_mesg_size)
end

function H5Pget_shared_mesg_nindexes(plist_id, nindexes)
    ccall((:H5Pget_shared_mesg_nindexes, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, nindexes)
end

function H5Pget_shared_mesg_phase_change(plist_id, max_list, min_btree)
    ccall((:H5Pget_shared_mesg_phase_change, libhdf5), herr_t, (hid_t, Ptr{Cuint}, Ptr{Cuint}), plist_id, max_list, min_btree)
end

function H5Pget_sizes(plist_id, sizeof_addr, sizeof_size)
    ccall((:H5Pget_sizes, libhdf5), herr_t, (hid_t, Ptr{Csize_t}, Ptr{Csize_t}), plist_id, sizeof_addr, sizeof_size)
end

function H5Pget_sym_k(plist_id, ik, lk)
    ccall((:H5Pget_sym_k, libhdf5), herr_t, (hid_t, Ptr{Cuint}, Ptr{Cuint}), plist_id, ik, lk)
end

function H5Pget_userblock(plist_id, size)
    ccall((:H5Pget_userblock, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), plist_id, size)
end

function H5Pset_file_space_page_size(plist_id, fsp_size)
    ccall((:H5Pset_file_space_page_size, libhdf5), herr_t, (hid_t, hsize_t), plist_id, fsp_size)
end

function H5Pset_file_space_strategy(plist_id, strategy, persist, threshold)
    ccall((:H5Pset_file_space_strategy, libhdf5), herr_t, (hid_t, H5F_fspace_strategy_t, hbool_t, hsize_t), plist_id, strategy, persist, threshold)
end

function H5Pset_istore_k(plist_id, ik)
    ccall((:H5Pset_istore_k, libhdf5), herr_t, (hid_t, Cuint), plist_id, ik)
end

function H5Pset_shared_mesg_index(plist_id, index_num, mesg_type_flags, min_mesg_size)
    ccall((:H5Pset_shared_mesg_index, libhdf5), herr_t, (hid_t, Cuint, Cuint, Cuint), plist_id, index_num, mesg_type_flags, min_mesg_size)
end

function H5Pset_shared_mesg_nindexes(plist_id, nindexes)
    ccall((:H5Pset_shared_mesg_nindexes, libhdf5), herr_t, (hid_t, Cuint), plist_id, nindexes)
end

function H5Pset_shared_mesg_phase_change(plist_id, max_list, min_btree)
    ccall((:H5Pset_shared_mesg_phase_change, libhdf5), herr_t, (hid_t, Cuint, Cuint), plist_id, max_list, min_btree)
end

function H5Pset_sizes(plist_id, sizeof_addr, sizeof_size)
    ccall((:H5Pset_sizes, libhdf5), herr_t, (hid_t, Csize_t, Csize_t), plist_id, sizeof_addr, sizeof_size)
end

function H5Pset_sym_k(plist_id, ik, lk)
    ccall((:H5Pset_sym_k, libhdf5), herr_t, (hid_t, Cuint, Cuint), plist_id, ik, lk)
end

function H5Pset_userblock(plist_id, size)
    ccall((:H5Pset_userblock, libhdf5), herr_t, (hid_t, hsize_t), plist_id, size)
end

function H5Pget_alignment(fapl_id, threshold, alignment)
    ccall((:H5Pget_alignment, libhdf5), herr_t, (hid_t, Ptr{hsize_t}, Ptr{hsize_t}), fapl_id, threshold, alignment)
end

function H5Pget_cache(plist_id, mdc_nelmts, rdcc_nslots, rdcc_nbytes, rdcc_w0)
    ccall((:H5Pget_cache, libhdf5), herr_t, (hid_t, Ptr{Cint}, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Cdouble}), plist_id, mdc_nelmts, rdcc_nslots, rdcc_nbytes, rdcc_w0)
end

function H5Pget_core_write_tracking(fapl_id, is_enabled, page_size)
    ccall((:H5Pget_core_write_tracking, libhdf5), herr_t, (hid_t, Ptr{hbool_t}, Ptr{Csize_t}), fapl_id, is_enabled, page_size)
end

function H5Pget_driver(plist_id)
    ccall((:H5Pget_driver, libhdf5), hid_t, (hid_t,), plist_id)
end

function H5Pget_driver_info(plist_id)
    ccall((:H5Pget_driver_info, libhdf5), Ptr{Cvoid}, (hid_t,), plist_id)
end

function H5Pget_elink_file_cache_size(plist_id, efc_size)
    ccall((:H5Pget_elink_file_cache_size, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, efc_size)
end

function H5Pget_evict_on_close(fapl_id, evict_on_close)
    ccall((:H5Pget_evict_on_close, libhdf5), herr_t, (hid_t, Ptr{hbool_t}), fapl_id, evict_on_close)
end

function H5Pget_family_offset(fapl_id, offset)
    ccall((:H5Pget_family_offset, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), fapl_id, offset)
end

function H5Pget_fclose_degree(fapl_id, degree)
    ccall((:H5Pget_fclose_degree, libhdf5), herr_t, (hid_t, Ptr{H5F_close_degree_t}), fapl_id, degree)
end

function H5Pget_file_image(fapl_id, buf_ptr_ptr, buf_len_ptr)
    ccall((:H5Pget_file_image, libhdf5), herr_t, (hid_t, Ptr{Ptr{Cvoid}}, Ptr{Csize_t}), fapl_id, buf_ptr_ptr, buf_len_ptr)
end

function H5Pget_file_image_callbacks(fapl_id, callbacks_ptr)
    ccall((:H5Pget_file_image_callbacks, libhdf5), herr_t, (hid_t, Ptr{H5FD_file_image_callbacks_t}), fapl_id, callbacks_ptr)
end

function H5Pget_file_locking(fapl_id, use_file_locking, ignore_when_disabled)
    ccall((:H5Pget_file_locking, libhdf5), herr_t, (hid_t, Ptr{hbool_t}, Ptr{hbool_t}), fapl_id, use_file_locking, ignore_when_disabled)
end

function H5Pget_gc_references(fapl_id, gc_ref)
    ccall((:H5Pget_gc_references, libhdf5), herr_t, (hid_t, Ptr{Cuint}), fapl_id, gc_ref)
end

function H5Pget_libver_bounds(plist_id, low, high)
    ccall((:H5Pget_libver_bounds, libhdf5), herr_t, (hid_t, Ptr{H5F_libver_t}, Ptr{H5F_libver_t}), plist_id, low, high)
end

function H5Pget_mdc_config(plist_id, config_ptr)
    ccall((:H5Pget_mdc_config, libhdf5), herr_t, (hid_t, Ptr{H5AC_cache_config_t}), plist_id, config_ptr)
end

function H5Pget_mdc_image_config(plist_id, config_ptr)
    ccall((:H5Pget_mdc_image_config, libhdf5), herr_t, (hid_t, Ptr{H5AC_cache_image_config_t}), plist_id, config_ptr)
end

function H5Pget_mdc_log_options(plist_id, is_enabled, location, location_size, start_on_access)
    ccall((:H5Pget_mdc_log_options, libhdf5), herr_t, (hid_t, Ptr{hbool_t}, Ptr{Cchar}, Ptr{Csize_t}, Ptr{hbool_t}), plist_id, is_enabled, location, location_size, start_on_access)
end

function H5Pget_meta_block_size(fapl_id, size)
    ccall((:H5Pget_meta_block_size, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), fapl_id, size)
end

function H5Pget_metadata_read_attempts(plist_id, attempts)
    ccall((:H5Pget_metadata_read_attempts, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, attempts)
end

function H5Pget_multi_type(fapl_id, type)
    ccall((:H5Pget_multi_type, libhdf5), herr_t, (hid_t, Ptr{H5FD_mem_t}), fapl_id, type)
end

function H5Pget_object_flush_cb(plist_id, func, udata)
    ccall((:H5Pget_object_flush_cb, libhdf5), herr_t, (hid_t, Ptr{H5F_flush_cb_t}, Ptr{Ptr{Cvoid}}), plist_id, func, udata)
end

function H5Pget_page_buffer_size(plist_id, buf_size, min_meta_perc, min_raw_perc)
    ccall((:H5Pget_page_buffer_size, libhdf5), herr_t, (hid_t, Ptr{Csize_t}, Ptr{Cuint}, Ptr{Cuint}), plist_id, buf_size, min_meta_perc, min_raw_perc)
end

function H5Pget_sieve_buf_size(fapl_id, size)
    ccall((:H5Pget_sieve_buf_size, libhdf5), herr_t, (hid_t, Ptr{Csize_t}), fapl_id, size)
end

function H5Pget_small_data_block_size(fapl_id, size)
    ccall((:H5Pget_small_data_block_size, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), fapl_id, size)
end

function H5Pget_vol_id(plist_id, vol_id)
    ccall((:H5Pget_vol_id, libhdf5), herr_t, (hid_t, Ptr{hid_t}), plist_id, vol_id)
end

function H5Pget_vol_info(plist_id, vol_info)
    ccall((:H5Pget_vol_info, libhdf5), herr_t, (hid_t, Ptr{Ptr{Cvoid}}), plist_id, vol_info)
end

function H5Pset_alignment(fapl_id, threshold, alignment)
    ccall((:H5Pset_alignment, libhdf5), herr_t, (hid_t, hsize_t, hsize_t), fapl_id, threshold, alignment)
end

function H5Pset_cache(plist_id, mdc_nelmts, rdcc_nslots, rdcc_nbytes, rdcc_w0)
    ccall((:H5Pset_cache, libhdf5), herr_t, (hid_t, Cint, Csize_t, Csize_t, Cdouble), plist_id, mdc_nelmts, rdcc_nslots, rdcc_nbytes, rdcc_w0)
end

function H5Pset_core_write_tracking(fapl_id, is_enabled, page_size)
    ccall((:H5Pset_core_write_tracking, libhdf5), herr_t, (hid_t, hbool_t, Csize_t), fapl_id, is_enabled, page_size)
end

function H5Pset_driver(plist_id, driver_id, driver_info)
    ccall((:H5Pset_driver, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cvoid}), plist_id, driver_id, driver_info)
end

function H5Pset_elink_file_cache_size(plist_id, efc_size)
    ccall((:H5Pset_elink_file_cache_size, libhdf5), herr_t, (hid_t, Cuint), plist_id, efc_size)
end

function H5Pset_evict_on_close(fapl_id, evict_on_close)
    ccall((:H5Pset_evict_on_close, libhdf5), herr_t, (hid_t, hbool_t), fapl_id, evict_on_close)
end

function H5Pset_family_offset(fapl_id, offset)
    ccall((:H5Pset_family_offset, libhdf5), herr_t, (hid_t, hsize_t), fapl_id, offset)
end

function H5Pset_fclose_degree(fapl_id, degree)
    ccall((:H5Pset_fclose_degree, libhdf5), herr_t, (hid_t, H5F_close_degree_t), fapl_id, degree)
end

function H5Pset_file_image(fapl_id, buf_ptr, buf_len)
    ccall((:H5Pset_file_image, libhdf5), herr_t, (hid_t, Ptr{Cvoid}, Csize_t), fapl_id, buf_ptr, buf_len)
end

function H5Pset_file_image_callbacks(fapl_id, callbacks_ptr)
    ccall((:H5Pset_file_image_callbacks, libhdf5), herr_t, (hid_t, Ptr{H5FD_file_image_callbacks_t}), fapl_id, callbacks_ptr)
end

function H5Pset_file_locking(fapl_id, use_file_locking, ignore_when_disabled)
    ccall((:H5Pset_file_locking, libhdf5), herr_t, (hid_t, hbool_t, hbool_t), fapl_id, use_file_locking, ignore_when_disabled)
end

function H5Pset_gc_references(fapl_id, gc_ref)
    ccall((:H5Pset_gc_references, libhdf5), herr_t, (hid_t, Cuint), fapl_id, gc_ref)
end

function H5Pset_libver_bounds(plist_id, low, high)
    ccall((:H5Pset_libver_bounds, libhdf5), herr_t, (hid_t, H5F_libver_t, H5F_libver_t), plist_id, low, high)
end

function H5Pset_mdc_config(plist_id, config_ptr)
    ccall((:H5Pset_mdc_config, libhdf5), herr_t, (hid_t, Ptr{H5AC_cache_config_t}), plist_id, config_ptr)
end

function H5Pset_mdc_log_options(plist_id, is_enabled, location, start_on_access)
    ccall((:H5Pset_mdc_log_options, libhdf5), herr_t, (hid_t, hbool_t, Ptr{Cchar}, hbool_t), plist_id, is_enabled, location, start_on_access)
end

function H5Pset_meta_block_size(fapl_id, size)
    ccall((:H5Pset_meta_block_size, libhdf5), herr_t, (hid_t, hsize_t), fapl_id, size)
end

function H5Pset_metadata_read_attempts(plist_id, attempts)
    ccall((:H5Pset_metadata_read_attempts, libhdf5), herr_t, (hid_t, Cuint), plist_id, attempts)
end

function H5Pset_multi_type(fapl_id, type)
    ccall((:H5Pset_multi_type, libhdf5), herr_t, (hid_t, H5FD_mem_t), fapl_id, type)
end

function H5Pset_object_flush_cb(plist_id, func, udata)
    ccall((:H5Pset_object_flush_cb, libhdf5), herr_t, (hid_t, H5F_flush_cb_t, Ptr{Cvoid}), plist_id, func, udata)
end

function H5Pset_sieve_buf_size(fapl_id, size)
    ccall((:H5Pset_sieve_buf_size, libhdf5), herr_t, (hid_t, Csize_t), fapl_id, size)
end

function H5Pset_small_data_block_size(fapl_id, size)
    ccall((:H5Pset_small_data_block_size, libhdf5), herr_t, (hid_t, hsize_t), fapl_id, size)
end

function H5Pset_vol(plist_id, new_vol_id, new_vol_info)
    ccall((:H5Pset_vol, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cvoid}), plist_id, new_vol_id, new_vol_info)
end

function H5Pset_mdc_image_config(plist_id, config_ptr)
    ccall((:H5Pset_mdc_image_config, libhdf5), herr_t, (hid_t, Ptr{H5AC_cache_image_config_t}), plist_id, config_ptr)
end

function H5Pset_page_buffer_size(plist_id, buf_size, min_meta_per, min_raw_per)
    ccall((:H5Pset_page_buffer_size, libhdf5), herr_t, (hid_t, Csize_t, Cuint, Cuint), plist_id, buf_size, min_meta_per, min_raw_per)
end

function H5Pfill_value_defined(plist, status)
    ccall((:H5Pfill_value_defined, libhdf5), herr_t, (hid_t, Ptr{H5D_fill_value_t}), plist, status)
end

function H5Pget_alloc_time(plist_id, alloc_time)
    ccall((:H5Pget_alloc_time, libhdf5), herr_t, (hid_t, Ptr{H5D_alloc_time_t}), plist_id, alloc_time)
end

function H5Pget_chunk(plist_id, max_ndims, dim)
    ccall((:H5Pget_chunk, libhdf5), Cint, (hid_t, Cint, Ptr{hsize_t}), plist_id, max_ndims, dim)
end

function H5Pget_chunk_opts(plist_id, opts)
    ccall((:H5Pget_chunk_opts, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, opts)
end

function H5Pget_dset_no_attrs_hint(dcpl_id, minimize)
    ccall((:H5Pget_dset_no_attrs_hint, libhdf5), herr_t, (hid_t, Ptr{hbool_t}), dcpl_id, minimize)
end

function H5Pget_external(plist_id, idx, name_size, name, offset, size)
    ccall((:H5Pget_external, libhdf5), herr_t, (hid_t, Cuint, Csize_t, Ptr{Cchar}, Ptr{off_t}, Ptr{hsize_t}), plist_id, idx, name_size, name, offset, size)
end

function H5Pget_external_count(plist_id)
    ccall((:H5Pget_external_count, libhdf5), Cint, (hid_t,), plist_id)
end

function H5Pget_fill_time(plist_id, fill_time)
    ccall((:H5Pget_fill_time, libhdf5), herr_t, (hid_t, Ptr{H5D_fill_time_t}), plist_id, fill_time)
end

function H5Pget_fill_value(plist_id, type_id, value)
    ccall((:H5Pget_fill_value, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cvoid}), plist_id, type_id, value)
end

function H5Pget_layout(plist_id)
    ccall((:H5Pget_layout, libhdf5), H5D_layout_t, (hid_t,), plist_id)
end

function H5Pget_virtual_count(dcpl_id, count)
    ccall((:H5Pget_virtual_count, libhdf5), herr_t, (hid_t, Ptr{Csize_t}), dcpl_id, count)
end

function H5Pget_virtual_dsetname(dcpl_id, index, name, size)
    ccall((:H5Pget_virtual_dsetname, libhdf5), Cssize_t, (hid_t, Csize_t, Ptr{Cchar}, Csize_t), dcpl_id, index, name, size)
end

function H5Pget_virtual_filename(dcpl_id, index, name, size)
    ccall((:H5Pget_virtual_filename, libhdf5), Cssize_t, (hid_t, Csize_t, Ptr{Cchar}, Csize_t), dcpl_id, index, name, size)
end

function H5Pget_virtual_srcspace(dcpl_id, index)
    ccall((:H5Pget_virtual_srcspace, libhdf5), hid_t, (hid_t, Csize_t), dcpl_id, index)
end

function H5Pget_virtual_vspace(dcpl_id, index)
    ccall((:H5Pget_virtual_vspace, libhdf5), hid_t, (hid_t, Csize_t), dcpl_id, index)
end

function H5Pset_alloc_time(plist_id, alloc_time)
    ccall((:H5Pset_alloc_time, libhdf5), herr_t, (hid_t, H5D_alloc_time_t), plist_id, alloc_time)
end

function H5Pset_chunk(plist_id, ndims, dim)
    ccall((:H5Pset_chunk, libhdf5), herr_t, (hid_t, Cint, Ptr{hsize_t}), plist_id, ndims, dim)
end

function H5Pset_chunk_opts(plist_id, opts)
    ccall((:H5Pset_chunk_opts, libhdf5), herr_t, (hid_t, Cuint), plist_id, opts)
end

function H5Pset_dset_no_attrs_hint(dcpl_id, minimize)
    ccall((:H5Pset_dset_no_attrs_hint, libhdf5), herr_t, (hid_t, hbool_t), dcpl_id, minimize)
end

function H5Pset_external(plist_id, name, offset, size)
    ccall((:H5Pset_external, libhdf5), herr_t, (hid_t, Ptr{Cchar}, off_t, hsize_t), plist_id, name, offset, size)
end

function H5Pset_fill_time(plist_id, fill_time)
    ccall((:H5Pset_fill_time, libhdf5), herr_t, (hid_t, H5D_fill_time_t), plist_id, fill_time)
end

function H5Pset_fill_value(plist_id, type_id, value)
    ccall((:H5Pset_fill_value, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cvoid}), plist_id, type_id, value)
end

function H5Pset_shuffle(plist_id)
    ccall((:H5Pset_shuffle, libhdf5), herr_t, (hid_t,), plist_id)
end

function H5Pset_layout(plist_id, layout)
    ccall((:H5Pset_layout, libhdf5), herr_t, (hid_t, H5D_layout_t), plist_id, layout)
end

function H5Pset_nbit(plist_id)
    ccall((:H5Pset_nbit, libhdf5), herr_t, (hid_t,), plist_id)
end

function H5Pset_scaleoffset(plist_id, scale_type, scale_factor)
    ccall((:H5Pset_scaleoffset, libhdf5), herr_t, (hid_t, H5Z_SO_scale_type_t, Cint), plist_id, scale_type, scale_factor)
end

function H5Pset_szip(plist_id, options_mask, pixels_per_block)
    ccall((:H5Pset_szip, libhdf5), herr_t, (hid_t, Cuint, Cuint), plist_id, options_mask, pixels_per_block)
end

function H5Pset_virtual(dcpl_id, vspace_id, src_file_name, src_dset_name, src_space_id)
    ccall((:H5Pset_virtual, libhdf5), herr_t, (hid_t, hid_t, Ptr{Cchar}, Ptr{Cchar}, hid_t), dcpl_id, vspace_id, src_file_name, src_dset_name, src_space_id)
end

function H5Pget_append_flush(dapl_id, dims, boundary, func, udata)
    ccall((:H5Pget_append_flush, libhdf5), herr_t, (hid_t, Cuint, Ptr{hsize_t}, Ptr{H5D_append_cb_t}, Ptr{Ptr{Cvoid}}), dapl_id, dims, boundary, func, udata)
end

function H5Pget_chunk_cache(dapl_id, rdcc_nslots, rdcc_nbytes, rdcc_w0)
    ccall((:H5Pget_chunk_cache, libhdf5), herr_t, (hid_t, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Cdouble}), dapl_id, rdcc_nslots, rdcc_nbytes, rdcc_w0)
end

function H5Pget_efile_prefix(dapl_id, prefix, size)
    ccall((:H5Pget_efile_prefix, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), dapl_id, prefix, size)
end

function H5Pget_virtual_prefix(dapl_id, prefix, size)
    ccall((:H5Pget_virtual_prefix, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), dapl_id, prefix, size)
end

function H5Pget_virtual_printf_gap(dapl_id, gap_size)
    ccall((:H5Pget_virtual_printf_gap, libhdf5), herr_t, (hid_t, Ptr{hsize_t}), dapl_id, gap_size)
end

function H5Pget_virtual_view(dapl_id, view)
    ccall((:H5Pget_virtual_view, libhdf5), herr_t, (hid_t, Ptr{H5D_vds_view_t}), dapl_id, view)
end

function H5Pset_append_flush(dapl_id, ndims, boundary, func, udata)
    ccall((:H5Pset_append_flush, libhdf5), herr_t, (hid_t, Cuint, Ptr{hsize_t}, H5D_append_cb_t, Ptr{Cvoid}), dapl_id, ndims, boundary, func, udata)
end

function H5Pset_chunk_cache(dapl_id, rdcc_nslots, rdcc_nbytes, rdcc_w0)
    ccall((:H5Pset_chunk_cache, libhdf5), herr_t, (hid_t, Csize_t, Csize_t, Cdouble), dapl_id, rdcc_nslots, rdcc_nbytes, rdcc_w0)
end

function H5Pset_efile_prefix(dapl_id, prefix)
    ccall((:H5Pset_efile_prefix, libhdf5), herr_t, (hid_t, Ptr{Cchar}), dapl_id, prefix)
end

function H5Pset_virtual_prefix(dapl_id, prefix)
    ccall((:H5Pset_virtual_prefix, libhdf5), herr_t, (hid_t, Ptr{Cchar}), dapl_id, prefix)
end

function H5Pset_virtual_printf_gap(dapl_id, gap_size)
    ccall((:H5Pset_virtual_printf_gap, libhdf5), herr_t, (hid_t, hsize_t), dapl_id, gap_size)
end

function H5Pset_virtual_view(dapl_id, view)
    ccall((:H5Pset_virtual_view, libhdf5), herr_t, (hid_t, H5D_vds_view_t), dapl_id, view)
end

function H5Pget_btree_ratios(plist_id, left, middle, right)
    ccall((:H5Pget_btree_ratios, libhdf5), herr_t, (hid_t, Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), plist_id, left, middle, right)
end

function H5Pget_buffer(plist_id, tconv, bkg)
    ccall((:H5Pget_buffer, libhdf5), Csize_t, (hid_t, Ptr{Ptr{Cvoid}}, Ptr{Ptr{Cvoid}}), plist_id, tconv, bkg)
end

function H5Pget_data_transform(plist_id, expression, size)
    ccall((:H5Pget_data_transform, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), plist_id, expression, size)
end

function H5Pget_edc_check(plist_id)
    ccall((:H5Pget_edc_check, libhdf5), H5Z_EDC_t, (hid_t,), plist_id)
end

function H5Pget_hyper_vector_size(fapl_id, size)
    ccall((:H5Pget_hyper_vector_size, libhdf5), herr_t, (hid_t, Ptr{Csize_t}), fapl_id, size)
end

function H5Pget_preserve(plist_id)
    ccall((:H5Pget_preserve, libhdf5), Cint, (hid_t,), plist_id)
end

function H5Pget_type_conv_cb(dxpl_id, op, operate_data)
    ccall((:H5Pget_type_conv_cb, libhdf5), herr_t, (hid_t, Ptr{H5T_conv_except_func_t}, Ptr{Ptr{Cvoid}}), dxpl_id, op, operate_data)
end

function H5Pget_vlen_mem_manager(plist_id, alloc_func, alloc_info, free_func, free_info)
    ccall((:H5Pget_vlen_mem_manager, libhdf5), herr_t, (hid_t, Ptr{H5MM_allocate_t}, Ptr{Ptr{Cvoid}}, Ptr{H5MM_free_t}, Ptr{Ptr{Cvoid}}), plist_id, alloc_func, alloc_info, free_func, free_info)
end

function H5Pset_btree_ratios(plist_id, left, middle, right)
    ccall((:H5Pset_btree_ratios, libhdf5), herr_t, (hid_t, Cdouble, Cdouble, Cdouble), plist_id, left, middle, right)
end

function H5Pset_buffer(plist_id, size, tconv, bkg)
    ccall((:H5Pset_buffer, libhdf5), herr_t, (hid_t, Csize_t, Ptr{Cvoid}, Ptr{Cvoid}), plist_id, size, tconv, bkg)
end

function H5Pset_data_transform(plist_id, expression)
    ccall((:H5Pset_data_transform, libhdf5), herr_t, (hid_t, Ptr{Cchar}), plist_id, expression)
end

function H5Pset_edc_check(plist_id, check)
    ccall((:H5Pset_edc_check, libhdf5), herr_t, (hid_t, H5Z_EDC_t), plist_id, check)
end

function H5Pset_filter_callback(plist_id, func, op_data)
    ccall((:H5Pset_filter_callback, libhdf5), herr_t, (hid_t, H5Z_filter_func_t, Ptr{Cvoid}), plist_id, func, op_data)
end

function H5Pset_hyper_vector_size(plist_id, size)
    ccall((:H5Pset_hyper_vector_size, libhdf5), herr_t, (hid_t, Csize_t), plist_id, size)
end

function H5Pset_preserve(plist_id, status)
    ccall((:H5Pset_preserve, libhdf5), herr_t, (hid_t, hbool_t), plist_id, status)
end

function H5Pset_type_conv_cb(dxpl_id, op, operate_data)
    ccall((:H5Pset_type_conv_cb, libhdf5), herr_t, (hid_t, H5T_conv_except_func_t, Ptr{Cvoid}), dxpl_id, op, operate_data)
end

function H5Pset_vlen_mem_manager(plist_id, alloc_func, alloc_info, free_func, free_info)
    ccall((:H5Pset_vlen_mem_manager, libhdf5), herr_t, (hid_t, H5MM_allocate_t, Ptr{Cvoid}, H5MM_free_t, Ptr{Cvoid}), plist_id, alloc_func, alloc_info, free_func, free_info)
end

function H5Pget_create_intermediate_group(plist_id, crt_intmd)
    ccall((:H5Pget_create_intermediate_group, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, crt_intmd)
end

function H5Pset_create_intermediate_group(plist_id, crt_intmd)
    ccall((:H5Pset_create_intermediate_group, libhdf5), herr_t, (hid_t, Cuint), plist_id, crt_intmd)
end

function H5Pget_est_link_info(plist_id, est_num_entries, est_name_len)
    ccall((:H5Pget_est_link_info, libhdf5), herr_t, (hid_t, Ptr{Cuint}, Ptr{Cuint}), plist_id, est_num_entries, est_name_len)
end

function H5Pget_link_creation_order(plist_id, crt_order_flags)
    ccall((:H5Pget_link_creation_order, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, crt_order_flags)
end

function H5Pget_link_phase_change(plist_id, max_compact, min_dense)
    ccall((:H5Pget_link_phase_change, libhdf5), herr_t, (hid_t, Ptr{Cuint}, Ptr{Cuint}), plist_id, max_compact, min_dense)
end

function H5Pget_local_heap_size_hint(plist_id, size_hint)
    ccall((:H5Pget_local_heap_size_hint, libhdf5), herr_t, (hid_t, Ptr{Csize_t}), plist_id, size_hint)
end

function H5Pset_est_link_info(plist_id, est_num_entries, est_name_len)
    ccall((:H5Pset_est_link_info, libhdf5), herr_t, (hid_t, Cuint, Cuint), plist_id, est_num_entries, est_name_len)
end

function H5Pset_link_creation_order(plist_id, crt_order_flags)
    ccall((:H5Pset_link_creation_order, libhdf5), herr_t, (hid_t, Cuint), plist_id, crt_order_flags)
end

function H5Pset_link_phase_change(plist_id, max_compact, min_dense)
    ccall((:H5Pset_link_phase_change, libhdf5), herr_t, (hid_t, Cuint, Cuint), plist_id, max_compact, min_dense)
end

function H5Pset_local_heap_size_hint(plist_id, size_hint)
    ccall((:H5Pset_local_heap_size_hint, libhdf5), herr_t, (hid_t, Csize_t), plist_id, size_hint)
end

function H5Pget_char_encoding(plist_id, encoding)
    ccall((:H5Pget_char_encoding, libhdf5), herr_t, (hid_t, Ptr{H5T_cset_t}), plist_id, encoding)
end

function H5Pset_char_encoding(plist_id, encoding)
    ccall((:H5Pset_char_encoding, libhdf5), herr_t, (hid_t, H5T_cset_t), plist_id, encoding)
end

function H5Pget_elink_acc_flags(lapl_id, flags)
    ccall((:H5Pget_elink_acc_flags, libhdf5), herr_t, (hid_t, Ptr{Cuint}), lapl_id, flags)
end

function H5Pget_elink_cb(lapl_id, func, op_data)
    ccall((:H5Pget_elink_cb, libhdf5), herr_t, (hid_t, Ptr{H5L_elink_traverse_t}, Ptr{Ptr{Cvoid}}), lapl_id, func, op_data)
end

function H5Pget_elink_fapl(lapl_id)
    ccall((:H5Pget_elink_fapl, libhdf5), hid_t, (hid_t,), lapl_id)
end

function H5Pget_elink_prefix(plist_id, prefix, size)
    ccall((:H5Pget_elink_prefix, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), plist_id, prefix, size)
end

function H5Pget_nlinks(plist_id, nlinks)
    ccall((:H5Pget_nlinks, libhdf5), herr_t, (hid_t, Ptr{Csize_t}), plist_id, nlinks)
end

function H5Pset_elink_acc_flags(lapl_id, flags)
    ccall((:H5Pset_elink_acc_flags, libhdf5), herr_t, (hid_t, Cuint), lapl_id, flags)
end

function H5Pset_elink_cb(lapl_id, func, op_data)
    ccall((:H5Pset_elink_cb, libhdf5), herr_t, (hid_t, H5L_elink_traverse_t, Ptr{Cvoid}), lapl_id, func, op_data)
end

function H5Pset_elink_fapl(lapl_id, fapl_id)
    ccall((:H5Pset_elink_fapl, libhdf5), herr_t, (hid_t, hid_t), lapl_id, fapl_id)
end

function H5Pset_elink_prefix(plist_id, prefix)
    ccall((:H5Pset_elink_prefix, libhdf5), herr_t, (hid_t, Ptr{Cchar}), plist_id, prefix)
end

function H5Pset_nlinks(plist_id, nlinks)
    ccall((:H5Pset_nlinks, libhdf5), herr_t, (hid_t, Csize_t), plist_id, nlinks)
end

function H5Padd_merge_committed_dtype_path(plist_id, path)
    ccall((:H5Padd_merge_committed_dtype_path, libhdf5), herr_t, (hid_t, Ptr{Cchar}), plist_id, path)
end

function H5Pfree_merge_committed_dtype_paths(plist_id)
    ccall((:H5Pfree_merge_committed_dtype_paths, libhdf5), herr_t, (hid_t,), plist_id)
end

function H5Pget_copy_object(plist_id, copy_options)
    ccall((:H5Pget_copy_object, libhdf5), herr_t, (hid_t, Ptr{Cuint}), plist_id, copy_options)
end

function H5Pget_mcdt_search_cb(plist_id, func, op_data)
    ccall((:H5Pget_mcdt_search_cb, libhdf5), herr_t, (hid_t, Ptr{H5O_mcdt_search_cb_t}, Ptr{Ptr{Cvoid}}), plist_id, func, op_data)
end

function H5Pset_copy_object(plist_id, copy_options)
    ccall((:H5Pset_copy_object, libhdf5), herr_t, (hid_t, Cuint), plist_id, copy_options)
end

function H5Pset_mcdt_search_cb(plist_id, func, op_data)
    ccall((:H5Pset_mcdt_search_cb, libhdf5), herr_t, (hid_t, H5O_mcdt_search_cb_t, Ptr{Cvoid}), plist_id, func, op_data)
end

function H5Pregister1(cls_id, name, size, def_value, prp_create, prp_set, prp_get, prp_del, prp_copy, prp_close)
    ccall((:H5Pregister1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Csize_t, Ptr{Cvoid}, H5P_prp_create_func_t, H5P_prp_set_func_t, H5P_prp_get_func_t, H5P_prp_delete_func_t, H5P_prp_copy_func_t, H5P_prp_close_func_t), cls_id, name, size, def_value, prp_create, prp_set, prp_get, prp_del, prp_copy, prp_close)
end

function H5Pinsert1(plist_id, name, size, value, prp_set, prp_get, prp_delete, prp_copy, prp_close)
    ccall((:H5Pinsert1, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Csize_t, Ptr{Cvoid}, H5P_prp_set_func_t, H5P_prp_get_func_t, H5P_prp_delete_func_t, H5P_prp_copy_func_t, H5P_prp_close_func_t), plist_id, name, size, value, prp_set, prp_get, prp_delete, prp_copy, prp_close)
end

function H5Pencode1(plist_id, buf, nalloc)
    ccall((:H5Pencode1, libhdf5), herr_t, (hid_t, Ptr{Cvoid}, Ptr{Csize_t}), plist_id, buf, nalloc)
end

function H5Pget_filter1(plist_id, filter, flags, cd_nelmts, cd_values, namelen, name)
    ccall((:H5Pget_filter1, libhdf5), H5Z_filter_t, (hid_t, Cuint, Ptr{Cuint}, Ptr{Csize_t}, Ptr{Cuint}, Csize_t, Ptr{Cchar}), plist_id, filter, flags, cd_nelmts, cd_values, namelen, name)
end

function H5Pget_filter_by_id1(plist_id, id, flags, cd_nelmts, cd_values, namelen, name)
    ccall((:H5Pget_filter_by_id1, libhdf5), herr_t, (hid_t, H5Z_filter_t, Ptr{Cuint}, Ptr{Csize_t}, Ptr{Cuint}, Csize_t, Ptr{Cchar}), plist_id, id, flags, cd_nelmts, cd_values, namelen, name)
end

function H5Pget_version(plist_id, boot, freelist, stab, shhdr)
    ccall((:H5Pget_version, libhdf5), herr_t, (hid_t, Ptr{Cuint}, Ptr{Cuint}, Ptr{Cuint}, Ptr{Cuint}), plist_id, boot, freelist, stab, shhdr)
end

function H5Pset_file_space(plist_id, strategy, threshold)
    ccall((:H5Pset_file_space, libhdf5), herr_t, (hid_t, H5F_file_space_type_t, hsize_t), plist_id, strategy, threshold)
end

function H5Pget_file_space(plist_id, strategy, threshold)
    ccall((:H5Pget_file_space, libhdf5), herr_t, (hid_t, Ptr{H5F_file_space_type_t}, Ptr{hsize_t}), plist_id, strategy, threshold)
end

@cenum H5PL_type_t::Int32 begin
    H5PL_TYPE_ERROR = -1
    H5PL_TYPE_FILTER = 0
    H5PL_TYPE_VOL = 1
    H5PL_TYPE_NONE = 2
end

function H5PLset_loading_state(plugin_control_mask)
    ccall((:H5PLset_loading_state, libhdf5), herr_t, (Cuint,), plugin_control_mask)
end

function H5PLget_loading_state(plugin_control_mask)
    ccall((:H5PLget_loading_state, libhdf5), herr_t, (Ptr{Cuint},), plugin_control_mask)
end

function H5PLappend(search_path)
    ccall((:H5PLappend, libhdf5), herr_t, (Ptr{Cchar},), search_path)
end

function H5PLprepend(search_path)
    ccall((:H5PLprepend, libhdf5), herr_t, (Ptr{Cchar},), search_path)
end

function H5PLreplace(search_path, index)
    ccall((:H5PLreplace, libhdf5), herr_t, (Ptr{Cchar}, Cuint), search_path, index)
end

function H5PLinsert(search_path, index)
    ccall((:H5PLinsert, libhdf5), herr_t, (Ptr{Cchar}, Cuint), search_path, index)
end

function H5PLremove(index)
    ccall((:H5PLremove, libhdf5), herr_t, (Cuint,), index)
end

function H5PLget(index, path_buf, buf_size)
    ccall((:H5PLget, libhdf5), Cssize_t, (Cuint, Ptr{Cchar}, Csize_t), index, path_buf, buf_size)
end

function H5PLsize(num_paths)
    ccall((:H5PLsize, libhdf5), herr_t, (Ptr{Cuint},), num_paths)
end

const hobj_ref_t = haddr_t

struct hdset_reg_ref_t
    __data::NTuple{12, UInt8}
end

struct var"##Ctag#295"
    data::NTuple{64, UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#295"}, f::Symbol)
    f === :__data && return Ptr{NTuple{64, UInt8}}(x + 0)
    f === :align && return Ptr{Int64}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#295", f::Symbol)
    r = Ref{var"##Ctag#295"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#295"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#295"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct H5R_ref_t
    u::var"##Ctag#295"
end

function H5Rcreate_object(loc_id, name, oapl_id, ref_ptr)
    ccall((:H5Rcreate_object, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, Ptr{H5R_ref_t}), loc_id, name, oapl_id, ref_ptr)
end

function H5Rcreate_region(loc_id, name, space_id, oapl_id, ref_ptr)
    ccall((:H5Rcreate_region, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, hid_t, Ptr{H5R_ref_t}), loc_id, name, space_id, oapl_id, ref_ptr)
end

function H5Rcreate_attr(loc_id, name, attr_name, oapl_id, ref_ptr)
    ccall((:H5Rcreate_attr, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Ptr{Cchar}, hid_t, Ptr{H5R_ref_t}), loc_id, name, attr_name, oapl_id, ref_ptr)
end

function H5Rdestroy(ref_ptr)
    ccall((:H5Rdestroy, libhdf5), herr_t, (Ptr{H5R_ref_t},), ref_ptr)
end

function H5Rget_type(ref_ptr)
    ccall((:H5Rget_type, libhdf5), H5R_type_t, (Ptr{H5R_ref_t},), ref_ptr)
end

function H5Requal(ref1_ptr, ref2_ptr)
    ccall((:H5Requal, libhdf5), htri_t, (Ptr{H5R_ref_t}, Ptr{H5R_ref_t}), ref1_ptr, ref2_ptr)
end

function H5Rcopy(src_ref_ptr, dst_ref_ptr)
    ccall((:H5Rcopy, libhdf5), herr_t, (Ptr{H5R_ref_t}, Ptr{H5R_ref_t}), src_ref_ptr, dst_ref_ptr)
end

function H5Ropen_object(ref_ptr, rapl_id, oapl_id)
    ccall((:H5Ropen_object, libhdf5), hid_t, (Ptr{H5R_ref_t}, hid_t, hid_t), ref_ptr, rapl_id, oapl_id)
end

function H5Ropen_region(ref_ptr, rapl_id, oapl_id)
    ccall((:H5Ropen_region, libhdf5), hid_t, (Ptr{H5R_ref_t}, hid_t, hid_t), ref_ptr, rapl_id, oapl_id)
end

function H5Ropen_attr(ref_ptr, rapl_id, aapl_id)
    ccall((:H5Ropen_attr, libhdf5), hid_t, (Ptr{H5R_ref_t}, hid_t, hid_t), ref_ptr, rapl_id, aapl_id)
end

function H5Rget_obj_type3(ref_ptr, rapl_id, obj_type)
    ccall((:H5Rget_obj_type3, libhdf5), herr_t, (Ptr{H5R_ref_t}, hid_t, Ptr{H5O_type_t}), ref_ptr, rapl_id, obj_type)
end

function H5Rget_file_name(ref_ptr, name, size)
    ccall((:H5Rget_file_name, libhdf5), Cssize_t, (Ptr{H5R_ref_t}, Ptr{Cchar}, Csize_t), ref_ptr, name, size)
end

function H5Rget_obj_name(ref_ptr, rapl_id, name, size)
    ccall((:H5Rget_obj_name, libhdf5), Cssize_t, (Ptr{H5R_ref_t}, hid_t, Ptr{Cchar}, Csize_t), ref_ptr, rapl_id, name, size)
end

function H5Rget_attr_name(ref_ptr, name, size)
    ccall((:H5Rget_attr_name, libhdf5), Cssize_t, (Ptr{H5R_ref_t}, Ptr{Cchar}, Csize_t), ref_ptr, name, size)
end

function H5Rget_obj_type1(id, ref_type, ref)
    ccall((:H5Rget_obj_type1, libhdf5), H5G_obj_t, (hid_t, H5R_type_t, Ptr{Cvoid}), id, ref_type, ref)
end

function H5Rdereference1(obj_id, ref_type, ref)
    ccall((:H5Rdereference1, libhdf5), hid_t, (hid_t, H5R_type_t, Ptr{Cvoid}), obj_id, ref_type, ref)
end

function H5Rcreate(ref, loc_id, name, ref_type, space_id)
    ccall((:H5Rcreate, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, Ptr{Cchar}, H5R_type_t, hid_t), ref, loc_id, name, ref_type, space_id)
end

function H5Rget_region(dataset, ref_type, ref)
    ccall((:H5Rget_region, libhdf5), hid_t, (hid_t, H5R_type_t, Ptr{Cvoid}), dataset, ref_type, ref)
end

function H5Rget_name(loc_id, ref_type, ref, name, size)
    ccall((:H5Rget_name, libhdf5), Cssize_t, (hid_t, H5R_type_t, Ptr{Cvoid}, Ptr{Cchar}, Csize_t), loc_id, ref_type, ref, name, size)
end

@cenum H5S_class_t::Int32 begin
    H5S_NO_CLASS = -1
    H5S_SCALAR = 0
    H5S_SIMPLE = 1
    H5S_NULL = 2
end

@cenum H5S_seloper_t::Int32 begin
    H5S_SELECT_NOOP = -1
    H5S_SELECT_SET = 0
    H5S_SELECT_OR = 1
    H5S_SELECT_AND = 2
    H5S_SELECT_XOR = 3
    H5S_SELECT_NOTB = 4
    H5S_SELECT_NOTA = 5
    H5S_SELECT_APPEND = 6
    H5S_SELECT_PREPEND = 7
    H5S_SELECT_INVALID = 8
end

@cenum H5S_sel_type::Int32 begin
    H5S_SEL_ERROR = -1
    H5S_SEL_NONE = 0
    H5S_SEL_POINTS = 1
    H5S_SEL_HYPERSLABS = 2
    H5S_SEL_ALL = 3
    H5S_SEL_N = 4
end

function H5Sclose(space_id)
    ccall((:H5Sclose, libhdf5), herr_t, (hid_t,), space_id)
end

function H5Scombine_hyperslab(space_id, op, start, stride, count, block)
    ccall((:H5Scombine_hyperslab, libhdf5), hid_t, (hid_t, H5S_seloper_t, Ptr{hsize_t}, Ptr{hsize_t}, Ptr{hsize_t}, Ptr{hsize_t}), space_id, op, start, stride, count, block)
end

function H5Scombine_select(space1_id, op, space2_id)
    ccall((:H5Scombine_select, libhdf5), hid_t, (hid_t, H5S_seloper_t, hid_t), space1_id, op, space2_id)
end

function H5Scopy(space_id)
    ccall((:H5Scopy, libhdf5), hid_t, (hid_t,), space_id)
end

function H5Screate(type)
    ccall((:H5Screate, libhdf5), hid_t, (H5S_class_t,), type)
end

function H5Screate_simple(rank, dims, maxdims)
    ccall((:H5Screate_simple, libhdf5), hid_t, (Cint, Ptr{hsize_t}, Ptr{hsize_t}), rank, dims, maxdims)
end

function H5Sdecode(buf)
    ccall((:H5Sdecode, libhdf5), hid_t, (Ptr{Cvoid},), buf)
end

function H5Sextent_copy(dst_id, src_id)
    ccall((:H5Sextent_copy, libhdf5), herr_t, (hid_t, hid_t), dst_id, src_id)
end

function H5Sextent_equal(space1_id, space2_id)
    ccall((:H5Sextent_equal, libhdf5), htri_t, (hid_t, hid_t), space1_id, space2_id)
end

function H5Sget_regular_hyperslab(spaceid, start, stride, count, block)
    ccall((:H5Sget_regular_hyperslab, libhdf5), htri_t, (hid_t, Ptr{hsize_t}, Ptr{hsize_t}, Ptr{hsize_t}, Ptr{hsize_t}), spaceid, start, stride, count, block)
end

function H5Sget_select_bounds(spaceid, start, _end)
    ccall((:H5Sget_select_bounds, libhdf5), herr_t, (hid_t, Ptr{hsize_t}, Ptr{hsize_t}), spaceid, start, _end)
end

function H5Sget_select_elem_npoints(spaceid)
    ccall((:H5Sget_select_elem_npoints, libhdf5), hssize_t, (hid_t,), spaceid)
end

function H5Sget_select_elem_pointlist(spaceid, startpoint, numpoints, buf)
    ccall((:H5Sget_select_elem_pointlist, libhdf5), herr_t, (hid_t, hsize_t, hsize_t, Ptr{hsize_t}), spaceid, startpoint, numpoints, buf)
end

function H5Sget_select_hyper_blocklist(spaceid, startblock, numblocks, buf)
    ccall((:H5Sget_select_hyper_blocklist, libhdf5), herr_t, (hid_t, hsize_t, hsize_t, Ptr{hsize_t}), spaceid, startblock, numblocks, buf)
end

function H5Sget_select_hyper_nblocks(spaceid)
    ccall((:H5Sget_select_hyper_nblocks, libhdf5), hssize_t, (hid_t,), spaceid)
end

function H5Sget_select_npoints(spaceid)
    ccall((:H5Sget_select_npoints, libhdf5), hssize_t, (hid_t,), spaceid)
end

function H5Sget_select_type(spaceid)
    ccall((:H5Sget_select_type, libhdf5), H5S_sel_type, (hid_t,), spaceid)
end

function H5Sget_simple_extent_dims(space_id, dims, maxdims)
    ccall((:H5Sget_simple_extent_dims, libhdf5), Cint, (hid_t, Ptr{hsize_t}, Ptr{hsize_t}), space_id, dims, maxdims)
end

function H5Sget_simple_extent_ndims(space_id)
    ccall((:H5Sget_simple_extent_ndims, libhdf5), Cint, (hid_t,), space_id)
end

function H5Sget_simple_extent_npoints(space_id)
    ccall((:H5Sget_simple_extent_npoints, libhdf5), hssize_t, (hid_t,), space_id)
end

function H5Sget_simple_extent_type(space_id)
    ccall((:H5Sget_simple_extent_type, libhdf5), H5S_class_t, (hid_t,), space_id)
end

function H5Sis_regular_hyperslab(spaceid)
    ccall((:H5Sis_regular_hyperslab, libhdf5), htri_t, (hid_t,), spaceid)
end

function H5Sis_simple(space_id)
    ccall((:H5Sis_simple, libhdf5), htri_t, (hid_t,), space_id)
end

function H5Smodify_select(space1_id, op, space2_id)
    ccall((:H5Smodify_select, libhdf5), herr_t, (hid_t, H5S_seloper_t, hid_t), space1_id, op, space2_id)
end

function H5Soffset_simple(space_id, offset)
    ccall((:H5Soffset_simple, libhdf5), herr_t, (hid_t, Ptr{hssize_t}), space_id, offset)
end

function H5Ssel_iter_close(sel_iter_id)
    ccall((:H5Ssel_iter_close, libhdf5), herr_t, (hid_t,), sel_iter_id)
end

function H5Ssel_iter_create(spaceid, elmt_size, flags)
    ccall((:H5Ssel_iter_create, libhdf5), hid_t, (hid_t, Csize_t, Cuint), spaceid, elmt_size, flags)
end

function H5Ssel_iter_get_seq_list(sel_iter_id, maxseq, maxbytes, nseq, nbytes, off, len)
    ccall((:H5Ssel_iter_get_seq_list, libhdf5), herr_t, (hid_t, Csize_t, Csize_t, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{hsize_t}, Ptr{Csize_t}), sel_iter_id, maxseq, maxbytes, nseq, nbytes, off, len)
end

function H5Ssel_iter_reset(sel_iter_id, space_id)
    ccall((:H5Ssel_iter_reset, libhdf5), herr_t, (hid_t, hid_t), sel_iter_id, space_id)
end

function H5Sselect_adjust(spaceid, offset)
    ccall((:H5Sselect_adjust, libhdf5), herr_t, (hid_t, Ptr{hssize_t}), spaceid, offset)
end

function H5Sselect_all(spaceid)
    ccall((:H5Sselect_all, libhdf5), herr_t, (hid_t,), spaceid)
end

function H5Sselect_copy(dst_id, src_id)
    ccall((:H5Sselect_copy, libhdf5), herr_t, (hid_t, hid_t), dst_id, src_id)
end

function H5Sselect_elements(space_id, op, num_elem, coord)
    ccall((:H5Sselect_elements, libhdf5), herr_t, (hid_t, H5S_seloper_t, Csize_t, Ptr{hsize_t}), space_id, op, num_elem, coord)
end

function H5Sselect_hyperslab(space_id, op, start, stride, count, block)
    ccall((:H5Sselect_hyperslab, libhdf5), herr_t, (hid_t, H5S_seloper_t, Ptr{hsize_t}, Ptr{hsize_t}, Ptr{hsize_t}, Ptr{hsize_t}), space_id, op, start, stride, count, block)
end

function H5Sselect_intersect_block(space_id, start, _end)
    ccall((:H5Sselect_intersect_block, libhdf5), htri_t, (hid_t, Ptr{hsize_t}, Ptr{hsize_t}), space_id, start, _end)
end

function H5Sselect_none(spaceid)
    ccall((:H5Sselect_none, libhdf5), herr_t, (hid_t,), spaceid)
end

function H5Sselect_project_intersection(src_space_id, dst_space_id, src_intersect_space_id)
    ccall((:H5Sselect_project_intersection, libhdf5), hid_t, (hid_t, hid_t, hid_t), src_space_id, dst_space_id, src_intersect_space_id)
end

function H5Sselect_shape_same(space1_id, space2_id)
    ccall((:H5Sselect_shape_same, libhdf5), htri_t, (hid_t, hid_t), space1_id, space2_id)
end

function H5Sselect_valid(spaceid)
    ccall((:H5Sselect_valid, libhdf5), htri_t, (hid_t,), spaceid)
end

function H5Sset_extent_none(space_id)
    ccall((:H5Sset_extent_none, libhdf5), herr_t, (hid_t,), space_id)
end

function H5Sset_extent_simple(space_id, rank, dims, max)
    ccall((:H5Sset_extent_simple, libhdf5), herr_t, (hid_t, Cint, Ptr{hsize_t}, Ptr{hsize_t}), space_id, rank, dims, max)
end

function H5Sencode1(obj_id, buf, nalloc)
    ccall((:H5Sencode1, libhdf5), herr_t, (hid_t, Ptr{Cvoid}, Ptr{Csize_t}), obj_id, buf, nalloc)
end

const H5VL_class_value_t = Cint

@cenum H5VL_subclass_t::UInt32 begin
    H5VL_SUBCLS_NONE = 0
    H5VL_SUBCLS_INFO = 1
    H5VL_SUBCLS_WRAP = 2
    H5VL_SUBCLS_ATTR = 3
    H5VL_SUBCLS_DATASET = 4
    H5VL_SUBCLS_DATATYPE = 5
    H5VL_SUBCLS_FILE = 6
    H5VL_SUBCLS_GROUP = 7
    H5VL_SUBCLS_LINK = 8
    H5VL_SUBCLS_OBJECT = 9
    H5VL_SUBCLS_REQUEST = 10
    H5VL_SUBCLS_BLOB = 11
    H5VL_SUBCLS_TOKEN = 12
end

function H5VLregister_connector_by_name(connector_name, vipl_id)
    ccall((:H5VLregister_connector_by_name, libhdf5), hid_t, (Ptr{Cchar}, hid_t), connector_name, vipl_id)
end

function H5VLregister_connector_by_value(connector_value, vipl_id)
    ccall((:H5VLregister_connector_by_value, libhdf5), hid_t, (H5VL_class_value_t, hid_t), connector_value, vipl_id)
end

function H5VLis_connector_registered_by_name(name)
    ccall((:H5VLis_connector_registered_by_name, libhdf5), htri_t, (Ptr{Cchar},), name)
end

function H5VLis_connector_registered_by_value(connector_value)
    ccall((:H5VLis_connector_registered_by_value, libhdf5), htri_t, (H5VL_class_value_t,), connector_value)
end

function H5VLget_connector_id(obj_id)
    ccall((:H5VLget_connector_id, libhdf5), hid_t, (hid_t,), obj_id)
end

function H5VLget_connector_id_by_name(name)
    ccall((:H5VLget_connector_id_by_name, libhdf5), hid_t, (Ptr{Cchar},), name)
end

function H5VLget_connector_id_by_value(connector_value)
    ccall((:H5VLget_connector_id_by_value, libhdf5), hid_t, (H5VL_class_value_t,), connector_value)
end

function H5VLget_connector_name(id, name, size)
    ccall((:H5VLget_connector_name, libhdf5), Cssize_t, (hid_t, Ptr{Cchar}, Csize_t), id, name, size)
end

function H5VLclose(connector_id)
    ccall((:H5VLclose, libhdf5), herr_t, (hid_t,), connector_id)
end

function H5VLunregister_connector(connector_id)
    ccall((:H5VLunregister_connector, libhdf5), herr_t, (hid_t,), connector_id)
end

function H5VLquery_optional(obj_id, subcls, opt_type, supported)
    ccall((:H5VLquery_optional, libhdf5), herr_t, (hid_t, H5VL_subclass_t, Cint, Ptr{hbool_t}), obj_id, subcls, opt_type, supported)
end

@cenum H5ES_status_t::UInt32 begin
    H5ES_STATUS_IN_PROGRESS = 0
    H5ES_STATUS_SUCCEED = 1
    H5ES_STATUS_FAIL = 2
    H5ES_STATUS_CANCELED = 3
end

@cenum H5VL_attr_get_t::UInt32 begin
    H5VL_ATTR_GET_ACPL = 0
    H5VL_ATTR_GET_INFO = 1
    H5VL_ATTR_GET_NAME = 2
    H5VL_ATTR_GET_SPACE = 3
    H5VL_ATTR_GET_STORAGE_SIZE = 4
    H5VL_ATTR_GET_TYPE = 5
end

@cenum H5VL_attr_specific_t::UInt32 begin
    H5VL_ATTR_DELETE = 0
    H5VL_ATTR_EXISTS = 1
    H5VL_ATTR_ITER = 2
    H5VL_ATTR_RENAME = 3
end

const H5VL_attr_optional_t = Cint

@cenum H5VL_dataset_get_t::UInt32 begin
    H5VL_DATASET_GET_DAPL = 0
    H5VL_DATASET_GET_DCPL = 1
    H5VL_DATASET_GET_SPACE = 2
    H5VL_DATASET_GET_SPACE_STATUS = 3
    H5VL_DATASET_GET_STORAGE_SIZE = 4
    H5VL_DATASET_GET_TYPE = 5
end

@cenum H5VL_dataset_specific_t::UInt32 begin
    H5VL_DATASET_SET_EXTENT = 0
    H5VL_DATASET_FLUSH = 1
    H5VL_DATASET_REFRESH = 2
end

const H5VL_dataset_optional_t = Cint

@cenum H5VL_datatype_get_t::UInt32 begin
    H5VL_DATATYPE_GET_BINARY = 0
    H5VL_DATATYPE_GET_TCPL = 1
end

@cenum H5VL_datatype_specific_t::UInt32 begin
    H5VL_DATATYPE_FLUSH = 0
    H5VL_DATATYPE_REFRESH = 1
end

const H5VL_datatype_optional_t = Cint

@cenum H5VL_file_get_t::UInt32 begin
    H5VL_FILE_GET_CONT_INFO = 0
    H5VL_FILE_GET_FAPL = 1
    H5VL_FILE_GET_FCPL = 2
    H5VL_FILE_GET_FILENO = 3
    H5VL_FILE_GET_INTENT = 4
    H5VL_FILE_GET_NAME = 5
    H5VL_FILE_GET_OBJ_COUNT = 6
    H5VL_FILE_GET_OBJ_IDS = 7
end

@cenum H5VL_file_specific_t::UInt32 begin
    H5VL_FILE_FLUSH = 0
    H5VL_FILE_REOPEN = 1
    H5VL_FILE_MOUNT = 2
    H5VL_FILE_UNMOUNT = 3
    H5VL_FILE_IS_ACCESSIBLE = 4
    H5VL_FILE_DELETE = 5
    H5VL_FILE_IS_EQUAL = 6
end

const H5VL_file_optional_t = Cint

@cenum H5VL_group_get_t::UInt32 begin
    H5VL_GROUP_GET_GCPL = 0
    H5VL_GROUP_GET_INFO = 1
end

@cenum H5VL_group_specific_t::UInt32 begin
    H5VL_GROUP_FLUSH = 0
    H5VL_GROUP_REFRESH = 1
end

const H5VL_group_optional_t = Cint

@cenum H5VL_link_create_type_t::UInt32 begin
    H5VL_LINK_CREATE_HARD = 0
    H5VL_LINK_CREATE_SOFT = 1
    H5VL_LINK_CREATE_UD = 2
end

@cenum H5VL_link_get_t::UInt32 begin
    H5VL_LINK_GET_INFO = 0
    H5VL_LINK_GET_NAME = 1
    H5VL_LINK_GET_VAL = 2
end

@cenum H5VL_link_specific_t::UInt32 begin
    H5VL_LINK_DELETE = 0
    H5VL_LINK_EXISTS = 1
    H5VL_LINK_ITER = 2
end

const H5VL_link_optional_t = Cint

@cenum H5VL_object_get_t::UInt32 begin
    H5VL_OBJECT_GET_FILE = 0
    H5VL_OBJECT_GET_NAME = 1
    H5VL_OBJECT_GET_TYPE = 2
    H5VL_OBJECT_GET_INFO = 3
end

@cenum H5VL_object_specific_t::UInt32 begin
    H5VL_OBJECT_CHANGE_REF_COUNT = 0
    H5VL_OBJECT_EXISTS = 1
    H5VL_OBJECT_LOOKUP = 2
    H5VL_OBJECT_VISIT = 3
    H5VL_OBJECT_FLUSH = 4
    H5VL_OBJECT_REFRESH = 5
end

const H5VL_object_optional_t = Cint

@cenum H5VL_request_specific_t::UInt32 begin
    H5VL_REQUEST_WAITANY = 0
    H5VL_REQUEST_WAITSOME = 1
    H5VL_REQUEST_WAITALL = 2
end

const H5VL_request_optional_t = Cint

@cenum H5VL_blob_specific_t::UInt32 begin
    H5VL_BLOB_DELETE = 0
    H5VL_BLOB_GETSIZE = 1
    H5VL_BLOB_ISNULL = 2
    H5VL_BLOB_SETNULL = 3
end

const H5VL_blob_optional_t = Cint

@cenum H5VL_loc_type_t::UInt32 begin
    H5VL_OBJECT_BY_SELF = 0
    H5VL_OBJECT_BY_NAME = 1
    H5VL_OBJECT_BY_IDX = 2
    H5VL_OBJECT_BY_TOKEN = 3
end

struct H5VL_loc_by_name
    name::Ptr{Cchar}
    lapl_id::hid_t
end

const H5VL_loc_by_name_t = H5VL_loc_by_name

struct H5VL_loc_by_idx
    name::Ptr{Cchar}
    idx_type::H5_index_t
    order::H5_iter_order_t
    n::hsize_t
    lapl_id::hid_t
end

const H5VL_loc_by_idx_t = H5VL_loc_by_idx

struct H5VL_loc_by_token
    token::Ptr{H5O_token_t}
end

const H5VL_loc_by_token_t = H5VL_loc_by_token

struct var"##Ctag#301"
    data::NTuple{32, UInt8}
end

function Base.getproperty(x::Ptr{var"##Ctag#301"}, f::Symbol)
    f === :loc_by_token && return Ptr{H5VL_loc_by_token_t}(x + 0)
    f === :loc_by_name && return Ptr{H5VL_loc_by_name_t}(x + 0)
    f === :loc_by_idx && return Ptr{H5VL_loc_by_idx_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::var"##Ctag#301", f::Symbol)
    r = Ref{var"##Ctag#301"}(x)
    ptr = Base.unsafe_convert(Ptr{var"##Ctag#301"}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{var"##Ctag#301"}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct H5VL_loc_params_t
    data::NTuple{40, UInt8}
end

function Base.getproperty(x::Ptr{H5VL_loc_params_t}, f::Symbol)
    f === :obj_type && return Ptr{H5I_type_t}(x + 0)
    f === :type && return Ptr{H5VL_loc_type_t}(x + 4)
    f === :loc_data && return Ptr{var"##Ctag#301"}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::H5VL_loc_params_t, f::Symbol)
    r = Ref{H5VL_loc_params_t}(x)
    ptr = Base.unsafe_convert(Ptr{H5VL_loc_params_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{H5VL_loc_params_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct H5VL_file_cont_info_t
    version::Cuint
    feature_flags::UInt64
    token_size::Csize_t
    blob_id_size::Csize_t
end

struct H5VL_info_class_t
    size::Csize_t
    copy::Ptr{Cvoid}
    cmp::Ptr{Cvoid}
    free::Ptr{Cvoid}
    to_str::Ptr{Cvoid}
    from_str::Ptr{Cvoid}
end

struct H5VL_wrap_class_t
    get_object::Ptr{Cvoid}
    get_wrap_ctx::Ptr{Cvoid}
    wrap_object::Ptr{Cvoid}
    unwrap_object::Ptr{Cvoid}
    free_wrap_ctx::Ptr{Cvoid}
end

struct H5VL_attr_class_t
    create::Ptr{Cvoid}
    open::Ptr{Cvoid}
    read::Ptr{Cvoid}
    write::Ptr{Cvoid}
    get::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
    close::Ptr{Cvoid}
end

struct H5VL_dataset_class_t
    create::Ptr{Cvoid}
    open::Ptr{Cvoid}
    read::Ptr{Cvoid}
    write::Ptr{Cvoid}
    get::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
    close::Ptr{Cvoid}
end

struct H5VL_datatype_class_t
    commit::Ptr{Cvoid}
    open::Ptr{Cvoid}
    get::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
    close::Ptr{Cvoid}
end

struct H5VL_file_class_t
    create::Ptr{Cvoid}
    open::Ptr{Cvoid}
    get::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
    close::Ptr{Cvoid}
end

struct H5VL_group_class_t
    create::Ptr{Cvoid}
    open::Ptr{Cvoid}
    get::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
    close::Ptr{Cvoid}
end

struct H5VL_link_class_t
    create::Ptr{Cvoid}
    copy::Ptr{Cvoid}
    move::Ptr{Cvoid}
    get::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
end

struct H5VL_object_class_t
    open::Ptr{Cvoid}
    copy::Ptr{Cvoid}
    get::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
end

# typedef herr_t ( * H5VL_request_notify_t ) ( void * ctx , H5ES_status_t status )
const H5VL_request_notify_t = Ptr{Cvoid}

@cenum H5VL_get_conn_lvl_t::UInt32 begin
    H5VL_GET_CONN_LVL_CURR = 0
    H5VL_GET_CONN_LVL_TERM = 1
end

struct H5VL_introspect_class_t
    get_conn_cls::Ptr{Cvoid}
    opt_query::Ptr{Cvoid}
end

struct H5VL_request_class_t
    wait::Ptr{Cvoid}
    notify::Ptr{Cvoid}
    cancel::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
    free::Ptr{Cvoid}
end

struct H5VL_blob_class_t
    put::Ptr{Cvoid}
    get::Ptr{Cvoid}
    specific::Ptr{Cvoid}
    optional::Ptr{Cvoid}
end

struct H5VL_token_class_t
    cmp::Ptr{Cvoid}
    to_str::Ptr{Cvoid}
    from_str::Ptr{Cvoid}
end

struct H5VL_class_t
    version::Cuint
    value::H5VL_class_value_t
    name::Ptr{Cchar}
    cap_flags::Cuint
    initialize::Ptr{Cvoid}
    terminate::Ptr{Cvoid}
    info_cls::H5VL_info_class_t
    wrap_cls::H5VL_wrap_class_t
    attr_cls::H5VL_attr_class_t
    dataset_cls::H5VL_dataset_class_t
    datatype_cls::H5VL_datatype_class_t
    file_cls::H5VL_file_class_t
    group_cls::H5VL_group_class_t
    link_cls::H5VL_link_class_t
    object_cls::H5VL_object_class_t
    introspect_cls::H5VL_introspect_class_t
    request_cls::H5VL_request_class_t
    blob_cls::H5VL_blob_class_t
    token_cls::H5VL_token_class_t
    optional::Ptr{Cvoid}
end

function H5VLregister_connector(cls, vipl_id)
    ccall((:H5VLregister_connector, libhdf5), hid_t, (Ptr{H5VL_class_t}, hid_t), cls, vipl_id)
end

function H5VLobject(obj_id)
    ccall((:H5VLobject, libhdf5), Ptr{Cvoid}, (hid_t,), obj_id)
end

function H5VLget_file_type(file_obj, connector_id, dtype_id)
    ccall((:H5VLget_file_type, libhdf5), hid_t, (Ptr{Cvoid}, hid_t, hid_t), file_obj, connector_id, dtype_id)
end

function H5VLpeek_connector_id_by_name(name)
    ccall((:H5VLpeek_connector_id_by_name, libhdf5), hid_t, (Ptr{Cchar},), name)
end

function H5VLpeek_connector_id_by_value(value)
    ccall((:H5VLpeek_connector_id_by_value, libhdf5), hid_t, (H5VL_class_value_t,), value)
end

function H5VLcmp_connector_cls(cmp, connector_id1, connector_id2)
    ccall((:H5VLcmp_connector_cls, libhdf5), herr_t, (Ptr{Cint}, hid_t, hid_t), cmp, connector_id1, connector_id2)
end

function H5VLwrap_register(obj, type)
    ccall((:H5VLwrap_register, libhdf5), hid_t, (Ptr{Cvoid}, H5I_type_t), obj, type)
end

function H5VLretrieve_lib_state(state)
    ccall((:H5VLretrieve_lib_state, libhdf5), herr_t, (Ptr{Ptr{Cvoid}},), state)
end

function H5VLrestore_lib_state(state)
    ccall((:H5VLrestore_lib_state, libhdf5), herr_t, (Ptr{Cvoid},), state)
end

function H5VLreset_lib_state()
    ccall((:H5VLreset_lib_state, libhdf5), herr_t, ())
end

function H5VLfree_lib_state(state)
    ccall((:H5VLfree_lib_state, libhdf5), herr_t, (Ptr{Cvoid},), state)
end

function H5VLget_object(obj, connector_id)
    ccall((:H5VLget_object, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, hid_t), obj, connector_id)
end

function H5VLget_wrap_ctx(obj, connector_id, wrap_ctx)
    ccall((:H5VLget_wrap_ctx, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, Ptr{Ptr{Cvoid}}), obj, connector_id, wrap_ctx)
end

function H5VLwrap_object(obj, obj_type, connector_id, wrap_ctx)
    ccall((:H5VLwrap_object, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, H5I_type_t, hid_t, Ptr{Cvoid}), obj, obj_type, connector_id, wrap_ctx)
end

function H5VLunwrap_object(obj, connector_id)
    ccall((:H5VLunwrap_object, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, hid_t), obj, connector_id)
end

function H5VLfree_wrap_ctx(wrap_ctx, connector_id)
    ccall((:H5VLfree_wrap_ctx, libhdf5), herr_t, (Ptr{Cvoid}, hid_t), wrap_ctx, connector_id)
end

function H5VLinitialize(connector_id, vipl_id)
    ccall((:H5VLinitialize, libhdf5), herr_t, (hid_t, hid_t), connector_id, vipl_id)
end

function H5VLterminate(connector_id)
    ccall((:H5VLterminate, libhdf5), herr_t, (hid_t,), connector_id)
end

function H5VLget_cap_flags(connector_id, cap_flags)
    ccall((:H5VLget_cap_flags, libhdf5), herr_t, (hid_t, Ptr{Cuint}), connector_id, cap_flags)
end

function H5VLget_value(connector_id, conn_value)
    ccall((:H5VLget_value, libhdf5), herr_t, (hid_t, Ptr{H5VL_class_value_t}), connector_id, conn_value)
end

function H5VLcopy_connector_info(connector_id, dst_vol_info, src_vol_info)
    ccall((:H5VLcopy_connector_info, libhdf5), herr_t, (hid_t, Ptr{Ptr{Cvoid}}, Ptr{Cvoid}), connector_id, dst_vol_info, src_vol_info)
end

function H5VLcmp_connector_info(cmp, connector_id, info1, info2)
    ccall((:H5VLcmp_connector_info, libhdf5), herr_t, (Ptr{Cint}, hid_t, Ptr{Cvoid}, Ptr{Cvoid}), cmp, connector_id, info1, info2)
end

function H5VLfree_connector_info(connector_id, vol_info)
    ccall((:H5VLfree_connector_info, libhdf5), herr_t, (hid_t, Ptr{Cvoid}), connector_id, vol_info)
end

function H5VLconnector_info_to_str(info, connector_id, str)
    ccall((:H5VLconnector_info_to_str, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, Ptr{Ptr{Cchar}}), info, connector_id, str)
end

function H5VLconnector_str_to_info(str, connector_id, info)
    ccall((:H5VLconnector_str_to_info, libhdf5), herr_t, (Ptr{Cchar}, hid_t, Ptr{Ptr{Cvoid}}), str, connector_id, info)
end

function H5VLattr_create(obj, loc_params, connector_id, attr_name, type_id, space_id, acpl_id, aapl_id, dxpl_id, req)
    ccall((:H5VLattr_create, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, attr_name, type_id, space_id, acpl_id, aapl_id, dxpl_id, req)
end

function H5VLattr_open(obj, loc_params, connector_id, name, aapl_id, dxpl_id, req)
    ccall((:H5VLattr_open, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{Cchar}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, name, aapl_id, dxpl_id, req)
end

function H5VLattr_read(attr, connector_id, dtype_id, buf, dxpl_id, req)
    ccall((:H5VLattr_read, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, Ptr{Cvoid}, hid_t, Ptr{Ptr{Cvoid}}), attr, connector_id, dtype_id, buf, dxpl_id, req)
end

function H5VLattr_write(attr, connector_id, dtype_id, buf, dxpl_id, req)
    ccall((:H5VLattr_write, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, Ptr{Cvoid}, hid_t, Ptr{Ptr{Cvoid}}), attr, connector_id, dtype_id, buf, dxpl_id, req)
end

function H5VLattr_close(attr, connector_id, dxpl_id, req)
    ccall((:H5VLattr_close, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), attr, connector_id, dxpl_id, req)
end

function H5VLdataset_create(obj, loc_params, connector_id, name, lcpl_id, type_id, space_id, dcpl_id, dapl_id, dxpl_id, req)
    ccall((:H5VLdataset_create, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t, hid_t, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, name, lcpl_id, type_id, space_id, dcpl_id, dapl_id, dxpl_id, req)
end

function H5VLdataset_open(obj, loc_params, connector_id, name, dapl_id, dxpl_id, req)
    ccall((:H5VLdataset_open, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{Cchar}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, name, dapl_id, dxpl_id, req)
end

function H5VLdataset_read(dset, connector_id, mem_type_id, mem_space_id, file_space_id, plist_id, buf, req)
    ccall((:H5VLdataset_read, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, hid_t, hid_t, hid_t, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), dset, connector_id, mem_type_id, mem_space_id, file_space_id, plist_id, buf, req)
end

function H5VLdataset_write(dset, connector_id, mem_type_id, mem_space_id, file_space_id, plist_id, buf, req)
    ccall((:H5VLdataset_write, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, hid_t, hid_t, hid_t, Ptr{Cvoid}, Ptr{Ptr{Cvoid}}), dset, connector_id, mem_type_id, mem_space_id, file_space_id, plist_id, buf, req)
end

function H5VLdataset_close(dset, connector_id, dxpl_id, req)
    ccall((:H5VLdataset_close, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), dset, connector_id, dxpl_id, req)
end

function H5VLdatatype_commit(obj, loc_params, connector_id, name, type_id, lcpl_id, tcpl_id, tapl_id, dxpl_id, req)
    ccall((:H5VLdatatype_commit, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, name, type_id, lcpl_id, tcpl_id, tapl_id, dxpl_id, req)
end

function H5VLdatatype_open(obj, loc_params, connector_id, name, tapl_id, dxpl_id, req)
    ccall((:H5VLdatatype_open, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{Cchar}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, name, tapl_id, dxpl_id, req)
end

function H5VLdatatype_close(dt, connector_id, dxpl_id, req)
    ccall((:H5VLdatatype_close, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), dt, connector_id, dxpl_id, req)
end

function H5VLfile_create(name, flags, fcpl_id, fapl_id, dxpl_id, req)
    ccall((:H5VLfile_create, libhdf5), Ptr{Cvoid}, (Ptr{Cchar}, Cuint, hid_t, hid_t, hid_t, Ptr{Ptr{Cvoid}}), name, flags, fcpl_id, fapl_id, dxpl_id, req)
end

function H5VLfile_open(name, flags, fapl_id, dxpl_id, req)
    ccall((:H5VLfile_open, libhdf5), Ptr{Cvoid}, (Ptr{Cchar}, Cuint, hid_t, hid_t, Ptr{Ptr{Cvoid}}), name, flags, fapl_id, dxpl_id, req)
end

function H5VLfile_close(file, connector_id, dxpl_id, req)
    ccall((:H5VLfile_close, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), file, connector_id, dxpl_id, req)
end

function H5VLgroup_create(obj, loc_params, connector_id, name, lcpl_id, gcpl_id, gapl_id, dxpl_id, req)
    ccall((:H5VLgroup_create, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, name, lcpl_id, gcpl_id, gapl_id, dxpl_id, req)
end

function H5VLgroup_open(obj, loc_params, connector_id, name, gapl_id, dxpl_id, req)
    ccall((:H5VLgroup_open, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{Cchar}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, name, gapl_id, dxpl_id, req)
end

function H5VLgroup_close(grp, connector_id, dxpl_id, req)
    ccall((:H5VLgroup_close, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, hid_t, Ptr{Ptr{Cvoid}}), grp, connector_id, dxpl_id, req)
end

function H5VLlink_copy(src_obj, loc_params1, dst_obj, loc_params2, connector_id, lcpl_id, lapl_id, dxpl_id, req)
    ccall((:H5VLlink_copy, libhdf5), herr_t, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, hid_t, hid_t, hid_t, Ptr{Ptr{Cvoid}}), src_obj, loc_params1, dst_obj, loc_params2, connector_id, lcpl_id, lapl_id, dxpl_id, req)
end

function H5VLlink_move(src_obj, loc_params1, dst_obj, loc_params2, connector_id, lcpl_id, lapl_id, dxpl_id, req)
    ccall((:H5VLlink_move, libhdf5), herr_t, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, hid_t, hid_t, hid_t, Ptr{Ptr{Cvoid}}), src_obj, loc_params1, dst_obj, loc_params2, connector_id, lcpl_id, lapl_id, dxpl_id, req)
end

function H5VLobject_open(obj, loc_params, connector_id, opened_type, dxpl_id, req)
    ccall((:H5VLobject_open, libhdf5), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, hid_t, Ptr{H5I_type_t}, hid_t, Ptr{Ptr{Cvoid}}), obj, loc_params, connector_id, opened_type, dxpl_id, req)
end

function H5VLobject_copy(src_obj, loc_params1, src_name, dst_obj, loc_params2, dst_name, connector_id, ocpypl_id, lcpl_id, dxpl_id, req)
    ccall((:H5VLobject_copy, libhdf5), herr_t, (Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, Ptr{Cchar}, Ptr{Cvoid}, Ptr{H5VL_loc_params_t}, Ptr{Cchar}, hid_t, hid_t, hid_t, hid_t, Ptr{Ptr{Cvoid}}), src_obj, loc_params1, src_name, dst_obj, loc_params2, dst_name, connector_id, ocpypl_id, lcpl_id, dxpl_id, req)
end

function H5VLintrospect_get_conn_cls(obj, connector_id, lvl, conn_cls)
    ccall((:H5VLintrospect_get_conn_cls, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, H5VL_get_conn_lvl_t, Ptr{Ptr{H5VL_class_t}}), obj, connector_id, lvl, conn_cls)
end

function H5VLintrospect_opt_query(obj, connector_id, subcls, opt_type, supported)
    ccall((:H5VLintrospect_opt_query, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, H5VL_subclass_t, Cint, Ptr{hbool_t}), obj, connector_id, subcls, opt_type, supported)
end

function H5VLrequest_wait(req, connector_id, timeout, status)
    ccall((:H5VLrequest_wait, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, UInt64, Ptr{H5ES_status_t}), req, connector_id, timeout, status)
end

function H5VLrequest_notify(req, connector_id, cb, ctx)
    ccall((:H5VLrequest_notify, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, H5VL_request_notify_t, Ptr{Cvoid}), req, connector_id, cb, ctx)
end

function H5VLrequest_cancel(req, connector_id)
    ccall((:H5VLrequest_cancel, libhdf5), herr_t, (Ptr{Cvoid}, hid_t), req, connector_id)
end

function H5VLrequest_free(req, connector_id)
    ccall((:H5VLrequest_free, libhdf5), herr_t, (Ptr{Cvoid}, hid_t), req, connector_id)
end

function H5VLblob_put(obj, connector_id, buf, size, blob_id, ctx)
    ccall((:H5VLblob_put, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, Ptr{Cvoid}, Csize_t, Ptr{Cvoid}, Ptr{Cvoid}), obj, connector_id, buf, size, blob_id, ctx)
end

function H5VLblob_get(obj, connector_id, blob_id, buf, size, ctx)
    ccall((:H5VLblob_get, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, Ptr{Cvoid}, Ptr{Cvoid}, Csize_t, Ptr{Cvoid}), obj, connector_id, blob_id, buf, size, ctx)
end

function H5VLtoken_cmp(obj, connector_id, token1, token2, cmp_value)
    ccall((:H5VLtoken_cmp, libhdf5), herr_t, (Ptr{Cvoid}, hid_t, Ptr{H5O_token_t}, Ptr{H5O_token_t}, Ptr{Cint}), obj, connector_id, token1, token2, cmp_value)
end

function H5VLtoken_to_str(obj, obj_type, connector_id, token, token_str)
    ccall((:H5VLtoken_to_str, libhdf5), herr_t, (Ptr{Cvoid}, H5I_type_t, hid_t, Ptr{H5O_token_t}, Ptr{Ptr{Cchar}}), obj, obj_type, connector_id, token, token_str)
end

function H5VLtoken_from_str(obj, obj_type, connector_id, token_str, token)
    ccall((:H5VLtoken_from_str, libhdf5), herr_t, (Ptr{Cvoid}, H5I_type_t, hid_t, Ptr{Cchar}, Ptr{H5O_token_t}), obj, obj_type, connector_id, token_str, token)
end

function H5VLnative_addr_to_token(loc_id, addr, token)
    ccall((:H5VLnative_addr_to_token, libhdf5), herr_t, (hid_t, haddr_t, Ptr{H5O_token_t}), loc_id, addr, token)
end

function H5VLnative_token_to_addr(loc_id, token, addr)
    ccall((:H5VLnative_token_to_addr, libhdf5), herr_t, (hid_t, H5O_token_t, Ptr{haddr_t}), loc_id, token, addr)
end

function H5Pset_fapl_core(fapl_id, increment, backing_store)
    ccall((:H5Pset_fapl_core, libhdf5), herr_t, (hid_t, Csize_t, hbool_t), fapl_id, increment, backing_store)
end

function H5Pget_fapl_core(fapl_id, increment, backing_store)
    ccall((:H5Pget_fapl_core, libhdf5), herr_t, (hid_t, Ptr{Csize_t}, Ptr{hbool_t}), fapl_id, increment, backing_store)
end

function H5Pset_fapl_family(fapl_id, memb_size, memb_fapl_id)
    ccall((:H5Pset_fapl_family, libhdf5), herr_t, (hid_t, hsize_t, hid_t), fapl_id, memb_size, memb_fapl_id)
end

function H5Pget_fapl_family(fapl_id, memb_size, memb_fapl_id)
    ccall((:H5Pget_fapl_family, libhdf5), herr_t, (hid_t, Ptr{hsize_t}, Ptr{hid_t}), fapl_id, memb_size, memb_fapl_id)
end

struct H5FD_hdfs_fapl_t
    version::Int32
    namenode_name::NTuple{129, Cchar}
    namenode_port::Int32
    user_name::NTuple{129, Cchar}
    kerberos_ticket_cache::NTuple{129, Cchar}
    stream_buffer_size::Int32
end

function H5FD_hdfs_init()
    ccall((:H5FD_hdfs_init, libhdf5), hid_t, ())
end

function H5Pget_fapl_hdfs(fapl_id, fa_out)
    ccall((:H5Pget_fapl_hdfs, libhdf5), herr_t, (hid_t, Ptr{H5FD_hdfs_fapl_t}), fapl_id, fa_out)
end

function H5Pset_fapl_hdfs(fapl_id, fa)
    ccall((:H5Pset_fapl_hdfs, libhdf5), herr_t, (hid_t, Ptr{H5FD_hdfs_fapl_t}), fapl_id, fa)
end

function H5Pset_fapl_log(fapl_id, logfile, flags, buf_size)
    ccall((:H5Pset_fapl_log, libhdf5), herr_t, (hid_t, Ptr{Cchar}, Culonglong, Csize_t), fapl_id, logfile, flags, buf_size)
end

@cenum H5FD_mpio_xfer_t::UInt32 begin
    H5FD_MPIO_INDEPENDENT = 0
    H5FD_MPIO_COLLECTIVE = 1
end

@cenum H5FD_mpio_chunk_opt_t::UInt32 begin
    H5FD_MPIO_CHUNK_DEFAULT = 0
    H5FD_MPIO_CHUNK_ONE_IO = 1
    H5FD_MPIO_CHUNK_MULTI_IO = 2
end

@cenum H5FD_mpio_collective_opt_t::UInt32 begin
    H5FD_MPIO_COLLECTIVE_IO = 0
    H5FD_MPIO_INDIVIDUAL_IO = 1
end

function H5Pset_fapl_multi(fapl_id, memb_map, memb_fapl, memb_name, memb_addr, relax)
    ccall((:H5Pset_fapl_multi, libhdf5), herr_t, (hid_t, Ptr{H5FD_mem_t}, Ptr{hid_t}, Ptr{Ptr{Cchar}}, Ptr{haddr_t}, hbool_t), fapl_id, memb_map, memb_fapl, memb_name, memb_addr, relax)
end

function H5Pget_fapl_multi(fapl_id, memb_map, memb_fapl, memb_name, memb_addr, relax)
    ccall((:H5Pget_fapl_multi, libhdf5), herr_t, (hid_t, Ptr{H5FD_mem_t}, Ptr{hid_t}, Ptr{Ptr{Cchar}}, Ptr{haddr_t}, Ptr{hbool_t}), fapl_id, memb_map, memb_fapl, memb_name, memb_addr, relax)
end

function H5Pset_fapl_split(fapl, meta_ext, meta_plist_id, raw_ext, raw_plist_id)
    ccall((:H5Pset_fapl_split, libhdf5), herr_t, (hid_t, Ptr{Cchar}, hid_t, Ptr{Cchar}, hid_t), fapl, meta_ext, meta_plist_id, raw_ext, raw_plist_id)
end

function H5Pset_fapl_sec2(fapl_id)
    ccall((:H5Pset_fapl_sec2, libhdf5), herr_t, (hid_t,), fapl_id)
end

struct H5FD_splitter_vfd_config_t
    magic::Int32
    version::Cuint
    rw_fapl_id::hid_t
    wo_fapl_id::hid_t
    wo_path::NTuple{4097, Cchar}
    log_file_path::NTuple{4097, Cchar}
    ignore_wo_errs::hbool_t
end

function H5Pset_fapl_splitter(fapl_id, config_ptr)
    ccall((:H5Pset_fapl_splitter, libhdf5), herr_t, (hid_t, Ptr{H5FD_splitter_vfd_config_t}), fapl_id, config_ptr)
end

function H5Pget_fapl_splitter(fapl_id, config_ptr)
    ccall((:H5Pget_fapl_splitter, libhdf5), herr_t, (hid_t, Ptr{H5FD_splitter_vfd_config_t}), fapl_id, config_ptr)
end

function H5Pset_fapl_stdio(fapl_id)
    ccall((:H5Pset_fapl_stdio, libhdf5), herr_t, (hid_t,), fapl_id)
end

function H5Pset_fapl_windows(fapl_id)
    ccall((:H5Pset_fapl_windows, libhdf5), herr_t, (hid_t,), fapl_id)
end

struct H5VL_pass_through_info_t
    under_vol_id::hid_t
    under_vol_info::Ptr{Cvoid}
end

const H5_HAVE_WINDOWS = 1

const H5_HAVE_MINGW = 1

const H5_HAVE_WIN32_API = 1

const H5_DEFAULT_PLUGINDIR = "%ALLUSERSPROFILE%\\hdf5\\lib\\plugin"

const H5_DEV_T_IS_SCALAR = 1

const H5_FORTRAN_C_LONG_DOUBLE_IS_UNIQUE = 1

const H5_FORTRAN_HAVE_C_LONG_DOUBLE = 1

const H5_FORTRAN_HAVE_C_SIZEOF = 1

const H5_FORTRAN_HAVE_SIZEOF = 1

const H5_FORTRAN_HAVE_STORAGE_SIZE = 1

const H5_FORTRAN_SIZEOF_LONG_DOUBLE = 16

const H5_Fortran_COMPILER_ID = GNU

# Skipping MacroDefinition: H5_H5CONFIG_F_IKIND INTEGER , DIMENSION ( 1 : num_ikinds ) : : ikind = ( / 1 , 2 , 4 , 8 , 16 / )

# Skipping MacroDefinition: H5_H5CONFIG_F_NUM_IKIND INTEGER , PARAMETER : : num_ikinds = 5

# Skipping MacroDefinition: H5_H5CONFIG_F_NUM_RKIND INTEGER , PARAMETER : : num_rkinds = 4

# Skipping MacroDefinition: H5_H5CONFIG_F_RKIND INTEGER , DIMENSION ( 1 : num_rkinds ) : : rkind = ( / 4 , 8 , 10 , 16 / )

# Skipping MacroDefinition: H5_H5CONFIG_F_RKIND_SIZEOF INTEGER , DIMENSION ( 1 : num_rkinds ) : : rkind_sizeof = ( / 4 , 8 , 16 , 16 / )

const H5_HAVE_ALARM = 1

const H5_HAVE_ASPRINTF = 1

const H5_HAVE_ATTRIBUTE = 1

const H5_HAVE_C99_DESIGNATED_INITIALIZER = 1

const H5_HAVE_C99_FUNC = 1

const H5_HAVE_CLOCK_GETTIME = 1

const H5_HAVE_DIFFTIME = 1

const H5_HAVE_EMBEDDED_LIBINFO = 1

const H5_HAVE_FILTER_DEFLATE = 1

const H5_HAVE_FILTER_SZIP = 1

const H5_HAVE_FLOAT128 = 1

const H5_HAVE_FREXPF = 1

const H5_HAVE_FREXPL = 1

const H5_HAVE_FSEEKO = 1

const H5_HAVE_FUNCTION = 1

const H5_HAVE_Fortran_INTEGER_SIZEOF_16 = 1

const H5_HAVE_GETCONSOLESCREENBUFFERINFO = 1

const H5_HAVE_GETTIMEOFDAY = 1

const H5_HAVE_INLINE = 1

const H5_HAVE_LIBM = 1

const H5_HAVE_LIBSZ = 1

const H5_HAVE_LIBWS2_32 = 1

const H5_HAVE_LIBZ = 1

const H5_HAVE_LLROUND = 1

const H5_HAVE_LLROUNDF = 1

const H5_HAVE_LONGJMP = 1

const H5_HAVE_LROUND = 1

const H5_HAVE_LROUNDF = 1

const H5_HAVE_LSEEK64 = 1

const H5_HAVE_ROUND = 1

const H5_HAVE_ROUNDF = 1

const H5_HAVE_SETJMP = 1

const H5_HAVE_SIGNAL = 1

const H5_HAVE_SNPRINTF = 1

const H5_HAVE_STDINT_H_CXX = 1

const H5_HAVE_STRDUP = 1

const H5_HAVE_STRTOLL = 1

const H5_HAVE_STRTOULL = 1

const H5_HAVE_SYSTEM = 1

const H5_HAVE_TIMEZONE = 1

const H5_HAVE_TMPFILE = 1

const H5_HAVE_VASPRINTF = 1

const H5_HAVE_VSNPRINTF = 1

const H5_HAVE_WINDOW_PATH = 1

const H5_HAVE___INLINE = 1

const H5_HAVE___INLINE__ = 1

const H5_IGNORE_DISABLED_FILE_LOCKS = 1

const H5_INCLUDE_HL = 1

const H5_LDOUBLE_TO_LLONG_ACCURATE = 1

const H5_LLONG_TO_LDOUBLE_CORRECT = 1

const H5_NO_ALIGNMENT_RESTRICTIONS = 1

const H5_PACKAGE = "hdf5"

const H5_PACKAGE_BUGREPORT = "help@hdfgroup.org"

const H5_PACKAGE_NAME = "HDF5"

const H5_PACKAGE_STRING = "HDF5 1.12.1"

const H5_PACKAGE_TARNAME = "hdf5"

const H5_PACKAGE_URL = "http://www.hdfgroup.org"

const H5_PACKAGE_VERSION = "1.12.1"

const H5_PAC_C_MAX_REAL_PRECISION = 33

const H5_PAC_FC_MAX_REAL_PRECISION = 33

const H5_PRINTF_LL_WIDTH = "I64"

const H5_SIZEOF_BOOL = 1

const H5_SIZEOF_CHAR = 1

const H5_SIZEOF_DOUBLE = 8

const H5_SIZEOF_FLOAT = 4

const H5_SIZEOF_INT = 4

const H5_SIZEOF_INT16_T = 2

const H5_SIZEOF_INT32_T = 4

const H5_SIZEOF_INT64_T = 8

const H5_SIZEOF_INT8_T = 1

const H5_SIZEOF_INT_FAST16_T = 2

const H5_SIZEOF_INT_FAST32_T = 4

const H5_SIZEOF_INT_FAST64_T = 8

const H5_SIZEOF_INT_FAST8_T = 1

const H5_SIZEOF_INT_LEAST16_T = 2

const H5_SIZEOF_INT_LEAST32_T = 4

const H5_SIZEOF_INT_LEAST64_T = 8

const H5_SIZEOF_INT_LEAST8_T = 1

const H5_SIZEOF_SIZE_T = 8

const H5_SIZEOF_SSIZE_T = 8

const H5_SIZEOF_LONG = 4

const H5_SIZEOF_LONG_DOUBLE = 16

const H5_SIZEOF_LONG_LONG = 8

const H5_SIZEOF_OFF64_T = 8

const H5_SIZEOF_OFF_T = 8

const H5_SIZEOF_PTRDIFF_T = 8

const H5_SIZEOF_SHORT = 2

const H5_SIZEOF_TIME_T = 8

const H5_SIZEOF_UINT16_T = 2

const H5_SIZEOF_UINT32_T = 4

const H5_SIZEOF_UINT64_T = 8

const H5_SIZEOF_UINT8_T = 1

const H5_SIZEOF_UINT_FAST16_T = 2

const H5_SIZEOF_UINT_FAST32_T = 4

const H5_SIZEOF_UINT_FAST64_T = 8

const H5_SIZEOF_UINT_FAST8_T = 1

const H5_SIZEOF_UINT_LEAST16_T = 2

const H5_SIZEOF_UINT_LEAST32_T = 4

const H5_SIZEOF_UINT_LEAST64_T = 8

const H5_SIZEOF_UINT_LEAST8_T = 1

const H5_SIZEOF_UNSIGNED = 4

const H5_SIZEOF__QUAD = 0

const H5_SIZEOF___FLOAT128 = 16

const H5_SIZEOF___INT64 = 8

const H5_STDC_HEADERS = 1

const H5_SYSTEM_SCOPE_THREADS = 1

const H5_TIME_WITH_SYS_TIME = 1

const H5_USE_112_API_DEFAULT = 1

const H5_USE_FILE_LOCKING = 1

const H5_VERSION = "1.12.1"

const H5_WANT_DATA_ACCURACY = 1

const H5_WANT_DCONV_EXCEPTION = 1

const H5Acreate_vers = 2

const H5Acreate = H5Acreate2

const H5Aiterate_vers = 2

const H5Aiterate = H5Aiterate2

const H5A_operator_t = H5A_operator2_t

const H5Dcreate_vers = 2

const H5Dcreate = H5Dcreate2

const H5Dopen_vers = 2

const H5Dopen = H5Dopen2

const H5Eclear_vers = 2

const H5Eclear = H5Eclear2

const H5Eget_auto_vers = 2

const H5Eget_auto = H5Eget_auto2

const H5Eprint_vers = 2

const H5Eprint = H5Eprint2

const H5Epush_vers = 2

const H5Epush = H5Epush2

const H5Eset_auto_vers = 2

const H5Eset_auto = H5Eset_auto2

const H5Ewalk_vers = 2

const H5Ewalk = H5Ewalk2

const H5E_error_t = H5E_error2_t

const H5E_walk_t = H5E_walk2_t

const H5Fget_info_vers = 2

const H5Fget_info = H5Fget_info2

const H5F_info_t = H5F_info2_t

const H5Gcreate_vers = 2

const H5Gcreate = H5Gcreate2

const H5Gopen_vers = 2

const H5Gopen = H5Gopen2

const H5Lget_info_vers = 2

const H5Lget_info = H5Lget_info2

const H5L_info_t = H5L_info2_t

const H5Lget_info_by_idx_vers = 2

const H5Lget_info_by_idx = H5Lget_info_by_idx2

const H5Literate_vers = 2

const H5Literate = H5Literate2

const H5L_iterate_t = H5L_iterate2_t

const H5Literate_by_name_vers = 2

const H5Literate_by_name = H5Literate_by_name2

const H5Lvisit_vers = 2

const H5Lvisit = H5Lvisit2

const H5Lvisit_by_name_vers = 2

const H5Lvisit_by_name = H5Lvisit_by_name2

const H5Oget_info_vers = 3

const H5Oget_info = H5Oget_info3

const H5Oget_info_by_idx_vers = 3

const H5Oget_info_by_idx = H5Oget_info_by_idx3

const H5Oget_info_by_name_vers = 3

const H5Oget_info_by_name = H5Oget_info_by_name3

const H5Ovisit_vers = 3

const H5Ovisit = H5Ovisit3

const H5Ovisit_by_name_vers = 3

const H5Ovisit_by_name = H5Ovisit_by_name3

const H5Pencode_vers = 2

const H5Pencode = H5Pencode2

const H5Pget_filter_vers = 2

const H5Pget_filter = H5Pget_filter2

const H5Pget_filter_by_id_vers = 2

const H5Pget_filter_by_id = H5Pget_filter_by_id2

const H5Pinsert_vers = 2

const H5Pinsert = H5Pinsert2

const H5Pregister_vers = 2

const H5Pregister = H5Pregister2

const H5Rdereference_vers = 2

const H5Rdereference = H5Rdereference2

const H5Rget_obj_type_vers = 2

const H5Rget_obj_type = H5Rget_obj_type2

const H5Sencode_vers = 2

const H5Sencode = H5Sencode2

const H5Tarray_create_vers = 2

const H5Tarray_create = H5Tarray_create2

const H5Tcommit_vers = 2

const H5Tcommit = H5Tcommit2

const H5Tget_array_dims_vers = 2

const H5Tget_array_dims = H5Tget_array_dims2

const H5Topen_vers = 2

const H5Topen = H5Topen2

const H5E_auto_t_vers = 2

const H5E_auto_t = H5E_auto2_t

const H5O_info_t_vers = 2

const H5O_info_t = H5O_info2_t

const H5O_iterate_t_vers = 2

const H5O_iterate_t = H5O_iterate2_t

const H5Z_class_t_vers = 2

const H5Z_class_t = H5Z_class2_t

# Skipping MacroDefinition: H5_DLLVAR extern

# Skipping MacroDefinition: H5TEST_DLLVAR extern

# Skipping MacroDefinition: H5TOOLS_DLLVAR extern

# Skipping MacroDefinition: H5_DLLCPPVAR extern

# Skipping MacroDefinition: H5_HLDLLVAR extern

# Skipping MacroDefinition: H5_HLCPPDLLVAR extern

# Skipping MacroDefinition: H5_FCDLLVAR extern

# Skipping MacroDefinition: H5_FCTESTDLLVAR extern

# Skipping MacroDefinition: HDF5_HL_F90CSTUBDLLVAR extern

const H5_VERS_MAJOR = 1

const H5_VERS_MINOR = 12

const H5_VERS_RELEASE = 1

const H5_VERS_SUBRELEASE = ""

const H5_VERS_INFO = "HDF5 library version: 1.12.1"

const PRIdHSIZE = H5_PRINTF_LL_WIDTH("d")

const PRIiHSIZE = H5_PRINTF_LL_WIDTH("i")

const PRIoHSIZE = H5_PRINTF_LL_WIDTH("o")

const PRIuHSIZE = H5_PRINTF_LL_WIDTH("u")

const PRIxHSIZE = H5_PRINTF_LL_WIDTH("x")

const PRIXHSIZE = H5_PRINTF_LL_WIDTH("X")

const H5_SIZEOF_HSIZE_T = H5_SIZEOF_LONG_LONG

const H5_SIZEOF_HSSIZE_T = H5_SIZEOF_LONG_LONG

const HSIZE_UNDEF = ULLONG_MAX

const HADDR_UNDEF = ULLONG_MAX

const H5_SIZEOF_HADDR_T = H5_SIZEOF_LONG_LONG

const PRIdHADDR = H5_PRINTF_LL_WIDTH("d")

const PRIoHADDR = H5_PRINTF_LL_WIDTH("o")

const PRIuHADDR = H5_PRINTF_LL_WIDTH("u")

const PRIxHADDR = H5_PRINTF_LL_WIDTH("x")

const PRIXHADDR = H5_PRINTF_LL_WIDTH("X")

const H5_PRINTF_HADDR_FMT = ("%")(PRIuHADDR)

const HADDR_MAX = HADDR_UNDEF - 1

const H5_ITER_ERROR = -1

const H5_ITER_CONT = 0

const H5_ITER_STOP = 1

const H5O_MAX_TOKEN_SIZE = 16

const PRIdHID = PRId64

const PRIxHID = PRIx64

const PRIXHID = PRIX64

const PRIoHID = PRIo64

const H5_SIZEOF_HID_T = H5_SIZEOF_INT64_T

const H5I_INVALID_HID = -1

const H5T_NCSET = H5T_CSET_RESERVED_2

const H5T_NSTR = H5T_STR_RESERVED_3

const H5T_VARIABLE = size_t(-1)

const H5T_OPAQUE_TAG_MAX = 256

# Skipping MacroDefinition: H5OPEN H5open ( ) ,

const H5T_IEEE_F32BE = H5OPEN(H5T_IEEE_F32BE_g)

const H5T_IEEE_F32LE = H5OPEN(H5T_IEEE_F32LE_g)

const H5T_IEEE_F64BE = H5OPEN(H5T_IEEE_F64BE_g)

const H5T_IEEE_F64LE = H5OPEN(H5T_IEEE_F64LE_g)

const H5T_STD_I8BE = H5OPEN(H5T_STD_I8BE_g)

const H5T_STD_I8LE = H5OPEN(H5T_STD_I8LE_g)

const H5T_STD_I16BE = H5OPEN(H5T_STD_I16BE_g)

const H5T_STD_I16LE = H5OPEN(H5T_STD_I16LE_g)

const H5T_STD_I32BE = H5OPEN(H5T_STD_I32BE_g)

const H5T_STD_I32LE = H5OPEN(H5T_STD_I32LE_g)

const H5T_STD_I64BE = H5OPEN(H5T_STD_I64BE_g)

const H5T_STD_I64LE = H5OPEN(H5T_STD_I64LE_g)

const H5T_STD_U8BE = H5OPEN(H5T_STD_U8BE_g)

const H5T_STD_U8LE = H5OPEN(H5T_STD_U8LE_g)

const H5T_STD_U16BE = H5OPEN(H5T_STD_U16BE_g)

const H5T_STD_U16LE = H5OPEN(H5T_STD_U16LE_g)

const H5T_STD_U32BE = H5OPEN(H5T_STD_U32BE_g)

const H5T_STD_U32LE = H5OPEN(H5T_STD_U32LE_g)

const H5T_STD_U64BE = H5OPEN(H5T_STD_U64BE_g)

const H5T_STD_U64LE = H5OPEN(H5T_STD_U64LE_g)

const H5T_STD_B8BE = H5OPEN(H5T_STD_B8BE_g)

const H5T_STD_B8LE = H5OPEN(H5T_STD_B8LE_g)

const H5T_STD_B16BE = H5OPEN(H5T_STD_B16BE_g)

const H5T_STD_B16LE = H5OPEN(H5T_STD_B16LE_g)

const H5T_STD_B32BE = H5OPEN(H5T_STD_B32BE_g)

const H5T_STD_B32LE = H5OPEN(H5T_STD_B32LE_g)

const H5T_STD_B64BE = H5OPEN(H5T_STD_B64BE_g)

const H5T_STD_B64LE = H5OPEN(H5T_STD_B64LE_g)

const H5T_STD_REF_OBJ = H5OPEN(H5T_STD_REF_OBJ_g)

const H5T_STD_REF_DSETREG = H5OPEN(H5T_STD_REF_DSETREG_g)

const H5T_STD_REF = H5OPEN(H5T_STD_REF_g)

const H5T_UNIX_D32BE = H5OPEN(H5T_UNIX_D32BE_g)

const H5T_UNIX_D32LE = H5OPEN(H5T_UNIX_D32LE_g)

const H5T_UNIX_D64BE = H5OPEN(H5T_UNIX_D64BE_g)

const H5T_UNIX_D64LE = H5OPEN(H5T_UNIX_D64LE_g)

const H5T_C_S1 = H5OPEN(H5T_C_S1_g)

const H5T_FORTRAN_S1 = H5OPEN(H5T_FORTRAN_S1_g)

const H5T_INTEL_I8 = H5T_STD_I8LE

const H5T_INTEL_I16 = H5T_STD_I16LE

const H5T_INTEL_I32 = H5T_STD_I32LE

const H5T_INTEL_I64 = H5T_STD_I64LE

const H5T_INTEL_U8 = H5T_STD_U8LE

const H5T_INTEL_U16 = H5T_STD_U16LE

const H5T_INTEL_U32 = H5T_STD_U32LE

const H5T_INTEL_U64 = H5T_STD_U64LE

const H5T_INTEL_B8 = H5T_STD_B8LE

const H5T_INTEL_B16 = H5T_STD_B16LE

const H5T_INTEL_B32 = H5T_STD_B32LE

const H5T_INTEL_B64 = H5T_STD_B64LE

const H5T_INTEL_F32 = H5T_IEEE_F32LE

const H5T_INTEL_F64 = H5T_IEEE_F64LE

const H5T_ALPHA_I8 = H5T_STD_I8LE

const H5T_ALPHA_I16 = H5T_STD_I16LE

const H5T_ALPHA_I32 = H5T_STD_I32LE

const H5T_ALPHA_I64 = H5T_STD_I64LE

const H5T_ALPHA_U8 = H5T_STD_U8LE

const H5T_ALPHA_U16 = H5T_STD_U16LE

const H5T_ALPHA_U32 = H5T_STD_U32LE

const H5T_ALPHA_U64 = H5T_STD_U64LE

const H5T_ALPHA_B8 = H5T_STD_B8LE

const H5T_ALPHA_B16 = H5T_STD_B16LE

const H5T_ALPHA_B32 = H5T_STD_B32LE

const H5T_ALPHA_B64 = H5T_STD_B64LE

const H5T_ALPHA_F32 = H5T_IEEE_F32LE

const H5T_ALPHA_F64 = H5T_IEEE_F64LE

const H5T_MIPS_I8 = H5T_STD_I8BE

const H5T_MIPS_I16 = H5T_STD_I16BE

const H5T_MIPS_I32 = H5T_STD_I32BE

const H5T_MIPS_I64 = H5T_STD_I64BE

const H5T_MIPS_U8 = H5T_STD_U8BE

const H5T_MIPS_U16 = H5T_STD_U16BE

const H5T_MIPS_U32 = H5T_STD_U32BE

const H5T_MIPS_U64 = H5T_STD_U64BE

const H5T_MIPS_B8 = H5T_STD_B8BE

const H5T_MIPS_B16 = H5T_STD_B16BE

const H5T_MIPS_B32 = H5T_STD_B32BE

const H5T_MIPS_B64 = H5T_STD_B64BE

const H5T_MIPS_F32 = H5T_IEEE_F32BE

const H5T_MIPS_F64 = H5T_IEEE_F64BE

const H5T_VAX_F32 = H5OPEN(H5T_VAX_F32_g)

const H5T_VAX_F64 = H5OPEN(H5T_VAX_F64_g)

const H5T_NATIVE_SCHAR = H5OPEN(H5T_NATIVE_SCHAR_g)

const H5T_NATIVE_UCHAR = H5OPEN(H5T_NATIVE_UCHAR_g)

const H5T_NATIVE_CHAR = if CHAR_MIN
            H5T_NATIVE_SCHAR
        else
            H5T_NATIVE_UCHAR
        end

const H5T_NATIVE_SHORT = H5OPEN(H5T_NATIVE_SHORT_g)

const H5T_NATIVE_USHORT = H5OPEN(H5T_NATIVE_USHORT_g)

const H5T_NATIVE_INT = H5OPEN(H5T_NATIVE_INT_g)

const H5T_NATIVE_UINT = H5OPEN(H5T_NATIVE_UINT_g)

const H5T_NATIVE_LONG = H5OPEN(H5T_NATIVE_LONG_g)

const H5T_NATIVE_ULONG = H5OPEN(H5T_NATIVE_ULONG_g)

const H5T_NATIVE_LLONG = H5OPEN(H5T_NATIVE_LLONG_g)

const H5T_NATIVE_ULLONG = H5OPEN(H5T_NATIVE_ULLONG_g)

const H5T_NATIVE_FLOAT = H5OPEN(H5T_NATIVE_FLOAT_g)

const H5T_NATIVE_DOUBLE = H5OPEN(H5T_NATIVE_DOUBLE_g)

const H5T_NATIVE_LDOUBLE = H5OPEN(H5T_NATIVE_LDOUBLE_g)

const H5T_NATIVE_B8 = H5OPEN(H5T_NATIVE_B8_g)

const H5T_NATIVE_B16 = H5OPEN(H5T_NATIVE_B16_g)

const H5T_NATIVE_B32 = H5OPEN(H5T_NATIVE_B32_g)

const H5T_NATIVE_B64 = H5OPEN(H5T_NATIVE_B64_g)

const H5T_NATIVE_OPAQUE = H5OPEN(H5T_NATIVE_OPAQUE_g)

const H5T_NATIVE_HADDR = H5OPEN(H5T_NATIVE_HADDR_g)

const H5T_NATIVE_HSIZE = H5OPEN(H5T_NATIVE_HSIZE_g)

const H5T_NATIVE_HSSIZE = H5OPEN(H5T_NATIVE_HSSIZE_g)

const H5T_NATIVE_HERR = H5OPEN(H5T_NATIVE_HERR_g)

const H5T_NATIVE_HBOOL = H5OPEN(H5T_NATIVE_HBOOL_g)

const H5T_NATIVE_INT8 = H5OPEN(H5T_NATIVE_INT8_g)

const H5T_NATIVE_UINT8 = H5OPEN(H5T_NATIVE_UINT8_g)

const H5T_NATIVE_INT_LEAST8 = H5OPEN(H5T_NATIVE_INT_LEAST8_g)

const H5T_NATIVE_UINT_LEAST8 = H5OPEN(H5T_NATIVE_UINT_LEAST8_g)

const H5T_NATIVE_INT_FAST8 = H5OPEN(H5T_NATIVE_INT_FAST8_g)

const H5T_NATIVE_UINT_FAST8 = H5OPEN(H5T_NATIVE_UINT_FAST8_g)

const H5T_NATIVE_INT16 = H5OPEN(H5T_NATIVE_INT16_g)

const H5T_NATIVE_UINT16 = H5OPEN(H5T_NATIVE_UINT16_g)

const H5T_NATIVE_INT_LEAST16 = H5OPEN(H5T_NATIVE_INT_LEAST16_g)

const H5T_NATIVE_UINT_LEAST16 = H5OPEN(H5T_NATIVE_UINT_LEAST16_g)

const H5T_NATIVE_INT_FAST16 = H5OPEN(H5T_NATIVE_INT_FAST16_g)

const H5T_NATIVE_UINT_FAST16 = H5OPEN(H5T_NATIVE_UINT_FAST16_g)

const H5T_NATIVE_INT32 = H5OPEN(H5T_NATIVE_INT32_g)

const H5T_NATIVE_UINT32 = H5OPEN(H5T_NATIVE_UINT32_g)

const H5T_NATIVE_INT_LEAST32 = H5OPEN(H5T_NATIVE_INT_LEAST32_g)

const H5T_NATIVE_UINT_LEAST32 = H5OPEN(H5T_NATIVE_UINT_LEAST32_g)

const H5T_NATIVE_INT_FAST32 = H5OPEN(H5T_NATIVE_INT_FAST32_g)

const H5T_NATIVE_UINT_FAST32 = H5OPEN(H5T_NATIVE_UINT_FAST32_g)

const H5T_NATIVE_INT64 = H5OPEN(H5T_NATIVE_INT64_g)

const H5T_NATIVE_UINT64 = H5OPEN(H5T_NATIVE_UINT64_g)

const H5T_NATIVE_INT_LEAST64 = H5OPEN(H5T_NATIVE_INT_LEAST64_g)

const H5T_NATIVE_UINT_LEAST64 = H5OPEN(H5T_NATIVE_UINT_LEAST64_g)

const H5T_NATIVE_INT_FAST64 = H5OPEN(H5T_NATIVE_INT_FAST64_g)

const H5T_NATIVE_UINT_FAST64 = H5OPEN(H5T_NATIVE_UINT_FAST64_g)

const H5L_MAX_LINK_NAME_LEN = uint32_t(-1)

const H5L_SAME_LOC = hid_t(0)

const H5L_LINK_CLASS_T_VERS = 1

const H5L_TYPE_BUILTIN_MAX = H5L_TYPE_SOFT

const H5L_TYPE_UD_MIN = H5L_TYPE_EXTERNAL

const H5L_TYPE_UD_MAX = H5L_TYPE_MAX

const H5L_LINK_CLASS_T_VERS_0 = 0

const H5O_COPY_SHALLOW_HIERARCHY_FLAG = Cuint(0x0001)

const H5O_COPY_EXPAND_SOFT_LINK_FLAG = Cuint(0x0002)

const H5O_COPY_EXPAND_EXT_LINK_FLAG = Cuint(0x0004)

const H5O_COPY_EXPAND_REFERENCE_FLAG = Cuint(0x0008)

const H5O_COPY_WITHOUT_ATTR_FLAG = Cuint(0x0010)

const H5O_COPY_PRESERVE_NULL_FLAG = Cuint(0x0020)

const H5O_COPY_MERGE_COMMITTED_DTYPE_FLAG = Cuint(0x0040)

const H5O_COPY_ALL = Cuint(0x007f)

const H5O_SHMESG_NONE_FLAG = 0x0000

const H5O_SHMESG_SDSPACE_FLAG = unsigned(1) << 0x0001

const H5O_SHMESG_DTYPE_FLAG = unsigned(1) << 0x0003

const H5O_SHMESG_FILL_FLAG = unsigned(1) << 0x0005

const H5O_SHMESG_PLINE_FLAG = unsigned(1) << 0x000b

const H5O_SHMESG_ATTR_FLAG = unsigned(1) << 0x000c

const H5O_SHMESG_ALL_FLAG = (((H5O_SHMESG_SDSPACE_FLAG | H5O_SHMESG_DTYPE_FLAG) | H5O_SHMESG_FILL_FLAG) | H5O_SHMESG_PLINE_FLAG) | H5O_SHMESG_ATTR_FLAG

const H5O_HDR_CHUNK0_SIZE = 0x03

const H5O_HDR_ATTR_CRT_ORDER_TRACKED = 0x04

const H5O_HDR_ATTR_CRT_ORDER_INDEXED = 0x08

const H5O_HDR_ATTR_STORE_PHASE_CHANGE = 0x10

const H5O_HDR_STORE_TIMES = 0x20

const H5O_HDR_ALL_FLAGS = (((H5O_HDR_CHUNK0_SIZE | H5O_HDR_ATTR_CRT_ORDER_TRACKED) | H5O_HDR_ATTR_CRT_ORDER_INDEXED) | H5O_HDR_ATTR_STORE_PHASE_CHANGE) | H5O_HDR_STORE_TIMES

const H5O_SHMESG_MAX_NINDEXES = 8

const H5O_SHMESG_MAX_LIST_SIZE = 5000

const H5O_INFO_BASIC = Cuint(0x0001)

const H5O_INFO_TIME = Cuint(0x0002)

const H5O_INFO_NUM_ATTRS = Cuint(0x0004)

const H5O_INFO_ALL = (H5O_INFO_BASIC | H5O_INFO_TIME) | H5O_INFO_NUM_ATTRS

const H5O_NATIVE_INFO_HDR = Cuint(0x0008)

const H5O_NATIVE_INFO_META_SIZE = Cuint(0x0010)

const H5O_NATIVE_INFO_ALL = H5O_NATIVE_INFO_HDR | H5O_NATIVE_INFO_META_SIZE

const H5O_TOKEN_UNDEF = H5OPEN(H5O_TOKEN_UNDEF_g)

const H5O_INFO_HDR = Cuint(0x0008)

const H5O_INFO_META_SIZE = Cuint(0x0010)

const H5AC__CURR_CACHE_CONFIG_VERSION = 1

const H5AC__MAX_TRACE_FILE_NAME_LEN = 1024

const H5AC_METADATA_WRITE_STRATEGY__PROCESS_0_ONLY = 0

const H5AC_METADATA_WRITE_STRATEGY__DISTRIBUTED = 1

const H5AC__CURR_CACHE_IMAGE_CONFIG_VERSION = 1

const H5AC__CACHE_IMAGE__ENTRY_AGEOUT__NONE = -1

const H5AC__CACHE_IMAGE__ENTRY_AGEOUT__MAX = 100

const H5D_CHUNK_CACHE_NSLOTS_DEFAULT = size_t - 1

const H5D_CHUNK_CACHE_NBYTES_DEFAULT = size_t - 1

const H5D_CHUNK_CACHE_W0_DEFAULT = -(Float32(1.0))

const H5D_CHUNK_DONT_FILTER_PARTIAL_CHUNKS = Cuint(0x0002)

const H5D_CHUNK_BTREE = H5D_CHUNK_IDX_BTREE

const H5D_XFER_DIRECT_CHUNK_WRITE_FLAG_NAME = "direct_chunk_flag"

const H5D_XFER_DIRECT_CHUNK_WRITE_FILTERS_NAME = "direct_chunk_filters"

const H5D_XFER_DIRECT_CHUNK_WRITE_OFFSET_NAME = "direct_chunk_offset"

const H5D_XFER_DIRECT_CHUNK_WRITE_DATASIZE_NAME = "direct_chunk_datasize"

const H5D_XFER_DIRECT_CHUNK_READ_FLAG_NAME = "direct_chunk_read_flag"

const H5D_XFER_DIRECT_CHUNK_READ_OFFSET_NAME = "direct_chunk_read_offset"

const H5D_XFER_DIRECT_CHUNK_READ_FILTERS_NAME = "direct_chunk_read_filters"

const H5E_DEFAULT = hid_t(0)

const H5E_ERR_CLS = H5OPEN(H5E_ERR_CLS_g)

const H5E_FUNC = H5OPEN(H5E_FUNC_g)

const H5E_FILE = H5OPEN(H5E_FILE_g)

const H5E_VOL = H5OPEN(H5E_VOL_g)

const H5E_SOHM = H5OPEN(H5E_SOHM_g)

const H5E_SYM = H5OPEN(H5E_SYM_g)

const H5E_PLUGIN = H5OPEN(H5E_PLUGIN_g)

const H5E_VFL = H5OPEN(H5E_VFL_g)

const H5E_INTERNAL = H5OPEN(H5E_INTERNAL_g)

const H5E_BTREE = H5OPEN(H5E_BTREE_g)

const H5E_REFERENCE = H5OPEN(H5E_REFERENCE_g)

const H5E_DATASPACE = H5OPEN(H5E_DATASPACE_g)

const H5E_RESOURCE = H5OPEN(H5E_RESOURCE_g)

const H5E_RS = H5OPEN(H5E_RS_g)

const H5E_FARRAY = H5OPEN(H5E_FARRAY_g)

const H5E_HEAP = H5OPEN(H5E_HEAP_g)

const H5E_MAP = H5OPEN(H5E_MAP_g)

const H5E_ATTR = H5OPEN(H5E_ATTR_g)

const H5E_IO = H5OPEN(H5E_IO_g)

const H5E_EFL = H5OPEN(H5E_EFL_g)

const H5E_TST = H5OPEN(H5E_TST_g)

const H5E_LIB = H5OPEN(H5E_LIB_g)

const H5E_PAGEBUF = H5OPEN(H5E_PAGEBUF_g)

const H5E_FSPACE = H5OPEN(H5E_FSPACE_g)

const H5E_DATASET = H5OPEN(H5E_DATASET_g)

const H5E_STORAGE = H5OPEN(H5E_STORAGE_g)

const H5E_LINK = H5OPEN(H5E_LINK_g)

const H5E_PLIST = H5OPEN(H5E_PLIST_g)

const H5E_DATATYPE = H5OPEN(H5E_DATATYPE_g)

const H5E_OHDR = H5OPEN(H5E_OHDR_g)

const H5E_ATOM = H5OPEN(H5E_ATOM_g)

const H5E_NONE_MAJOR = H5OPEN(H5E_NONE_MAJOR_g)

const H5E_SLIST = H5OPEN(H5E_SLIST_g)

const H5E_ARGS = H5OPEN(H5E_ARGS_g)

const H5E_CONTEXT = H5OPEN(H5E_CONTEXT_g)

const H5E_EARRAY = H5OPEN(H5E_EARRAY_g)

const H5E_PLINE = H5OPEN(H5E_PLINE_g)

const H5E_ERROR = H5OPEN(H5E_ERROR_g)

const H5E_CACHE = H5OPEN(H5E_CACHE_g)

const H5E_SEEKERROR = H5OPEN(H5E_SEEKERROR_g)

const H5E_READERROR = H5OPEN(H5E_READERROR_g)

const H5E_WRITEERROR = H5OPEN(H5E_WRITEERROR_g)

const H5E_CLOSEERROR = H5OPEN(H5E_CLOSEERROR_g)

const H5E_OVERFLOW = H5OPEN(H5E_OVERFLOW_g)

const H5E_FCNTL = H5OPEN(H5E_FCNTL_g)

const H5E_NOSPACE = H5OPEN(H5E_NOSPACE_g)

const H5E_CANTALLOC = H5OPEN(H5E_CANTALLOC_g)

const H5E_CANTCOPY = H5OPEN(H5E_CANTCOPY_g)

const H5E_CANTFREE = H5OPEN(H5E_CANTFREE_g)

const H5E_ALREADYEXISTS = H5OPEN(H5E_ALREADYEXISTS_g)

const H5E_CANTLOCK = H5OPEN(H5E_CANTLOCK_g)

const H5E_CANTUNLOCK = H5OPEN(H5E_CANTUNLOCK_g)

const H5E_CANTGC = H5OPEN(H5E_CANTGC_g)

const H5E_CANTGETSIZE = H5OPEN(H5E_CANTGETSIZE_g)

const H5E_OBJOPEN = H5OPEN(H5E_OBJOPEN_g)

const H5E_CANTRESTORE = H5OPEN(H5E_CANTRESTORE_g)

const H5E_CANTCOMPUTE = H5OPEN(H5E_CANTCOMPUTE_g)

const H5E_CANTEXTEND = H5OPEN(H5E_CANTEXTEND_g)

const H5E_CANTATTACH = H5OPEN(H5E_CANTATTACH_g)

const H5E_CANTUPDATE = H5OPEN(H5E_CANTUPDATE_g)

const H5E_CANTOPERATE = H5OPEN(H5E_CANTOPERATE_g)

const H5E_CANTINIT = H5OPEN(H5E_CANTINIT_g)

const H5E_ALREADYINIT = H5OPEN(H5E_ALREADYINIT_g)

const H5E_CANTRELEASE = H5OPEN(H5E_CANTRELEASE_g)

const H5E_CANTGET = H5OPEN(H5E_CANTGET_g)

const H5E_CANTSET = H5OPEN(H5E_CANTSET_g)

const H5E_DUPCLASS = H5OPEN(H5E_DUPCLASS_g)

const H5E_SETDISALLOWED = H5OPEN(H5E_SETDISALLOWED_g)

const H5E_CANTMERGE = H5OPEN(H5E_CANTMERGE_g)

const H5E_CANTREVIVE = H5OPEN(H5E_CANTREVIVE_g)

const H5E_CANTSHRINK = H5OPEN(H5E_CANTSHRINK_g)

const H5E_LINKCOUNT = H5OPEN(H5E_LINKCOUNT_g)

const H5E_VERSION = H5OPEN(H5E_VERSION_g)

const H5E_ALIGNMENT = H5OPEN(H5E_ALIGNMENT_g)

const H5E_BADMESG = H5OPEN(H5E_BADMESG_g)

const H5E_CANTDELETE = H5OPEN(H5E_CANTDELETE_g)

const H5E_BADITER = H5OPEN(H5E_BADITER_g)

const H5E_CANTPACK = H5OPEN(H5E_CANTPACK_g)

const H5E_CANTRESET = H5OPEN(H5E_CANTRESET_g)

const H5E_CANTRENAME = H5OPEN(H5E_CANTRENAME_g)

const H5E_SYSERRSTR = H5OPEN(H5E_SYSERRSTR_g)

const H5E_NOFILTER = H5OPEN(H5E_NOFILTER_g)

const H5E_CALLBACK = H5OPEN(H5E_CALLBACK_g)

const H5E_CANAPPLY = H5OPEN(H5E_CANAPPLY_g)

const H5E_SETLOCAL = H5OPEN(H5E_SETLOCAL_g)

const H5E_NOENCODER = H5OPEN(H5E_NOENCODER_g)

const H5E_CANTFILTER = H5OPEN(H5E_CANTFILTER_g)

const H5E_CANTOPENOBJ = H5OPEN(H5E_CANTOPENOBJ_g)

const H5E_CANTCLOSEOBJ = H5OPEN(H5E_CANTCLOSEOBJ_g)

const H5E_COMPLEN = H5OPEN(H5E_COMPLEN_g)

const H5E_PATH = H5OPEN(H5E_PATH_g)

const H5E_NONE_MINOR = H5OPEN(H5E_NONE_MINOR_g)

const H5E_OPENERROR = H5OPEN(H5E_OPENERROR_g)

const H5E_FILEEXISTS = H5OPEN(H5E_FILEEXISTS_g)

const H5E_FILEOPEN = H5OPEN(H5E_FILEOPEN_g)

const H5E_CANTCREATE = H5OPEN(H5E_CANTCREATE_g)

const H5E_CANTOPENFILE = H5OPEN(H5E_CANTOPENFILE_g)

const H5E_CANTCLOSEFILE = H5OPEN(H5E_CANTCLOSEFILE_g)

const H5E_NOTHDF5 = H5OPEN(H5E_NOTHDF5_g)

const H5E_BADFILE = H5OPEN(H5E_BADFILE_g)

const H5E_TRUNCATED = H5OPEN(H5E_TRUNCATED_g)

const H5E_MOUNT = H5OPEN(H5E_MOUNT_g)

const H5E_CANTDELETEFILE = H5OPEN(H5E_CANTDELETEFILE_g)

const H5E_CANTLOCKFILE = H5OPEN(H5E_CANTLOCKFILE_g)

const H5E_CANTUNLOCKFILE = H5OPEN(H5E_CANTUNLOCKFILE_g)

const H5E_BADATOM = H5OPEN(H5E_BADATOM_g)

const H5E_BADGROUP = H5OPEN(H5E_BADGROUP_g)

const H5E_CANTREGISTER = H5OPEN(H5E_CANTREGISTER_g)

const H5E_CANTINC = H5OPEN(H5E_CANTINC_g)

const H5E_CANTDEC = H5OPEN(H5E_CANTDEC_g)

const H5E_NOIDS = H5OPEN(H5E_NOIDS_g)

const H5E_CANTFLUSH = H5OPEN(H5E_CANTFLUSH_g)

const H5E_CANTUNSERIALIZE = H5OPEN(H5E_CANTUNSERIALIZE_g)

const H5E_CANTSERIALIZE = H5OPEN(H5E_CANTSERIALIZE_g)

const H5E_CANTTAG = H5OPEN(H5E_CANTTAG_g)

const H5E_CANTLOAD = H5OPEN(H5E_CANTLOAD_g)

const H5E_PROTECT = H5OPEN(H5E_PROTECT_g)

const H5E_NOTCACHED = H5OPEN(H5E_NOTCACHED_g)

const H5E_SYSTEM = H5OPEN(H5E_SYSTEM_g)

const H5E_CANTINS = H5OPEN(H5E_CANTINS_g)

const H5E_CANTPROTECT = H5OPEN(H5E_CANTPROTECT_g)

const H5E_CANTUNPROTECT = H5OPEN(H5E_CANTUNPROTECT_g)

const H5E_CANTPIN = H5OPEN(H5E_CANTPIN_g)

const H5E_CANTUNPIN = H5OPEN(H5E_CANTUNPIN_g)

const H5E_CANTMARKDIRTY = H5OPEN(H5E_CANTMARKDIRTY_g)

const H5E_CANTMARKCLEAN = H5OPEN(H5E_CANTMARKCLEAN_g)

const H5E_CANTMARKUNSERIALIZED = H5OPEN(H5E_CANTMARKUNSERIALIZED_g)

const H5E_CANTMARKSERIALIZED = H5OPEN(H5E_CANTMARKSERIALIZED_g)

const H5E_CANTDIRTY = H5OPEN(H5E_CANTDIRTY_g)

const H5E_CANTCLEAN = H5OPEN(H5E_CANTCLEAN_g)

const H5E_CANTEXPUNGE = H5OPEN(H5E_CANTEXPUNGE_g)

const H5E_CANTRESIZE = H5OPEN(H5E_CANTRESIZE_g)

const H5E_CANTDEPEND = H5OPEN(H5E_CANTDEPEND_g)

const H5E_CANTUNDEPEND = H5OPEN(H5E_CANTUNDEPEND_g)

const H5E_CANTNOTIFY = H5OPEN(H5E_CANTNOTIFY_g)

const H5E_LOGGING = H5OPEN(H5E_LOGGING_g)

const H5E_CANTCORK = H5OPEN(H5E_CANTCORK_g)

const H5E_CANTUNCORK = H5OPEN(H5E_CANTUNCORK_g)

const H5E_TRAVERSE = H5OPEN(H5E_TRAVERSE_g)

const H5E_NLINKS = H5OPEN(H5E_NLINKS_g)

const H5E_NOTREGISTERED = H5OPEN(H5E_NOTREGISTERED_g)

const H5E_CANTMOVE = H5OPEN(H5E_CANTMOVE_g)

const H5E_CANTSORT = H5OPEN(H5E_CANTSORT_g)

const H5E_MPI = H5OPEN(H5E_MPI_g)

const H5E_MPIERRSTR = H5OPEN(H5E_MPIERRSTR_g)

const H5E_CANTRECV = H5OPEN(H5E_CANTRECV_g)

const H5E_CANTGATHER = H5OPEN(H5E_CANTGATHER_g)

const H5E_NO_INDEPENDENT = H5OPEN(H5E_NO_INDEPENDENT_g)

const H5E_CANTCLIP = H5OPEN(H5E_CANTCLIP_g)

const H5E_CANTCOUNT = H5OPEN(H5E_CANTCOUNT_g)

const H5E_CANTSELECT = H5OPEN(H5E_CANTSELECT_g)

const H5E_CANTNEXT = H5OPEN(H5E_CANTNEXT_g)

const H5E_BADSELECT = H5OPEN(H5E_BADSELECT_g)

const H5E_CANTCOMPARE = H5OPEN(H5E_CANTCOMPARE_g)

const H5E_INCONSISTENTSTATE = H5OPEN(H5E_INCONSISTENTSTATE_g)

const H5E_CANTAPPEND = H5OPEN(H5E_CANTAPPEND_g)

const H5E_UNINITIALIZED = H5OPEN(H5E_UNINITIALIZED_g)

const H5E_UNSUPPORTED = H5OPEN(H5E_UNSUPPORTED_g)

const H5E_BADTYPE = H5OPEN(H5E_BADTYPE_g)

const H5E_BADRANGE = H5OPEN(H5E_BADRANGE_g)

const H5E_BADVALUE = H5OPEN(H5E_BADVALUE_g)

const H5E_NOTFOUND = H5OPEN(H5E_NOTFOUND_g)

const H5E_EXISTS = H5OPEN(H5E_EXISTS_g)

const H5E_CANTENCODE = H5OPEN(H5E_CANTENCODE_g)

const H5E_CANTDECODE = H5OPEN(H5E_CANTDECODE_g)

const H5E_CANTSPLIT = H5OPEN(H5E_CANTSPLIT_g)

const H5E_CANTREDISTRIBUTE = H5OPEN(H5E_CANTREDISTRIBUTE_g)

const H5E_CANTSWAP = H5OPEN(H5E_CANTSWAP_g)

const H5E_CANTINSERT = H5OPEN(H5E_CANTINSERT_g)

const H5E_CANTLIST = H5OPEN(H5E_CANTLIST_g)

const H5E_CANTMODIFY = H5OPEN(H5E_CANTMODIFY_g)

const H5E_CANTREMOVE = H5OPEN(H5E_CANTREMOVE_g)

const H5E_CANTCONVERT = H5OPEN(H5E_CANTCONVERT_g)

const H5E_BADSIZE = H5OPEN(H5E_BADSIZE_g)

# Skipping MacroDefinition: H5E_BEGIN_TRY { unsigned H5E_saved_is_v2 ; union { H5E_auto1_t efunc1 ; H5E_auto2_t efunc2 ; } H5E_saved ; void * H5E_saved_edata ; ( void ) H5Eauto_is_v2 ( H5E_DEFAULT , & H5E_saved_is_v2 ) ; if ( H5E_saved_is_v2 ) { ( void ) H5Eget_auto2 ( H5E_DEFAULT , & H5E_saved . efunc2 , & H5E_saved_edata ) ; ( void ) H5Eset_auto2 ( H5E_DEFAULT , NULL , NULL ) ; } else { ( void ) H5Eget_auto1 ( & H5E_saved . efunc1 , & H5E_saved_edata ) ; ( void ) H5Eset_auto1 ( NULL , NULL ) ; }

# Skipping MacroDefinition: H5E_END_TRY if ( H5E_saved_is_v2 ) ( void ) H5Eset_auto2 ( H5E_DEFAULT , H5E_saved . efunc2 , H5E_saved_edata ) ; else ( void ) H5Eset_auto1 ( H5E_saved . efunc1 , H5E_saved_edata ) ; }

# Skipping MacroDefinition: H5CHECK H5check ( ) ,

const H5F_ACC_RDONLY = (H5CHECK(H5OPEN))(Cuint(0x0000))

const H5F_ACC_RDWR = (H5CHECK(H5OPEN))(Cuint(0x0001))

const H5F_ACC_TRUNC = (H5CHECK(H5OPEN))(Cuint(0x0002))

const H5F_ACC_EXCL = (H5CHECK(H5OPEN))(Cuint(0x0004))

const H5F_ACC_CREAT = (H5CHECK(H5OPEN))(Cuint(0x0010))

const H5F_ACC_SWMR_WRITE = H5CHECK(Cuint(0x0020))

const H5F_ACC_SWMR_READ = H5CHECK(Cuint(0x0040))

const H5F_ACC_DEFAULT = (H5CHECK(H5OPEN))(Cuint(0xffff))

const H5F_OBJ_FILE = Cuint(0x0001)

const H5F_OBJ_DATASET = Cuint(0x0002)

const H5F_OBJ_GROUP = Cuint(0x0004)

const H5F_OBJ_DATATYPE = Cuint(0x0008)

const H5F_OBJ_ATTR = Cuint(0x0010)

const H5F_OBJ_ALL = (((H5F_OBJ_FILE | H5F_OBJ_DATASET) | H5F_OBJ_GROUP) | H5F_OBJ_DATATYPE) | H5F_OBJ_ATTR

const H5F_OBJ_LOCAL = Cuint(0x0020)

const H5F_FAMILY_DEFAULT = hsize_t(0)

const H5F_UNLIMITED = hsize_t(Clong(-1))

const H5F_LIBVER_LATEST = H5F_LIBVER_V112

const H5F_NUM_METADATA_READ_RETRY_TYPES = 21

const H5F_ACC_DEBUG = (H5CHECK(H5OPEN))(Cuint(0x0000))

const H5_HAVE_VFL = 1

const H5FD_VFD_DEFAULT = 0

const H5FD_MEM_FHEAP_HDR = H5FD_MEM_OHDR

const H5FD_MEM_FHEAP_IBLOCK = H5FD_MEM_OHDR

const H5FD_MEM_FHEAP_DBLOCK = H5FD_MEM_LHEAP

const H5FD_MEM_FHEAP_HUGE_OBJ = H5FD_MEM_DRAW

const H5FD_MEM_FSPACE_HDR = H5FD_MEM_OHDR

const H5FD_MEM_FSPACE_SINFO = H5FD_MEM_LHEAP

const H5FD_MEM_SOHM_TABLE = H5FD_MEM_OHDR

const H5FD_MEM_SOHM_INDEX = H5FD_MEM_BTREE

const H5FD_MEM_EARRAY_HDR = H5FD_MEM_OHDR

const H5FD_MEM_EARRAY_IBLOCK = H5FD_MEM_OHDR

const H5FD_MEM_EARRAY_SBLOCK = H5FD_MEM_BTREE

const H5FD_MEM_EARRAY_DBLOCK = H5FD_MEM_LHEAP

const H5FD_MEM_EARRAY_DBLK_PAGE = H5FD_MEM_LHEAP

const H5FD_MEM_FARRAY_HDR = H5FD_MEM_OHDR

const H5FD_MEM_FARRAY_DBLOCK = H5FD_MEM_LHEAP

const H5FD_MEM_FARRAY_DBLK_PAGE = H5FD_MEM_LHEAP

# Skipping MacroDefinition: H5FD_FLMAP_SINGLE { H5FD_MEM_SUPER , /*default*/ H5FD_MEM_SUPER , /*super*/ H5FD_MEM_SUPER , /*btree*/ H5FD_MEM_SUPER , /*draw*/ H5FD_MEM_SUPER , /*gheap*/ H5FD_MEM_SUPER , /*lheap*/ H5FD_MEM_SUPER /*ohdr*/ }

# Skipping MacroDefinition: H5FD_FLMAP_DICHOTOMY { H5FD_MEM_SUPER , /*default*/ H5FD_MEM_SUPER , /*super*/ H5FD_MEM_SUPER , /*btree*/ H5FD_MEM_DRAW , /*draw*/ H5FD_MEM_DRAW , /*gheap*/ H5FD_MEM_SUPER , /*lheap*/ H5FD_MEM_SUPER /*ohdr*/ }

# Skipping MacroDefinition: H5FD_FLMAP_DEFAULT { H5FD_MEM_DEFAULT , /*default*/ H5FD_MEM_DEFAULT , /*super*/ H5FD_MEM_DEFAULT , /*btree*/ H5FD_MEM_DEFAULT , /*draw*/ H5FD_MEM_DEFAULT , /*gheap*/ H5FD_MEM_DEFAULT , /*lheap*/ H5FD_MEM_DEFAULT /*ohdr*/ }

const H5FD_FEAT_AGGREGATE_METADATA = 0x00000001

const H5FD_FEAT_ACCUMULATE_METADATA_WRITE = 0x00000002

const H5FD_FEAT_ACCUMULATE_METADATA_READ = 0x00000004

const H5FD_FEAT_ACCUMULATE_METADATA = H5FD_FEAT_ACCUMULATE_METADATA_WRITE | H5FD_FEAT_ACCUMULATE_METADATA_READ

const H5FD_FEAT_DATA_SIEVE = 0x00000008

const H5FD_FEAT_AGGREGATE_SMALLDATA = 0x00000010

const H5FD_FEAT_IGNORE_DRVRINFO = 0x00000020

const H5FD_FEAT_DIRTY_DRVRINFO_LOAD = 0x00000040

const H5FD_FEAT_POSIX_COMPAT_HANDLE = 0x00000080

const H5FD_FEAT_HAS_MPI = 0x00000100

const H5FD_FEAT_ALLOCATE_EARLY = 0x00000200

const H5FD_FEAT_ALLOW_FILE_IMAGE = 0x00000400

const H5FD_FEAT_CAN_USE_FILE_IMAGE_CALLBACKS = 0x00000800

const H5FD_FEAT_SUPPORTS_SWMR_IO = 0x00001000

const H5FD_FEAT_USE_ALLOC_SIZE = 0x00002000

const H5FD_FEAT_PAGED_AGGR = 0x00004000

const H5FD_FEAT_DEFAULT_VFD_COMPATIBLE = 0x00008000

const H5G_SAME_LOC = H5L_SAME_LOC

const H5G_LINK_ERROR = H5L_TYPE_ERROR

const H5G_LINK_HARD = H5L_TYPE_HARD

const H5G_LINK_SOFT = H5L_TYPE_SOFT

const H5G_link_t = H5L_type_t

const H5G_NTYPES = 256

const H5G_NLIBTYPES = 8

const H5G_NUSERTYPES = H5G_NTYPES - H5G_NLIBTYPES

const H5VL_MAP_CREATE = 1

const H5VL_MAP_OPEN = 2

const H5VL_MAP_GET_VAL = 3

const H5VL_MAP_EXISTS = 4

const H5VL_MAP_PUT = 5

const H5VL_MAP_GET = 6

const H5VL_MAP_SPECIFIC = 7

const H5VL_MAP_OPTIONAL = 8

const H5VL_MAP_CLOSE = 9

const H5Z_FILTER_ERROR = -1

const H5Z_FILTER_NONE = 0

const H5Z_FILTER_DEFLATE = 1

const H5Z_FILTER_SHUFFLE = 2

const H5Z_FILTER_FLETCHER32 = 3

const H5Z_FILTER_SZIP = 4

const H5Z_FILTER_NBIT = 5

const H5Z_FILTER_SCALEOFFSET = 6

const H5Z_FILTER_RESERVED = 256

const H5Z_FILTER_MAX = 65535

const H5Z_FILTER_ALL = 0

const H5Z_MAX_NFILTERS = 32

const H5Z_FLAG_DEFMASK = 0x00ff

const H5Z_FLAG_MANDATORY = 0x0000

const H5Z_FLAG_OPTIONAL = 0x0001

const H5Z_FLAG_INVMASK = 0xff00

const H5Z_FLAG_REVERSE = 0x0100

const H5Z_FLAG_SKIP_EDC = 0x0200

const H5_SZIP_ALLOW_K13_OPTION_MASK = 1

const H5_SZIP_CHIP_OPTION_MASK = 2

const H5_SZIP_EC_OPTION_MASK = 4

const H5_SZIP_NN_OPTION_MASK = 32

const H5_SZIP_MAX_PIXELS_PER_BLOCK = 32

const H5Z_SHUFFLE_USER_NPARMS = 0

const H5Z_SHUFFLE_TOTAL_NPARMS = 1

const H5Z_SZIP_USER_NPARMS = 2

const H5Z_SZIP_TOTAL_NPARMS = 4

const H5Z_SZIP_PARM_MASK = 0

const H5Z_SZIP_PARM_PPB = 1

const H5Z_SZIP_PARM_BPP = 2

const H5Z_SZIP_PARM_PPS = 3

const H5Z_NBIT_USER_NPARMS = 0

const H5Z_SCALEOFFSET_USER_NPARMS = 2

const H5Z_SO_INT_MINBITS_DEFAULT = 0

const H5Z_CLASS_T_VERS = 1

const H5Z_FILTER_CONFIG_ENCODE_ENABLED = 0x0001

const H5Z_FILTER_CONFIG_DECODE_ENABLED = 0x0002

const H5P_ROOT = H5OPEN(H5P_CLS_ROOT_ID_g)

const H5P_OBJECT_CREATE = H5OPEN(H5P_CLS_OBJECT_CREATE_ID_g)

const H5P_FILE_CREATE = H5OPEN(H5P_CLS_FILE_CREATE_ID_g)

const H5P_FILE_ACCESS = H5OPEN(H5P_CLS_FILE_ACCESS_ID_g)

const H5P_DATASET_CREATE = H5OPEN(H5P_CLS_DATASET_CREATE_ID_g)

const H5P_DATASET_ACCESS = H5OPEN(H5P_CLS_DATASET_ACCESS_ID_g)

const H5P_DATASET_XFER = H5OPEN(H5P_CLS_DATASET_XFER_ID_g)

const H5P_FILE_MOUNT = H5OPEN(H5P_CLS_FILE_MOUNT_ID_g)

const H5P_GROUP_CREATE = H5OPEN(H5P_CLS_GROUP_CREATE_ID_g)

const H5P_GROUP_ACCESS = H5OPEN(H5P_CLS_GROUP_ACCESS_ID_g)

const H5P_DATATYPE_CREATE = H5OPEN(H5P_CLS_DATATYPE_CREATE_ID_g)

const H5P_DATATYPE_ACCESS = H5OPEN(H5P_CLS_DATATYPE_ACCESS_ID_g)

const H5P_MAP_CREATE = H5OPEN(H5P_CLS_MAP_CREATE_ID_g)

const H5P_MAP_ACCESS = H5OPEN(H5P_CLS_MAP_ACCESS_ID_g)

const H5P_STRING_CREATE = H5OPEN(H5P_CLS_STRING_CREATE_ID_g)

const H5P_ATTRIBUTE_CREATE = H5OPEN(H5P_CLS_ATTRIBUTE_CREATE_ID_g)

const H5P_ATTRIBUTE_ACCESS = H5OPEN(H5P_CLS_ATTRIBUTE_ACCESS_ID_g)

const H5P_OBJECT_COPY = H5OPEN(H5P_CLS_OBJECT_COPY_ID_g)

const H5P_LINK_CREATE = H5OPEN(H5P_CLS_LINK_CREATE_ID_g)

const H5P_LINK_ACCESS = H5OPEN(H5P_CLS_LINK_ACCESS_ID_g)

const H5P_VOL_INITIALIZE = H5OPEN(H5P_CLS_VOL_INITIALIZE_ID_g)

const H5P_REFERENCE_ACCESS = H5OPEN(H5P_CLS_REFERENCE_ACCESS_ID_g)

const H5P_FILE_CREATE_DEFAULT = H5OPEN(H5P_LST_FILE_CREATE_ID_g)

const H5P_FILE_ACCESS_DEFAULT = H5OPEN(H5P_LST_FILE_ACCESS_ID_g)

const H5P_DATASET_CREATE_DEFAULT = H5OPEN(H5P_LST_DATASET_CREATE_ID_g)

const H5P_DATASET_ACCESS_DEFAULT = H5OPEN(H5P_LST_DATASET_ACCESS_ID_g)

const H5P_DATASET_XFER_DEFAULT = H5OPEN(H5P_LST_DATASET_XFER_ID_g)

const H5P_FILE_MOUNT_DEFAULT = H5OPEN(H5P_LST_FILE_MOUNT_ID_g)

const H5P_GROUP_CREATE_DEFAULT = H5OPEN(H5P_LST_GROUP_CREATE_ID_g)

const H5P_GROUP_ACCESS_DEFAULT = H5OPEN(H5P_LST_GROUP_ACCESS_ID_g)

const H5P_DATATYPE_CREATE_DEFAULT = H5OPEN(H5P_LST_DATATYPE_CREATE_ID_g)

const H5P_DATATYPE_ACCESS_DEFAULT = H5OPEN(H5P_LST_DATATYPE_ACCESS_ID_g)

const H5P_MAP_CREATE_DEFAULT = H5OPEN(H5P_LST_MAP_CREATE_ID_g)

const H5P_MAP_ACCESS_DEFAULT = H5OPEN(H5P_LST_MAP_ACCESS_ID_g)

const H5P_ATTRIBUTE_CREATE_DEFAULT = H5OPEN(H5P_LST_ATTRIBUTE_CREATE_ID_g)

const H5P_ATTRIBUTE_ACCESS_DEFAULT = H5OPEN(H5P_LST_ATTRIBUTE_ACCESS_ID_g)

const H5P_OBJECT_COPY_DEFAULT = H5OPEN(H5P_LST_OBJECT_COPY_ID_g)

const H5P_LINK_CREATE_DEFAULT = H5OPEN(H5P_LST_LINK_CREATE_ID_g)

const H5P_LINK_ACCESS_DEFAULT = H5OPEN(H5P_LST_LINK_ACCESS_ID_g)

const H5P_VOL_INITIALIZE_DEFAULT = H5OPEN(H5P_LST_VOL_INITIALIZE_ID_g)

const H5P_REFERENCE_ACCESS_DEFAULT = H5OPEN(H5P_LST_REFERENCE_ACCESS_ID_g)

const H5P_CRT_ORDER_TRACKED = 0x0001

const H5P_CRT_ORDER_INDEXED = 0x0002

const H5P_DEFAULT = hid_t(0)

const H5P_NO_CLASS = H5P_ROOT

const H5PL_NO_PLUGIN = "::"

const H5PL_FILTER_PLUGIN = 0x0001

const H5PL_VOL_PLUGIN = 0x0002

const H5PL_ALL_PLUGIN = 0xffff

# Skipping MacroDefinition: H5R_OBJ_REF_BUF_SIZE sizeof ( haddr_t )

# Skipping MacroDefinition: H5R_DSET_REG_REF_BUF_SIZE ( sizeof ( haddr_t ) + 4 )

const H5R_REF_BUF_SIZE = 64

const H5R_OBJECT = H5R_OBJECT1

const H5R_DATASET_REGION = H5R_DATASET_REGION1

const H5S_ALL = hid_t(0)

const H5S_UNLIMITED = HSIZE_UNDEF

const H5S_MAX_RANK = 32

const H5S_SEL_ITER_GET_SEQ_LIST_SORTED = 0x0001

const H5S_SEL_ITER_SHARE_WITH_DATASPACE = 0x0002

const H5VL_VERSION = 0

const H5_VOL_INVALID = -1

const H5_VOL_NATIVE = 0

const H5_VOL_RESERVED = 256

const H5_VOL_MAX = 65535

const H5VL_CAP_FLAG_NONE = 0

const H5VL_CAP_FLAG_THREADSAFE = 0x01

const H5VL_CONTAINER_INFO_VERSION = 0x01

const H5VL_MAX_BLOB_ID_SIZE = 16

const H5VL_NATIVE = H5VL_native_register()

const H5VL_NATIVE_NAME = "native"

const H5VL_NATIVE_VALUE = H5_VOL_NATIVE

const H5VL_NATIVE_VERSION = 0

const H5VL_NATIVE_ATTR_ITERATE_OLD = 0

const H5VL_NATIVE_DATASET_FORMAT_CONVERT = 0

const H5VL_NATIVE_DATASET_GET_CHUNK_INDEX_TYPE = 1

const H5VL_NATIVE_DATASET_GET_CHUNK_STORAGE_SIZE = 2

const H5VL_NATIVE_DATASET_GET_NUM_CHUNKS = 3

const H5VL_NATIVE_DATASET_GET_CHUNK_INFO_BY_IDX = 4

const H5VL_NATIVE_DATASET_GET_CHUNK_INFO_BY_COORD = 5

const H5VL_NATIVE_DATASET_CHUNK_READ = 6

const H5VL_NATIVE_DATASET_CHUNK_WRITE = 7

const H5VL_NATIVE_DATASET_GET_VLEN_BUF_SIZE = 8

const H5VL_NATIVE_DATASET_GET_OFFSET = 9

const H5VL_NATIVE_FILE_CLEAR_ELINK_CACHE = 0

const H5VL_NATIVE_FILE_GET_FILE_IMAGE = 1

const H5VL_NATIVE_FILE_GET_FREE_SECTIONS = 2

const H5VL_NATIVE_FILE_GET_FREE_SPACE = 3

const H5VL_NATIVE_FILE_GET_INFO = 4

const H5VL_NATIVE_FILE_GET_MDC_CONF = 5

const H5VL_NATIVE_FILE_GET_MDC_HR = 6

const H5VL_NATIVE_FILE_GET_MDC_SIZE = 7

const H5VL_NATIVE_FILE_GET_SIZE = 8

const H5VL_NATIVE_FILE_GET_VFD_HANDLE = 9

const H5VL_NATIVE_FILE_RESET_MDC_HIT_RATE = 10

const H5VL_NATIVE_FILE_SET_MDC_CONFIG = 11

const H5VL_NATIVE_FILE_GET_METADATA_READ_RETRY_INFO = 12

const H5VL_NATIVE_FILE_START_SWMR_WRITE = 13

const H5VL_NATIVE_FILE_START_MDC_LOGGING = 14

const H5VL_NATIVE_FILE_STOP_MDC_LOGGING = 15

const H5VL_NATIVE_FILE_GET_MDC_LOGGING_STATUS = 16

const H5VL_NATIVE_FILE_FORMAT_CONVERT = 17

const H5VL_NATIVE_FILE_RESET_PAGE_BUFFERING_STATS = 18

const H5VL_NATIVE_FILE_GET_PAGE_BUFFERING_STATS = 19

const H5VL_NATIVE_FILE_GET_MDC_IMAGE_INFO = 20

const H5VL_NATIVE_FILE_GET_EOA = 21

const H5VL_NATIVE_FILE_INCR_FILESIZE = 22

const H5VL_NATIVE_FILE_SET_LIBVER_BOUNDS = 23

const H5VL_NATIVE_FILE_GET_MIN_DSET_OHDR_FLAG = 24

const H5VL_NATIVE_FILE_SET_MIN_DSET_OHDR_FLAG = 25

const H5VL_NATIVE_FILE_GET_MPI_ATOMICITY = 26

const H5VL_NATIVE_FILE_SET_MPI_ATOMICITY = 27

const H5VL_NATIVE_FILE_POST_OPEN = 28

const H5VL_NATIVE_GROUP_ITERATE_OLD = 0

const H5VL_NATIVE_GROUP_GET_OBJINFO = 1

const H5VL_NATIVE_OBJECT_GET_COMMENT = 0

const H5VL_NATIVE_OBJECT_SET_COMMENT = 1

const H5VL_NATIVE_OBJECT_DISABLE_MDC_FLUSHES = 2

const H5VL_NATIVE_OBJECT_ENABLE_MDC_FLUSHES = 3

const H5VL_NATIVE_OBJECT_ARE_MDC_FLUSHES_DISABLED = 4

const H5VL_NATIVE_OBJECT_GET_NATIVE_INFO = 5

const H5FD_CORE = H5FD_core_init()

const H5FD_DIRECT = H5I_INVALID_HID

const H5FD_FAMILY = H5FD_family_init()

const H5FD_HDFS = H5I_INVALID_HID

const H5FD__CURR_HDFS_FAPL_T_VERSION = 1

const H5FD__HDFS_NODE_NAME_SPACE = 128

const H5FD__HDFS_USER_NAME_SPACE = 128

const H5FD__HDFS_KERB_CACHE_PATH_SPACE = 128

const H5FD_LOG = H5FD_log_init()

const H5FD_LOG_TRUNCATE = 0x00000001

const H5FD_LOG_META_IO = H5FD_LOG_TRUNCATE

const H5FD_LOG_LOC_READ = 0x00000002

const H5FD_LOG_LOC_WRITE = 0x00000004

const H5FD_LOG_LOC_SEEK = 0x00000008

const H5FD_LOG_LOC_IO = (H5FD_LOG_LOC_READ | H5FD_LOG_LOC_WRITE) | H5FD_LOG_LOC_SEEK

const H5FD_LOG_FILE_READ = 0x00000010

const H5FD_LOG_FILE_WRITE = 0x00000020

const H5FD_LOG_FILE_IO = H5FD_LOG_FILE_READ | H5FD_LOG_FILE_WRITE

const H5FD_LOG_FLAVOR = 0x00000040

const H5FD_LOG_NUM_READ = 0x00000080

const H5FD_LOG_NUM_WRITE = 0x00000100

const H5FD_LOG_NUM_SEEK = 0x00000200

const H5FD_LOG_NUM_TRUNCATE = 0x00000400

const H5FD_LOG_NUM_IO = ((H5FD_LOG_NUM_READ | H5FD_LOG_NUM_WRITE) | H5FD_LOG_NUM_SEEK) | H5FD_LOG_NUM_TRUNCATE

const H5FD_LOG_TIME_OPEN = 0x00000800

const H5FD_LOG_TIME_STAT = 0x00001000

const H5FD_LOG_TIME_READ = 0x00002000

const H5FD_LOG_TIME_WRITE = 0x00004000

const H5FD_LOG_TIME_SEEK = 0x00008000

const H5FD_LOG_TIME_TRUNCATE = 0x00010000

const H5FD_LOG_TIME_CLOSE = 0x00020000

const H5FD_LOG_TIME_IO = (((((H5FD_LOG_TIME_OPEN | H5FD_LOG_TIME_STAT) | H5FD_LOG_TIME_READ) | H5FD_LOG_TIME_WRITE) | H5FD_LOG_TIME_SEEK) | H5FD_LOG_TIME_TRUNCATE) | H5FD_LOG_TIME_CLOSE

const H5FD_LOG_ALLOC = 0x00040000

const H5FD_LOG_FREE = 0x00080000

const H5FD_LOG_ALL = ((((((H5FD_LOG_FREE | H5FD_LOG_ALLOC) | H5FD_LOG_TIME_IO) | H5FD_LOG_NUM_IO) | H5FD_LOG_FLAVOR) | H5FD_LOG_FILE_IO) | H5FD_LOG_LOC_IO) | H5FD_LOG_META_IO

const H5FD_MIRROR = H5I_INAVLID_HID

const H5D_ONE_LINK_CHUNK_IO_THRESHOLD = 0

const H5D_MULTI_CHUNK_IO_COL_THRESHOLD = 60

const H5FD_MPIO = H5I_INVALID_HID

const H5FD_MULTI = H5FD_multi_init()

const H5FD_ROS3 = H5I_INVALID_HID

const H5FD_SEC2 = H5FD_sec2_init()

const H5FD_SPLITTER = H5FD_splitter_init()

const H5FD_CURR_SPLITTER_VFD_CONFIG_VERSION = 1

const H5FD_SPLITTER_PATH_MAX = 4096

const H5FD_SPLITTER_MAGIC = 0x2b916880

const H5FD_STDIO = H5FD_stdio_init()

const H5FD_WINDOWS = H5FD_sec2_init()

const H5VL_PASSTHRU = H5VL_pass_through_register()

const H5VL_PASSTHRU_NAME = "pass_through"

const H5VL_PASSTHRU_VALUE = 505

const H5VL_PASSTHRU_VERSION = 0

# exports
const PREFIXES = ["H5"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
