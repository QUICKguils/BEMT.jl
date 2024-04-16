"Define the constant values used throughout the package."
module Constants

# Conversion factors
const FT2M     = 0.3048       # foot                  -> meter
const MPH2MS   = 0.44704      # miles per hour        -> meter per second
const SLUG2KG  = 14.59390     # slug                  -> kilogram
const LB2KG    = 0.45359237   # pound mass            -> kilogram
const LBF2N    = 4.448222     # pound force           -> newton
const MIN2S    = 60           # minute                -> second
const RPM2RADS = π/30         # revolution per minute -> radian per second
const RPS2RADS = 2π           # revolution per second -> radian per second
const DEG2RAD  = π/180        # degree                -> radian
const HP2W     = 745.7        # imperial horsepower   -> watt

end  # module Constants
