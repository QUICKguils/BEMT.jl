# BEMT Project - Part 1
#
# Considering an engine rotational speed of 800 RPM, compute the thrust, the power absorbed
# by the propeller and the propulsive efficiency for θ75 = 25◦ at a wind speed of 90 mph,
# and for θ75 = 35◦ at a wind speed of 135 mph.
# Plot the thrust and power distribution along the span and discuss the spanwise
# distribution of the velocity triangles, torque and thrust.

using GLMakie

using BEMT

# 0. Statement data from project description

include("load_statement.jl")

# 1. Statement data from part 1

# Operating conditions
n   = 800       / C.MIN2S     # Rotation speed [tr/s]
Ω   = n         * C.RPS2RADS  # Rotation speed [rad/s]
θ75 = [25, 35]  * C.DEG2RAD   # Collective pitches [rad]
v∞  = [90, 135] * C.MPH2MS    # Wind speeds [m/s]
ρ   = 1.2255                  # Density of the air [kg/m³]
μ   = 17.89e-6                # Dynamic viscosity of the air [Pa*s]
oper1 = OperatingConditions(Ω, θ75[1], v∞[1], ρ, μ)
oper2 = OperatingConditions(Ω, θ75[2], v∞[2], ρ, μ)

# 2. Compute the BEM quantities

sol1 = bem(prop, oper1)
sol2 = bem(prop, oper2)

# 3. Plot the quantities

# Instantiate a Figure object
f = Figure(size=(1000, 500))

# Get the width of the streamtubes defined by the bem() function
dr = sol1.radii[2] - sol1.radii[1]

# Thrust distribution along the blades span
ax1 = Axis(f[1, 1], title="Thrust distribution", xlabel=L"r/R", ylabel=L"dT/dr [N/m]")
scatterlines!(ax1, sol1.radii/(diameter/2), sol1.thrust_dist/dr, label="oper1")
scatterlines!(ax1, sol2.radii/(diameter/2), sol2.thrust_dist/dr, label="oper2")
axislegend(ax1, position=:lt)

# Power distribution along the blades span
ax2 = Axis(f[1, 2], title="Power distribution", xlabel=L"r/R", ylabel=L"dP/dr [W/m]")
scatterlines!(ax2, sol1.radii/(diameter/2), sol1.torque_dist*Ω/dr, label="oper1")
scatterlines!(ax2, sol2.radii/(diameter/2), sol2.torque_dist*Ω/dr, label="oper2")
axislegend(ax2, position=:lt)

# Display the plot
current_figure()
