__precompile__()

module HDF5

using Compat

using Base: unsafe_convert
using Compat: StringVector

import Base:
    close, convert, done, eltype, endof, flush, getindex, ==,
    isempty, isvalid, length, names, ndims, next, parent, read,
    setindex!, show, size, sizeof, start, write, isopen

export
    # types
    HDF5Attribute, HDF5File, HDF5Group, HDF5Dataset, HDF5Datatype,
    HDF5Dataspace, HDF5Object, HDF5Properties, HDF5Vlen, HDF5ChunkStorage,
    # functions
    a_create, a_delete, a_open, a_read, a_write, attrs,
    d_create, d_create_external, d_open, d_read, d_write,
    dataspace, datatype, exists, file, filename,
    g_create, g_open, get_chunk, get_create_properties, get_datasets,
    h5open, h5read, h5rewrite, h5writeattr, h5readattr, h5write,
    has, iscontiguous, ishdf5, ismmappable, name,
    o_copy, o_delete, o_open, p_create,
    readmmap, @read, @write, root, set_dims!, t_create, t_commit

include("datafile.jl")

### Load and initialize the HDF library ###
const depsfile = joinpath(dirname(@__DIR__), "deps", "deps.jl")
if isfile(depsfile)
    include(depsfile)
else
    error("HDF5 not properly installed. Please run Pkg.build(\"HDF5\")")
end

let d = dirname(libhdf5), b = basename(libhdf5)
    base,ext = split(b, ".", limit=2)
    hl = joinpath(d, "libhdf5_hl.$ext")
    global const libhdf5_hl = isfile(hl) ? hl : ""
end

function init_libhdf5()
    status = ccall((:H5open, libhdf5), Cint, ())
    status < 0 && error("Can't initialize the HDF5 library")
    nothing
end

function h5_get_libversion()
    majnum, minnum, relnum = Ref{Cuint}(), Ref{Cuint}(), Ref{Cuint}()
    status = ccall((:H5get_libversion, libhdf5),
                   Cint, (Ptr{Cuint}, Ptr{Cuint}, Ptr{Cuint}), majnum, minnum, relnum)
    status < 0 && error("Error getting HDF5 library version")
    VersionNumber(majnum[], minnum[], relnum[])
end

const libversion = h5_get_libversion()

## C types
const C_time_t = Int

## HDF5 types and constants
if libversion >= v"1.10.0"
    const Hid = Int64
else
    const Hid = Cint
end
const Herr    = Cint
const Hsize   = UInt64
const Hssize  = Int64
const Htri    = Cint   # pseudo-boolean (negative if error)
const Haddr   = UInt64

# Function to extract exported library constants
# Kudos to the library developers for making these available this way!
const libhdf5handle = Libdl.dlopen(libhdf5)
read_const(sym::Symbol) = unsafe_load(convert(Ptr{Hid}, Libdl.dlsym(libhdf5handle, sym)))

# iteration order constants
const H5_ITER_UNKNOWN = -1
const H5_ITER_INC     = 0
const H5_ITER_DEC     = 1
const H5_ITER_NATIVE  = 2
const H5_ITER_N       = 3
# indexing type constants
const H5_INDEX_UNKNOWN   = -1
const H5_INDEX_NAME      = 0
const H5_INDEX_CRT_ORDER = 1
# dataset constants
const H5D_COMPACT      = 0
const H5D_CONTIGUOUS   = 1
const H5D_CHUNKED      = 2
# error-related constants
const H5E_DEFAULT      = 0
# file access modes
const H5F_ACC_RDONLY     = 0x0000
const H5F_ACC_RDWR       = 0x0001
const H5F_ACC_TRUNC      = 0x0002
const H5F_ACC_EXCL       = 0x0004
const H5F_ACC_DEBUG      = 0x0008
const H5F_ACC_CREAT      = 0x0010
const H5F_ACC_SWMR_WRITE = 0x0020
const H5F_ACC_SWMR_READ  = 0x0040
# object types
const H5F_OBJ_FILE     = 0x0001
const H5F_OBJ_DATASET  = 0x0002
const H5F_OBJ_GROUP    = 0x0004
const H5F_OBJ_DATATYPE = 0x0008
const H5F_OBJ_ATTR     = 0x0010
const H5F_OBJ_ALL      = (H5F_OBJ_FILE|H5F_OBJ_DATASET|H5F_OBJ_GROUP|H5F_OBJ_DATATYPE|H5F_OBJ_ATTR)
const H5F_OBJ_LOCAL    = 0x0020
# other file constants
const H5F_SCOPE_LOCAL   = 0
const H5F_SCOPE_GLOBAL  = 1
const H5F_CLOSE_DEFAULT = 0
const H5F_CLOSE_WEAK    = 1
const H5F_CLOSE_SEMI    = 2
const H5F_CLOSE_STRONG  = 3
# object types (C enum H5Itype_t)
const H5I_FILE         = 1
const H5I_GROUP        = 2
const H5I_DATATYPE     = 3
const H5I_DATASPACE    = 4
const H5I_DATASET      = 5
const H5I_ATTR         = 6
const H5I_REFERENCE    = 7
# Link constants
const H5L_TYPE_HARD    = 0
const H5L_TYPE_SOFT    = 1
const H5L_TYPE_EXTERNAL= 2
# Object constants
const H5O_TYPE_GROUP   = 0
const H5O_TYPE_DATASET = 1
const H5O_TYPE_NAMED_DATATYPE = 2
# Property constants
const H5P_DEFAULT          = 0
const H5P_OBJECT_CREATE    = read_const(libversion >= v"1.8.14" ? :H5P_CLS_OBJECT_CREATE_ID_g    : :H5P_CLS_OBJECT_CREATE_g)
const H5P_FILE_CREATE      = read_const(libversion >= v"1.8.14" ? :H5P_CLS_FILE_CREATE_ID_g      : :H5P_CLS_FILE_CREATE_g)
const H5P_FILE_ACCESS      = read_const(libversion >= v"1.8.14" ? :H5P_CLS_FILE_ACCESS_ID_g      : :H5P_CLS_FILE_ACCESS_g)
const H5P_DATASET_CREATE   = read_const(libversion >= v"1.8.14" ? :H5P_CLS_DATASET_CREATE_ID_g   : :H5P_CLS_DATASET_CREATE_g)
const H5P_DATASET_ACCESS   = read_const(libversion >= v"1.8.14" ? :H5P_CLS_DATASET_ACCESS_ID_g   : :H5P_CLS_DATASET_ACCESS_g)
const H5P_DATASET_XFER     = read_const(libversion >= v"1.8.14" ? :H5P_CLS_DATASET_XFER_ID_g     : :H5P_CLS_DATASET_XFER_g)
const H5P_FILE_MOUNT       = read_const(libversion >= v"1.8.14" ? :H5P_CLS_FILE_MOUNT_ID_g       : :H5P_CLS_FILE_MOUNT_g)
const H5P_GROUP_CREATE     = read_const(libversion >= v"1.8.14" ? :H5P_CLS_GROUP_CREATE_ID_g     : :H5P_CLS_GROUP_CREATE_g)
const H5P_GROUP_ACCESS     = read_const(libversion >= v"1.8.14" ? :H5P_CLS_GROUP_ACCESS_ID_g     : :H5P_CLS_GROUP_ACCESS_g)
const H5P_DATATYPE_CREATE  = read_const(libversion >= v"1.8.14" ? :H5P_CLS_DATATYPE_CREATE_ID_g  : :H5P_CLS_DATATYPE_CREATE_g)
const H5P_DATATYPE_ACCESS  = read_const(libversion >= v"1.8.14" ? :H5P_CLS_DATATYPE_ACCESS_ID_g  : :H5P_CLS_DATATYPE_ACCESS_g)
const H5P_STRING_CREATE    = read_const(libversion >= v"1.8.14" ? :H5P_CLS_STRING_CREATE_ID_g    : :H5P_CLS_STRING_CREATE_g)
const H5P_ATTRIBUTE_CREATE = read_const(libversion >= v"1.8.14" ? :H5P_CLS_ATTRIBUTE_CREATE_ID_g : :H5P_CLS_ATTRIBUTE_CREATE_g)
const H5P_OBJECT_COPY      = read_const(libversion >= v"1.8.14" ? :H5P_CLS_OBJECT_COPY_ID_g      : :H5P_CLS_OBJECT_COPY_g)
const H5P_LINK_CREATE      = read_const(libversion >= v"1.8.14" ? :H5P_CLS_LINK_CREATE_ID_g      : :H5P_CLS_LINK_CREATE_g)
const H5P_LINK_ACCESS      = read_const(libversion >= v"1.8.14" ? :H5P_CLS_LINK_ACCESS_ID_g      : :H5P_CLS_LINK_ACCESS_g)
# Reference constants
const H5R_OBJECT         = 0
const H5R_DATASET_REGION = 1
const H5R_OBJ_REF_BUF_SIZE      = 8
const H5R_DSET_REG_REF_BUF_SIZE = 12
# Dataspace constants
const H5S_ALL          = convert(Hid, 0)
const H5S_SCALAR       = convert(Hid, 0)
const H5S_SIMPLE       = convert(Hid, 1)
const H5S_NULL         = convert(Hid, 2)
const H5S_UNLIMITED    = typemax(Hsize)
# Dataspace selection constants
const H5S_SELECT_SET   = 0
const H5S_SELECT_OR    = 1
const H5S_SELECT_AND   = 2
const H5S_SELECT_XOR   = 3
const H5S_SELECT_NOTB  = 4
const H5S_SELECT_NOTA  = 5
const H5S_SELECT_APPEND  = 6
const H5S_SELECT_PREPEND = 7
# type classes (C enum H5T_class_t)
const H5T_INTEGER      = convert(Hid, 0)
const H5T_FLOAT        = convert(Hid, 1)
const H5T_TIME         = convert(Hid, 2)  # not supported by HDF5 library
const H5T_STRING       = convert(Hid, 3)
const H5T_BITFIELD     = convert(Hid, 4)
const H5T_OPAQUE       = convert(Hid, 5)
const H5T_COMPOUND     = convert(Hid, 6)
const H5T_REFERENCE    = convert(Hid, 7)
const H5T_ENUM         = convert(Hid, 8)
const H5T_VLEN         = convert(Hid, 9)
const H5T_ARRAY        = convert(Hid, 10)
# Character types
const H5T_CSET_ASCII   = 0
const H5T_CSET_UTF8    = 1
# Sign types (C enum H5T_sign_t)
const H5T_SGN_NONE     = convert(Cint, 0)  # unsigned
const H5T_SGN_2        = convert(Cint, 1)  # 2's complement
# Search directions
const H5T_DIR_ASCEND   = 1
const H5T_DIR_DESCEND  = 2
# String padding modes
const H5T_STR_NULLTERM = 0
const H5T_STR_NULLPAD  = 1
const H5T_STR_SPACEPAD = 2
# Other type constants
const H5T_VARIABLE     = reinterpret(UInt, -1)
# Type_id constants (LE = little endian, I16 = Int16, etc)
const H5T_STD_I8LE        = read_const(:H5T_STD_I8LE_g)
const H5T_STD_I8BE        = read_const(:H5T_STD_I8BE_g)
const H5T_STD_U8LE        = read_const(:H5T_STD_U8LE_g)
const H5T_STD_U8BE        = read_const(:H5T_STD_U8BE_g)
const H5T_STD_I16LE       = read_const(:H5T_STD_I16LE_g)
const H5T_STD_I16BE       = read_const(:H5T_STD_I16BE_g)
const H5T_STD_U16LE       = read_const(:H5T_STD_U16LE_g)
const H5T_STD_U16BE       = read_const(:H5T_STD_U16BE_g)
const H5T_STD_I32LE       = read_const(:H5T_STD_I32LE_g)
const H5T_STD_I32BE       = read_const(:H5T_STD_I32BE_g)
const H5T_STD_U32LE       = read_const(:H5T_STD_U32LE_g)
const H5T_STD_U32BE       = read_const(:H5T_STD_U32BE_g)
const H5T_STD_I64LE       = read_const(:H5T_STD_I64LE_g)
const H5T_STD_I64BE       = read_const(:H5T_STD_I64BE_g)
const H5T_STD_U64LE       = read_const(:H5T_STD_U64LE_g)
const H5T_STD_U64BE       = read_const(:H5T_STD_U64BE_g)
const H5T_IEEE_F32LE      = read_const(:H5T_IEEE_F32LE_g)
const H5T_IEEE_F32BE      = read_const(:H5T_IEEE_F32BE_g)
const H5T_IEEE_F64LE      = read_const(:H5T_IEEE_F64LE_g)
const H5T_IEEE_F64BE      = read_const(:H5T_IEEE_F64BE_g)
const H5T_C_S1            = read_const(:H5T_C_S1_g)
const H5T_STD_REF_OBJ     = read_const(:H5T_STD_REF_OBJ_g)
const H5T_STD_REF_DSETREG = read_const(:H5T_STD_REF_DSETREG_g)
# Native types
const H5T_NATIVE_INT8     = read_const(:H5T_NATIVE_INT8_g)
const H5T_NATIVE_UINT8    = read_const(:H5T_NATIVE_UINT8_g)
const H5T_NATIVE_INT16    = read_const(:H5T_NATIVE_INT16_g)
const H5T_NATIVE_UINT16   = read_const(:H5T_NATIVE_UINT16_g)
const H5T_NATIVE_INT32    = read_const(:H5T_NATIVE_INT32_g)
const H5T_NATIVE_UINT32   = read_const(:H5T_NATIVE_UINT32_g)
const H5T_NATIVE_INT64    = read_const(:H5T_NATIVE_INT64_g)
const H5T_NATIVE_UINT64   = read_const(:H5T_NATIVE_UINT64_g)
const H5T_NATIVE_FLOAT    = read_const(:H5T_NATIVE_FLOAT_g)
const H5T_NATIVE_DOUBLE   = read_const(:H5T_NATIVE_DOUBLE_g)
# Library versions
const H5F_LIBVER_EARLIEST = 0
const H5F_LIBVER_LATEST   = 1
# Constructed types (occurs at runtime)
function make_float16()
    FLOAT16 = h5t_copy(H5T_NATIVE_FLOAT)
    h5t_set_fields(FLOAT16, 15, 10, 5, 0, 10)
    h5t_set_size(FLOAT16, 2)
    h5t_set_ebias(FLOAT16, 15)
    h5t_lock(FLOAT16)
    return FLOAT16
end
# const H5T_FLOAT16 = make_float16()  (in `__init__()`)

# Object reference types
struct HDF5ReferenceObj
    r::UInt64 # Size must be H5R_OBJ_REF_BUF_SIZE
end
const HDF5ReferenceObj_NULL = HDF5ReferenceObj(UInt64(0))

## Conversion between Julia types and HDF5 atomic types
hdf5_type_id(::Type{Int8})       = H5T_NATIVE_INT8
hdf5_type_id(::Type{UInt8})      = H5T_NATIVE_UINT8
hdf5_type_id(::Type{Int16})      = H5T_NATIVE_INT16
hdf5_type_id(::Type{UInt16})     = H5T_NATIVE_UINT16
hdf5_type_id(::Type{Int32})      = H5T_NATIVE_INT32
hdf5_type_id(::Type{UInt32})     = H5T_NATIVE_UINT32
hdf5_type_id(::Type{Int64})      = H5T_NATIVE_INT64
hdf5_type_id(::Type{UInt64})     = H5T_NATIVE_UINT64
#hdf5_type_id(::Type{Float16})   = H5T_FLOAT16  (in `__init__()`)
hdf5_type_id(::Type{Float32})    = H5T_NATIVE_FLOAT
hdf5_type_id(::Type{Float64})    = H5T_NATIVE_DOUBLE
hdf5_type_id(::Type{HDF5ReferenceObj}) = H5T_STD_REF_OBJ

