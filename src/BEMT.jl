#    ___  ______  _________
#   / _ )/ __/  |/  /_  __/
#  / _  / _// /|_/ / / /
# /____/___/_/  /_/ /_/.jl
#           Guilain Ernotte

# TODO:
# - see if it is really necessary to have inner modules, instead of
#   simple source file that are included here and share the same BEMT scope.
#   Having inner namespaces like this complexify the code.

"""
    BEMT
Blade Element Momentum Techniques.

Library of tools and computational methods
that are based on the blade element momentum theory.
"""
module BEMT

include("Constants.jl")
import .Constants: Constants as C
export C

include("propellers.jl")
export Propeller, PropellerGeometry, AirfoilPolar

include("performance.jl")
export bem, OperatingConditions

end  # Module BEMT
