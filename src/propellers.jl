"""Hold the geometric description of a propeller."""
struct PropellerGeometry
    diameter::Real            # Diameter [m]
    n_blades::Integer         # Number of blades
    stations::Vector{Real}    # Station locations [m]
    chords::Vector{Real}      # Chords evaluated at stations [m]
    geopitches::Vector{Real}  # Geometric pitches evaluated at stations [m]
end

"""
Tabulated values of cl and cd.

Contain the tabulated values of cl and cd, for the corresponding sampled
angles of attack and Reynolds numbers.
"""
struct AirfoilPolar
    aoa::Vector{Real}  # Sample of angles of attack [rad]
    Re::Vector{Real}   # Sample of Reynolds numbers
    cl::Matrix{Real}   # Corresponding lift coefficients
    cd::Matrix{Real}   # Corresponding drag coefficients
end

"""Implement a generic propeller."""
struct Propeller
    airfoil::AirfoilPolar
    geometry::PropellerGeometry
end
