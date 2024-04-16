# BEMT Project - Part 2
#
# Reproduce the experiments of [1] by computing the thrust coefficient, power coefficient
# and propulsive efficiency with respect to advance ratio for θ75 = 15◦ to 45◦.
# Compare your results with the experimental results.

using GLMakie

using BEMT

# 0. Statement data from project description

include("load_statement.jl")

# 1. Statement data from part 2

# Operating conditions.
n_range      = [1000, 1000, 800, 800, 800, 700, 700] ./ C.MIN2S  # Rotation speeds [tr/s]
Ω_range      = n_range .* C.RPS2RADS                             # Rotation speeds [rad/s]
θ75deg_range = [15,   20,   25,  30,  35,  40,  45]              # Collective pitches [°]
θ75_range    = θ75deg_range .* C.DEG2RAD                         # Collective pitches [rad]
v∞_range     = collect(5:5:115) * C.MPH2MS                       # Wind speeds [m/s]
ρ            = 1.2255                                            # Density of the air [kg/m³]
μ            = 17.89e-6                                          # Dynamic viscosity of the air [Pa*s]

# 2. Compute the BEM quantities

thrusts = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
powers  = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
Ωs      = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
v∞s     = [Vector{Real}() for _ ∈ eachindex(θ75_range)]

# Reproduce the experimental method conducted in [1].
# Calculate the propeller thrust and power for an increasing wind speed, up to a maximum of
# 115 mph. Then decrease the propeller rotation speed to further increase the advance ratio.
# Stop the computation when the computed thrust becomes negative.
for iθ ∈ eachindex(θ75_range)

    iJ = 1
    Ω  = Ω_range[iθ]
    v∞ = v∞_range[iJ]

    while true
        oper = OperatingConditions(Ω, θ75_range[iθ], v∞, ρ, μ)
        sol  = bem(prop, oper)

        sol.thrust <= 0 && break

        push!(Ωs[iθ],      oper.Ω)
        push!(v∞s[iθ],     oper.v∞)
        push!(thrusts[iθ], sol.thrust)
        push!(powers[iθ],  sol.torque * Ω)

        if iJ < length(v∞_range)
            iJ += 1
            v∞ = v∞_range[iJ]
            @show iJ  # TODO: remove when debugged
        else
            Ω -= 0.1 * Ω_range[iθ]
        end
    end
end


# 3. Compute the performance coefficients

J   = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
C_T = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
C_P = [Vector{Real}() for _ ∈ eachindex(θ75_range)]
eta = [Vector{Real}() for _ ∈ eachindex(θ75_range)]

# WARN: conversion in imperial units
# TODO: verify all the conversions
# TODO: verify the coeff def
for i ∈ eachindex(θ75_range)

    # Advance ratios
    J[i] = (v∞s[i] ./ (diameter*Ωs[i])
        / C.MPH2MS * C.FT2M * C.RPS2RADS)

    # Thrust coefficient
    C_T[i] = (thrusts[i] ./ (diameter^4*ρ*Ωs[i].^2)
        / C.LBF2N * C.FT2M^4 * C.SLUG2KG / C.FT2M^3 * C.RPS2RADS^2)

    # Power coefficient
    C_P[i] = (powers[i] ./ (diameter^5*ρ*Ωs[i].^3)
        / C.HP2W * C.FT2M^5 * C.SLUG2KG / C.FT2M^3 * C.RPS2RADS^3)

    # Propulsive efficiency
    eta[i] = C_T[i] ./ C_P[i] .* J[i]
end

# 4. Plot the coefficients

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
Legend(fig[1, 1:2], ax_eta,
       L"\theta_{75}", titleposition=:left, titlegap=20, orientation=:horizontal)
rowsize!(fig.layout, 2, Auto(0.6))

# Display the plot
current_figure()

