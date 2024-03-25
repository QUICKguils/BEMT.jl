"Define the constant values used throughout the project."
module Constants

# Physical constants
const γ_air = 1.4        # Adiabatic index or ratio of specific heats (dry air at 20ºC).
const R_air = 287.05287  # Specific gas constant for dry air [J/(Kg*K)].
const g     = 9.80665    # Gravity acceleration at Earth surface at 45º geodetic latitude [m/s²].

# Reference quantities
const p_ref = 101325  # Reference atmospheric pressure [Pa].
const T_ref = 288     # Reference temperature [K].

# Conversion factors
const in2m     = 0.0254       # Inch            ->  meter.
const ft2m     = 0.3048       # Foot            ->  meter.
const mi2m     = 1609.344     # Mile            ->  meter.
const nmi2m    = 1852         # Nautical mile   ->  meter.
const mph2kmh  = 1609.344     # Miles per hour  ->  kilometers per hour.
const mph2ms   = 0.44704      # Miles per hour  ->  meters per second.
const kn2kmh   = 1.852        # Knot            ->  kilometers per hour.
const kn2ms    = 0.514444     # Knot            ->  meters per second.
const slug2kg  = 14.59390     # Slug            ->  kilogram.
const lb2kg    = 0.45359237   # Pound mass      ->  kilogram.
const lbf2n    = 4.448222     # Pound force     ->  newton.
const usgal2m3 = 3.785411784  # US gallon       ->  cubic meter.

end # module Constants
