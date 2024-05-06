"""
    BEMT project - Part 2

Reproduce the experiments of [1] by computing the thrust coefficient, power coefficient
and propulsive efficiency with respect to advance ratio for θ75 = 15° to 45°.
Compare your results with the experimental results.
"""
module Part2

using GLMakie  # TODO: find a way to conditionally load GLMakie
using BEMT
using ..Statement: Statement as Stm

# Operating conditions
const Ω_range      = [1000, 1000, 800, 800, 800, 700, 700] .* C.rpm2rads  # Rotation speeds [rad/s]
const θ75deg_range = [15,   20,   25,  30,  35,  40,  45]                 # Collective pitches [°]
const θ75_range    = θ75deg_range .* C.deg2rad                            # Collective pitches [rad]
const v∞_range     = collect(30:5:115) * C.mph2ms                         # Wind speeds [m/s]
const ρ            = 1.2255                                               # Density of the air [kg/m³]
const μ            = 17.89e-6                                             # Dynamic viscosity of the air [Pa*s]

"""Execute the second part of the project."""
function main(args)
    thrusts, powers, Ωs, v∞s = reproduce_report(args)
    J, C_T, C_P, eta = performance_coefficients(thrusts, powers, Ωs, v∞s)

    # Plot the coefficients, if desired
    args["plot"] && plot_sol(J, C_T, C_P, eta)

    return J, C_T, C_P, eta
end

"""
    reproduce_report(args)
Reproduce the experimental method conducted in the reference NACA report.

Calculate the propeller thrust and power for an increasing wind speed, up to a maximum of
115 mph. Then decrease the propeller rotation speed to further increase the advance ratio.
Stop the computation when the computed thrust becomes negative.
"""
function reproduce_report(args)
    thrusts = [Float64[] for _ ∈ eachindex(θ75_range)]
    powers  = [Float64[] for _ ∈ eachindex(θ75_range)]
    Ωs      = [Float64[] for _ ∈ eachindex(θ75_range)]
    v∞s     = [Float64[] for _ ∈ eachindex(θ75_range)]

    for θ75_index ∈ eachindex(θ75_range)
        max_thrust = 0
        v∞_index = 1
        Ω = Ω_range[θ75_index]
        v∞ = v∞_range[v∞_index]

        while true
            oper = OperatingConditions(Ω, θ75_range[θ75_index], v∞, ρ, μ)
            sol = bem(Stm.prop, oper, sdiv=args["sdiv"])
            max_thrust = max(sol.thrust, max_thrust)

            sol.thrust <= 0 && break

            push!(Ωs[θ75_index],      oper.Ω)
            push!(v∞s[θ75_index],     oper.v∞)
            push!(thrusts[θ75_index], sol.thrust)
            push!(powers[θ75_index],  sol.torque * Ω)

            if v∞_index < length(v∞_range)
                v∞_index += 1
                v∞ = v∞_range[v∞_index]
            else
                # Heuristic method for decreasing the rotation speed
                # Decrease slower when approaching the zero thrust
                sol.thrust > 0.1*max_thrust ? Ω -= 0.03 * Ω : Ω -= 0.01 * Ω
            end
        end
    end

    return thrusts, powers, Ωs, v∞s
end

"""
    performance_coefficients(thrusts, powers, Ωs, v∞s)
Compute the performance coefficients associated to the experimental reproduction results.
"""
function performance_coefficients(thrusts, powers, Ωs, v∞s)
    J   = [Float64[] for _ ∈ eachindex(θ75_range)]  # Advance ratios
    C_T = [Float64[] for _ ∈ eachindex(θ75_range)]  # Thrust coefficients
    C_P = [Float64[] for _ ∈ eachindex(θ75_range)]  # Power coefficients
    eta = [Float64[] for _ ∈ eachindex(θ75_range)]  # Propulsive efficiencies

    for i ∈ eachindex(θ75_range)
        ns     = Ωs/C.tr2rad;
        J[i]   = v∞s[i] ./ (2*Stm.span*ns[i])
        C_T[i] = 4 * thrusts[i] ./ ((2*Stm.span)^4*ρ*ns[i].^2)
        C_P[i] = 4 * powers[i] ./ ((2*Stm.span)^5*ρ*ns[i].^3)
        eta[i] = C_T[i] ./ C_P[i] .* J[i]
    end

    # NOTE: to translate in imperial units, use:
    # J   = J   / C.mph2ms * C.ft2m * C.tr2rad
    # C_T = C_T / C.lbf2n * C.ft2m^4 * C.slug2kg / C.ft2m^3 * C.tr2rad^2
    # C_P = C_P / C.hp2w * C.ft2m^5 * C.slug2kg / C.ft2m^3 * C.tr2rad^3

    return J, C_T, C_P, eta
end

"""Plot the solutions of the second part of the project."""
function plot_sol(J, C_T, C_P, eta)
    # Instantiate a Figure object
    fig = Figure(size=(1200, 900))

    # Axes creation and layout
    ax_eta    = Axis(fig[2, 1:2], xlabel="Advance ratio", ylabel="Propulsive efficiency")
    ax_thrust = Axis(fig[3, 1],   xlabel="Advance ratio", ylabel="Thrust coefficient")
    ax_power  = Axis(fig[3, 2],   xlabel="Advance ratio", ylabel="Power coefficient")

    # Plot the perfomance coefficients vs advance ratio, for different collective pitches
    for i ∈ eachindex(θ75_range)
        scatterlines!(ax_eta,    J[i], eta[i], label="$(θ75deg_range[i])°")
        scatterlines!(ax_thrust, J[i], C_T[i])
        scatterlines!(ax_power,  J[i], C_P[i])
    end

    # Dress the plot: legend and layout
    Legend(
        fig[1, 1:2], ax_eta, L"\theta_{75}",
        titleposition=:left, titlegap=20, orientation=:horizontal
    )
    rowsize!(fig.layout, 2, Auto(0.6))

    display(fig)

    return nothing
end

end  # module Part2
