using DelimitedFiles

"Build the location path for the given resource file."
fpath(fname::AbstractString) = joinpath(@__DIR__, "res", fname)

# Airfoil geometry
clarky = readdlm(fpath("clarky.dat"); skipstart=1)

# Airfoil polar data
aoa     = readdlm(fpath("polar_data/aoa.dat"))      |> vec
Re      = readdlm(fpath("polar_data/reynolds.dat")) |> vec
cl      = readdlm(fpath("polar_data/cl.dat"))
cd      = readdlm(fpath("polar_data/cd.dat"))
airfoil = AirfoilPolar(aoa, Re, cl, cd)

# Geometry of the blade
diameter   = 10 * C.FT2M
n_blades   = 3;
stations   = [0.2,    0.3,    0.4,    0.5,    0.6,    0.7,    0.8,    0.9]    * diameter/2
chords     = [0.0360, 0.0525, 0.0700, 0.0760, 0.0735, 0.0660, 0.0565, 0.0450] * diameter
geopitches = [0.670,  0.840,  0.940,  0.980,  1.020,  1.090,  1.125,  1.190]  * diameter
geometry   = PropellerGeometry(diameter, n_blades, stations, chords, geopitches)

# Define the propeller to study
prop = Propeller(airfoil, geometry)
