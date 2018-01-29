using HDF5
using Base.Test
using Compat

@testset "plain" begin

# Create a new file
fn = tempname()
f = h5open(fn, "w")
@test isopen(f)
# Write scalars
f["Float64"] = 3.2
f["Int16"] = Int16(4)
# compression of empty array (issue #246)
f["compressedempty", "shuffle", (), "compress", 4] = Int64[]
# compression of zero-dimensional array (pull request #445)
f["compressed_zerodim", "shuffle", (), "compress", 4] = fill(Int32(42), ())
f["bloscempty", "blosc", 4] = Int64[]
# Create arrays of different types
A = randn(3, 5)
write(f, "Afloat64", convert(Matrix{Float64}, A))
write(f, "Afloat32", convert(Matrix{Float32}, A))
Ai = rand(1:20, 2, 4)
write(f, "Aint8", convert(Matrix{Int8}, Ai))
f["Aint16"] = convert(Matrix{Int16}, Ai)
write(f, "Aint32", convert(Matrix{Int32}, Ai))
write(f, "Aint64", convert(Matrix{Int64}, Ai))
write(f, "Auint8", convert(Matrix{UInt8}, Ai))
write(f, "Auint16", convert(Matrix{UInt16}, Ai))
write(f, "Auint32", convert(Matrix{UInt32}, Ai))
write(f, "Auint64", convert(Matrix{UInt64}, Ai))

salut = "Hi there"
ucode = "uniçº∂e"
write(f, "salut", salut)
write(f, "ucode", ucode)
# Manually write a variable-length string (issue #187)
let
    dtype = HDF5Datatype(HDF5.h5t_copy(HDF5.H5T_C_S1))
    HDF5.h5t_set_size(dtype.id, HDF5.H5T_VARIABLE)
    HDF5.h5t_set_cset(dtype.id, HDF5.cset(typeof(salut)))
    dspace = HDF5.dataspace(salut)
    dset = HDF5.d_create(f, "salut-vlen", dtype, dspace)
    HDF5.h5d_write(dset, dtype, HDF5.H5S_ALL, HDF5.H5S_ALL, HDF5.H5P_DEFAULT, [pointer(salut)])
end
# Arrays of strings
salut_split = ["Hi", "there"]
write(f, "salut_split", salut_split)
salut_2d = ["Hi" "there"; "Salut" "friend"]
write(f, "salut_2d", salut_2d)
# Arrays of strings as vlen
vlen = HDF5Vlen(salut_split)
d_write(f, "salut_vlen", vlen)
# Empty arrays
empty = UInt32[]
write(f, "empty", empty)
# Empty strings
empty_string = ""
write(f, "empty_string", empty_string)
# Empty array of strings
empty_string_array = String[]
write(f, "empty_string_array", empty_string_array)
# Array of empty string
empty_array_of_strings = [""]
write(f, "empty_array_of_strings", empty_array_of_strings)
# Attributes
species = [["N", "C"]; ["A", "B"]]
attrs(f)["species"] = species
C∞ = 42
attrs(f)["C∞"] = C∞
dset = f["salut"]
@test !isempty(dset)
label = "This is a string"
attrs(dset)["typeinfo"] = label
close(dset)
# Scalar reference values in attributes
attrs(f)["ref_test"] = HDF5.HDF5ReferenceObj(f, "empty_array_of_strings")
@test read(attrs(f)["ref_test"]) === HDF5.HDF5ReferenceObj(f, "empty_array_of_strings")
# Group
g = g_create(f, "mygroup")
# Test dataset with compression
R = rand(1:20, 20, 40);
g["CompressedA", "chunk", (5, 6), "shuffle", (), "compress", 9] = R
g["BloscA", "chunk", (5, 6), "shuffle", (), "blosc", 9] = R
close(g)
# Copy group containing dataset
o_copy(f, "mygroup", f, "mygroup2")
# Copy dataset
g = g_create(f, "mygroup3")
o_copy(f["mygroup/CompressedA"], g, "CompressedA")
o_copy(f["mygroup/BloscA"], g, "BloscA")
close(g)
# Writing hyperslabs
dset = d_create(f, "slab", datatype(Float64), dataspace(20, 20, 5), "chunk", (5, 5, 1))
Xslab = randn(20, 20, 5)
for i = 1:5
    dset[:,:,i] = Xslab[:,:,i]
