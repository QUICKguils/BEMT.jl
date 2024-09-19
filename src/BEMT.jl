#    ___  ______  _________
#   / _ )/ __/  |/  /_  __/
#  / _  / _// /|_/ / / /
# /____/___/_/  /_/ /_/.jl
#           Guilain Ernotte

"""
    BEMT
Blade Element Momentum Techniques.

Library of tools and computational methods
that are based on the blade element momentum theory.
"""
module BEMT

using Unitful

# include("Constants.jl")
# import .Constants: Constants as C
# export C

include("propellers.jl")
export Propeller, PropellerGeometry, AirfoilPolar

include("performance.jl")
export OperatingConditions, BemSolution, bem

end  # Module BEMT
