# The context API is under active development. This is an internal API and may change.

"""
    HDF5Context

*Internal API*

An `HDF5Context` is a collection of HDF5 property lists. It is meant to be used
as a `Task` local mechanism to store state and change the default property lists
for new objects.

Use the function `get_context_property(name::Symbol)` to access a property
list within the local context.

The context in `task_local_storage()[:hdf5_context]` will be checked first.
A common global HDF5Context is stored in the constant `HDF5.CONTEXT` and
serves as the default context if the current task does not have a
`:hdf5_context`.

# Fields

* attribute_access
* attribute_create
* dataset_access
* dataset_create
* dataset_tranfer
* datatype_access
* datatype_create
* file_access
* file_create
* file_mount
* group_access
* group_create
* link_access
* link_create
* object_copy
* object_create
* string_create
"""
struct HDF5Context
    attribute_access :: AttributeAccessProperties
    attribute_create :: AttributeCreateProperties
    dataset_access   :: DatasetAccessProperties
    dataset_create   :: DatasetCreateProperties
    dataset_transfer :: DatasetTransferProperties
    datatype_access  :: DatatypeAccessProperties
    datatype_create  :: DatatypeCreateProperties
    file_access      :: FileAccessProperties
    file_create      :: FileCreateProperties
    file_mount       :: FileMountProperties
    group_access     :: GroupAccessProperties
    group_create     :: GroupCreateProperties
    link_access      :: LinkAccessProperties
    link_create      :: LinkCreateProperties
    object_copy      :: ObjectCopyProperties
    object_create    :: ObjectCreateProperties
    string_create    :: StringCreateProperties
end

Base.copy(ctx::HDF5Context) =
    HDF5Context(map(n -> copy(getfield(ctx, n)), fieldnames(HDF5Context))...)

Base.close(ctx::HDF5Context) =
    foreach(n -> close(getfield(ctx, n)), fieldnames(HDF5Context))

function HDF5Context()
    HDF5Context(
        AttributeAccessProperties(),
        AttributeCreateProperties(),
        DatasetAccessProperties(),
        DatasetCreateProperties(),
        DatasetTransferProperties(),
        DatatypeAccessProperties(),
        DatatypeCreateProperties(),
        FileAccessProperties(),
        FileCreateProperties(),
        FileMountProperties(),
        GroupAccessProperties(),
        GroupCreateProperties(),
        LinkAccessProperties(),
        LinkCreateProperties(),
        ObjectCopyProperties(),
        ObjectCreateProperties(),
        StringCreateProperties(),
    )
end

function Base.show(io::IO, ::MIME"text/plain", context::HDF5Context)
    show(io, HDF5Context)
    print(io, " with:")
    alldefault = true
    for fn in fieldnames(HDF5Context)
        prop = getfield(context, fn)
        if getfield(prop, :id) != API.H5P_DEFAULT
            alldefault = false
            print(io, "\n   Modified $fn")
        end
    end
    if alldefault
        print(io, "\n    All default property lists")
    end
end
precompile(Base.show, (IO, MIME"text/plain", HDF5Context))

"""
    HDF5.CONTEXT

*Internal API*

Default global `HDF5Context`.
"""
const CONTEXT = HDF5Context()

"""
    create_local_context([context::Union{HDF5Context, Nothing}])

*Internal API*

Create a task local `HDF5Context`(@ref). If a context is not provided as an
argument or is `nothing`, then the local context will be initialized to
`copy(HDF5.CONTEXT)`.

See also `delete_local_context!()`(@ref)
"""
function create_local_context(context::Union{HDF5Context,Nothing}=nothing)
    tls = task_local_storage()
    if !haskey(tls, :hdf5context)
        if isnothing(context)
            tls[:hdf5_context] = copy(CONTEXT)::HDF5Context
        else
            tls[:hdf5_context] = context
        end
    end
end

