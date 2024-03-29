# BEMT 🛨

This repository holds all the code written for the project carried out as part
of the Aerospace Propulsion course (AERO0014), academic year 2023-2024.

This repository consists of two elements.
 - A julia package named `BEMT`, the source code of which lies in the `src/`
   directory. It provides tools and computation methods that are based on the
   blade element momentum theory.
- Executable scripts that lies in the `run/` directory. It directly uses the
  `BEMT` library to compute the quantities needed to fulfill the project
  requirements.

## Installation

In order to use this package, a version of Julia (>=1.0.0) have to be
[installed](https://julialang.org/downloads/) on the system.

Next, simply clone the project and install the possible dependencies:
```sh
# Clone this repository.
git clone git@github.com:QUICKguils/BEMT.jl.git

# Go to the project top level directory.
cd BEMT.jl

# Make sure the environment is ready to use.
julia --project -e "using Pkg; Pkg.instantiate();"
```

## Basic usage

From the top level directory (where this README lies), just run the main project
file:
```sh
julia run.jl
```

## Advanced usage

### Run the project file with custom parameters

```sh
julia run.jl -h
```

### Use and extend the package

```julia
using BEMT
```

## Project architecture
