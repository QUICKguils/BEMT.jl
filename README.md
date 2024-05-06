# BEMT 🛨

This repository holds all the code written for the project carried out as part
of the Aerospace Propulsion course (AERO0014), academic year 2023-2024.

This repository consists of two elements.
- A Julia package named `BEMT`. The source code of this package lies in the
  `src/` directory. It provides tools and computation methods that are based on
  the blade element momentum theory.
- The course project files and an executable script. These files lie in the
  `run/` directory. They directly use the `BEMT` library to compute the
  quantities needed to fulfill the project requirements.

## Installation

In order to use this package, a version of Julia (>=1.0.0) have to be
[installed](https://julialang.org/downloads/) on the system.

Next, simply clone the project and install the possible dependencies:
```sh
# Clone this repository
git clone https://github.com/QUICKguils/BEMT.jl.git

# Go to the project `run/` directory
cd BEMT.jl/run

# Make sure the environment is ready to use
julia --project -e "using Pkg; Pkg.instantiate();"
```

Please note that this last step can take some time if Julia has been freshly
installed on the system.

## Basic usage

From the `run/` directory, just execute the main project file:
```
julia --project -i run.jl
```

Note that the execution time of this script is quite slow, as Julia needs to
re-evaluate the project environment for each execution. If the code has to be
run more than once, is thus advised to use the code interactively in a Julia
REPL. See the explanations below.

## Advanced usage

### Run the project file with custom parameters

The `-h` flag provides an overview of the available options:
```
julia --project run.jl -h

usage: run.jl [--sdiv SDIV] [--part [PART...]] [--plot [PLOT]] [-h]

Execution script of the BEMT project.

optional arguments:
  --sdiv SDIV       Number of subdivisions in the propeller blades.
                    (type: Int64, default: 20)
  --part [PART...]  Which parts of the project to execute. (type:
                    Int64, default: [1, 2, 3])
  --plot [PLOT]     Plot the computed results. (type: Bool, default:
                    true, without arg: true)
  -h, --help        show this help message and exit
```

For example, to run the two last part of the project without creating the
associated plots, run:
```
julia --project -i run.jl --part 2 3 --plot false
```

### Use the code interactively

If some project files need to be repeatedly executed, it is advised to keep a
Julia session open and run them in the Julia REPL.
```
# Enter the Julia REPL, inside the right project environment (`run/` directory)
julia --project

# Include the project statement data
julia> include("Statement.jl")

# Include, for example, the module that answers the first part of the project
julia> include("Part1.jl")

# Define custom running arguments
julia> args = Dict("sdiv" => 20, "plot" => true)

# Run the first part of the project
julia> sol1, sol2 = Part1.main(args);
```
Then, include and run as many times as wanted the different project parts in the
REPL.
Finally, hit `CTRL-D` to quit the Julia session.