"""
    delete_local_context!()

*Internal API*

Close the current context and its property lists. Then remove the context
from task local storage.
"""
function delete_local_context!()
    tls = task_local_storage()
    if haskey(tls, :hdf5_context)
        context = pop!(tls, :hdf5_context)
        close(context)
    end
    return nothing
end

"""
    local_context(f::Function, [context::Union{HDF5Context, Nothing}])

*Internal API*

Execute a function, `f(context::HDF5Context)`, with a task local [`HDF5Context`](@ref) consisting
of property lists. The behavior of functions called within `f` may be
influenced by the context, such as by providing default property lists.

The context and its property lists will be closed after `f` returns. The global
context, `HDF5.CONTEXT` will not be affected unless directly referenced.

See also [`get_context`](@ref), [`get_context_property`](@ref),
and[`copy_context_property`](@ref).
"""
function local_context(f::Function, context::Union{HDF5Context,Nothing}=nothing)
    fetch(@async begin
        local_context = create_local_context(context)
        try
            f(local_context)
        finally
            delete_local_context!()
        end
    end)
end

"""
    get_context()::HDF5Context

*Internal API*

Retrieve the `HDF5Context` from task local storage, defaulting to
`HDF5.CONTEXT` if `task_local_storage()[:hdf5_context]` does not
exist.
"""
function get_context()::HDF5Context
    return get(task_local_storage(), :hdf5_context, CONTEXT)
end

"""
    get_context_property(name::Symbol)

*Internal API*

Retrieve a property list from the task local context via `get_context`.
"""
get_context_property(name::Symbol) = getfield(get_context(), name)

"""
    copy_context_property([f::Function], name::Symbol)

*Internal API*

Retrieve a copy of a property list from the task local context via `get_context`.
"""
copy_context_property(name::Symbol) = copy(get_context_property(name))

function copy_context_property(f::Function, name::Symbol)
    property = copy_context_property(name)
    try
        f(property)
    finally
        close(property)
    end
end

"""
    get_access_context(::Type{T})

*Internal API*

Get the access context property list for `T`.
"""
get_access_context(::Type{Attribute}) = get_context_property(:attribute_access)
get_access_context(::Type{Dataset}) = get_context_property(:dataset_access)
get_access_context(::Type{DataType}) = get_context_property(:datatype_access)
get_access_context(::Type{File}) = get_context_property(:file_access)
get_access_context(::Type{Group}) = get_context_property(:group_access)
#get_access_context(::Type{Link}) = get_context_property(:link_access)

"""
    copy_access_context([f::Function,] ::Type{T})

*Internal API*

Copy the access context property list for `T`.
If a function, `f`, is provided, pass the copied property list to the function,
and then finally close the property list after `f` returns.
"""
copy_access_context(::Type{T}) where {T} = copy(get_access_context(T))

function copy_access_context(f::Function, ::Type{T}) where {T}
    property = copy_access_context(T)
    try
        f(property)
    finally
        close(property)
    end
end

"""
    get_create_context(::Type{T})

*Internal API*

Get the create context property list for `T`.
"""
get_create_context(::Type{Attribute}) = get_context_property(:attribute_create)
get_create_context(::Type{Dataset}) = get_context_property(:dataset_create)
get_create_context(::Type{DataType}) = get_context_property(:datatype_create)
get_create_context(::Type{File}) = get_context_property(:file_create)
get_create_context(::Type{Group}) = get_context_property(:group_create)
#get_create_context(::Type{Link}) = get_context_property(:link_create)

"""
    copy_create_context([f::Function,], ::Type{T})

*Internal API*

Copy the create context property list for `T`.
If a function, `f`, is provided, pass the copied property list to the function,
and then finally close the property list after `f` returns.
"""
copy_create_context(::Type{T}) where {T} = copy(get_create_context(T))

function copy_create_context(f::Function, ::Type{T}) where {T}
    property = copy_create_context(T)
    try
        f(property)
    finally
        close(property)
    end
end