end
# More complex hyperslab and assignment with "incorrect" types (issue #34)
d = d_create(f, "slab2", datatype(Float64), ((10, 20), (100, 200)), "chunk", (1, 1))
d[:,:] = 5
d[1,1] = 4
# 1d indexing
d = d_create(f, "slab3", datatype(Int), ((10,), (-1,)), "chunk", (5,))
@test d[:] == zeros(Int, 10)
d[3:5] = 3:5
# Create a dataset designed to be deleted
f["deleteme"] = 17.2
close(f)
@test !isopen(f)
# Test the h5read/write interface, with attributes
W = copy(reshape(1:120, 15, 8))
Wa = Dict("a" => 1, "b" => 2)
h5write(fn, "newgroup/W", W)
h5writeattr(fn, "newgroup/W", Wa)

# Read the file back in
fr = h5open(fn)
x = read(fr, "Float64")
@test x == 3.2 && isa(x, Float64)
y = read(fr, "Int16")
@test y == 4 && isa(y, Int16)
zerodim = read(fr, "compressed_zerodim")
@test zerodim == 42 && isa(zerodim, Int32)
bloscempty = read(fr, "bloscempty")
@test bloscempty == Int64[] && isa(bloscempty, Vector{Int64})
Af32 = read(fr, "Afloat32")
@test convert(Matrix{Float32}, A) == Af32
@test eltype(Af32) == Float32
Af64 = read(fr, "Afloat64")
@test convert(Matrix{Float64}, A) == Af64
@test eltype(Af64) == Float64
@test eltype(fr["Afloat64"]) == Float64  # issue 167
Ai8 = read(fr, "Aint8")
@test Ai == Ai8
@test eltype(Ai8) == Int8
Ai16 = read(fr, "Aint16")
@test Ai == Ai16
@test eltype(Ai16) == Int16
Ai32 = read(fr, "Aint32")
@test Ai == Ai32
@test eltype(Ai32) == Int32
Ai64 = read(fr, "Aint64")
@test Ai == Ai64
@test eltype(Ai64) == Int64
Ai8 = read(fr, "Auint8")
@test Ai == Ai8
@test eltype(Ai8) == UInt8
Ai16 = read(fr, "Auint16")
@test Ai == Ai16
@test eltype(Ai16) == UInt16
Ai32 = read(fr, "Auint32")
@test Ai == Ai32
@test eltype(Ai32) == UInt32
Ai64 = read(fr, "Auint64")
@test Ai == Ai64
@test eltype(Ai64) == UInt64
salutr = read(fr, "salut")
@test salut == salutr
salutr = read(fr, "salut-vlen")
@test salut == salutr
ucoder = read(fr, "ucode")
@test ucode == ucoder
salut_splitr = read(fr, "salut_split")
@test salut_splitr == salut_split
salut_2dr = read(fr, "salut_2d")
@test salut_2d == salut_2dr
salut_vlenr = read(fr, "salut_vlen")
@test salut_vlenr == salut_split
Rr = read(fr, "mygroup/CompressedA")
@test Rr == R
Rr2 = read(fr, "mygroup2/CompressedA")
@test Rr2 == R
Rr3 = read(fr, "mygroup3/CompressedA")
@test Rr3 == R
Rr4 = read(fr, "mygroup/BloscA")
@test Rr4 == R
Rr5 = read(fr, "mygroup2/BloscA")
@test Rr5 == R
Rr6 = read(fr, "mygroup3/BloscA")
@test Rr6 == R
dset = fr["mygroup/CompressedA"]
@test get_chunk(dset) == (5, 6)
@test name(dset) == "/mygroup/CompressedA"
dset2 = fr["mygroup/BloscA"]
@test get_chunk(dset2) == (5, 6)
@test name(dset2) == "/mygroup/BloscA"
Xslabr = read(fr, "slab")
@test Xslabr == Xslab
Xslabr = h5read(fn, "slab", (:, :, :))  # issue #87
@test Xslabr == Xslab
Xslab2r = read(fr, "slab2")
target = fill(5, 10, 20)
target[1] = 4
@test Xslab2r == target
dset = fr["slab3"]
@test dset[3:5] == [3:5;]
emptyr = read(fr, "empty")
@test isempty(emptyr)
empty_stringr = read(fr, "empty_string")
@test empty_stringr == empty_string
empty_string_arrayr = read(fr, "empty_string_array")
@test empty_string_arrayr == empty_string_array
empty_array_of_stringsr = read(fr, "empty_array_of_strings")
@test empty_array_of_stringsr == empty_array_of_strings
@test a_read(fr, "species") == species
@test a_read(fr, "C∞") == C∞
dset = fr["salut"]
@test a_read(dset, "typeinfo") == label
close(dset)
# Test ref-based reading
Aref = fr["Afloat64"]
sel = (2:3, 1:2:5)
Asub = Aref[sel...]
@test Asub == A[sel...]
close(Aref)
# Test iteration, name, and parent
for obj in fr
    @test filename(obj) == fn
    n = name(obj)
    p = parent(obj)
