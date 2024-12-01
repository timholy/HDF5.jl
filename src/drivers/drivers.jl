module Drivers

export POSIX, ROS3

import ..API
import ..HDF5: HDF5, Properties, h5doc

using Libdl: dlopen, dlsym

function get_driver(p::Properties)
    driver_id = API.h5p_get_driver(p)
    D = get(DRIVERS, driver_id) do
        error("Unknown driver type")
    end
    get_driver(p, D)
end

abstract type Driver end

const DRIVERS = Dict{API.hid_t,Type{<:Driver}}()

"""
    Core([increment::Csize_t, backing_store::Cuint, [write_tracking::Cuint, page_size::Csize_t]])
    Core(; increment::Csize_t = 8192, backing_store::Cuint = true, write_tracking::Cuint = false, page_size::Csize_t = 524288)

# Arguments

* `increment`: specifies the increment by which allocated memory is to be increased each time more memory is required. (default: 8192)
* `backing_store`: Boolean flag indicating whether to write the file contents to disk when the file is closed. (default: true)
* `write_tracking`: Boolean flag indicating whether write tracking is enabled. (default: false)
* `page_size`: Size, in bytes, of write aggregation pages. (default: 524288)
"""
struct Core <: Driver
    increment::Csize_t
    backing_store::Cuint #Bool
    write_tracking::Cuint #Bool
    page_size::Csize_t
end
Core(increment, backing_store) = Core(increment, backing_store, false, 524288)
Core(; increment=8192, backing_store=true, write_tracking=false, page_size=524288) =
    Core(increment, backing_store, write_tracking, page_size)

function get_driver(p::Properties, ::Type{Core})
    r_increment = Ref{Csize_t}(0)
    r_backing_store = Ref{Bool}(0)
    r_write_tracking = Ref{Bool}(0)
    r_page_size = Ref{Csize_t}(0)
    API.h5p_get_fapl_core(p, r_increment, r_backing_store)
    API.h5p_get_core_write_tracking(p, r_write_tracking, r_page_size)
    return Core(r_increment[], r_backing_store[], r_write_tracking[], r_page_size[])
end

function set_driver!(fapl::Properties, driver::Core)
    HDF5.init!(fapl)
    API.h5p_set_fapl_core(fapl, driver.increment, driver.backing_store)
    API.h5p_set_core_write_tracking(fapl, driver.write_tracking, driver.page_size)
    DRIVERS[API.h5p_get_driver(fapl)] = Core
    return nothing
end

"""
    POSIX()

Also referred to as SEC2, this driver uses POSIX file-system functions like read and
write to perform I/O to a single, permanent file on local disk with no system
buffering. This driver is POSIX-compliant and is the default file driver for all systems.
"""
struct POSIX <: Driver end

function get_driver(fapl::Properties, ::Type{POSIX})
    POSIX()
end

function set_driver!(fapl::Properties, ::POSIX)
    HDF5.init!(fapl)
    API.h5p_set_fapl_sec2(fapl)
    DRIVERS[API.h5p_get_driver(fapl)] = POSIX
    return nothing
end

function __init__()
    # Initialize POSIX key in DRIVERS
    HDF5.FileAccessProperties() do fapl
        set_driver!(fapl, POSIX())
    end

    # Check whether the libhdf5 was compiled with parallel support.
    HDF5.HAS_PARALLEL[] = API._has_symbol(:H5Pset_fapl_mpio)
    HDF5.HAS_ROS3[] = API._has_symbol(:H5Pset_fapl_ros3)
end

# The docstring for `MPIO` basically belongs to the struct `MPIO` in
# ext/MPIExt/MPIExt.jl. However, we need to document it here to make it
# work smoothly both for Julia without package extensions (up to v1.8) and
# with package extensions (v1.9 and newer).
@doc """
    MPIO(comm::MPI.Comm, info::MPI.Info)
    MPIO(comm::MPI.Comm; kwargs....)

The parallel MPI file driver. This requires the use of
[MPI.jl](https://github.com/JuliaParallel/MPI.jl), and a custom HDF5 binary that has been
built with MPI support.

- `comm` is the communicator over which the file will be opened.
- `info`/`kwargs` are MPI-IO options, and are passed to `MPI_FILE_OPEN`.

# See also

- [`HDF5.has_parallel`](@ref)
- [Parallel HDF5](@ref)

# External links

- $(h5doc("H5P_SET_FAPL_MPIO"))
- [Parallel HDF5](https://portal.hdfgroup.org/display/HDF5/Parallel+HDF5)
"""
function MPIO end

include("ros3.jl")
end # module
