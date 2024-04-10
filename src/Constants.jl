"Define the constant values used throughout the project."
module Constants

# TODO: cleanup this module

# Conversion factors
const IN2M     = 0.0254       # Inch                  -> meter.
const FT2M     = 0.3048       # Foot                  -> meter.
const MI2M     = 1609.344     # Mile                  -> meter.
const NMI2M    = 1852         # Nautical mile         -> meter.
const MPH2KMH  = 1.609344     # Miles per hour        -> kilometer per hour.
const MPH2MS   = 0.44704      # Miles per hour        -> meter per second.
const KN2KMH   = 1.852        # Knot                  -> kilometer per hour.
const KN2MS    = 0.514444     # Knot                  -> meter per second.
const SLUG2KG  = 14.59390     # Slug                  -> kilogram.
const LB2KG    = 0.45359237   # Pound mass            -> kilogram.
const LBF2N    = 4.448222     # Pound force           -> newton.
const USGAL2M3 = 3.785411784  # US gallon             -> cubic meter.
const RPM2RADS = π/30         # Revolution per minute -> radian per second.
const DEG2RAD  = π/180        # Degree                -> radian.

end  # module Constants