end
# Test reading multiple vars at once
z = read(fr, "Float64", "Int16")
@test z == (3.2, 4)
@test typeof(z) == Tuple{Float64,Int16}
# Test function syntax
read(fr, "Float64") do x
	@test x == 3.2
end
read(fr, "Float64", "Int16") do x, y
	@test x == 3.2
	@test y == 4
end
# Test reading entire file at once
z = read(fr)
@test z["Float64"] == 3.2
close(fr)

# Test object deletion
fr = h5open(fn, "r+")
@test exists(fr, "deleteme")
o_delete(fr, "deleteme")
@test !exists(fr, "deleteme")
close(fr)

# Test the h5read interface
Wr = h5read(fn, "newgroup/W")
@test Wr == W
rng = (2:3:15, 3:5)
Wr = h5read(fn, "newgroup/W", rng)
@test Wr == W[rng...]
War = h5readattr(fn, "newgroup/W")
@test War == Wa

# more do syntax
h5open(fn, "w") do fid
    g_create(fid, "mygroup") do g
        write(g, "x", 3.2)
    end
end
fid = h5open(fn, "r")
@test names(fid) == ["mygroup"]
g = fid["mygroup"]
@test names(g) == ["x"]
close(g)
close(fid)
rm(fn)

# more do syntax: atomic rename version
tmpdir = mktempdir()
outfile = joinpath(tmpdir, "test.h5")

# create a new file
h5rewrite(outfile) do fid
    g_create(fid, "mygroup") do g
        write(g, "x", 3.3)
    end
end
@test length(readdir(tmpdir)) == 1
h5open(outfile, "r") do fid
    @test names(fid) == ["mygroup"]
    @test names(fid["mygroup"]) == ["x"]
end

# fail to overwrite
@test_throws ErrorException h5rewrite(outfile) do fid
    g_create(fid, "mygroup") do g
        write(g, "oops", 3.3)
    end
    error("failed")
end
@test length(readdir(tmpdir)) == 1
h5open(outfile, "r") do fid
    @test names(fid) == ["mygroup"]
    @test names(fid["mygroup"]) == ["x"]
end

# overwrite
h5rewrite(outfile) do fid
    g_create(fid, "mygroup") do g
        write(g, "y", 3.3)
    end
end
@test length(readdir(tmpdir)) == 1
h5open(outfile, "r") do fid
    @test names(fid) == ["mygroup"]
    @test names(fid["mygroup"]) == ["y"]
end

