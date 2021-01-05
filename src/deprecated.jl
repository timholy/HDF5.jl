import Base: @deprecate, @deprecate_binding, depwarn

###
### v0.15 deprecations
###

### Add empty exists method for JLD,MAT to extend to smooth over deprecation process PR#790
export exists
function exists end

### Changed in PR#776
@deprecate create_dataset(parent::Union{File,Group}, path::AbstractString, dtype::Datatype, dspace::Dataspace,
    lcpl::Properties, dcpl::Properties, dapl::Properties, dxpl::Properties) HDF5.Dataset(HDF5.h5d_create(parent, path, dtype, dspace, lcpl, dcpl, dapl), HDF5.file(parent), dxpl) false

@deprecate get_dims(dspace::Union{Dataspace,Dataset,Attribute}) get_simple_extent_dims(dspace) false
@deprecate set_dims!(dspace::Union{Dataspace,Dataset,Attribute}) set_extent!(dset) false
