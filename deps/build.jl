using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libhdf5"], :libhdf5),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaPackaging/Yggdrasil/releases/download/HDF5-v1.10.5+1"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:i686, libc=:glibc) => ("$bin_prefix/HDF5.v1.10.5.i686-linux-gnu.tar.gz", "7fcb6949436a793796f4e548ef5f6a29b01a54c0929c9680b3d2bbb89a3d69b1"),
    Windows(:i686) => ("$bin_prefix/HDF5.v1.10.5.i686-w64-mingw32.tar.gz", "cb88263a578cbfc4b5d5aba1a4fe1b8883e32a20858c4b1b291159c2574ffbb3"),
    MacOS(:x86_64) => ("$bin_prefix/HDF5.v1.10.5.x86_64-apple-darwin14.tar.gz", "c5f491933d353c8002be6cd5750f0ce74c6f6b9fd93a499dec9040f53366ea1c"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/HDF5.v1.10.5.x86_64-linux-gnu.tar.gz", "481378199cd8a5d67fda5b175874b5c3119cc29c6e6fecd10f7ec824e57893a6"),
    Windows(:x86_64) => ("$bin_prefix/HDF5.v1.10.5.x86_64-w64-mingw32.tar.gz", "e21b425551395a80e83ecc41026e440611cc498b545976db0e9e2c709d7dd3ac"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)
