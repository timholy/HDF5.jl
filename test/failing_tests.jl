using HDF5, Test

@testset "h5a_iterate failing" begin
    for i in 1:1000
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

        @test_throws AssertionError HDF5.API.h5a_iterate(
            f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
        ) do loc, name, info
            @assert false
        end

        # HDF5 error
        @test_throws HDF5.API.H5Error HDF5.API.h5a_iterate(
            f, HDF5.API.H5_INDEX_NAME, HDF5.API.H5_ITER_INC
        ) do loc, name, info
            return -1
        end

        close(f)
    end
end

@testset "h5l_iterate failing" begin
    for i in 1:1000
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
            @assert false
        end

        close(f)
    end
end
