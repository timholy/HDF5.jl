using HDF5, Test

@testset "h5a_iterate" begin
    filename = tempname()
    f = h5open(filename, "w")

    write_attribute(f, "a", 1)
    write_attribute(f, "b", 2)

    # iterate over attributes
    names = String[]
    @test HDF5.API.h5a_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
    ) do loc, name, info
        push!(names, unsafe_string(name))
        return false
    end == 2
    @test names == ["a", "b"]

    # iterate over attributes in reverse
    names = String[]
    @test HDF5.API.h5a_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_DEC
    ) do loc, name, info
        push!(names, unsafe_string(name))
        return false
    end == 2
    @test names == ["b", "a"]

    # only iterate once
    names = String[]
    @test HDF5.API.h5a_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
    ) do loc, name, info
        push!(names, unsafe_string(name))
        return true
    end == 1
    @test names == ["a"]

    # Julia error
    @test_throws AssertionError HDF5.API.h5a_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
    ) do loc, name, info
        throw(AssertionError("False is not true"))
    end

    # HDF5 error
    @test_throws HDF5.API.H5Error HDF5.API.h5a_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
    ) do loc, name, info
        return -1
    end
end

@testset "h5l_iterate" begin
    filename = tempname()
    f = h5open(filename, "w")

    create_group(f, "a")
    create_group(f, "b")

    # iterate over groups
    names = String[]
    @test HDF5.API.h5l_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
    ) do loc, name, info
        push!(names, unsafe_string(name))
        return false
    end == 2
    @test names == ["a", "b"]

    # iterate over attributes in reverse
    names = String[]
    @test HDF5.API.h5l_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_DEC
    ) do loc, name, info
        push!(names, unsafe_string(name))
        return false
    end == 2
    @test names == ["b", "a"]

    # only iterate once
    names = String[]
    @test HDF5.API.h5l_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
    ) do loc, name, info
        push!(names, unsafe_string(name))
        return true
    end == 1
    @test names == ["a"]

    # HDF5 error
    @test_throws HDF5.API.H5Error HDF5.API.h5l_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
    ) do loc, name, info
        return -1
    end

    # Julia error
    @test_throws AssertionError HDF5.API.h5l_iterate(
        f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
    ) do loc, name, info
        throw(AssertionError("False is not true"))
    end
end

@testset "h5dchunk_iter" begin
    @test convert(HDF5.API.H5_iter_t, 0) == HDF5.API.H5_ITER_CONT
    @test convert(HDF5.API.H5_iter_t, 1) == HDF5.API.H5_ITER_STOP
    @test convert(HDF5.API.H5_iter_t, -1) == HDF5.API.H5_ITER_ERROR
end
