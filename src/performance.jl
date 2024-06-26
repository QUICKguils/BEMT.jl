using Logging
using Interpolations

struct OperatingConditions{R<:Real}
    Ω::R    # Rotation speed [rad/s]
    θ75::R  # Collective pitch [rad]
    v∞::R   # Wind speed [m/s]
    ρ::R    # Density of the air [kg/m³]
    μ::R    # Dynamic viscosity of the air [Pa*s]
end

struct LocalGeometry{I<:Integer, R<:Real}
    span::R      # Span of one blade [m]
    n_blades::I  # Number of blades
    r::R         # Radial position of the local geometry [m]
    dr::R        # Streamtube width [m]
    chord::R     # Chord [m]
    geopitch::R  # Geometric pitch [m]
end

"""Outer constructor method, to directly use a Propeller object."""
function LocalGeometry(prop::Propeller, r, dr, chord, geopitch)
    LocalGeometry(prop.geometry.span, prop.geometry.n_blades, r, dr, chord, geopitch)
end

struct BemSolution{R<:Real, Vec<:Vector{R}}
    thrust::R         # Total thrust provided by the propeller [N]
    torque::R         # Total torque provided by the propeller [N*m]
    r_dist::Vec       # Radial position of the local geometries [m]
    thrust_dist::Vec  # Spanwise distribution of the stream tubes thrust [N]
    torque_dist::Vec  # Spanwise distribution of the stream tubes torque [N*m]
    va2_dist::Vec     # Spanwise distribution of va2 (= wa2) [m/s]
    vu2_dist::Vec     # Spanwise distribution of vu2 [m/s]
    wu2_dist::Vec     # Spanwise distribution of wu2 [m/s]
end

struct LocalBemSolution{R<:Real}
    thrust::R  # Thrust generated in the local stream tube [N]
    torque::R  # Torque generated in the local stream tube [N*m]
    va2::R     # Local axial speed [m/s]
    vu2::R     # Local absolute tangential speed [m/s]
    wu2::R     # Local relative tangential speed [m/s]
end

"""
    bem(prop, oper; sdiv=20)
Calculate quantities derived from momentum balance of a propeller.

This function applies the blade element method to the propeller `prop`,
for the specified operating conditions `oper` and subdivisions `sdiv` in the blades.
"""
function bem(prop::Propeller, oper::OperatingConditions; sdiv=20)
    # Subdivise the propeller span
    r_min  = prop.geometry.stations[1]
    r_max  = prop.geometry.span
    r_dist = range(r_min, r_max, sdiv) |> collect
    dr     = r_dist[2] - r_dist[1]  # WARN: not robust: fails for non-linear range

    chords = linear_interpolation(
        prop.geometry.stations, prop.geometry.chords, extrapolation_bc=Line())(r_dist)
    geopitches = linear_interpolation(
        prop.geometry.stations, prop.geometry.geopitches, extrapolation_bc=Line())(r_dist)

    thrust_dist = zeros(size(r_dist))
    torque_dist = zeros(size(r_dist))
    va2_dist    = zeros(size(r_dist))
    vu2_dist    = zeros(size(r_dist))
    wu2_dist    = zeros(size(r_dist))

    # Compute the thrust and torque for all of these locations
    for i ∈ eachindex(r_dist)
        lgeom = LocalGeometry(prop, r_dist[i], dr, chords[i], geopitches[i])

        local_bem_sol = local_bem(lgeom, prop.airfoil, oper)

        thrust_dist[i] = local_bem_sol.thrust
        torque_dist[i] = local_bem_sol.torque
        va2_dist[i]    = local_bem_sol.va2
        vu2_dist[i]    = local_bem_sol.vu2
        wu2_dist[i]    = local_bem_sol.wu2
    end

    # Total thrust and torque exerted by the propeller
    thrust = sum(thrust_dist)
    torque = sum(torque_dist)

    return BemSolution(
        thrust, torque, r_dist, thrust_dist, torque_dist, va2_dist, vu2_dist, wu2_dist
    )
end

"""
    local_bem(lgeom, airfoil, oper; kwargs)
Calculate quantities derived from momentum balance in one stream tube, for one blade.

This function applies the blade element method to the propeller local geometry `lgeom`,
for the specified airfoil polar data `airfoil` and operating conditions `oper`.
"""
function local_bem(
    lgeom::LocalGeometry, airfoil::AirfoilPolar, oper::OperatingConditions;
    rtol=1e-3, atol=1e-2, maxiter=50
)
    # FIX: crashes for v∞=0m/s
    # The mass flow in null, hence va3_new and vu2p_new are NaN.

    # Initial speed guesstimates
    va3 = oper.v∞
    vu2p = 0

    # Initialize computed quantities
    n_iter = 0
    thrust = torque = 0
    va2 = vu2 = wu2 = 0

    stagger(r::Real) = atan(lgeom.geopitch, 2π*r)
    pitch = stagger(lgeom.r) - stagger(0.75*lgeom.span) + oper.θ75

    # Linear interpolator methods for lift and drag coefficients
    cl_lerp = linear_interpolation(
        (airfoil.aoa, airfoil.Re), airfoil.cl, extrapolation_bc=Line())
    cd_lerp = linear_interpolation(
        (airfoil.aoa, airfoil.Re), airfoil.cd, extrapolation_bc=Line())

    # Determine forces and velocities iteratively
    while true
        n_iter += 1

        # Velocity components at the propeller disk
        va2 = (oper.v∞ + va3) / 2
        vu2 = vu2p / 2
        wu2 = vu2 - oper.Ω*lgeom.r
        w2  = √(va2^2 + wu2^2)
        β2  = atan(wu2, va2)

        aoa = pitch - (π/2 + β2)
        Re = oper.ρ * w2 * lgeom.chord / oper.μ

        cl = cl_lerp(aoa, Re)
        cd = cd_lerp(aoa, Re)

        lift = 1//2 * oper.ρ * w2^2 * lgeom.chord * lgeom.dr * cl
        drag = 1//2 * oper.ρ * w2^2 * lgeom.chord * lgeom.dr * cd

        thrust = -lgeom.n_blades * (lift*sin(β2) + drag*cos(β2))
        torque =  lgeom.n_blades * (lift*cos(β2) - drag*sin(β2)) * lgeom.r

        # New approximations for the absolute velocity components
        mass_flow = 2π * lgeom.r * lgeom.dr * oper.ρ * va2
        va3_new   = oper.v∞ + thrust/mass_flow
        vu2p_new  = torque / (mass_flow * lgeom.r)

        # Stop the iterations if the speeds have sufficiently converged
        va3_ok  = isapprox(va3,  va3_new,  atol=atol, rtol=rtol)
        vu2p_ok = isapprox(vu2p, vu2p_new, atol=atol, rtol=rtol)
        va3_ok && vu2p_ok && break

        if n_iter == maxiter
            @warn "Maximum number of iterations reached" maxlog=1
            break
        end

        # Otherwise update the speeds for the next iteration
        vu2p = vu2p_new
        va3  = va3_new
    end

    return LocalBemSolution(thrust, torque, va2, vu2, wu2)
end

