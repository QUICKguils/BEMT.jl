"""
    BEMT project - Part 2

Reproduce the experiments of [1] by computing the thrust coefficient, power coefficient
and propulsive efficiency with respect to advance ratio for θ75 = 15° to 45°.
Compare your results with the experimental results.
"""
module Part2

# TODO: find a way to conditionnaly load GLMakie
using GLMakie
using BEMT
using ..Statement: Statement as Stm

# Operating conditions
const n_range      = [1000, 1000, 800, 800, 800, 700, 700] ./ C.MIN2S  # Rotation speeds [tr/s]
const Ω_range      = n_range .* C.RPS2RADS                             # Rotation speeds [rad/s]
const θ75deg_range = [15,   20,   25,  30,  35,  40,  45]              # Collective pitches [°]
const θ75_range    = θ75deg_range .* C.DEG2RAD                         # Collective pitches [rad]
const v∞_range     = collect(5:5:115) * C.MPH2MS                       # Wind speeds [m/s]
const ρ            = 1.2255                                            # Density of the air [kg/m³]
const μ            = 17.89e-6                                          # Dynamic viscosity of the air [Pa*s]

"""Execute the second part of the project."""
function main(args)
    thrusts = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
    powers  = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
    Ωs      = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
    v∞s     = [Vector{Real}() for _ ∈ eachindex(θ75_range)]

    # Reproduce the experimental method conducted in [1].
    # Calculate the propeller thrust and power for an increasing wind speed, up to a maximum
    # of 115 mph. Then decrease the propeller rotation speed to further increase the advance
    # ratio. Stop the computation when the computed thrust becomes negative.
    for iθ ∈ eachindex(θ75_range)
        iJ = 1
        Ω  = Ω_range[iθ]
        v∞ = v∞_range[iJ]

        while true
            oper = OperatingConditions(Ω, θ75_range[iθ], v∞, ρ, μ)
            sol  = bem(Stm.prop, oper)

            sol.thrust <= 0 && break

            push!(Ωs[iθ],      oper.Ω)
            push!(v∞s[iθ],     oper.v∞)
            push!(thrusts[iθ], sol.thrust)
            push!(powers[iθ],  sol.torque * Ω)

            if iJ < length(v∞_range)
                @show iJ  # TODO: remove when debugged
                iJ += 1
                v∞ = v∞_range[iJ]
            else
                Ω -= 0.1 * Ω_range[iθ]
            end
        end
    end


    # Compute the performance coefficients

    # TODO: prealloc possible here
    J   = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
    C_T = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
    C_P = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
    eta = [Vector{Real}() for _ ∈ eachindex(θ75_range)]

    # WARN: conversion in imperial units
    # TODO: verify all the conversions
    # TODO: verify the coeff def
    for i ∈ eachindex(θ75_range)
        # Advance ratios
        J[i] = (v∞s[i] ./ (Stm.diameter*Ωs[i])
            / C.MPH2MS * C.FT2M * C.RPS2RADS)

        # Thrust coefficients
        C_T[i] = (thrusts[i] ./ (Stm.diameter^4*ρ*Ωs[i].^2)
            / C.LBF2N * C.FT2M^4 * C.SLUG2KG / C.FT2M^3 * C.RPS2RADS^2)

        # Power coefficients
        C_P[i] = (powers[i] ./ (Stm.diameter^5*ρ*Ωs[i].^3)
            / C.HP2W * C.FT2M^5 * C.SLUG2KG / C.FT2M^3 * C.RPS2RADS^3)

        # Propulsive efficiencies
        eta[i] = C_T[i] ./ C_P[i] .* J[i]
    end

    # Plot the coefficients, if desired
    args["plot"] && plot_sol(J, C_T, C_P, eta, )
end

"""Plot the solutions of the second part of the project."""
function plot_sol(J, C_T, C_P, eta)
    # Instantiate a Figure object
    fig = Figure(size=(1200, 900))

    # Propulsive efficiency vs advance ratio, for different collective pitches
    ax_eta = Axis(fig[2, 1:2], xlabel="Advance ratio", ylabel="Propulsive efficiency")
    for i ∈ eachindex(θ75_range)
        scatterlines!(ax_eta, J[i], eta[i], label="$(θ75deg_range[i])°")
    end

    # Thrust coefficient vs advance ratio, for different collective pitches
    ax_thrust = Axis(fig[3, 1], xlabel="Advance ratio", ylabel="Thrust coefficient")
    for i ∈ eachindex(θ75_range)
        scatterlines!(ax_thrust, J[i], C_T[i])
    end

    # Power coefficient vs advance ratio, for different collective pitches
    ax_power = Axis(fig[3, 2], xlabel="Advance ratio", ylabel="Power coefficient")
    for i ∈ eachindex(θ75_range)
        scatterlines!(ax_power, J[i], C_P[i])
    end

    # Dress the plot: legend and layout
    Legend(fig[1, 1:2], ax_eta, L"\theta_{75}", titleposition=:left, titlegap=20, orientation=:horizontal)
    rowsize!(fig.layout, 2, Auto(0.6))

    # Display the plot
    display(fig)
end

end  # module Part2