const HDF5BitsKind = Union{Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float16, Float32, Float64}
const HDF5Scalar = Union{HDF5BitsKind, HDF5ReferenceObj}
const ScalarOrString = Union{HDF5Scalar, String}

# It's not safe to use particular id codes because these can change, so we use characteristics of the type.
const hdf5_type_map = Dict(
    (H5T_INTEGER, H5T_SGN_2, convert(Csize_t, 1)) => Int8,
    (H5T_INTEGER, H5T_SGN_2, convert(Csize_t, 2)) => Int16,
    (H5T_INTEGER, H5T_SGN_2, convert(Csize_t, 4)) => Int32,
    (H5T_INTEGER, H5T_SGN_2, convert(Csize_t, 8)) => Int64,
    (H5T_INTEGER, H5T_SGN_NONE, convert(Csize_t, 1)) => UInt8,
    (H5T_INTEGER, H5T_SGN_NONE, convert(Csize_t, 2)) => UInt16,
    (H5T_INTEGER, H5T_SGN_NONE, convert(Csize_t, 4)) => UInt32,
    (H5T_INTEGER, H5T_SGN_NONE, convert(Csize_t, 8)) => UInt64,
    (H5T_FLOAT, nothing, convert(Csize_t, 2)) => Float16,
    (H5T_FLOAT, nothing, convert(Csize_t, 4)) => Float32,
    (H5T_FLOAT, nothing, convert(Csize_t, 8)) => Float64,
)

hdf5_type_id(::Type{S}) where {S<:AbstractString}  = H5T_C_S1

# Single character types
# These are needed to safely handle VLEN objects
abstract type CharType <: AbstractString end

struct ASCIIChar <: CharType
    c::UInt8
end
length(c::ASCIIChar) = 1

struct UTF8Char <: CharType
    c::UInt8
end
length(c::UTF8Char) = 1

chartype(::Type{String}) = ASCIIChar
stringtype(::Type{ASCIIChar}) = String
stringtype(::Type{UTF8Char}) = String

cset(::Type{String}) = H5T_CSET_UTF8
cset(::Type{UTF8Char}) = H5T_CSET_UTF8
cset(::Type{ASCIIChar}) = H5T_CSET_ASCII

hdf5_type_id(::Type{C}) where {C<:CharType} = H5T_C_S1

## HDF5 uses a plain integer to refer to each file, group, or
## dataset. These are wrapped into special types in order to allow
## method dispatch.

# Note re finalizers: we use them to ensure that objects passed back
# to the user will eventually be cleaned up properly. However, since
# finalizers don't run on a predictable schedule, we also call close
# directly on function exit. (This avoids certain problems, like those
# that occur when passing a freshly-created file to some other
# application).

# This defines an "unformatted" HDF5 data file. Formatted files are defined in separate modules.
mutable struct HDF5File <: DataFile
    id::Hid
    filename::String

    function HDF5File(id, filename, toclose::Bool=true)
        f = new(id, filename)
        if toclose
            finalizer(f, close)
        end
        f
    end
end
convert(::Type{Hid}, f::HDF5File) = f.id
function show(io::IO, fid::HDF5File)
    if isvalid(fid)
        print(io, "HDF5 data file: ", fid.filename)
    else
        print(io, "HFD5 data file (closed): ", fid.filename)
    end
end


mutable struct HDF5Group <: DataFile
    id::Hid
    file::HDF5File         # the parent file

    function HDF5Group(id, file)
        g = new(id, file)
        finalizer(g, close)
        g
    end
end
convert(::Type{Hid}, g::HDF5Group) = g.id
function show(io::IO, g::HDF5Group)
    if isvalid(g)
        print(io, "HDF5 group: ", name(g), " (file: ", g.file.filename, ")")
    else
        print(io, "HFD5 group (invalid)")
    end
end

mutable struct HDF5Dataset
    id::Hid
    file::HDF5File

    function HDF5Dataset(id, file)
        dset = new(id, file)
        finalizer(dset, close)
        dset
    end
end
convert(::Type{Hid}, dset::HDF5Dataset) = dset.id
function show(io::IO, dset::HDF5Dataset)
    if isvalid(dset)
        print(io, "HDF5 dataset: ", name(dset), " (file: ", dset.file.filename, ")")
    else
        print(io, "HFD5 dataset (invalid)")
    end
end

mutable struct HDF5Datatype
    id::Hid
    toclose::Bool
    file::HDF5File

    function HDF5Datatype(id, toclose::Bool=true)
        nt = new(id, toclose)
        if toclose
            finalizer(nt, close)
        end
        nt
    end
    function HDF5Datatype(id, file::HDF5File, toclose::Bool=true)
        nt = new(id, toclose, file)
        if toclose
            finalizer(nt, close)
        end
        nt
    end
end
convert(::Type{Hid}, dtype::HDF5Datatype) = dtype.id
show(io::IO, dtype::HDF5Datatype) = print(io, "HDF5 datatype ", dtype.id) # TODO: compound datatypes?
hash(dtype::HDF5Datatype, h::UInt) =
    (dtype.id % UInt + h) ^ (0xadaf9b66bc962084 % UInt)
==(dt1::HDF5Datatype, dt2::HDF5Datatype) = h5t_equal(dt1, dt2) > 0

# Define an H5O Object type
const HDF5Object = Union{HDF5Group, HDF5Dataset, HDF5Datatype}

mutable struct HDF5Dataspace
    id::Hid

    function HDF5Dataspace(id)
        dspace = new(id)
        finalizer(dspace, close)
        dspace
    end
end
convert(::Type{Hid}, dspace::HDF5Dataspace) = dspace.id

mutable struct HDF5Attribute
    id::Hid
    file::HDF5File

    function HDF5Attribute(id, file)
        dset = new(id, file)
        finalizer(dset, close)
        dset
    end
end
convert(::Type{Hid}, attr::HDF5Attribute) = attr.id
show(io::IO, attr::HDF5Attribute) = isvalid(attr) ? print(io, "HDF5 attribute: ", name(attr)) : print(io, "HDF5 attribute (invalid)")

mutable struct HDF5Attributes
    parent::Union{HDF5File, HDF5Group, HDF5Dataset}
end
attrs(p::Union{HDF5File, HDF5Group, HDF5Dataset}) = HDF5Attributes(p)

mutable struct HDF5Properties
    id::Hid
    toclose::Bool

    function HDF5Properties(id, toclose::Bool=true)
        p = new(id, toclose)
        if toclose
            finalizer(p, close)
        end
        p
    end
end
HDF5Properties() = HDF5Properties(H5P_DEFAULT)
convert(::Type{Hid}, p::HDF5Properties) = p.id

# Methods for reference types
const REF_TEMP_ARRAY = Ref{HDF5ReferenceObj}()
function HDF5ReferenceObj(parent::Union{HDF5File, HDF5Group, HDF5Dataset}, name::String)
    h5r_create(REF_TEMP_ARRAY, checkvalid(parent).id, name, H5R_OBJECT, -1)
    REF_TEMP_ARRAY[]
end
==(a::HDF5ReferenceObj, b::HDF5ReferenceObj) = a.r == b.r
hash(x::HDF5ReferenceObj, h::UInt) = hash(x.r, h)

# Compound types
struct HDF5Compound{N}
    data::NTuple{N,Any}
    membername::NTuple{N,String}
    membertype::NTuple{N,Type}
end

# Opaque types
struct HDF5Opaque
    data
    tag::String
end

# An empty array type
struct EmptyArray{T} end

# Stub types to encode fixed-size arrays for H5T_ARRAY
struct FixedArray{T,D} end
size(::Type{FixedArray{T,D}}) where {T,D} = D
eltype(::Type{FixedArray{T,D}}) where {T,D} = T

# VLEN objects
struct HDF5Vlen{T}
    data
end
HDF5Vlen(strs::Array{S}) where {S<:String} = HDF5Vlen{chartype(S)}(strs)
HDF5Vlen(A::Array{Array{T}}) where {T<:HDF5Scalar} = HDF5Vlen{T}(A)
HDF5Vlen(A::Array{Array{T,N}}) where {T<:HDF5Scalar,N} = HDF5Vlen{T}(A)

## Types that correspond to C structs and get used for ccall
# For VLEN
struct Hvl_t
    len::Csize_t
    p::Ptr{Void}
end
const HVL_SIZE = sizeof(Hvl_t) # and determine the size of the buffer needed
function vlenpack(v::HDF5Vlen{T}) where {T<:Union{HDF5Scalar,CharType}}
    len = length(v.data)
    Tp = t2p(T)  # Ptr{UInt8} or Ptr{T}
    h = Vector{Hvl_t}(len)
    for i = 1:len
        h[i] = Hvl_t(convert(Csize_t, length(v.data[i])), convert(Ptr{Void}, unsafe_convert(Tp, v.data[i])))
    end
    h
end

# For group information
struct H5Ginfo
    storage_type::Cint
    nlinks::Hsize
    max_corder::Int64
    mounted::Cint
end

# For objects
struct Hmetainfo
    index_size::Hsize
    heap_size::Hsize
end
struct H5Oinfo
    fileno::Cuint
    addr::Hsize
    otype::Cint
    rc::Cuint
    atime::C_time_t
    mtime::C_time_t
    ctime::C_time_t
    btime::C_time_t
    num_attrs::Hsize
    version::Cuint
    nmesgs::Cuint
    nchunks::Cuint
    flags::Cuint
    total::Hsize
    meta::Hsize
    mesg::Hsize
    free::Hsize
    present::UInt64
    shared::UInt64
    meta_obj::Hmetainfo
    meta_attr::Hmetainfo
end
# For links
struct H5LInfo
    linktype::Cint
    corder_valid::Cuint
    corder::Int64
    cset::Cint
    u::UInt64
end

# Blosc compression:
include("blosc_filter.jl")

# heuristic chunk layout (return empty array to disable chunking)
function heuristic_chunk(T, shape)
    Ts = sizeof(T)
    sz = prod(shape)
    sz == 0 && return Int[] # never return a zero-size chunk
    chunk = [shape...]
    nd = length(chunk)
    # simplification of ugly heuristic target chunk size from PyTables/h5py:
    target = min(1500000, max(12000, floor(Int, 300*cbrt(Ts*sz))))
    Ts > target && return ones(chunk)
    # divide last non-unit dimension by 2 until we get <= target
    # (since Julia default to column-major, favor contiguous first dimension)
    while Ts*prod(chunk) > target
        i = nd
        while chunk[i] == 1
            i -= 1
        end
        chunk[i] >>= 1
    end
    return chunk
end
heuristic_chunk(T, ::Tuple{}) = Int[]
heuristic_chunk(A::AbstractArray{T}) where {T} = heuristic_chunk(T, size(A))
heuristic_chunk(x) = Int[]
# (strings are saved as scalars, and hence cannot be chunked)

### High-level interface ###
# Open or create an HDF5 file
function h5open(filename::AbstractString, rd::Bool, wr::Bool, cr::Bool, tr::Bool, ff::Bool,
        cpl::HDF5Properties=DEFAULT_PROPERTIES, apl::HDF5Properties=DEFAULT_PROPERTIES; swmr=false)
    swmr && HDF5.libversion < v"1.10.0" && error("SWMR requires libversion >= v\"1.10.0\"")
    if ff && !wr
        error("HDF5 does not support appending without writing")
    end
    close_apl = false
    if apl.id == H5P_DEFAULT
        apl = p_create(H5P_FILE_ACCESS, false)
        close_apl = true
        # With garbage collection, the other modes don't make sense
        apl["fclose_degree"] = H5F_CLOSE_STRONG
    end
    if cr && (tr || !isfile(filename))
        flag = swmr ? H5F_ACC_TRUNC|H5F_ACC_SWMR_WRITE : H5F_ACC_TRUNC
        fid = h5f_create(filename, flag, cpl.id, apl.id)
    else
        if !h5f_is_hdf5(filename)
            error("This does not appear to be an HDF5 file")
        end
        if wr
            flag = swmr ? H5F_ACC_RDWR|H5F_ACC_SWMR_WRITE : H5F_ACC_RDWR
        else
            flag = swmr ? H5F_ACC_RDONLY|H5F_ACC_SWMR_READ : H5F_ACC_RDONLY
        end
        fid = h5f_open(filename, flag, apl.id)
    end
    if close_apl
        # Close properties manually to avoid errors when the file is
        # closed before the properties are gc'ed
        close(apl)
    end
    HDF5File(fid, filename)
end

"""
    h5open(filename::AbstractString, mode::AbstractString="r"; swmr=false)

Open or create an HDF5 file where `mode` is one of:
 - "r"  read only
 - "r+" read and write
 - "w"  read and write, create a new file (destroys any existing contents)

Pass `swmr=true` to enable (Single Writer Multiple Reader) SWMR write access for "w" and
"r+", or SWMR read access for "r".
"""
function h5open(filename::AbstractString, mode::AbstractString="r", pv...; swmr=false)
    # pv is interpreted as pairs of arguments
    # the first of a pair is a key of hdf5_prop_get_set
    # the second of a pair is a property value
    apl = p_create(H5P_FILE_ACCESS) # access property list
    # With garbage collection, the other modes don't make sense
    # (Set this first, so that the user-passed properties can overwrite this.)
    apl["fclose_degree"] = H5F_CLOSE_STRONG
    for i = 1:2:length(pv)
        thisname = pv[i]
        if !isa(thisname, String)
            error("Argument ", i+2, " should be a String, but it's a ", typeof(thisname))
        end
        apl[thisname] = pv[i+1]
    end
    modes =
        mode == "r"  ? (true,  false, false, false, false) :
        mode == "r+" ? (true,  true,  false, false, true ) :
        mode == "w"  ? (false, true,  true,  true,  false) :
        # mode == "w+" ? (true,  true,  true,  true,  false) :
        # mode == "a"  ? (true,  true,  true,  true,  true ) :
        error("invalid open mode: ", mode)
    h5open(filename, modes..., DEFAULT_PROPERTIES, apl; swmr=swmr)
end

"""
    function h5open(f::Function, args...; swmr=false)

Apply the function f to the result of `h5open(args...;kwargs...)` and close the resulting
`HDF5File` upon completion. For example with a `do` block:


    h5open("foo.h5","w") do h5
        h5["foo"]=[1,2,3]
    end

"""
function h5open(f::Function, args...; swmr=false)
    fid = h5open(args...; swmr=swmr)
    try
        f(fid)
    finally
        close(fid)
    end
end

function h5rewrite(f::Function, filename::AbstractString, args...)
    tmppath,tmpio = mktemp(dirname(filename))
    close(tmpio)

    try
        val = h5open(f, tmppath, "w", args...)
        Base.Filesystem.rename(tmppath, filename)
        return val
    catch
        Base.Filesystem.unlink(tmppath)
        rethrow()
    end
end

function h5write(filename, name::String, data)
    fid = h5open(filename, true, true, true, false, true)
    try
        write(fid, name, data)
    finally
        close(fid)
    end
end

function h5read(filename, name::String)
    local dat
    fid = h5open(filename, "r")
    try
        dat = read(fid, name)
    finally
        close(fid)
    end
    dat
end

function h5read(filename, name::String, indices::Tuple{Vararg{Union{AbstractRange{Int},Int,Colon}}})
    local dat
    fid = h5open(filename, "r")
    try
        dset = fid[name]
        dat = dset[indices...]
    finally
        close(fid)
    end
    dat
end

function h5writeattr(filename, name::String, data::Dict)
    fid = h5open(filename, "r+")
    try
        for x in keys(data)
            attrs(fid[name])[x] = data[x]
        end
    finally
        close(fid)
    end
