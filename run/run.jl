# BEMT project - main executable script
#
# to get usage help, try to type in your shell (from this current file directory):
# > julia --project run.jl --help

using ArgParse

include("Statement.jl")
include("Part1.jl")
include("Part2.jl")
include("Part3.jl")

function parse_commandline(args)
    s = ArgParseSettings("Execution script of the BEMT project.")

    @add_arg_table! s begin
        "--sdiv"
        help     = "Number of subdivisions in the propeller blades."
        arg_type = Int  # only Int arguments allowed
        default  = 20   # this is used when the option is not passed

        "--part"
        help     = "Which parts of the project to execute."
        nargs    = '*'        # '*' means any number of arguments
        arg_type = Int        # only Int arguments allowed
        default  = [1, 2, 3]  # this is used when the option is not passed

        "--plot"
        help     = "Plot the computed results."
        nargs    = '?'   # '?' means optional argument
        arg_type = Bool  # only Bool arguments allowed
        default  = true  # this is used when the option is not passed
        constant = true  # this is used if --plot is parsed with no argument
    end

    return parse_args(args, s)
end

function main(args)
    parsed_args = parse_commandline(args)

    1 ∈ parsed_args["part"] && Part1.main(parsed_args)
    2 ∈ parsed_args["part"] && Part2.main(parsed_args)
    3 ∈ parsed_args["part"] && Part3.main(parsed_args)

    return nothing
end

# Run this badboy
main(ARGS)
