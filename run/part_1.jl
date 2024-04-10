using DelimitedFiles

using GLMakie

using BEMT

# 1. Load problem data

"Build the location path for the given resource file."
fpath(fname::AbstractString) = joinpath(@__DIR__, "res", fname)

# Airfoil geometry
clarky = readdlm(fpath("clarky.dat"); skipstart=1)

# Airfoil polar data
aoa      = readdlm(fpath("polar_data/aoa.dat"))      |> vec
reynolds = readdlm(fpath("polar_data/reynolds.dat")) |> vec
cl       = readdlm(fpath("polar_data/cl.dat"))
cd       = readdlm(fpath("polar_data/cd.dat"))
airfoil  = AirfoilPolar(aoa, reynolds, cl, cd)

# Geometry of the blade
diameter      = 10 * C.FT2M
n_blades      = 3;
stations      = [0.2,    0.3,    0.4,    0.5,    0.6,    0.7,    0.8,    0.9]    * diameter/2
chord_dist    = [0.0360, 0.0525, 0.0700, 0.0760, 0.0735, 0.0660, 0.0565, 0.0450] * diameter
geopitch_dist = [0.670,  0.840,  0.940,  0.980,  1.020,  1.090,  1.125,  1.190]  * diameter
geometry      = PropellerGeometry(diameter, n_blades, stations, chord_dist, geopitch_dist)

# Define the propeller to study
prop = Propeller(airfoil, geometry)

# Operating conditions
Ω   = 800       * C.RPM2RADS  # Rotation speed [rad/s]
θ75 = [25, 35]  * C.DEG2RAD   # Collective pitches [rad]
v∞  = [90, 135] * C.MPH2MS    # Wind speeds [m/s]
ρ   = 1.2255                  # Density of the air [kg/m³]
μ   = 17.89e-6                # Dynamic viscosity of the air [Pa*s]
oper1 = OperatingConditions(Ω, θ75[1], v∞[1], ρ, μ)
oper2 = OperatingConditions(Ω, θ75[2], v∞[2], ρ, μ)

# 2. Performance parameters

sol1 = bem(prop, oper1)
# sol2 = bem(prop, oper2)


# 3. Plot the desired quantities