end

function h5readattr(filename, name::String)
    local dat
    fid = h5open(filename,"r")
    try
        a = attrs(fid[name])
        dat = Dict(x => read(a[x]) for x in names(a))
    finally
        close(fid)
    end
    dat
end

# Ensure that objects haven't been closed
isvalid(obj::Union{HDF5File, HDF5Properties, HDF5Datatype, HDF5Dataspace}) = obj.id != -1 && h5i_is_valid(obj.id)
isvalid(obj::Union{HDF5Group, HDF5Dataset, HDF5Attribute}) = obj.id != -1 && obj.file.id != -1 && h5i_is_valid(obj.id)
checkvalid(obj) = isvalid(obj) ? obj : error("File or object has been closed")

# Close functions

# Close functions that should try calling close regardless
function close(obj::HDF5File)
    if obj.id != -1
        h5f_close(obj.id)
        obj.id = -1
    end
    nothing
end

"""
    isopen(obj::HDF5File)

Returns `true` if `obj` has not been closed, `false` if it has been closed.
"""
isopen(obj::HDF5File) = obj.id != -1

for (h5type, h5func) in
    ((:(Union{HDF5Group, HDF5Dataset}), :h5o_close),
     (:HDF5Attribute, :h5a_close))
    # Close functions that should first check that the file is still open. The common case is a
    # file that has been closed with CLOSE_STRONG but there are still finalizers that have not run
    # for the datasets, etc, in the file.
    @eval begin
        function close(obj::$h5type)
            if obj.id != -1
                if obj.file.id != -1 && isvalid(obj)
                    $h5func(obj.id)
                end
                obj.id = -1
            end
            nothing
        end
    end
end

function close(obj::HDF5Datatype)
    if obj.toclose && obj.id != -1
        if (!isdefined(obj, :file) || obj.file.id != -1) && isvalid(obj)
            h5o_close(obj.id)
        end
        obj.id = -1
    end
    nothing
end

function close(obj::HDF5Dataspace)
    if obj.id != -1
        if isvalid(obj)
            h5s_close(obj.id)
        end
        obj.id = -1
    end
    nothing
end

function close(obj::HDF5Properties)
    if obj.toclose && obj.id != -1
        h5p_close(obj.id)
        obj.id = -1
    end
    nothing
end

"""
    ishdf5(name::AbstractString)

Returns `true` if `name` is a path to a valid hdf5 file, `false` otherwise.
"""
ishdf5(name::AbstractString) = h5f_is_hdf5(name)

# Extract the file
file(f::HDF5File) = f
file(g::HDF5Group) = g.file
file(dset::HDF5Dataset) = dset.file
file(dtype::HDF5Datatype) = dtype.file
file(a::HDF5Attribute) = a.file
fd(obj::HDF5Object) = h5i_get_file_id(checkvalid(obj).id)

# Flush buffers
flush(f::Union{HDF5Object, HDF5Attribute, HDF5Datatype, HDF5File}, scope) = h5f_flush(checkvalid(f).id, scope)
flush(f::Union{HDF5Object, HDF5Attribute, HDF5Datatype, HDF5File}) = flush(f, H5F_SCOPE_GLOBAL)

# Open objects
g_open(parent::Union{HDF5File, HDF5Group}, name::String) = HDF5Group(h5g_open(checkvalid(parent).id, name, H5P_DEFAULT), file(parent))
d_open(parent::Union{HDF5File, HDF5Group}, name::String, apl::HDF5Properties) = HDF5Dataset(h5d_open(checkvalid(parent).id, name, apl.id), file(parent))
d_open(parent::Union{HDF5File, HDF5Group}, name::String) = HDF5Dataset(h5d_open(checkvalid(parent).id, name, H5P_DEFAULT), file(parent))
t_open(parent::Union{HDF5File, HDF5Group}, name::String, apl::HDF5Properties) = HDF5Datatype(h5t_open(checkvalid(parent).id, name, apl.id), file(parent))
t_open(parent::Union{HDF5File, HDF5Group}, name::String) = HDF5Datatype(h5t_open(checkvalid(parent).id, name, H5P_DEFAULT), file(parent))
a_open(parent::Union{HDF5File, HDF5Object}, name::String) = HDF5Attribute(h5a_open(checkvalid(parent).id, name, H5P_DEFAULT), file(parent))
# Object (group, named datatype, or dataset) open
function h5object(obj_id::Hid, parent)
    obj_type = h5i_get_type(obj_id)
    obj_type == H5I_GROUP ? HDF5Group(obj_id, file(parent)) :
    obj_type == H5I_DATATYPE ? HDF5Datatype(obj_id, file(parent)) :
    obj_type == H5I_DATASET ? HDF5Dataset(obj_id, file(parent)) :
    error("Invalid object type for path ", path)
end
o_open(parent, path::String) = h5object(h5o_open(checkvalid(parent).id, path), parent)
# Get the root group
root(h5file::HDF5File) = g_open(h5file, "/")
root(obj::Union{HDF5Group, HDF5Dataset}) = g_open(file(obj), "/")
# getindex syntax: obj2 = obj1[path]
getindex(parent::Union{HDF5File, HDF5Group}, path::String) = o_open(parent, path)
getindex(dset::HDF5Dataset, name::String) = a_open(dset, name)
getindex(x::HDF5Attributes, name::String) = a_open(x.parent, name)

# Path manipulation
function split1(path::String)
    off = search(path, '/')
    if off == 0
        return path, nothing
    else
        if off == 1
            # Matches the root group
            return "/", path[2:end]
        else
            return path[1:prevind(path, off)], path[nextind(path, off):end]
        end
    end
end

function g_create(parent::Union{HDF5File, HDF5Group}, path::String,
                  lcpl::HDF5Properties=_link_properties(path),
                  dcpl::HDF5Properties=DEFAULT_PROPERTIES)
    HDF5Group(h5g_create(checkvalid(parent).id, path, lcpl.id, dcpl.id), file(parent))
end
function g_create(f::Function, parent::Union{HDF5File, HDF5Group}, args...)
    g = g_create(parent, args...)
    try
        f(g)
    finally
        close(g)
    end
end

function d_create(parent::Union{HDF5File, HDF5Group}, path::String, dtype::HDF5Datatype,
         dspace::HDF5Dataspace, lcpl::HDF5Properties=_link_properties(path),
         dcpl::HDF5Properties=DEFAULT_PROPERTIES,
         dapl::HDF5Properties=DEFAULT_PROPERTIES)
    HDF5Dataset(h5d_create(checkvalid(parent).id, path, dtype.id, dspace.id, lcpl.id,
                dcpl.id, dapl.id), file(parent))
end

# Setting dset creation properties with name/value pairs
function d_create(parent::Union{HDF5File, HDF5Group}, path::String, dtype::HDF5Datatype, dspace::HDF5Dataspace, prop1::String, val1, pv...)
    if !iseven(length(pv))
        error("Properties and values must come in pairs")
    end
    p = p_create(H5P_DATASET_CREATE)
    p[prop1] = val1
    for i = 1:2:length(pv)
        thisname = pv[i]
        if !isa(thisname, String)
            error("Argument ", i+3, " should be a String, but it's a ", typeof(thisname))
        end
        p[thisname] = pv[i+1]
    end
    HDF5Dataset(h5d_create(parent, path, dtype.id, dspace.id, _link_properties(path), p.id, H5P_DEFAULT), file(parent))
end
d_create(parent::Union{HDF5File, HDF5Group}, path::String, dtype::HDF5Datatype, dspace_dims::Dims, prop1::String, val1, pv...) = d_create(checkvalid(parent), path, dtype, dataspace(dspace_dims), prop1, val1, pv...)
d_create(parent::Union{HDF5File, HDF5Group}, path::String, dtype::HDF5Datatype, dspace_dims::Tuple{Dims,Dims}, prop1::String, val1, pv...) = d_create(checkvalid(parent), path, dtype, dataspace(dspace_dims[1], max_dims=dspace_dims[2]), prop1, val1, pv...)
d_create(parent::Union{HDF5File, HDF5Group}, path::String, dtype::Type, dspace_dims, prop1::String, val1, pv...) = d_create(checkvalid(parent), path, datatype(dtype), dataspace(dspace_dims[1], max_dims=dspace_dims[2]), prop1, val1, pv...)

# Note that H5Tcreate is very different; H5Tcommit is the analog of these others
t_create(class_id, sz) = HDF5Datatype(h5t_create(class_id, sz))
function t_commit(parent::Union{HDF5File, HDF5Group}, path::String, dtype::HDF5Datatype, lcpl::HDF5Properties, tcpl::HDF5Properties, tapl::HDF5Properties)
    h5p_set_char_encoding(lcpl.id, cset(typeof(path)))
    h5t_commit(checkvalid(parent).id, path, dtype.id, lcpl.id, tcpl.id, tapl.id)
    dtype.file = file(parent)
    dtype
end
function t_commit(parent::Union{HDF5File, HDF5Group}, path::String, dtype::HDF5Datatype, lcpl::HDF5Properties, tcpl::HDF5Properties)
    h5p_set_char_encoding(lcpl.id, cset(typeof(path)))
    h5t_commit(checkvalid(parent).id, path, dtype.id, lcpl.id, tcpl.id, H5P_DEFAULT)
    dtype.file = file(parent)
    dtype
end
function t_commit(parent::Union{HDF5File, HDF5Group}, path::String, dtype::HDF5Datatype, lcpl::HDF5Properties)
    h5p_set_char_encoding(lcpl.id, cset(typeof(path)))
    h5t_commit(checkvalid(parent).id, path, dtype.id, lcpl.id, H5P_DEFAULT, H5P_DEFAULT)
    dtype.file = file(parent)
    dtype
end
t_commit(parent::Union{HDF5File, HDF5Group}, path::String, dtype::HDF5Datatype) = t_commit(parent, path, dtype, p_create(H5P_LINK_CREATE))

a_create(parent::Union{HDF5File, HDF5Object}, name::String, dtype::HDF5Datatype, dspace::HDF5Dataspace) = HDF5Attribute(h5a_create(checkvalid(parent).id, name, dtype.id, dspace.id), file(parent))
p_create(class, toclose=false) = HDF5Properties(h5p_create(class), toclose)

# Delete objects
a_delete(parent::Union{HDF5File, HDF5Object}, path::String) = h5a_delete(checkvalid(parent).id, path)
o_delete(parent::Union{HDF5File, HDF5Group}, path::String, lapl::HDF5Properties) = h5l_delete(checkvalid(parent).id, path, lapl.id)
o_delete(parent::Union{HDF5File, HDF5Group}, path::String) = h5l_delete(checkvalid(parent).id, path, H5P_DEFAULT)
o_delete(obj::HDF5Object) = o_delete(parent(obj), ascii(split(name(obj),"/")[end]))

# Copy objects
o_copy(src_parent::Union{HDF5File, HDF5Group}, src_path::String, dst_parent::Union{HDF5File, HDF5Group}, dst_path::String) = h5o_copy(checkvalid(src_parent).id, src_path, checkvalid(dst_parent).id, dst_path, H5P_DEFAULT, _link_properties(dst_path))
o_copy(src_obj::HDF5Object, dst_parent::Union{HDF5File, HDF5Group}, dst_path::String) = h5o_copy(checkvalid(src_obj).id, ".", checkvalid(dst_parent).id, dst_path, H5P_DEFAULT, _link_properties(dst_path))

# Assign syntax: obj[path] = value
# Creates a dataset unless obj is a dataset, in which case it creates an attribute
setindex!(parent::Union{HDF5File, HDF5Group}, val, path::String) = write(parent, path, val)
setindex!(dset::HDF5Dataset, val, name::String) = a_write(dset, name, val)
setindex!(x::HDF5Attributes, val, name::String) = a_write(x.parent, name, val)
# Getting and setting properties: p["chunk"] = dims, p["compress"] = 6
function setindex!(p::HDF5Properties, val, name::String)
    funcget, funcset = hdf5_prop_get_set[name]
    funcset(p, val...)
    return p
end
# Create a dataset with properties: obj[path, prop1, set1, ...] = val
function setindex!(parent::Union{HDF5File, HDF5Group}, val, path::String, prop1::String, val1, pv...)
    if !iseven(length(pv))
        error("Properties and values must come in pairs")
    end
    p = p_create(H5P_DATASET_CREATE)
    need_chunks = prop1 in chunked_props
    have_chunks = prop1 == "chunk"
    chunk = heuristic_chunk(val)
    # ignore chunked_props (== compression) for empty datasets (issue #246):
    if !(need_chunks && isempty(chunk))
        p[prop1] = val1
    end
    for i = 1:2:length(pv)
        thisname = pv[i]
        if !isa(thisname, String)
            error("Argument ", i+3, " should be an String, but it's a ", typeof(thisname))
        end
        thisneeds_chunks = thisname in chunked_props
        if !(thisneeds_chunks && isempty(chunk))
            p[thisname] = pv[i+1]
        end
        need_chunks = need_chunks || thisneeds_chunks
        have_chunks = have_chunks || (thisname == "chunk")
    end
    if need_chunks && !have_chunks
        if !isempty(chunk)
            p["chunk"] = chunk
        end
    end
    write(parent, path, val, p_create(H5P_LINK_CREATE), p)
end

# Check existence
function exists(parent::Union{HDF5File, HDF5Group}, path::String, lapl::HDF5Properties)
    first, rest = split1(path)
    if first == "/"
        parent = root(parent)
    elseif !h5l_exists(parent.id, first, lapl.id)
        return false
    end
    ret = true
    if rest !== nothing && !isempty(rest)
        obj = parent[first]
        ret = exists(obj, rest, lapl)
        close(obj)
    end
    ret
end
exists(attr::HDF5Attributes, path::String) = h5a_exists(checkvalid(attr.parent).id, path)
exists(dset::Union{HDF5Dataset, HDF5Datatype}, path::String) = h5a_exists(checkvalid(dset).id, path)
exists(parent::Union{HDF5File, HDF5Group}, path::String) = exists(parent, path, HDF5Properties())
has(parent::Union{HDF5File, HDF5Group, HDF5Dataset}, path::String) = exists(parent, path)

# Querying items in the file
const H5GINFO_TEMP_ARRAY = Ref{H5Ginfo}()
function info(obj::Union{HDF5Group,HDF5File})
    h5g_get_info(obj, H5GINFO_TEMP_ARRAY)
    H5GINFO_TEMP_ARRAY[]
end

const H5OINFO_TEMP_ARRAY = Ref{H5Oinfo}()
function objinfo(obj::Union{HDF5File, HDF5Object})
    h5o_get_info(obj.id, H5OINFO_TEMP_ARRAY)
    H5OINFO_TEMP_ARRAY[]
end

const LENGTH_TEMP_ARRAY = Ref{UInt64}()
function length(x::Union{HDF5Group,HDF5File})
    h5g_get_num_objs(x.id, LENGTH_TEMP_ARRAY)
    LENGTH_TEMP_ARRAY[]
end

function length(x::HDF5Attributes)
    objinfo(x.parent).num_attrs
end

isempty(x::Union{HDF5Dataset,HDF5Group,HDF5File}) = length(x) == 0
function size(obj::Union{HDF5Dataset, HDF5Attribute})
    dspace = dataspace(obj)
    dims, maxdims = get_dims(dspace)
    close(dspace)
    convert(Tuple{Vararg{Int}}, dims)
