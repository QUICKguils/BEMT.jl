"Define the constant values used throughout the package."
module Constants

# Conversion factors
const ft2m     = 0.3048       # foot                  -> meter
const mph2ms   = 0.44704      # miles per hour        -> meter per second
const slug2kg  = 14.59390     # slug                  -> kilogram
const lb2kg    = 0.45359237   # pound mass            -> kilogram
const lbf2n    = 4.448222     # pound force           -> newton
const min2s    = 60           # minute                -> second
const rpm2rads = π/30         # revolution per minute -> radian per second
const tr2rad   = 2π           # Revolution (tour)     -> radian
const deg2rad  = π/180        # degree                -> radian
const hp2w     = 745.7        # imperial horsepower   -> watt

end  # module Constants
