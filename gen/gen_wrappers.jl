# Generate ../src/api/functions.jl
# Run `julia --project=.. gen_wrappers.jl`` to execute this script

include(joinpath(@__DIR__, "bind_generator.jl"))

# Read in the API definition macros from the definitions file
defs = read(joinpath(@__DIR__, "api_defs.jl"), String)
# Have Julia expand/run the @bind macro to generate expressions for all of the functions
exprs = Base.include_string(
    @__MODULE__, "@macroexpand1 begin\n" * defs * "\nend", "api_defs.jl"
)
# Insert the conditional version helper expression
prepend!(exprs.args, _libhdf5_build_ver_expr.args)
Base.remove_linenums!(exprs)

# Definitions which are not automatically generated, but should still be documented as
# part of the raw low-level API:
append!(bound_api["H5P"], [
    # defined in src/api/helpers.jl
    "h5p_get_class_name",
    "h5p_get_fapl_mpio",
    "h5p_set_fapl_mpio",
])
append!(bound_api["H5T"], [
    # defined in src/api/helpers.jl
    "h5t_get_member_name",
    "h5t_get_tag",
])

# Now dump the text representation to disk
open(joinpath(@__DIR__, "..", "src", "api", "functions.jl"), "w") do fid
    println(
        fid,
        """
#! format: off
# This file is autogenerated by HDF5.jl's `gen/gen_wrappers.jl` and should not be editted.
#
# To add new bindings, define the binding in `gen/api_defs.jl`, re-run
# `gen/gen_wrappers.jl`, and commit the updated `src/api/functions.jl`.
"""
    )
    function triplequote(s::String, indent="", prefix="")
        ret = indent * prefix * "\"\"\"\n"
        for l in eachline(IOBuffer(s))
            ret *= isempty(l) ? "\n" : indent * l * "\n"
        end
        ret *= indent * "\"\"\"\n"
        return ret
    end
    ismacro(ex, sym, n=0) =
        isexpr(ex, :macrocall) && length(ex.args) >= n + 2 && ex.args[1] == sym
    for funcblock in exprs.args
        if ismacro(funcblock, Symbol("@doc"), 2)
            # Pretty print the doc macro as just a juxtaposed doc string and function
            # definition; the `@doc` construction is necessary in AST form for the docs
            # to be included in interactive use of `@bind`, but in source form we can
            # rely on Julia's parsing behavior.
            print(fid, triplequote(funcblock.args[3]), funcblock.args[4], "\n\n")
        elseif ismacro(funcblock, Symbol("@static"), 1) &&
            isexpr(funcblock.args[3], :if, 2) &&
            ismacro(funcblock.args[3].args[2], Symbol("@doc"), 2)
            # Within a @static block, we have to keep the @doc prefix, but we can still
            # switch to triple-quoting and there's special parsing to allow the function
            # definition to be on the next line.
            #
            # Work around the expression printer in this more complex case by printing
            # to a buffer and string-replacing a sentinel value
            docstr = funcblock.args[3].args[2].args[3]
            funcblock.args[3].args[2].args[3] = "SENTINEL_DOC"
            buf = sprint(print, funcblock)
            # Two-step deindent since `r"^\s{4}(\s{4})?"m => s"\1"` errors: see JuliaLang/julia#31456
            buf = replace(buf, r"^\s{4}"m => s"") # deindent
            buf = replace(buf, r"^(\s{4})\s{4}"m => s"\1") # deindent
            # Now format the doc string and replace (note need to indent `function`)
            buf = replace(
                buf,
                r"^\s+@doc \"SENTINEL_DOC\" "m =>
                    triplequote(docstr, " "^4, "@doc ") * " "^4
            )
            print(fid, buf, "\n\n")
        else
            # passthrough
            print(fid, funcblock, "\n\n")
        end
    end
    # Remove last endline
    truncate(fid, position(fid) - 1)
end

# Also generate auto-docs that simply list all of the bound API functions
apidocs = ""
for (mod, desc, urltail) in (
    ("H5", "General Library Functions", "Library"),
    ("H5A", "Attribute Interface", "Attributes"),
    ("H5D", "Dataset Interface", "Datasets"),
    ("H5E", "Error Interface", "Error+Handling"),
    ("H5F", "File Interface", "Files"),
    ("H5G", "Group Interface", "Groups"),
    ("H5I", "Identifier Interface", "Identifiers"),
    ("H5L", "Link Interface", "Links"),
    ("H5O", "Object Interface", "Objects"),
    ("H5PL", "Plugin Interface", "Plugins"),
    ("H5P", "Property Interface", "Property+Lists"),
    ("H5R", "Reference Interface", "References"),
    ("H5S", "Dataspace Interface", "Dataspaces"),
    ("H5T", "Datatype Interface", "Datatypes"),
    ("H5Z", "Filter Interface", "Filters"),
    ("H5FD", "File Drivers", "File+Drivers"),
    ("H5DO", "Optimized Functions Interface", "Optimizations"),
    ("H5DS", "Dimension Scale Interface", "Dimension+Scales"),
    ("H5LT", "Lite Interface", "Lite"),
    ("H5TB", "Table Interface", "Tables"),
)
    global apidocs
    funclist = sort!(bound_api[mod])
    index = join(["- [`$f`](@ref $f)" for f in funclist], "\n")
    funcs = join(funclist, "\n")
    apidocs *= """
        ---

        ## [[`$mod`](https://portal.hdfgroup.org/display/HDF5/$urltail) — $desc](@id $mod)
        $index
        ```@docs
        $funcs
        ```

        """
end

open(joinpath(@__DIR__, "..", "docs", "src", "api_bindings.md"), "w") do fid
    write(
        fid,
        """
        ```@raw html
        <!-- This file is auto-generated and should not be manually editted. To update, run the
        gen/gen_wrappers.jl script -->
        ```
        ```@meta
        CurrentModule = HDF5.API
        ```

        # Low-level library bindings

        At the lowest level, `HDF5.jl` operates by calling the public API of the HDF5 shared
        library through a set of `ccall` wrapper functions.
        This page documents the function names and nominal C argument types of the API which
        have bindings in this package.
        Note that in many cases, high-level data types are valid arguments through automatic
        `ccall` conversions.
        For instance, `HDF5.Datatype` objects will be automatically converted to their `hid_t` ID
        by Julia's `cconvert`+`unsafe_convert` `ccall` rules.

        There are additional helper wrappers (often for out-argument functions) which are not
        documented here.

        $apidocs
        """
    )
end

nothing