end
size(dset::Union{HDF5Dataset, HDF5Attribute}, d) = d > ndims(dset) ? 1 : size(dset)[d]
length(dset::Union{HDF5Dataset, HDF5Attribute}) = prod(size(dset))
ndims(dset::Union{HDF5Dataset, HDF5Attribute}) = length(size(dset))
function eltype(dset::Union{HDF5Dataset, HDF5Attribute})
    T = Any
    dtype = datatype(dset)
    try
        T = hdf5_to_julia_eltype(dtype)
    finally
        close(dtype)
    end
    T
end
function isnull(obj::Union{HDF5Dataset, HDF5Attribute})
    dspace = dataspace(obj)
    ret = h5s_get_simple_extent_type(dspace.id) == H5S_NULL
    close(dspace)
    ret
end

# filename and name
filename(obj::Union{HDF5File, HDF5Group, HDF5Dataset, HDF5Attribute, HDF5Datatype}) = h5f_get_name(checkvalid(obj).id)
name(obj::Union{HDF5File, HDF5Group, HDF5Dataset, HDF5Datatype}) = h5i_get_name(checkvalid(obj).id)
name(attr::HDF5Attribute) = h5a_get_name(attr.id)
function names(x::Union{HDF5Group,HDF5File})
    checkvalid(x)
    n = length(x)
    res = Vector{String}(n)
    buf = Vector{UInt8}(100)
    for i in 1:n
        len = h5g_get_objname_by_idx(x.id, i - 1, buf, length(buf))
        if len >= length(buf)
            resize!(buf, len+10)
            len = h5g_get_objname_by_idx(x.id, i - 1, buf, length(buf))
        end
        res[i] = String(buf[1:len])
    end
    res
end

function names(x::HDF5Attributes)
    checkvalid(x.parent)
    n = length(x)
    res = Vector{String}(n)
    for i in 1:n
        len = h5a_get_name_by_idx(x.parent.id, ".", H5_INDEX_NAME, H5_ITER_INC, i-1, "", 0, H5P_DEFAULT)
        buf = Vector{UInt8}(len+1)
        len = h5a_get_name_by_idx(x.parent.id, ".", H5_INDEX_NAME, H5_ITER_INC, i-1, buf, len+1, H5P_DEFAULT)
        res[i] = String(buf[1:len])
    end
    res
end

# iteration by objects
# "next" opens new objects, "done" closes the old one. This prevents resource leaks.
start(parent::Union{HDF5File, HDF5Group}) = Any[1, nothing]
function done(parent::Union{HDF5File, HDF5Group}, iter::Array{Any})
    obj = iter[2]
    if !(obj === nothing)
        close(obj)
    end
    iter[1] > length(parent)
end
function next(parent::Union{HDF5File, HDF5Group}, iter)
    iter[2] = h5object(h5o_open_by_idx(checkvalid(parent).id, ".", H5_INDEX_NAME, H5_ITER_INC, iter[1]-1, H5P_DEFAULT), parent)
    iter[1] += 1
    (iter[2], iter)
end

endof(dset::HDF5Dataset) = length(dset)

function parent(obj::Union{HDF5File, HDF5Group, HDF5Dataset})
    f = file(obj)
    path = name(obj)
    if length(path) == 1
        return f
    end
    parentname = dirname(path)
    if !isempty(parentname)
        return o_open(f, dirname(path))
    else
        return root(f)
    end
end

# Get the datatype of a dataset
datatype(dset::HDF5Dataset) = HDF5Datatype(h5d_get_type(checkvalid(dset).id), file(dset))
# Get the datatype of an attribute
datatype(dset::HDF5Attribute) = HDF5Datatype(h5a_get_type(checkvalid(dset).id), file(dset))

# Create a datatype from in-memory types
datatype(x::T) where {T<:HDF5Scalar} = HDF5Datatype(hdf5_type_id(T), false)
datatype(::Type{T}) where {T<:HDF5Scalar} = HDF5Datatype(hdf5_type_id(T), false)
datatype(A::Array{T}) where {T<:HDF5Scalar} = HDF5Datatype(hdf5_type_id(T), false)
function datatype(str::S) where {S<:String}
    type_id = h5t_copy(hdf5_type_id(S))
    h5t_set_size(type_id, max(sizeof(str), 1))
    h5t_set_cset(type_id, cset(S))
    HDF5Datatype(type_id)
end
function datatype(str::Array{S}) where {S<:String}
    type_id = h5t_copy(hdf5_type_id(S))
    h5t_set_size(type_id, H5T_VARIABLE)
    h5t_set_cset(type_id, cset(S))
    HDF5Datatype(type_id)
end
datatype(A::HDF5Vlen{T}) where {T<:HDF5Scalar} = HDF5Datatype(h5t_vlen_create(hdf5_type_id(T)))
function datatype(str::HDF5Vlen{C}) where {C<:CharType}
    type_id = h5t_copy(hdf5_type_id(C))
    h5t_set_size(type_id, 1)
    h5t_set_cset(type_id, cset(C))
    HDF5Datatype(h5t_vlen_create(type_id))
end

sizeof(dtype::HDF5Datatype) = h5t_get_size(dtype)

# Get the dataspace of a dataset
dataspace(dset::HDF5Dataset) = HDF5Dataspace(h5d_get_space(checkvalid(dset).id))
# Get the dataspace of an attribute
dataspace(attr::HDF5Attribute) = HDF5Dataspace(h5a_get_space(checkvalid(attr).id))

# Create a dataspace from in-memory types
dataspace(x::T) where {T<:HDF5Scalar} = HDF5Dataspace(h5s_create(H5S_SCALAR))
function _dataspace(sz::Tuple{Vararg{Int}}, max_dims::Union{Dims, Tuple{}}=())
    dims = Vector{Hsize}(length(sz))
    any_zero = false
    for i = 1:length(sz)
        dims[end-i+1] = sz[i]
        any_zero |= sz[i] == 0
    end

    if any_zero
        space_id = h5s_create(H5S_NULL)
    else
        if isempty(max_dims)
            space_id = h5s_create_simple(length(dims), dims, dims)
        else
            # This allows max_dims to be specified as -1 without
            # triggering an overflow exception due to the signed->
            # unsigned conversion.
            space_id = h5s_create_simple(length(dims), dims,
                                         reinterpret(Hsize, convert(Vector{Hssize},
                                                                    [reverse(max_dims)...])))
        end
    end
    HDF5Dataspace(space_id)
end
dataspace(A::Array; max_dims::Union{Dims, Tuple{}} = ()) = _dataspace(size(A), max_dims)
dataspace(str::String) = HDF5Dataspace(h5s_create(H5S_SCALAR))
dataspace(v::HDF5Vlen; max_dims::Union{Dims, Tuple{}}=()) = _dataspace(size(v.data), max_dims)
dataspace(n::Void) = HDF5Dataspace(h5s_create(H5S_NULL))
dataspace(sz::Dims; max_dims::Union{Dims, Tuple{}}=()) = _dataspace(sz, max_dims)
dataspace(sz1::Int, sz2::Int, sz3::Int...; max_dims::Union{Dims, Tuple{}}=()) = _dataspace(tuple(sz1, sz2, sz3...), max_dims)


get_dims(dspace::HDF5Dataspace) = h5s_get_simple_extent_dims(dspace.id)

"""
    get_dims(dset::HDF5Dataset)

Get the array dimensions from a dataset and return a tuple of dims and maxdims.
"""
get_dims(dset::HDF5Dataset) = get_dims(dataspace(checkvalid(dset)))

"""
    set_dims!(dset::HDF5Dataset, new_dims::Dims)

Change the current dimensions of a dataset to `new_dims`, limited by
`max_dims = get_dims(dset)[2]`. Reduction is possible and leads to loss of truncated data.
"""
set_dims!(dset::HDF5Dataset, new_dims::Dims) = h5d_set_extent(checkvalid(dset), Hsize[reverse(new_dims)...])

"""
    start_swmr_write(h5::HDF5File)

Start Single Reader Multiple Writer (SWMR) writing mode.
See [SWMR documentation](https://support.hdfgroup.org/HDF5/doc/RM/RM_H5F.html#File-StartSwmrWrite).
"""
start_swmr_write(h5::HDF5File) = hf5start_swmr_write(h5.id)

refresh(ds::HDF5Dataset) = HDF5.h5d_refresh(checkvalid(ds).id)
flush(ds::HDF5Dataset) = HDF5.h5d_flush(HDF5.checkvalid(ds).id)

# Generic read functions
for (fsym, osym, ptype) in
    ((:d_read, :d_open, Union{HDF5File, HDF5Group}),
     (:a_read, :a_open, Union{HDF5File, HDF5Group, HDF5Dataset, HDF5Datatype}))
    @eval begin
        function ($fsym)(parent::$ptype, name::String)
            local ret
            obj = ($osym)(parent, name)
            try
                ret = read(obj)
            finally
                close(obj)
            end
            ret
        end
    end
end
function read(parent::Union{HDF5File, HDF5Group}, name::String)
    obj = o_open(parent, name)
    val = read(obj)
    close(obj)
    val
end

# "Plain" (unformatted) reads. These work only for simple types: scalars, arrays, and strings
# See also "Reading arrays using getindex" below
# This infers the Julia type from the HDF5Datatype. Specific file formats should provide their own read(dset).
const DatasetOrAttribute = Union{HDF5Dataset, HDF5Attribute}
function read(obj::DatasetOrAttribute)
    local T
    T = hdf5_to_julia(obj)
    read(obj, T)
end
# Read scalars
function read(obj::DatasetOrAttribute, ::Type{T}) where {T<:HDF5Scalar}
    x = read(obj, Array{T})
    x[1]
end
# Read array of scalars
function read(obj::DatasetOrAttribute, ::Type{Array{T}}) where {T<:HDF5Scalar}
    if isnull(obj)
        return T[]
    end
    dims = size(obj)
    data = Array{T}(dims)
    readarray(obj, hdf5_type_id(T), data)
    data
end
# Empty arrays
function read(obj::DatasetOrAttribute, ::Type{EmptyArray{T}}) where {T<:ScalarOrString}
    T[]
end
# Fixed-size arrays (H5T_ARRAY)
function read(obj::DatasetOrAttribute, ::Type{A}) where {A<:FixedArray}
    T = eltype(A)
    sz = size(A)
    data = Array{T}(sz)
    readarray(obj, hdf5_type_id(T), data)
    data
end
function read(obj::DatasetOrAttribute, ::Type{Array{A}}) where {A<:FixedArray}
    T = eltype(A)
    if !(T<:HDF5Scalar)
        error("Sorry, not yet supported")
    end
    sz = size(A)
    dims = size(obj)
    data = Array{T}(sz..., dims...)
    nd = length(sz)
    hsz = Hsize[convert(Hsize,sz[nd-i+1]) for i = 1:nd]
    memtype_id = h5t_array_create(hdf5_type_id(T), convert(Cuint, length(sz)), hsz)
    try
        h5d_read(obj.id, memtype_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, data)
    finally
        h5t_close(memtype_id)
    end
    ret = Array{Array{T}}(dims)
    # Because of garbage-collection concerns, it's best to copy the data
    L = prod(sz)
    for i = 1:prod(dims)
        ret[i] = reshape(data[(i-1)*L+1:i*L], sz)
    end
    ret
end

# Clean up string buffer according to padding mode
function unpad(s::String, pad::Integer)
    if pad == H5T_STR_NULLTERM
        v = search(s, '\0')
        v == 0 ? s : s[1:v-1]
    elseif pad == H5T_STR_NULLPAD
        rstrip(s, '\0')
    elseif pad == H5T_STR_SPACEPAD
        rstrip(s, ' ')
    else
        error("Unrecognized string padding mode $pad")
    end
end
unpad(s, pad::Integer) = unpad(String(s), pad)

# Read string
function read(obj::DatasetOrAttribute, ::Type{S}) where {S<:String}
    local ret::S
    objtype = datatype(obj)
    try
        if h5t_is_variable_str(objtype.id)
            buf = Cstring[C_NULL]
            memtype_id = h5t_copy(H5T_C_S1)
            h5t_set_size(memtype_id, H5T_VARIABLE)
            h5t_set_cset(memtype_id, h5t_get_cset(objtype))
            readarray(obj, memtype_id, buf)
            ret = unsafe_string(buf[1])
        else
            n = h5t_get_size(objtype.id)
            pad = h5t_get_strpad(objtype.id)
            buf = Vector{UInt8}(n)
            readarray(obj, objtype.id, buf)
            pbuf = String(buf)
            ret = unpad(pbuf, pad)
        end
    finally
        close(objtype)
    end
    ret
end
read(obj::DatasetOrAttribute, ::Type{S}) where {S<:CharType} = read(obj, stringtype(S))
# Read array of strings
function read(obj::DatasetOrAttribute, ::Type{Array{S}}) where {S<:String}
    local isvar::Bool
    local ret::Array{S}
    sz = size(obj)
    len = prod(sz)
    objtype = datatype(obj)
    memtype_id = h5t_copy(H5T_C_S1)
    try
        isvar = h5t_is_variable_str(objtype.id)
        ilen = Int(h5t_get_size(objtype.id))
        h5t_set_cset(memtype_id, h5t_get_cset(objtype))
    finally
        close(objtype)
    end
    if isempty(sz)
        h5t_close(memtype_id)
        return S[]
    else
        dspace = dataspace(obj)
        ret = Array{S}(sz)
        if isvar
            # Variable-length
            buf = Vector{Cstring}(len)
            h5t_set_size(memtype_id, H5T_VARIABLE)
            readarray(obj, memtype_id, buf)
            for i = 1:len
                ret[i] = unsafe_string(buf[i])
            end
        else
            # Fixed length
            ilen += 1  # for null terminator
            buf = Vector{UInt8}(len*ilen)
            h5t_set_size(memtype_id, ilen)
            readarray(obj, memtype_id, buf)
            src = 1
            for i = 1:len
                slen = findnext(buf, 0x00, src) - src # find null terminator
                sv = StringVector(slen)
                copy!(sv, 1, buf, src, slen)
                ret[i] = String(sv)
                src += ilen
            end
        end
    try
        h5d_vlen_reclaim(memtype_id, dspace.id, H5P_DEFAULT, buf)
    finally
        close(dspace)
        h5t_close(memtype_id)
    end
        return ret
    end
end
read(obj::DatasetOrAttribute, ::Type{Array{S}}) where {S<:CharType} = read(obj, Array{stringtype(S)})
# Empty Array of strings
function read(obj::DatasetOrAttribute, ::Type{EmptyArray{C}}) where {C<:CharType}
    stringtype(C)[]
end
# Dereference
function getindex(parent::Union{HDF5File, HDF5Group, HDF5Dataset}, r::HDF5ReferenceObj)
    r == HDF5ReferenceObj_NULL && error("Reference is null")
    obj_id = h5r_dereference(checkvalid(parent).id, H5R_OBJECT, r)
    h5object(obj_id, parent)
end

# Helper for reading compound types
function read_row(io::IO, membertype, membersize)
    row = Any[]
    for (dtype, dsize) in zip(membertype, membersize)
        if dtype === String
            push!(row, unpad(read!(io, Vector{UInt8}(dsize)), H5T_STR_NULLPAD))
        elseif dtype<:HDF5.FixedArray && eltype(dtype)<:HDF5BitsKind
            val = read!(io, Vector{eltype(dtype)}(prod(size(dtype))))
            push!(row, reshape(val, size(dtype)))
        elseif dtype<:HDF5BitsKind
            push!(row, read(io, dtype))
        else
            # for other types, just store the raw bytes and let the user
            # decide what to do
            push!(row, read!(io, Vector{UInt8}(dsize)))
        end
    end
    return (row...,)
end

