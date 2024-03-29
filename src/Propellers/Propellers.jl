"""
    Propellers
Functions and definitions related to propellers.

This module defines the blade geometries for the four propellers to be
studied. It also implements a function to recover the lift and drag
coefficient for the Clark-Y airfoil used for this propellers.
"""
module Propellers

using Interpolations

abstract type Propeller end

abstract type Aifoil <: Propeller end

abstract type PropellerGeometry <: Propeller end


end  # module Propellers
