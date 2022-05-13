using HDF5
using Test

@testset "views and non-allocating methods" begin
    fn = tempname()

    @info "view.jl" fn
    data = rand(UInt16, 16, 16)

    h5open(fn, "w") do h5f
        h5f["data"] = data
    end

    h5open(fn, "r") do h5f
        buffer = similar(h5f["data"])
        copyto!(buffer, h5f["data"])
        @test isequal(buffer, data)

        read!(h5f["data"], buffer)
        @test isequal(buffer, data)

        v = @view(h5f["data"][1:4, 1:4])

        buffer = similar(v)
        @test size(buffer) == (4,4)
        copyto!(buffer, v)
        @test isequal(buffer, @view(data[1:4, 1:4]))

        buffer .= 1
        read!(h5f["data"], buffer, 1:4, 1:4)
        @test isequal(buffer, @view(data[1:4, 1:4]))

        @test size(similar(h5f["data"], Int16)) == size(h5f["data"])
        @test size(similar(h5f["data"], 5,6)) == (5, 6)
        @test size(similar(h5f["data"], Int16, 8,7)) == (8,7)
    end

    rm(fn)
end