# Read compound type
function read(obj::HDF5Dataset, T::Union{Type{Array{HDF5Compound{N}}},Type{HDF5Compound{N}}}) where {N}
    t = datatype(obj)
    local sz = 0; local n;
    local membername; local membertype;
    local memberoffset; local memberfiletype; local membersize;
    try
        memberfiletype = Vector{HDF5Datatype}(N)
        membertype = Vector{Type}(N)
        membername = Vector{String}(N)
        memberoffset = Vector{UInt64}(N)
        membersize = Vector{UInt32}(N)
        for i = 1:N
            filetype = HDF5Datatype(h5t_get_member_type(t.id, i-1))
            memberfiletype[i] = filetype
            membertype[i] = hdf5_to_julia_eltype(filetype)
            memberoffset[i] = sz
            membersize[i] = sizeof(filetype)
            sz += sizeof(filetype)
            membername[i] = h5t_get_member_name(t.id, i-1)
        end
    finally
        close(t)
    end
    # Build the "memory type"
    memtype_id = h5t_create(H5T_COMPOUND, sz)
    for i = 1:N
        h5t_insert(memtype_id, membername[i], memberoffset[i], memberfiletype[i].id) # FIXME strings
    end
    # Read the raw data
    buf = Vector{UInt8}(length(obj)*sz)
    h5d_read(obj.id, memtype_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, buf)

    # Convert to the appropriate data format using iobuffer
    iobuff = IOBuffer(buf)
    data = Any[]
    while !eof(iobuff)
        push!(data, read_row(iobuff, membertype, membersize))
    end
    # convert HDF5Compound type parameters to tuples
    membername = (membername...,)
    membertype = (membertype...,)
    if T === HDF5Compound{N}
        return HDF5Compound(data[1], membername, membertype)
    else
        return [HDF5Compound(elem, membername, membertype) for elem in data]
    end
end

# Read OPAQUE datasets and attributes
function read(obj::DatasetOrAttribute, ::Type{Array{HDF5Opaque}})
    local buf
    local len
    local tag
    sz = size(obj)
    objtype = datatype(obj)
    try
        len = h5t_get_size(objtype)
        buf = Vector{UInt8}(prod(sz)*len)
        tag = h5t_get_tag(objtype.id)
        readarray(obj, objtype.id, buf)
    finally
        close(objtype)
    end
    data = Array{Array{UInt8}}(sz)
    for i = 1:prod(sz)
        data[i] = buf[(i-1)*len+1:i*len]
    end
    HDF5Opaque(data, tag)
end

# Read VLEN arrays and character arrays
atype(::Type{T}) where {T<:HDF5Scalar} = Array{T}
atype(::Type{C}) where {C<:CharType} = stringtype(C)
p2a(p::Ptr{T}, len::Int) where {T<:HDF5Scalar} = unsafe_wrap(Array, p, len, true)
p2a(p::Ptr{C}, len::Int) where {C<:CharType} = stringtype(C)(unsafe_wrap(Array, convert(Ptr{UInt8}, p), len, true))
t2p(::Type{T}) where {T<:HDF5Scalar} = Ptr{T}
t2p(::Type{C}) where {C<:CharType} = Ptr{UInt8}
function read(obj::DatasetOrAttribute, ::Type{HDF5Vlen{T}}) where {T<:Union{HDF5Scalar,CharType}}
    local data
    sz = size(obj)
    len = prod(sz)
    # Read the data
    structbuf = Vector{Hvl_t}(len)
    memtype_id = h5t_vlen_create(hdf5_type_id(T))
    readarray(obj, memtype_id, structbuf)
    h5t_close(memtype_id)
    # Unpack the data
    data = Array{atype(T)}(sz)
    for i = 1:len
        h = structbuf[i]
        data[i] = p2a(convert(Ptr{T}, h.p), Int(h.len))
    end
    data
end
read(attr::HDF5Attributes, name::String) = a_read(attr.parent, name)

# Reading with mmap
function iscontiguous(obj::HDF5Dataset)
    prop = h5d_get_create_plist(checkvalid(obj).id)
    try
        h5p_get_layout(prop) == H5D_CONTIGUOUS
    finally
        h5p_close(prop)
    end
end

ismmappable(::Type{Array{T}}) where {T<:HDF5Scalar} = true
ismmappable(::Type) = false
ismmappable(obj::HDF5Dataset, ::Type{T}) where {T} = ismmappable(T) && iscontiguous(obj)
ismmappable(obj::HDF5Dataset) = ismmappable(obj, hdf5_to_julia(obj))

function readmmap(obj::HDF5Dataset, ::Type{Array{T}}) where {T}
    dims = size(obj)
    if isempty(dims)
        return T[]
    end
    local fd
    prop = h5d_get_access_plist(checkvalid(obj).id)
    try
        ret = Ptr{Cint}[0]
        h5f_get_vfd_handle(obj.file.id, prop, ret)
        fd = unsafe_load(ret[1])
    finally
        HDF5.h5p_close(prop)
    end

    offset = h5d_get_offset(obj.id)
    if offset == reinterpret(Hsize, convert(Hssize, -1))
        error("Error mmapping array")
    end
    Mmap.mmap(fdio(fd), Array{T,length(dims)}, dims, offset)
end

function readmmap(obj::HDF5Dataset)
    T = hdf5_to_julia(obj)
    ismmappable(T) || error("Cannot mmap datasets of type $T")
    iscontiguous(obj) || error("Cannot mmap discontiguous dataset")
    readmmap(obj, T)
end

# Generic write
function write(parent::Union{HDF5File, HDF5Group}, name1::String, val1, name2::String, val2, nameval...)
    if !iseven(length(nameval))
        error("name, value arguments must come in pairs")
    end
    write(parent, name1, val1)
    write(parent, name2, val2)
    for i = 1:2:length(nameval)
        thisname = nameval[i]
        if !isa(thisname, String)
            error("Argument ", i+5, " should be a string, but it's a ", typeof(thisname))
        end
        write(parent, thisname, nameval[i+1])
    end
end

# Plain dataset & attribute writes
# Due to method ambiguities we generate these explicitly

# Create datasets and attributes with "native" types, but don't write the data.
# The return syntax is: dset, dtype = d_create(parent, name, data)
# You can also pass in property lists
for (privatesym, fsym, ptype) in
    ((:_d_create, :d_create, Union{HDF5File, HDF5Group}),
     (:_a_create, :a_create, Union{HDF5File, HDF5Group, HDF5Dataset, HDF5Datatype}))
    @eval begin
        # Generic create (hidden)
        function ($privatesym)(parent::$ptype, name::String, data, plists...)
            local dtype
            local obj
            dtype = datatype(data)
            dspace = dataspace(data)
            try
                obj = ($fsym)(parent, name, dtype, dspace, plists...)
            finally
                close(dspace)
            end
            obj, dtype
        end
        # Scalar types
        ($fsym)(parent::$ptype, name::String, data::Union{T, Array{T}}, plists...) where {T<:ScalarOrString} =
            ($privatesym)(parent, name, data, plists...)
        # VLEN types
        ($fsym)(parent::$ptype, name::String, data::HDF5Vlen{T}, plists...) where {T<:Union{HDF5Scalar,CharType}} =
            ($privatesym)(parent, name, data, plists...)
    end
end
# Create and write, closing the objects upon exit
for (privatesym, fsym, ptype, crsym) in
    ((:_d_write, :d_write, Union{HDF5File, HDF5Group}, :d_create),
     (:_a_write, :a_write, Union{HDF5File, HDF5Object, HDF5Datatype}, :a_create))
    @eval begin
        # Generic write (hidden)
        function ($privatesym)(parent::$ptype, name::String, data, plists...)
            obj, dtype = ($crsym)(parent, name, data, plists...)
            try
                writearray(obj, dtype.id, data)
            finally
                close(obj)
                close(dtype)
            end
        end
        # Scalar types
        ($fsym)(parent::$ptype, name::String, data::Union{T, Array{T}}, plists...) where {T<:ScalarOrString} =
            ($privatesym)(parent, name, data, plists...)
        # VLEN types
        ($fsym)(parent::$ptype, name::String, data::HDF5Vlen{T}, plists...) where {T<:Union{HDF5Scalar,CharType}} =
            ($privatesym)(parent, name, data, plists...)
    end
end
# Write to already-created objects
# Scalars
function write(obj::DatasetOrAttribute, x::Union{T, Array{T}}) where {T<:ScalarOrString}
    dtype = datatype(x)
    try
        writearray(obj, dtype.id, x)
    finally
       close(dtype)
    end
end
# VLEN types
function write(obj::DatasetOrAttribute, data::HDF5Vlen{T}) where {T<:Union{HDF5Scalar,CharType}}
    dtype = datatype(data)
    try
        writearray(obj, dtype.id, data)
    finally
        close(dtype)
    end
end
# For plain files and groups, let "write(obj, name, val)" mean "d_write"
write(parent::Union{HDF5File, HDF5Group}, name::String, data::Union{T, Array{T}}, plists...) where {T<:ScalarOrString} =
    d_write(parent, name, data, plists...)
# For datasets, "write(dset, name, val)" means "a_write"
write(parent::HDF5Dataset, name::String, data::Union{T, Array{T}}, plists...) where {T<:ScalarOrString} = a_write(parent, name, data, plists...)

# Reading arrays using getindex: data = dset[:,:,10]
function getindex(dset::HDF5Dataset, indices::Union{AbstractRange{Int},Int}...)
    local T
    dtype = datatype(dset)
    try
        T = hdf5_to_julia_eltype(dtype)
    finally
        close(dtype)
    end
    _getindex(dset,T, indices...)
end
function _getindex(dset::HDF5Dataset, T::Type, indices::Union{AbstractRange{Int},Int}...)
    if !(T <: HDF5Scalar)
        error("Dataset indexing (hyperslab) is available only for bits types")
    end
    dsel_id = hyperslab(dset, indices...)
    ret = Array{T}(map(length, indices))
    memtype = datatype(ret)
    memspace = dataspace(ret)
    try
        h5d_read(dset.id, memtype.id, memspace.id, dsel_id, H5P_DEFAULT, ret)
    finally
        close(memtype)
        close(memspace)
        h5s_close(dsel_id)
    end
    ret
end

# Write to a subset of a dataset using array slices: dataset[:,:,10] = array
function setindex!(dset::HDF5Dataset, X::Array, indices::Union{AbstractRange{Int},Int}...)
    T = hdf5_to_julia(dset)
    _setindex!(dset, T, X, indices...)
end
function _setindex!(dset::HDF5Dataset,T::Type, X::Array, indices::Union{AbstractRange{Int},Int}...)
    if !(T <: Array)
        error("Dataset indexing (hyperslab) is available only for arrays")
    end
    ET = eltype(T)
    if !(ET <: HDF5Scalar)
        error("Dataset indexing (hyperslab) is available only for bits types")
    end
    if length(X) != prod(map(length, indices))
        error("number of elements in range and length of array must be equal")
    end
    if eltype(X) != ET
        X = convert(Array{ET}, X)
    end
    dsel_id = hyperslab(dset, indices...)
    memtype = datatype(X)
    memspace = dataspace(X)
    try
        h5d_write(dset.id, memtype.id, memspace.id, dsel_id, H5P_DEFAULT, X)
    finally
        close(memtype)
        close(memspace)
        h5s_close(dsel_id)
    end
    X
end
function setindex!(dset::HDF5Dataset, X::AbstractArray, indices::Union{AbstractRange{Int},Int}...)
    T = hdf5_to_julia(dset)
    if !(T <: Array)
        error("Hyperslab interface is available only for arrays")
    end
    Y = convert(Array{eltype(T), ndims(X)}, X)
    setindex!(dset, Y, indices...)
end

function setindex!(dset::HDF5Dataset, x::Number, indices::Union{AbstractRange{Int},Int}...)
    T = hdf5_to_julia(dset)
    if !(T <: Array)
        error("Hyperslab interface is available only for arrays")
    end
    X = fill(convert(eltype(T), x), map(length, indices))
    setindex!(dset, X, indices...)
end

getindex(dset::HDF5Dataset, I::Union{AbstractRange{Int},Int,Colon}...) = getindex(dset, ntuple(i-> isa(I[i], Colon) ? (1:size(dset,i)) : I[i], length(I))...)
setindex!(dset::HDF5Dataset, x, I::Union{AbstractRange{Int},Int,Colon}...) = setindex!(dset, x, ntuple(i-> isa(I[i], Colon) ? (1:size(dset,i)) : I[i], length(I))...)

function hyperslab(dset::HDF5Dataset, indices::Union{AbstractRange{Int},Int}...)
    local dsel_id
    dspace = dataspace(dset)
    try
        dims, maxdims = get_dims(dspace)
        n_dims = length(dims)
        if length(indices) != n_dims
            error("Wrong number of indices supplied, supplied length $(length(indices)) but expected $(n_dims).")
        end
        dsel_id = h5s_copy(dspace.id)
        dsel_start  = Vector{Hsize}(n_dims)
        dsel_stride = Vector{Hsize}(n_dims)
        dsel_count  = Vector{Hsize}(n_dims)
        for k = 1:n_dims
            index = indices[n_dims-k+1]
            if isa(index, Integer)
                dsel_start[k] = index-1
                dsel_stride[k] = 1
                dsel_count[k] = 1
            elseif isa(index, AbstractRange)
                dsel_start[k] = first(index)-1
                dsel_stride[k] = step(index)
                dsel_count[k] = length(index)
            else
                error("index must be range or integer")
            end
            if dsel_start[k] < 0 || dsel_start[k]+(dsel_count[k]-1)*dsel_stride[k] >= dims[n_dims-k+1]
                println(dsel_start)
                println(dsel_stride)
                println(dsel_count)
                println(reverse(dims))
                error("index out of range")
            end
        end
        h5s_select_hyperslab(dsel_id, H5S_SELECT_SET, dsel_start, dsel_stride, dsel_count, C_NULL)
    finally
        close(dspace)
    end
    dsel_id
end

# Link to bytes in an external file
# If you need to link to multiple segments, use low-level interface
function d_create_external(parent::Union{HDF5File, HDF5Group}, name::String, filepath::String, t, sz::Dims, offset::Integer)
    checkvalid(parent)
    p = p_create(HDF5.H5P_DATASET_CREATE)
    h5p_set_external(p, filepath, Int(offset), prod(sz)*sizeof(t))
    d_create(parent, name, datatype(t), dataspace(sz), HDF5Properties(), p)
end
d_create_external(parent::Union{HDF5File, HDF5Group}, name::String, filepath::String, t::Type, sz::Dims) = d_create_external(parent, name, filepath, t, sz, 0)

function do_write_chunk(dataset::HDF5Dataset, offset, chunk_bytes::Vector{UInt8}, filter_mask=0)
    checkvalid(dataset)
    offs = collect(Hsize, reverse(offset))-1
    h5do_write_chunk(dataset, H5P_DEFAULT, UInt32(filter_mask), offs, length(chunk_bytes), chunk_bytes)
end

struct HDF5ChunkStorage
    dataset::HDF5Dataset
end

function setindex!(chunk_storage::HDF5ChunkStorage, v::Tuple{<:Integer,Vector{UInt8}}, index::Integer...)
    do_write_chunk(chunk_storage.dataset, Hsize.(index), v[2], UInt32(v[1]))
end

# end of high-level interface


### HDF5 utilities ###
readarray(dset::HDF5Dataset, type_id, buf) = h5d_read(dset.id, type_id, buf)
readarray(attr::HDF5Attribute, type_id, buf) = h5a_read(attr.id, type_id, buf)
writearray(dset::HDF5Dataset, type_id, buf) = h5d_write(dset.id, type_id, buf)
writearray(attr::HDF5Attribute, type_id, buf) = h5a_write(attr.id, type_id, buf)

