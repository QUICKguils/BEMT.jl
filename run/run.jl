# Push the local run environment to the environment stack,
# so that this script can use the extra packages of the run environment.
#
# This is the way to do, until
# https://github.com/JuliaLang/Pkg.jl/issues/1233
# will be implemented.
# push!(LOAD_PATH, @__DIR__)

using ArgParse

using BEMT

println("Hello from run/run.jl")
println(BEMT.Constants.in2m)
