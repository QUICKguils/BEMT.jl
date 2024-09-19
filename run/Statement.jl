"Define the general project statement data."
module Statement

using DelimitedFiles
using Unitful

using BEMT

"Build the location path for the given resource file."
fpath(fname::AbstractString) = joinpath(@__DIR__, "res", fname)

# Airfoil geometry
const clarky = readdlm(fpath("clarky.dat"); skipstart=1)

# Airfoil polar data
const aoa     = readdlm(fpath("polar_data/aoa.dat"))u"rad" |> vec
const Re      = readdlm(fpath("polar_data/reynolds.dat"))  |> vec
const cl      = readdlm(fpath("polar_data/cl.dat"))
const cd      = readdlm(fpath("polar_data/cd.dat"))
const airfoil = AirfoilPolar(aoa, Re, cl, cd)

# Geometry of the blade
const span       = (10/2)u"ft" |> u"m"
const n_blades   = 3
const stations   = [0.2,    0.3,    0.4,    0.5,    0.6,    0.7,    0.8,    0.9]    *   span
const chords     = [0.0360, 0.0525, 0.0700, 0.0760, 0.0735, 0.0660, 0.0565, 0.0450] * 2*span
const geopitches = [0.670,  0.840,  0.940,  0.980,  1.020,  1.090,  1.125,  1.190]  * 2*span
const geometry   = PropellerGeometry(span, n_blades, stations, chords, geopitches)

# Define the propeller to study
const prop = Propeller(airfoil, geometry)

end # module Statement