# Determine Julia "native" type from the class, datatype, and dataspace
# For datasets, defined file formats should use attributes instead
function hdf5_to_julia(obj::Union{HDF5Dataset, HDF5Attribute})
    local T
    objtype = datatype(obj)
    try
        T = hdf5_to_julia_eltype(objtype)
    finally
        close(objtype)
    end
    if T <: HDF5Vlen
        return T
    end
    # Determine whether it's an array
    objspace = dataspace(obj)
    try
        stype = h5s_get_simple_extent_type(objspace.id)
        if stype == H5S_SIMPLE
            return Array{T}
        elseif stype == H5S_NULL
            return EmptyArray{T}
        else
            return T
        end
    finally
        close(objspace)
    end
end

function hdf5_to_julia_eltype(objtype)
    local T
    class_id = h5t_get_class(objtype.id)
    if class_id == H5T_STRING
        cset = h5t_get_cset(objtype.id)
        n = h5t_get_size(objtype.id)
        if cset == H5T_CSET_ASCII
            T = (n == 1) ? ASCIIChar : String
        elseif cset == H5T_CSET_UTF8
            T = (n == 1) ? UTF8Char : String
        else
            error("character set ", cset, " not recognized")
        end
    elseif class_id == H5T_INTEGER || class_id == H5T_FLOAT
        # First look in the type list for a match
        # otherwise fall back to a native datatype
        # Allows for users to dynamically add types to the typemap
        t_size = h5t_get_size(objtype)
        if class_id == H5T_INTEGER
            is_signed = h5t_get_sign(objtype)
        else
            is_signed = nothing # probably should include the mantissa size, etc...
        end
        if haskey(hdf5_type_map, (class_id, is_signed, t_size))
            T = hdf5_type_map[(class_id, is_signed, t_size)]
        else
            native_type = h5t_get_native_type(objtype.id)
            try
                native_size = h5t_get_size(native_type)
                if class_id == H5T_INTEGER
                    is_signed = h5t_get_sign(native_type)
                else
                    is_signed = nothing
                end
                T = hdf5_type_map[(class_id, is_signed, native_size)]
            finally
                h5t_close(native_type)
            end
        end
    elseif class_id == H5T_ENUM
        super_type = h5t_get_super(objtype.id)
        try
            native_type = h5t_get_native_type(super_type)
            try
                native_size = h5t_get_size(native_type)
                is_signed = h5t_get_sign(native_type)
                T = hdf5_type_map[(H5T_INTEGER, is_signed, native_size)]
            finally
                h5t_close(native_type)
            end
        finally
            h5t_close(super_type)
        end
    elseif class_id == H5T_REFERENCE
        # How to test whether it's a region reference or an object reference??
        T = HDF5ReferenceObj
    elseif class_id == H5T_OPAQUE
        T = HDF5Opaque
    elseif class_id == H5T_VLEN
        super_id = h5t_get_super(objtype.id)
        T = HDF5Vlen{hdf5_to_julia_eltype(HDF5Datatype(super_id))}
    elseif class_id == H5T_COMPOUND
        N = Int(h5t_get_nmembers(objtype.id))
        T = HDF5Compound{N}
    elseif class_id == H5T_ARRAY
        T = hdf5array(objtype)
    else
        error("Class id ", class_id, " is not yet supported")
    end
    T
end


### Convenience wrappers ###
# These supply default values where possible
# See also the "special handling" section below
h5a_write(attr_id::Hid, mem_type_id::Hid, buf::String) = h5a_write(attr_id, mem_type_id, Vector{UInt8}(buf))
function h5a_write(attr_id::Hid, mem_type_id::Hid, x::T) where {T<:HDF5Scalar}
    tmp = Ref{T}(x)
    h5a_write(attr_id, mem_type_id, tmp)
end
function h5a_write(attr_id::Hid, memtype_id::Hid, strs::Array{S}) where {S<:String}
    p = Ref{Cstring}(strs)
    h5a_write(attr_id, memtype_id, p)
end
function h5a_write(attr_id::Hid, memtype_id::Hid, v::HDF5Vlen{T}) where {T<:Union{HDF5Scalar,CharType}}
    vp = vlenpack(v)
    h5a_write(attr_id, memtype_id, vp)
end
h5a_create(loc_id::Hid, name::String, type_id::Hid, space_id::Hid) = h5a_create(loc_id, name, type_id, space_id, _attr_properties(name), H5P_DEFAULT)
h5a_open(obj_id::Hid, name::String) = h5a_open(obj_id, name, H5P_DEFAULT)
h5d_create(loc_id::Hid, name::String, type_id::Hid, space_id::Hid) = h5d_create(loc_id, name, type_id, space_id, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT)
h5d_open(obj_id::Hid, name::String) = h5d_open(obj_id, name, H5P_DEFAULT)
h5d_read(dataset_id::Hid, memtype_id::Hid, buf::Array) = h5d_read(dataset_id, memtype_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, buf)
h5d_write(dataset_id::Hid, memtype_id::Hid, buf::Array) = h5d_write(dataset_id, memtype_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, buf)
function h5d_write(dataset_id::Hid, memtype_id::Hid, str::String)
    ccall((:H5Dwrite, libhdf5), Herr, (Hid, Hid, Hid, Hid, Hid, Cstring), dataset_id, memtype_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, str)
end
function h5d_write(dataset_id::Hid, memtype_id::Hid, x::T) where {T<:HDF5Scalar}
    tmp = Ref{T}(x)
    h5d_write(dataset_id, memtype_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, tmp)
end
function h5d_write(dataset_id::Hid, memtype_id::Hid, strs::Array{S}) where {S<:String}
    p = Ref{Cstring}(strs)
    h5d_write(dataset_id, memtype_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, p)
end
function h5d_write(dataset_id::Hid, memtype_id::Hid, v::HDF5Vlen{T}) where {T<:Union{HDF5Scalar,CharType}}
    vp = vlenpack(v)
    h5d_write(dataset_id, memtype_id, H5S_ALL, H5S_ALL, H5P_DEFAULT, vp)
end
h5f_create(filename::String) = h5f_create(filename, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT)
h5f_open(filename::String, mode) = h5f_open(filename, mode, H5P_DEFAULT)
h5g_create(obj_id::Hid, name::String) = h5g_create(obj_id, name, H5P_DEFAULT, H5P_DEFAULT, H5P_DEFAULT)
h5g_create(obj_id::Hid, name::String, lcpl_id, gcpl_id) = h5g_create(obj_id, name, lcpl_id, gcpl_id, H5P_DEFAULT)
h5g_open(file_id::Hid, name::String) = h5g_open(file_id, name, H5P_DEFAULT)
h5l_exists(loc_id::Hid, name::String) = h5l_exists(loc_id, name, H5P_DEFAULT)
h5o_open(obj_id::Hid, name::String) = h5o_open(obj_id, name, H5P_DEFAULT)
#h5s_get_simple_extent_ndims(space_id::Hid) = h5s_get_simple_extent_ndims(space_id, C_NULL, C_NULL)
h5t_get_native_type(type_id::Hid) = h5t_get_native_type(type_id, H5T_DIR_ASCEND)
if libversion >= v"1.10.0"
    const H5RDEREFERENCE = :H5Rdereference1
else
    const H5RDEREFERENCE = :H5Rdereference
end
function h5r_dereference(obj_id::Hid, ref_type::Integer, pointee::HDF5ReferenceObj)
    ret = ccall((H5RDEREFERENCE, libhdf5), Hid, (Hid, Cint, Ref{HDF5ReferenceObj}),
                obj_id, ref_type, pointee)
    if ret < 0
        error("Error dereferencing object")
    end
    ret
end

### Utilities for generating ccall wrapper functions programmatically ###

function ccallexpr(lib::AbstractString, ccallsym::Symbol, outtype, argtypes::Tuple, argsyms::Tuple)
    ccallargs = Any[Expr(:tuple, Expr(:quote, ccallsym), lib), outtype, Expr(:tuple, argtypes...)]
    ccallargs = ccallsyms(ccallargs, length(argtypes), argsyms)
    :(ccall($(ccallargs...)))
end

function ccallsyms(ccallargs, n, argsyms)
    if n > 0
        if length(argsyms) == n
            ccallargs = Any[ccallargs..., argsyms...]
        else
            for i = 1:length(argsyms)-1
                push!(ccallargs, argsyms[i])
            end
            for i = 1:n-length(argsyms)+1
                push!(ccallargs, Expr(:getindex, argsyms[end], i))
            end
        end
    end
    ccallargs
end

function funcdecexpr(funcsym, n::Int, argsyms)
    if length(argsyms) == n
        return Expr(:call, funcsym, argsyms...)
    else
        exargs = Any[funcsym, argsyms[1:end-1]...]
        push!(exargs, Expr(:..., argsyms[end]))
        return Expr(:call, exargs...)
    end
end

### ccall wrappers ###

# Note: use alphabetical order

# Functions that return Herr, pass back nothing to Julia (as an output), with simple
# error messages
for (jlname, h5name, outtype, argtypes, argsyms, msg) in
    ((:h5_close, :H5close, Herr, (), (), "Error closing the HDF5 resources"),
     (:h5_dont_atexit, :H5dont_atexit, Herr, (), (), "Error calling dont_atexit"),
     (:h5_garbage_collect, :H5garbage_collect, Herr, (), (), "Error on garbage collect"),
     (:h5_open, :H5open, Herr, (), (), "Error initializing the HDF5 library"),
     (:h5_set_free_list_limits, :H5set_free_list_limits, Herr, (Cint, Cint, Cint, Cint, Cint, Cint), (:reg_global_lim, :reg_list_lim, :arr_global_lim, :arr_list_lim, :blk_global_lim, :blk_list_lim), "Error setting limits on free lists"),
     (:h5a_close, :H5Aclose, Herr, (Hid,), (:id,), "Error closing attribute"),
     (:h5a_write, :H5Awrite, Herr, (Hid, Hid, Ptr{Void}), (:attr_hid, :mem_type_id, :buf), "Error writing attribute data"),
     (:h5d_close, :H5Dclose, Herr, (Hid,), (:dataset_id,), "Error closing dataset"),
     (:h5d_flush, :H5Dflush, Herr, (Hid,), (:dataset_id,), "Error flushing dataset"),
     (:h5d_oappend, :H5DOappend, Herr, (Hid, Hid, Cuint, Hsize, Hid, Ptr{Void}) , (:dset_id, :dxpl_id, :index, :num_elem, :memtype, :buffer), "error appending"),
     (:h5do_write_chunk, :H5DOwrite_chunk, Herr, (Hid, Hid, Int32, Ptr{Hsize}, Csize_t, Ptr{Void}), (:dset_id, :dxpl_id, :filter_mask, :offset, :bufsize, :buf), "Error writing chunk"),
     (:h5d_refresh, :H5Drefresh, Herr, (Hid,), (:dataset_id,), "Error refreshing dataset"),
     (:h5d_set_extent, :H5Dset_extent, Herr, (Hid, Ptr{Hsize}), (:dataset_id, :new_dims), "Error extending dataset dimensions"),
     (:h5d_vlen_get_buf_size, :H5Dvlen_get_buf_size, Herr, (Hid, Hid, Hid, Ptr{Hsize}), (:dset_id, :type_id, :space_id, :buf), "Error getting vlen buffer size"),
     (:h5d_vlen_reclaim, :H5Dvlen_reclaim, Herr, (Hid, Hid, Hid, Ptr{Void}), (:type_id, :space_id, :plist_id, :buf), "Error reclaiming vlen buffer"),
     (:h5d_write, :H5Dwrite, Herr, (Hid, Hid, Hid, Hid, Hid, Ptr{Void}), (:dataset_id, :mem_type_id, :mem_space_id, :file_space_id, :xfer_plist_id, :buf), "Error writing dataset"),
     (:h5e_set_auto, :H5Eset_auto2, Herr, (Hid, Ptr{Void}, Ptr{Void}), (:estack_id, :func, :client_data), "Error setting error reporting behavior"),  # FIXME callbacks, for now pass C_NULL for both pointers
     (:h5f_close, :H5Fclose, Herr, (Hid,), (:file_id,), "Error closing file"),
     (:h5f_flush, :H5Fflush, Herr, (Hid, Cint), (:object_id, :scope,), "Error flushing object to file"),
     (:hf5start_swmr_write, :H5Fstart_swmr_write, Herr, (Hid,), (:id,), "Error starting SWMR write"),
     (:h5f_get_vfd_handle, :H5Fget_vfd_handle, Herr, (Hid, Hid, Ptr{Ptr{Cint}}), (:file_id, :fapl_id, :file_handle), "Error getting VFD handle"),
     (:h5g_close, :H5Gclose, Herr, (Hid,), (:group_id,), "Error closing group"),
     (:h5g_get_info, :H5Gget_info, Herr, (Hid, Ptr{H5Ginfo}), (:group_id, :buf), "Error getting group info"),
     (:h5o_get_info, :H5Oget_info, Herr, (Hid, Ptr{H5Oinfo}), (:object_id, :buf), "Error getting object info"),
     (:h5o_close, :H5Oclose, Herr, (Hid,), (:object_id,), "Error closing object"),
     (:h5p_close, :H5Pclose, Herr, (Hid,), (:id,), "Error closing property list"),
     (:h5p_get_fclose_degree, :H5Pget_fclose_degree, Herr, (Hid, Ptr{Cint}), (:plist_id, :fc_degree), "Error getting close degree"),
     (:h5p_get_userblock, :H5Pget_userblock, Herr, (Hid, Ptr{Hsize}), (:plist_id, :len), "Error getting userblock"),
     (:h5p_set_char_encoding, :H5Pset_char_encoding, Herr, (Hid, Cint), (:plist_id, :encoding), "Error setting char encoding"),
     (:h5p_set_chunk, :H5Pset_chunk, Herr, (Hid, Cint, Ptr{Hsize}), (:plist_id, :ndims, :dims), "Error setting chunk size"),
     (:h5p_set_create_intermediate_group, :H5Pset_create_intermediate_group, Herr, (Hid, Cuint), (:plist_id, :setting), "Error setting create intermediate group"),
     (:h5p_set_external, :H5Pset_external, Herr, (Hid, Ptr{UInt8}, Int, Csize_t), (:plist_id, :name, :offset, :size), "Error setting external property"),
     (:h5p_set_fclose_degree, :H5Pset_fclose_degree, Herr, (Hid, Cint), (:plist_id, :fc_degree), "Error setting close degree"),
     (:h5p_set_deflate, :H5Pset_deflate, Herr, (Hid, Cuint), (:plist_id, :setting), "Error setting compression method and level (deflate)"),
     (:h5p_set_layout, :H5Pset_layout, Herr, (Hid, Cint), (:plist_id, :setting), "Error setting layout"),
     (:h5p_set_libver_bounds, :H5Pset_libver_bounds, Herr, (Hid, Cint, Cint), (:fapl_id, :libver_low, :libver_high), "Error setting library version bounds"),
     (:h5p_set_local_heap_size_hint, :H5Pset_local_heap_size_hint, Herr, (Hid, Cuint), (:fapl_id, :size_hint), "Error setting local heap size hint"),
     (:h5p_set_shuffle, :H5Pset_shuffle, Herr, (Hid,), (:plist_id,), "Error enabling shuffle filter"),
     (:h5p_set_userblock, :H5Pset_userblock, Herr, (Hid, Hsize), (:plist_id, :len), "Error setting userblock"),
     (:h5s_close, :H5Sclose, Herr, (Hid,), (:space_id,), "Error closing dataspace"),
     (:h5s_select_hyperslab, :H5Sselect_hyperslab, Herr, (Hid, Cint, Ptr{Hsize}, Ptr{Hsize}, Ptr{Hsize}, Ptr{Hsize}), (:dspace_id, :seloper, :start, :stride, :count, :block), "Error selecting hyperslab"),
     (:h5t_commit, :H5Tcommit2, Herr, (Hid, Ptr{UInt8}, Hid, Hid, Hid, Hid), (:loc_id, :name, :dtype_id, :lcpl_id, :tcpl_id, :tapl_id), "Error committing type"),
     (:h5t_close, :H5Tclose, Herr, (Hid,), (:dtype_id,), "Error closing datatype"),
     (:h5t_lock, :H5Tlock, Herr, (Hid,), (:dtype_id,), "Error locking datatype"),
     (:h5t_set_cset, :H5Tset_cset, Herr, (Hid, Cint), (:dtype_id, :cset), "Error setting character set in datatype"),
     (:h5t_set_ebias, :H5Tset_ebias, Herr, (Hid, Csize_t), (:dtype_id, :ebias), "Error setting exponential bias of floating-point type"),
     (:h5t_set_fields, :H5Tset_fields, Herr, (Hid, Csize_t, Csize_t, Csize_t, Csize_t, Csize_t), (:dtype_id, :spos, :epos, :esize, :mpos, :msize), "Error setting floating-point type fields"),
     (:h5t_set_size, :H5Tset_size, Herr, (Hid, Csize_t), (:dtype_id, :sz), "Error setting size of datatype"),
    )

    ex_dec = funcdecexpr(jlname, length(argtypes), argsyms)
    library = startswith(string(h5name), "H5DO") ? libhdf5_hl : libhdf5
    if library == ""
        # If the high-level library is not installed, then skip these functions
        continue
    end
    ex_ccall = ccallexpr(library, h5name, outtype, argtypes, argsyms)
    ex_body = quote
        status = $ex_ccall
        if status < 0
            error($msg)
        end
    end
    ex_func = Expr(:function, ex_dec, ex_body)
    @eval begin
        $ex_func
    end