# Test Float16 support
arr_float16 = Float16[1.0, 0.25, 0.5, 8.0]
h5write(joinpath(tmpdir, "test_float16.h5"), "x", arr_float16)
arr_float16_2 = h5read(joinpath(tmpdir, "test_float16.h5"), "x")
@test isa(arr_float16_2, Vector{Float16})
@test arr_float16_2 == arr_float16

rm(tmpdir, recursive=true)

test_files = joinpath(@__DIR__, "test_files")

d = h5read(joinpath(test_files, "compound.h5"), "/data")
@test typeof(d[1]) === HDF5.HDF5Compound{4}
@test length(d) == 2
dtypes = [typeof(x) for x in d[1].data]
@test dtypes == [Float64, Vector{Float64}, Vector{Float64}, Float64]
@test length(d[1].data[2]) == 3
@test d[1].membername == ("wgt", "xyz", "uvw", "E")

# get-datasets
fn = tempname()
fd = h5open(fn, "w")
fd["level_0"] = [1,2,3]
grp = g_create(fd, "mygroup")
fd["mygroup/level_1"] = [4, 5]
grp2 = g_create(grp, "deep_group")
fd["mygroup/deep_group/level_2"] = [6.0, 7.0]
datasets = get_datasets(fd)
@test sort(map(name, datasets)) ==  sort(["/level_0", "/mygroup/deep_group/level_2", "/mygroup/level_1"])
close(fd)
rm(fn)

# File creation and access property lists
cpl = HDF5Properties(p_create(HDF5.H5P_FILE_CREATE))
cpl["userblock"] = 1024
apl = HDF5Properties(p_create(HDF5.H5P_FILE_ACCESS))
apl["libver_bounds"] = (HDF5.H5F_LIBVER_EARLIEST, HDF5.H5F_LIBVER_LATEST)
h5open(fn, false, true, true, true, false, cpl, apl) do fid
    write(fid, "intarray", [1, 2, 3])
end
h5open(fn, "r", "libver_bounds",
    (HDF5.H5F_LIBVER_EARLIEST, HDF5.H5F_LIBVER_LATEST)) do fid
    intarray = read(fid, "intarray")
    @test intarray == [1, 2, 3]
end

# Test null terminated ASCII string (e.g. exported by h5py) #332
h5open(joinpath(test_files, "nullterm_ascii.h5"), "r") do fid
    str = read(fid["test"])
    @test str == "Hello World"
end

@test HDF5.unpad(UInt8[0x43, 0x43, 0x41], 1) == "CCA"

# Test the h5read/write interface with a filename as a first argument, when
# the file does not exist
h5write(fn, "newgroup/W", W)
Wr = h5read(fn, "newgroup/W")
@test Wr == W
close(f)
rm(fn)

# Test direct chunk writing
h5open(fn, "w") do f
  d = d_create(f, "dataset", datatype(Int), dataspace(4, 4), "chunk", (2, 2))
  raw = HDF5ChunkStorage(d)
  raw[1,1] = 0, collect(reinterpret(UInt8, [1,2,5,6]))
  raw[3,1] = 0, collect(reinterpret(UInt8, [3,4,7,8]))
  raw[1,3] = 0, collect(reinterpret(UInt8, [9,10,13,14]))
  raw[3,3] = 0, collect(reinterpret(UInt8, [11,12,15,16]))
end

@test h5open(fn, "r") do f
  vec(f["dataset"][:,:])
end == collect(1:16)

end # testset plain

# test strings with null and undefined references
@testset "undefined and null" begin
fn = tempname()
f = h5open(fn, "w")

# don't silently truncate data
@test_throws ArgumentError write(f, "test", ["hello","there","\0"])
@test_throws ArgumentError write(f, "trunc1", "\0")
@test_throws ArgumentError write(f, "trunc2", "trunc\0ateme")

# test writing uninitialized string arrays
undefstrarr = similar(Vector(1:3), String) # strs = String[#undef, #undef, #undef]
@test_throws UndefRefError write(f, "undef", undefstrarr)

close(f)
rm(fn)
end # testset null and undefined
