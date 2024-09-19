"""Hold the geometric description of a propeller."""
struct PropellerGeometry
    span::typeof(1.0u"m")                # Span of one blade
    n_blades::typeof(1)                  # Number of blades
    stations::Vector{typeof(1.0u"m")}    # Station locations
    chords::Vector{typeof(1.0u"m")}      # Chords evaluated at stations
    geopitches::Vector{typeof(1.0u"m")}  # Geometric pitches evaluated at stations
end

"""
Tabulated airfoil polar data.

Contain the tabulated values of cl and cd, for the corresponding sampled
angles of attack and Reynolds numbers.
"""
struct AirfoilPolar
    aoa::Vector{typeof(1.0u"rad")}  # Sample of angles of attack
    Re::Vector{Real}                # Sample of Reynolds numbers
    cl::Matrix{Real}                # Corresponding lift coefficients
    cd::Matrix{Real}                # Corresponding drag coefficients
end

"""Implement a generic propeller."""
struct Propeller
    airfoil::AirfoilPolar
    geometry::PropellerGeometry
end