end

# Functions returning a single argument, and/or with more complex
# error messages
for (jlname, h5name, outtype, argtypes, argsyms, ex_error) in
    ((:h5a_create, :H5Acreate2, Hid, (Hid, Ptr{UInt8}, Hid, Hid, Hid, Hid), (:loc_id, :pathname, :type_id, :space_id, :acpl_id, :aapl_id), :(error("Error creating attribute ", h5a_get_name(loc_id), "/", pathname))),
     (:h5a_create_by_name, :H5Acreate_by_name, Hid, (Hid, Ptr{UInt8}, Ptr{UInt8}, Hid, Hid, Hid, Hid, Hid), (:loc_id, :obj_name, :attr_name, :type_id, :space_id, :acpl_id, :aapl_id, :lapl_id), :(error("Error creating attribute ", attr_name, " for object ", obj_name))),
     (:h5a_delete, :H5Adelete, Herr, (Hid, Ptr{UInt8}), (:loc_id, :attr_name), :(error("Error deleting attribute ", attr_name))),
     (:h5a_delete_by_idx, :H5delete_by_idx, Herr, (Hid, Ptr{UInt8}, Cint, Cint, Hsize, Hid), (:loc_id, :obj_name, :idx_type, :order, :n, :lapl_id), :(error("Error deleting attribute ", n, " from object ", obj_name))),
     (:h5a_delete_by_name, :H5delete_by_name, Herr, (Hid, Ptr{UInt8}, Ptr{UInt8}, Hid), (:loc_id, :obj_name, :attr_name, :lapl_id), :(error("Error removing attribute ", attr_name, " from object ", obj_name))),
     (:h5a_get_create_plist, :H5Aget_create_plist, Hid, (Hid,), (:attr_id,), :(error("Cannot get creation property list"))),
     (:h5a_get_name, :H5Aget_name, Cssize_t, (Hid, Csize_t, Ptr{UInt8}), (:attr_id, :buf_size, :buf), :(error("Error getting attribute name"))),
     (:h5a_get_name_by_idx, :H5Aget_name_by_idx, Cssize_t, (Hid, Ptr{UInt8}, Cint, Cint, Hsize, Ptr{UInt8}, Csize_t, Hid), (:loc_id, :obj_name, :index_type, :order, :idx, :name, :size, :lapl_id), :(error("Error getting attribute name"))),
     (:h5a_get_space, :H5Aget_space, Hid, (Hid,), (:attr_id,), :(error("Error getting attribute dataspace"))),
     (:h5a_get_type, :H5Aget_type, Hid, (Hid,), (:attr_id,), :(error("Error getting attribute type"))),
     (:h5a_open, :H5Aopen, Hid, (Hid, Ptr{UInt8}, Hid), (:obj_id, :pathname, :aapl_id), :(error("Error opening attribute ", h5i_get_name(obj_id), "/", pathname))),
     (:h5a_read, :H5Aread, Herr, (Hid, Hid, Ptr{Void}), (:attr_id, :mem_type_id, :buf), :(error("Error reading attribute ", h5a_get_name(attr_id)))),
     (:h5d_create, :H5Dcreate2, Hid, (Hid, Ptr{UInt8}, Hid, Hid, Hid, Hid, Hid), (:loc_id, :pathname, :dtype_id, :space_id, :dlcpl_id, :dcpl_id, :dapl_id), :(error("Error creating dataset ", h5i_get_name(loc_id), "/", pathname))),
     (:h5d_get_access_plist, :H5Dget_access_plist, Hid, (Hid,), (:dataset_id,), :(error("Error getting dataset access property list"))),
     (:h5d_get_create_plist, :H5Dget_create_plist, Hid, (Hid,), (:dataset_id,), :(error("Error getting dataset create property list"))),
     (:h5d_get_offset, :H5Dget_offset, Haddr, (Hid,), (:dataset_id,), :(error("Error getting offset"))),
     (:h5d_get_space, :H5Dget_space, Hid, (Hid,), (:dataset_id,), :(error("Error getting dataspace"))),
     (:h5d_get_type, :H5Dget_type, Hid, (Hid,), (:dataset_id,), :(error("Error getting dataspace type"))),
     (:h5d_open, :H5Dopen2, Hid, (Hid, Ptr{UInt8}, Hid), (:loc_id, :pathname, :dapl_id), :(error("Error opening dataset ", h5i_get_name(loc_id), "/", pathname))),
     (:h5d_read, :H5Dread, Herr, (Hid, Hid, Hid, Hid, Hid, Ptr{Void}), (:dataset_id, :mem_type_id, :mem_space_id, :file_space_id, :xfer_plist_id, :buf), :(error("Error reading dataset ", h5i_get_name(dataset_id)))),
     (:h5f_create, :H5Fcreate, Hid, (Ptr{UInt8}, Cuint, Hid, Hid), (:pathname, :flags, :fcpl_id, :fapl_id), :(error("Error creating file ", pathname))),
     (:h5f_get_access_plist, :H5Fget_access_plist, Hid, (Hid,), (:file_id,), :(error("Error getting file access property list"))),
     (:h5f_get_create_plist, :H5Fget_create_plist, Hid, (Hid,), (:file_id,), :(error("Error getting file create property list"))),
     (:h5f_get_name, :H5Fget_name, Cssize_t, (Hid, Ptr{UInt8}, Csize_t), (:obj_id, :buf, :buf_size), :(error("Error getting file name"))),
     (:h5f_open, :H5Fopen, Hid, (Ptr{UInt8}, Cuint, Hid), (:pathname, :flags, :fapl_id), :(error("Error opening file ", pathname))),
     (:h5g_create, :H5Gcreate2, Hid, (Hid, Ptr{UInt8}, Hid, Hid, Hid), (:loc_id, :pathname, :lcpl_id, :gcpl_id, :gapl_id), :(error("Error creating group ", h5i_get_name(loc_id), "/", pathname))),
     (:h5g_get_create_plist, :H5Gget_create_plist, Hid, (Hid,), (:group_id,), :(error("Error getting group create property list"))),
     (:h5g_get_objname_by_idx, :H5Gget_objname_by_idx, Hid, (Hid, Hsize, Ptr{UInt8}, Csize_t), (:loc_id, :idx, :pathname, :size), :(error("Error getting group object name ", h5i_get_name(loc_id), "/", pathname))),
     (:h5g_get_num_objs, :H5Gget_num_objs, Hid, (Hid, Ptr{Hsize}), (:loc_id, :num_obj), :(error("Error getting group length"))),
     (:h5g_open, :H5Gopen2, Hid, (Hid, Ptr{UInt8}, Hid), (:loc_id, :pathname, :gapl_id), :(error("Error opening group ", h5i_get_name(loc_id), "/", pathname))),
     (:h5i_get_file_id, :H5Iget_file_id, Hid, (Hid,), (:obj_id,), :(error("Error getting file identifier"))),
     (:h5i_get_name, :H5Iget_name, Cssize_t, (Hid, Ptr{UInt8}, Csize_t), (:obj_id, :buf, :buf_size), :(error("Error getting object name"))),
     (:h5i_get_ref, :H5Iget_ref, Cint, (Hid,), (:obj_id,), :(error("Error getting reference count"))),
     (:h5i_get_type, :H5Iget_type, Cint, (Hid,), (:obj_id,), :(error("Error getting type"))),
     (:h5i_dec_ref, :H5Idec_ref, Cint, (Hid,), (:obj_id,), :(error("Error decementing reference"))),
     (:h5l_delete, :H5Ldelete, Herr, (Hid, Ptr{UInt8}, Hid), (:obj_id, :pathname, :lapl_id), :(error("Error deleting ", h5i_get_name(obj_id), "/", pathname))),
     (:h5l_create_external, :H5Lcreate_external, Herr, (Ptr{UInt8}, Ptr{UInt8}, Hid, Ptr{UInt8}, Hid, Hid), (:target_file_name, :target_obj_name, :link_loc_id, :link_name, :lcpl_id, :lapl_id), :(error("Error creating external link ", link_name, " pointing to ", target_obj_name, " in file ", target_file_name))),
     (:h5l_create_hard, :H5Lcreate_hard, Herr, (Hid, Ptr{UInt8}, Hid, Ptr{UInt8}, Hid, Hid), (:obj_loc_id, :obj_name, :link_loc_id, :link_name, :lcpl_id, :lapl_id), :(error("Error creating hard link ", link_name, " pointing to ", obj_name))),
     (:h5l_create_soft, :H5Lcreate_soft, Herr, (Ptr{UInt8}, Hid, Ptr{UInt8}, Hid, Hid), (:target_path, :link_loc_id, :link_name, :lcpl_id, :lapl_id), :(error("Error creating soft link ", link_name, " pointing to ", target_path))),
     (:h5l_get_info, :H5Lget_info, Herr, (Hid, Ptr{UInt8}, Ptr{H5LInfo}, Hid), (:link_loc_id, :link_name, :link_buf, :lapl_id), :(error("Error getting info for link ", link_name))),
     (:h5o_open, :H5Oopen, Hid, (Hid, Ptr{UInt8}, Hid), (:loc_id, :pathname, :lapl_id), :(error("Error opening object ", h5i_get_name(loc_id), "/", pathname))),
     (:h5o_open_by_idx, :H5Oopen_by_idx, Hid, (Hid, Ptr{UInt8}, Cint, Cint, Hsize, Hid), (:loc_id, :group_name, :index_type, :order, :n, :lapl_id), :(error("Error opening object of index ", n))),
     (:h5o_open_by_addr, :H5Oopen_by_addr, Hid, (Hid, Haddr), (:loc_id, :addr), :(error("Error opening object by address"))),
     (:h5o_copy, :H5Ocopy, Herr, (Hid, Ptr{UInt8}, Hid, Ptr{UInt8}, Hid, Hid), (:src_loc_id, :src_name, :dst_loc_id, :dst_name, :ocpypl_id, :lcpl_id), :(error("Error copying object ", h5i_get_name(src_loc_id), "/", src_name, " to ", h5i_get_name(dst_loc_id), "/", dst_name))),
     (:h5p_create, :H5Pcreate, Hid, (Hid,), (:cls_id,), "Error creating property list"),
     (:h5p_get_chunk, :H5Pget_chunk, Cint, (Hid, Cint, Ptr{Hsize}), (:plist_id, :n_dims, :dims), :(error("Error getting chunk size"))),
     (:h5p_get_layout, :H5Pget_layout, Cint, (Hid,), (:plist_id,), :(error("Error getting layout"))),
     (:h5p_get_driver, :H5Pget_driver_info, Ptr{Void}, (Hid,), (:plist_id,), "Error getting driver info"),
     (:h5r_create, :H5Rcreate, Herr, (Ptr{HDF5ReferenceObj}, Hid, Ptr{UInt8}, Cint, Hid), (:ref, :loc_id, :pathname, :ref_type, :space_id), :(error("Error creating reference to object ", hi5_get_name(loc_id), "/", pathname))),
     (:h5r_get_obj_type, :H5Rget_obj_type2, Herr, (Hid, Cint, Ptr{Void}, Ptr{Cint}), (:loc_id, :ref_type, :ref, :obj_type), :(error("Error getting object type"))),
     (:h5r_get_region, :H5Rget_region, Hid, (Hid, Cint, Ptr{Void}), (:loc_id, :ref_type, :ref), :(error("Error getting region from reference"))),
     (:h5s_copy, :H5Scopy, Hid, (Hid,), (:space_id,), :(error("Error copying dataspace"))),
     (:h5s_create, :H5Screate, Hid, (Cint,), (:class,), :(error("Error creating dataspace"))),
     (:h5s_create_simple, :H5Screate_simple, Hid, (Cint, Ptr{Hsize}, Ptr{Hsize}), (:rank, :current_dims, :maximum_dims), :(error("Error creating simple dataspace"))),
     (:h5s_get_simple_extent_dims, :H5Sget_simple_extent_dims, Cint, (Hid, Ptr{Hsize}, Ptr{Hsize}), (:space_id, :dims, :maxdims), :(error("Error getting the dimensions for a dataspace"))),
     (:h5s_get_simple_extent_ndims, :H5Sget_simple_extent_ndims, Cint, (Hid,), (:space_id,), :(error("Error getting the number of dimensions for a dataspace"))),
     (:h5s_get_simple_extent_type, :H5Sget_simple_extent_type, Cint, (Hid,), (:space_id,), :(error("Error getting the dataspace type"))),
     (:h5t_array_create, :H5Tarray_create2, Hid, (Hid, Cuint, Ptr{Hsize}), (:basetype_id, :ndims, :sz), :(error("Error creating H5T_ARRAY of id ", basetype_id, " and size ", sz))),
     (:h5t_copy, :H5Tcopy, Hid, (Hid,), (:dtype_id,), :(error("Error copying datatype"))),
     (:h5t_create, :H5Tcreate, Hid, (Cint, Csize_t), (:class_id, :sz), :(error("Error creating datatype of id ", class_id))),
     (:h5t_equal, :H5Tequal, Hid, (Hid, Hid), (:dtype_id1, :dtype_id2), :(error("Error checking datatype equality"))),
     (:h5t_get_array_dims, :H5Tget_array_dims2, Cint, (Hid, Ptr{Hsize}), (:dtype_id, :dims), :(error("Error getting dimensions of array"))),
     (:h5t_get_array_ndims, :H5Tget_array_ndims, Cint, (Hid,), (:dtype_id,), :(error("Error getting ndims of array"))),
     (:h5t_get_class, :H5Tget_class, Cint, (Hid,), (:dtype_id,), :(error("Error getting class"))),
     (:h5t_get_cset, :H5Tget_cset, Cint, (Hid,), (:dtype_id,), :(error("Error getting character set encoding"))),
     (:h5t_get_ebias, :H5Tget_ebias, Csize_t, (Hid,), (:dtype_id,), :(error("Error getting exponential bias"))),
     (:h5t_get_member_class, :H5Tget_member_class, Cint, (Hid, Cuint), (:dtype_id, :index), :(error("Error getting class of compound datatype member #", index))),
     (:h5t_get_member_index, :H5Tget_member_index, Cint, (Hid, Ptr{UInt8}), (:dtype_id, :membername), :(error("Error getting index of compound datatype member \"", membername, "\""))),
     (:h5t_get_member_offset, :H5Tget_member_offset, Csize_t, (Hid, Cuint), (:dtype_id, :index), :(error("Error getting offset of compound datatype member #", index))),
     (:h5t_get_member_type, :H5Tget_member_type, Hid, (Hid, Cuint), (:dtype_id, :index), :(error("Error getting type of compound datatype member #", index))),
     (:h5t_get_native_type, :H5Tget_native_type, Hid, (Hid, Cint), (:dtype_id, :direction), :(error("Error getting native type"))),
     (:h5t_get_nmembers, :H5Tget_nmembers, Cint, (Hid,), (:dtype_id,), :(error("Error getting the number of members"))),
     (:h5t_get_sign, :H5Tget_sign, Cint, (Hid,), (:dtype_id,), :(error("Error getting sign"))),
     (:h5t_get_size, :H5Tget_size, Csize_t, (Hid,), (:dtype_id,), :(error("Error getting size"))),
     (:h5t_get_super, :H5Tget_super, Hid, (Hid,), (:dtype_id,), :(error("Error getting super type"))),
     (:h5t_get_strpad, :H5Tget_strpad, Cint, (Hid,), (:dtype_id,), :(error("Error getting string padding"))),
     (:h5t_insert, :H5Tinsert, Herr, (Hid, Ptr{UInt8}, Csize_t, Hid), (:dtype_id, :fieldname, :offset, :field_id), :(error("Error adding field ", fieldname, " to compound datatype"))),
     (:h5t_open, :H5Topen2, Hid, (Hid, Ptr{UInt8}, Hid), (:loc_id, :name, :tapl_id), :(error("Error opening type ", h5i_get_name(loc_id), "/", name))),
     (:h5t_vlen_create, :H5Tvlen_create, Hid, (Hid,), (:base_type_id,), :(error("Error creating vlen type"))),
     ## The following doesn't work because it's in libhdf5_hl.so.
     ## (:h5tb_get_field_info, :H5TBget_field_info, Herr, (Hid, Ptr{UInt8}, Ptr{Ptr{UInt8}}, Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), (:loc_id, :table_name, :field_names, :field_sizes, :field_offsets, :type_size), :(error("Error getting field information")))
)

    ex_dec = funcdecexpr(jlname, length(argtypes), argsyms)
    ex_ccall = ccallexpr(libhdf5, h5name, outtype, argtypes, argsyms)
    ex_body = quote
        ret = $ex_ccall
        if ret < 0
            $ex_error
        end
        return ret
    end
    ex_func = Expr(:function, ex_dec, ex_body)
    @eval begin
        $ex_func
    end
