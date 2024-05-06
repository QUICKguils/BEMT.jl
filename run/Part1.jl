"""
    BEMT project - Part 1

Considering an engine rotational speed of 800 RPM, compute the thrust, the power absorbed
by the propeller and the propulsive efficiency for θ75 = 25° at a wind speed of 90 mph,
and for θ75 = 35° at a wind speed of 135 mph.
Plot the thrust and power distribution along the span and discuss the spanwise
distribution of the velocity triangles, torque and thrust.
"""
module Part1

using GLMakie  # TODO: find a way to conditionally load GLMakie
using BEMT
using ..Statement: Statement as Stm

# Operating conditions
const Ω   = 800       * C.rpm2rads  # Rotation speed [rad/s]
const θ75 = [25, 35]  * C.deg2rad   # Collective pitches [rad]
const v∞  = [90, 135] * C.mph2ms    # Wind speeds [m/s]
const ρ   = 1.2255                  # Density of the air [kg/m³]
const μ   = 17.89e-6                # Dynamic viscosity of the air [Pa*s]
const oper1 = OperatingConditions(Ω, θ75[1], v∞[1], ρ, μ)
const oper2 = OperatingConditions(Ω, θ75[2], v∞[2], ρ, μ)

"""Execute the first part of the project."""
function main(args)
    sol1 = bem(Stm.prop, oper1, sdiv=args["sdiv"])
    sol2 = bem(Stm.prop, oper2, sdiv=args["sdiv"])

    # Plot the quantities, if desired
    args["plot"] && plot_sol(sol1, sol2)

    return sol1, sol2
end

"""Plot the solutions of the first part of the project."""
function plot_sol(sol1::BemSolution, sol2::BemSolution)
    # Instantiate a Figure object
    fig = Figure(size=(1000, 500))

    # Get the width of the stream tubes  # TODO: not clean
    dr1 = sol1.r_dist[2] - sol1.r_dist[1]
    dr2 = sol2.r_dist[2] - sol2.r_dist[1]

    # Thrust distribution along the blades span
    ax1 = Axis(fig[1, 1], title="Thrust distribution", xlabel=L"r/R", ylabel=L"$dT/dr$ [N/m]")
    scatterlines!(ax1, sol1.r_dist/Stm.span, sol1.thrust_dist/dr1, label="Oper. 1")
    scatterlines!(ax1, sol2.r_dist/Stm.span, sol2.thrust_dist/dr1, label="Oper. 2")
    axislegend(ax1, position=:lt)

    # Power distribution along the blades span
    ax2 = Axis(fig[1, 2], title="Power distribution", xlabel=L"r/R", ylabel=L"$dP/dr$ [W/m]")
    scatterlines!(ax2, sol1.r_dist/Stm.span, sol1.torque_dist*Ω/dr2, label="Oper. 1")
    scatterlines!(ax2, sol2.r_dist/Stm.span, sol2.torque_dist*Ω/dr2, label="Oper. 2")
    axislegend(ax2, position=:lt)

    display(fig)

    return nothing
end

end  # module Part1
