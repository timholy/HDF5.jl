# Work around JuliaLang/Pkg.jl#2500
if VERSION < v"1.8-"
    test_project = first(Base.load_path())
    preferences_file = "../LocalPreferences.toml"
    test_preferences_file = joinpath(dirname(test_project), "LocalPreferences.toml")
    if isfile(preferences_file) && !isfile(test_preferences_file)
        cp(preferences_file, test_preferences_file)
        @info "copied LocalPreferences.toml to $test_preferences_file"
    end
end

using HDF5
using Test
using Pkg
filter_path = joinpath(dirname(pathof(HDF5)), "..", "filters")
Pkg.develop(PackageSpec(; path=joinpath(filter_path, "H5Zblosc")))
Pkg.develop(PackageSpec(; path=joinpath(filter_path, "H5Zbzip2")))
Pkg.develop(PackageSpec(; path=joinpath(filter_path, "H5Zlz4")))
Pkg.develop(PackageSpec(; path=joinpath(filter_path, "H5Zzstd")))
@static if VERSION >= v"1.6"
    Pkg.develop(PackageSpec(; path=joinpath(filter_path, "H5Zbitshuffle")))
end

@info "libhdf5 v$(HDF5.API.h5_get_libversion())"

# To debug HDF5.jl tests, uncomment the next line
# ENV["JULIA_DEBUG"] = "Main"

@testset "HDF5.jl" begin
    @debug "plain"
    include("plain.jl")
    @debug "strings"
    include("strings.jl")
    @debug "api"
    include("api.jl")
    @debug "compound"
    include("compound.jl")
    @debug "custom"
    include("custom.jl")
    @debug "reference"
    include("reference.jl")
    @debug "dataspace"
    include("dataspace.jl")
    @debug "datatype"
    include("datatype.jl")
    @debug "hyperslab"
    include("hyperslab.jl")
    @debug "attributes"
    include("attributes.jl")
    @debug "readremote"
    include("readremote.jl")
    @debug "extend_test"
    include("extend_test.jl")
    @debug "gc"
    include("gc.jl")
    @debug "external"
    include("external.jl")
    @debug "swmr"
    include("swmr.jl")
    @debug "mmap"
    include("mmap.jl")
    @debug "properties"
    include("properties.jl")
    @debug "table"
    include("table.jl")
    @debug "filter"
    include("filter.jl")
    @debug "chunkstorage"
    include("chunkstorage.jl")
    @debug "fileio"
    include("fileio.jl")
    @debug "nonallocating"
    include("nonallocating.jl")
    @debug "filter test utils"
    include("filters/FilterTestUtils.jl")
    @debug "objects"
    include("objects.jl")
    if VERSION ≥ v"1.6"
        @debug "virtual datasets"
        include("virtual_dataset.jl")
    end

    # basic MPI tests, for actual parallel tests we need to run in MPI mode
    include("mpio.jl")

    if HDF5.has_ros3()
        include("ros3.jl")
    end

    # Clean up after all resources
    HDF5.API.h5_close()
end