end

# Functions like the above, returning a Julia boolean
for (jlname, h5name, outtype, argtypes, argsyms, ex_error) in
    ((:h5a_exists, :H5Aexists, Htri, (Hid, Ptr{UInt8}), (:obj_id, :attr_name), :(error("Error checking whether attribute ", attr_name, " exists"))),
     (:h5a_exists_by_name, :H5Aexists_by_name, Htri, (Hid, Ptr{UInt8}, Ptr{UInt8}, Hid), (:loc_id, :obj_name, :attr_name, :lapl_id), :(error("Error checking whether object ", obj_name, " has attribute ", attr_name))),
     (:h5f_is_hdf5, :H5Fis_hdf5, Htri, (Ptr{UInt8},), (:pathname,), :(error("Cannot access file ", pathname))),
     (:h5i_is_valid, :H5Iis_valid, Htri, (Hid,), (:obj_id,), :(error("Cannot determine whether object is valid"))),
     (:h5l_exists, :H5Lexists, Htri, (Hid, Ptr{UInt8}, Hid), (:loc_id, :pathname, :lapl_id), :(error("Cannot determine whether ", pathname, " exists"))),
     (:h5s_is_simple, :H5Sis_simple, Htri, (Hid,), (:space_id,), :(error("Error determining whether dataspace is simple"))),
     (:h5t_is_variable_str, :H5Tis_variable_str, Htri, (Hid,), (:type_id,), :(error("Error determining whether string is of variable length"))),
     (:h5t_committed, :H5Tcommitted, Htri, (Hid,), (:dtype_id,), :(error("Error determining whether datatype is committed"))),
)
    ex_dec = funcdecexpr(jlname, length(argtypes), argsyms)
    ex_ccall = ccallexpr(libhdf5, h5name, outtype, argtypes, argsyms)
    ex_body = quote
        ret = $ex_ccall
        if ret < 0
            $ex_error
        end
        return ret > 0
    end
    ex_func = Expr(:function, ex_dec, ex_body)
    @eval begin
        $ex_func
    end
end

# Functions that require special handling

function h5a_get_name(attr_id::Hid)
    len = h5a_get_name(attr_id, 0, C_NULL) # order of args differs from {f,i}_get_name
    buf = Vector{UInt8}(len+1)
    h5a_get_name(attr_id, len+1, buf)
    String(buf[1:len])
end
function h5f_get_name(loc_id::Hid)
    len = h5f_get_name(loc_id, C_NULL, 0)
    buf = Vector{UInt8}(len+1)
    h5f_get_name(loc_id, buf, len+1)
    String(buf[1:len])
end
function h5i_get_name(loc_id::Hid)
    len = h5i_get_name(loc_id, C_NULL, 0)
    buf = Vector{UInt8}(len+1)
    h5i_get_name(loc_id, buf, len+1)
    String(buf[1:len])
end
function h5l_get_info(link_loc_id::Hid, link_name::String, lapl_id::Hid)
    info = Ref{H5LInfo}()
    h5l_get_info(link_loc_id, link_name, info, lapl_id)
    info[]
end
function h5s_get_simple_extent_dims(space_id::Hid)
    n = h5s_get_simple_extent_ndims(space_id)
    dims = Vector{Hsize}(n)
    maxdims = Vector{Hsize}(n)
    h5s_get_simple_extent_dims(space_id, dims, maxdims)
    return tuple(reverse!(dims)...), tuple(reverse!(maxdims)...)
end
function h5t_get_fields(type_id::Hid)
    spos = Ref{Csize_t}()
    epos = Ref{Csize_t}()
    esize = Ref{Csize_t}()
    mpos = Ref{Csize_t}()
    msize = Ref{Csize_t}()
    herr = ccall((:H5Tget_fields, libhdf5),
                 Herr,
                 (Hid, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}),
                 type_id, spos, epos, esize, mpos, msize)
    if herr < 0
        error("Error getting fields of floating-point datatype")
    end
    return (spos[], epos[], esize[], mpos[], msize[])
end
function h5t_get_member_name(type_id::Hid, index::Integer)
    pn = ccall((:H5Tget_member_name, libhdf5), Ptr{UInt8}, (Hid, Cuint), type_id, index)
    if pn == C_NULL
        error("Error getting name of compound datatype member #", index)
    end
    s = unsafe_string(pn)
    Libc.free(pn)
    s
end
function h5t_get_tag(type_id::Hid)
    pc = ccall((:H5Tget_tag, libhdf5),
                   Ptr{UInt8},
                   (Hid,),
                   type_id)
    if pc == C_NULL
        error("Error getting opaque tag")
    end
    s = unsafe_string(pc)
    Libc.free(pc)
    s
end

function h5f_get_obj_ids(file_id::Hid, types::Integer)
    sz = ccall((:H5Fget_obj_count, libhdf5), Int, (Hid, UInt32),
               file_id, types)
    sz >= 0 || error("error getting object count")
    hids = Vector{Hid}(sz)
    sz2 = ccall((:H5Fget_obj_ids, libhdf5), Int, (Hid, UInt32, UInt, Ptr{Hid}),
          file_id, types, sz, hids)
    sz2 >= 0 || error("error getting objects")
    sz2 != sz && resize!(hids, sz2)
    hids
end

function vlen_get_buf_size(dset::HDF5Dataset, dtype::HDF5Datatype, dspace::HDF5Dataspace)
    sz = Ref{Hsize}()
    h5d_vlen_get_buf_size(dset.id, dtype.id, dspace.id, sz)
    sz[]
end

function hdf5array(objtype)
    nd = h5t_get_array_ndims(objtype.id)
    dims = Vector{Hsize}(nd)
    h5t_get_array_dims(objtype.id, dims)
    eltyp = HDF5Datatype(h5t_get_super(objtype.id))
    T = hdf5_to_julia_eltype(eltyp)
    dimsizes = ntuple(i -> Int(dims[nd-i+1]), nd)  # reverse order
    FixedArray{T, dimsizes}
end

### Property manipulation ###
get_create_properties(dset::HDF5Dataset) = HDF5Properties(h5d_get_create_plist(dset.id))
get_create_properties(g::HDF5Group) = HDF5Properties(h5g_get_create_plist(dset.id))
get_create_properties(g::HDF5File) = HDF5Properties(h5f_get_create_plist(dset.id))
get_create_properties(g::HDF5Attribute) = HDF5Properties(h5a_get_create_plist(dset.id))
function get_chunk(p::HDF5Properties)
    n = h5p_get_chunk(p, 0, C_NULL)
    cdims = Vector{Hsize}(n)
    h5p_get_chunk(p, n, cdims)
    tuple(convert(Array{Int}, reverse(cdims))...)
end
function get_chunk(dset::HDF5Dataset)
    p = get_create_properties(dset)
    local ret
    try
        ret = get_chunk(p)
    finally
        close(p)
    end
    ret
end
set_chunk(p::HDF5Properties, dims...) = h5p_set_chunk(p.id, length(dims), Hsize[reverse(dims)...])
function get_userblock(p::HDF5Properties)
    alen = Ref{Hsize}()
    h5p_get_userblock(p.id, alen)
    alen[]
end
function get_fclose_degree(p::HDF5Properties)
    out = Ref{Cint}()
    h5p_get_fclose_degee(p.id, out)
    out[]
end
function get_libver_bounds(p::HDF5Properties)
    out1 = Ref{Cint}()
    out2 = Ref{Cint}()
    h5p_get_libver_bounds(p.id, out1, out2)
    out1[], out2[]
end

"""
    get_datasets(file::HDF5File) -> datasets::Vector{HDF5Dataset}

Get all the datasets in an hdf5 file without loading the data.
"""		
function get_datasets(file::HDF5File)
    list = HDF5Dataset[]
    get_datasets!(list, file)
    list
end
 function get_datasets!(list::Vector{HDF5Dataset}, node::Union{HDF5File,HDF5Group,HDF5Dataset})
    if isa(node, HDF5Dataset)
        push!(list, node)
    else
        for c in names(node)
            get_datasets!(list, node[c])
        end
    end
end

# property function get/set pairs
const hdf5_prop_get_set = Dict(
    "blosc"         => (nothing, h5p_set_blosc),
    "chunk"         => (get_chunk, set_chunk),
    "compress"      => (nothing, h5p_set_deflate),
    "deflate"       => (nothing, h5p_set_deflate),
    "fclose_degree" => (get_fclose_degree, h5p_set_fclose_degree),
    "layout"        => (h5p_get_layout, h5p_set_layout),
    "libver_bounds" => (get_libver_bounds, h5p_set_libver_bounds),
    "shuffle"       => (nothing, h5p_set_shuffle),
    "userblock"     => (get_userblock, h5p_set_userblock),
)
# properties that require chunks in order to work (e.g. any filter)
const chunked_props = Set(["compress", "deflate", "blosc", "shuffle"])

"""
    create_external(source::Union{HDF5File, HDF5Group}, source_relpath, target_filename, target_path;
                    lcpl_id=HDF5.H5P_DEFAULT, lapl_id=HDF5.H5P.DEFAULT)

Create an external link such that `source[source_relpath]` points to `target_path` within the file
with path `target_filename`; Calls `[H5Lcreate_external](https://www.hdfgroup.org/HDF5/doc/RM/RM_H5L.html#Link-CreateExternal)`.
"""
function create_external(source::Union{HDF5File, HDF5Group}, source_relpath, target_filename, target_path; lcpl_id=H5P_DEFAULT, lapl_id=H5P_DEFAULT)
    h5l_create_external(target_filename, target_path, source.id, source_relpath, lcpl_id, lapl_id)
    nothing
end

# error handling
function hiding_errors(f)
    error_stack = H5E_DEFAULT
    # error_stack = ccall((:H5Eget_current_stack, libhdf5), Hid, ())
    old_func = Ref{Ptr{Void}}()
    old_client_data = Ref{Ptr{Void}}()
    ccall((:H5Eget_auto2, libhdf5), Herr, (Hid, Ptr{Ptr{Void}}, Ptr{Ptr{Void}}),
        error_stack, old_func, old_client_data)
    ccall((:H5Eset_auto2, libhdf5), Herr, (Hid, Ptr{Void}, Ptr{Void}),
        error_stack, C_NULL, C_NULL)
    res = f()
    ccall((:H5Eset_auto2, libhdf5), Herr, (Hid, Ptr{Void}, Ptr{Void}),
        error_stack, old_func[], old_client_data[])
    res
end

# Define globally because JLD uses this, too
const rehash! = Base.rehash!

# Across initializations of the library, the id of various properties
# will change. So don't hard-code the id (important for precompilation)
const UTF8_LINK_PROPERTIES = Ref{HDF5Properties}()
_link_properties(path::String) = UTF8_LINK_PROPERTIES[]
const UTF8_ATTRIBUTE_PROPERTIES = Ref{HDF5Properties}()
_attr_properties(path::String) = UTF8_ATTRIBUTE_PROPERTIES[]
const ASCII_LINK_PROPERTIES = Ref{HDF5Properties}()
const ASCII_ATTRIBUTE_PROPERTIES = Ref{HDF5Properties}()

const DEFAULT_PROPERTIES = HDF5Properties(H5P_DEFAULT, false)

function __init__()
    init_libhdf5()
    register_blosc()
    # Turn off automatic error printing
    # h5e_set_auto(H5E_DEFAULT, C_NULL, C_NULL)

    ASCII_LINK_PROPERTIES[] = p_create(H5P_LINK_CREATE)
    h5p_set_char_encoding(ASCII_LINK_PROPERTIES[].id, H5T_CSET_ASCII)
    h5p_set_create_intermediate_group(ASCII_LINK_PROPERTIES[].id, 1)
    UTF8_LINK_PROPERTIES[] = p_create(H5P_LINK_CREATE)
    h5p_set_char_encoding(UTF8_LINK_PROPERTIES[].id, H5T_CSET_UTF8)
    h5p_set_create_intermediate_group(UTF8_LINK_PROPERTIES[].id, 1)
    ASCII_ATTRIBUTE_PROPERTIES[] = p_create(H5P_ATTRIBUTE_CREATE)
    h5p_set_char_encoding(ASCII_ATTRIBUTE_PROPERTIES[].id, H5T_CSET_ASCII)
    UTF8_ATTRIBUTE_PROPERTIES[] = p_create(H5P_ATTRIBUTE_CREATE)
    h5p_set_char_encoding(UTF8_ATTRIBUTE_PROPERTIES[].id, H5T_CSET_UTF8)

    # Set up Float16 (must occur at runtime)
    @eval(const H5T_FLOAT16 = make_float16())
    @eval hdf5_type_id(::Type{Float16}) = H5T_FLOAT16

    rehash!(hdf5_type_map, length(hdf5_type_map.keys))
    rehash!(hdf5_prop_get_set, length(hdf5_prop_get_set.keys))

    nothing
end

end  # module
