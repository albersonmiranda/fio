
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {fio}

<div style="text-align: justify">

Friendly & Fast Input-Output Analysis
<img src="man/figures/leontief.jpg" align="right" width="240px" style="margin-left: 20px;" />

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/fio)](https://CRAN.R-project.org/package=fio)
[![R-universe](https://albersonmiranda.r-universe.dev/badges/fio)](https://albersonmiranda.r-universe.dev/fio)
[![R-CMD-check](https://github.com/albersonmiranda/fio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/albersonmiranda/fio/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/albersonmiranda/fio/branch/main/graph/badge.svg)](https://app.codecov.io/gh/albersonmiranda/fio?branch=main)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/fio)](https://CRAN.R-project.org/package=fio)
[![DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/albersonmiranda/fio)
[![extendr](https://img.shields.io/badge/extendr-%5E0.8.1-276DC2)](https://extendr.rs/extendr/extendr_api/)
<!-- badges: end -->

`{fio}` (*Friendly Input-Output*) is a R package designed for economic
input-output analysis that combines user-friendly interfaces with
high-performance computation. It provides tools for analyzing both
single-region and multi-regional economic systems through a hybrid
architecture that pairs R’s accessibility with
[Rust’s](https://rust-lang.org/) computational efficiency.

The package is optimized for speed and efficiency. It leverages the [R6
class](https://r6.r-lib.org/) for clean, memory-efficient
object-oriented programming. Furthermore, all linear algebra
computations are implemented using
[faer](https://docs.rs/faer/latest/faer/) Rust crate to achieve highly
optimized performance.

## Input-Output Analysis?

Input-output analysis is a quantitative economic technique that examines
inter-industry relationships within an economy. Developed by the
Russian-American economist Wassily Leontief, it models how the output of
one industry serves as input to other industries, allowing analysts to
trace the ripple effects of changes in production, demand, or policy
throughout an economic system.

The fio package implements input-output analysis using two computational
paradigms:

- Demand-side (Leontief) model: Traces how changes in final demand
  propagate backward through supply chains, calculating the total
  production required across all sectors to satisfy a given level of
  final demand.
- Supply-side (Ghosh) model: Traces how changes in primary inputs
  propagate forward through production chains, analyzing how changes in
  value-added components affect sectoral outputs.

Both approaches rely on matrix algebra operations implemented in Rust
for computational efficiency, with R6 classes providing the R
user-facing interface.

## Features

{fio} is able to:

- Single-region capabilities:
  - Compute core matrices (technical and allocation coefficients,
    Leontief and Ghoshian inverses)
  - Multipliers (output, employment, wages, taxes)
  - Structural Analysis (key sectors, field of influence, hypothetical
    extraction)
  - Model closure (household and government)
- Multi-region inherits all single-region capabilities and adds:
  - Bilateral trade
  - Multi-regional multipliers
  - Spillover matrices
  - Regional interdependence
  - Country extraction for single-region analysis from multi-region data

{fio} also includes an utility function to download input-output data
from University of Groningen’s [World Input-Output Database
(WIOD)](https://www.rug.nl/ggdc/valuechain/wiod/?lang=en). Furthermore,
it counts with a companion data package
[{fiodata}](https://github.com/albersonmiranda/fiodata) that includes
two real world datasets — `br_2020` for single-region and `world_2000`
for multi-region analysis — in raw format (.xlsx) and R-ready (.rda) for
analysis and experimenting with {fio}.

## Installation

### CRAN Release

You can install the latest release of {fio} from CRAN with:

``` r
install.packages("fio")
```

### Development version

You can install the precompiled binaries from Github’s `main` branch
from R-Universe:

``` r
install.packages("fio", repos = c("https://albersonmiranda.r-universe.dev", "https://cloud.r-project.org"))
```

For bleeding edge development branches, other than `main`, compiling
from source requires [Rust](https://rust-lang.org/) to be installed on
your system. You can install Rust from your OS package manager or,
preferably, from [official
installer](https://rust-lang.org/tools/install/). Then:

``` r
remotes::install_github("albersonmiranda/fio", ref = "branch-name")
```

## Getting Started

If you are just getting started with `{fio}`, we recommend you to read
the
[vignettes](https://albersonmiranda.github.io/fio/articles/index.html)
for a comprehensive overview of the package.

## Single-region input-output analysis

``` r
# load included dataset
iom_br <- fiodata::br_2020

# compute technical coefficients matrix
iom_br$compute_tech_coeff()

# compute Leontief's inverse
iom_br$compute_leontief_inverse()

# key sectors
iom_br$compute_key_sectors()
iom_br$key_sectors |> head()
#>                               sector power_dispersion sensitivity_dispersion
#> 1 Agriculture, forestry, and logging        0.8682901              1.5528270
#> 2              Livestock and fishing        0.9667243              0.7724195
#> 3                Oil and natural gas        1.0229545              1.1077440
#> 4                           Iron ore        0.8988597              0.8340117
#> 5          Other extractive industry        1.0470158              0.7947658
#> 6                 Food and beverages        1.2759523              1.2776693
#>   power_dispersion_cv sensitivity_dispersion_cv             key_sectors
#> 1            5.134611                  2.449116  Strong Forward Linkage
#> 2            4.173404                  5.193911          Non-Key Sector
#> 3            3.960120                  3.513779              Key Sector
#> 4            4.423694                  4.636574          Non-Key Sector
#> 5            3.761186                  4.933658 Strong Backward Linkage
#> 6            3.519630                  3.474199              Key Sector

# hypothetical extraction
iom_br$compute_allocation_coeff()
iom_br$compute_hypothetical_extraction()
iom_br$hypothetical_extraction |> head()
#>                                    backward_absolute backward_relative
#> Agriculture, forestry, and logging        -358764.14      -0.026962180
#> Livestock and fishing                     -172937.80      -0.012996785
#> Oil and natural gas                       -214364.61      -0.016110131
#> Iron ore                                  -106984.50      -0.008040200
#> Other extractive industry                  -44124.08      -0.003316055
#> Food and beverages                       -1150341.99      -0.086451585
#>                                    forward_absolute forward_relative
#> Agriculture, forestry, and logging       -398083.76     -0.029917166
#> Livestock and fishing                    -202488.89     -0.015217636
#> Oil and natural gas                      -319722.18     -0.024028063
#> Iron ore                                  -96680.46     -0.007265821
#> Other extractive industry                 -70594.98     -0.005305421
#> Food and beverages                       -357953.32     -0.026901245
#>                                    total_absolute total_relative
#> Agriculture, forestry, and logging      -756847.9   -0.056879346
#> Livestock and fishing                   -375426.7   -0.028214420
#> Oil and natural gas                     -534086.8   -0.040138194
#> Iron ore                                -203665.0   -0.015306021
#> Other extractive industry               -114719.1   -0.008621475
#> Food and beverages                     -1508295.3   -0.113352829

# field of influence
iom_br$compute_field_influence(epsilon = 0.001)
iom_br$field_influence[1:5, 1:5]
#>                                    Agriculture, forestry, and logging
#> Agriculture, forestry, and logging                           1.687863
#> Livestock and fishing                                        1.800221
#> Oil and natural gas                                          1.774443
#> Iron ore                                                     1.669759
#> Other extractive industry                                    1.762653
#>                                    Livestock and fishing Oil and natural gas
#> Agriculture, forestry, and logging              1.282227            1.357990
#> Livestock and fishing                           1.372254            1.450645
#> Oil and natural gas                             1.349964            1.432484
#> Iron ore                                        1.270325            1.345621
#> Other extractive industry                       1.340999            1.420446
#>                                    Iron ore Other extractive industry
#> Agriculture, forestry, and logging 1.253284                  1.233775
#> Livestock and fishing              1.338806                  1.317962
#> Oil and natural gas                1.319714                  1.299181
#> Iron ore                           1.244176                  1.222513
#> Other extractive industry          1.310923                  1.293003

# closed model
iom_br$close_model("household")
iom_br$compute_tech_coeff()
iom_br$compute_leontief_inverse()
iom_br$compute_key_sectors()
iom_br$key_sectors |> tail() # household consumption is a key sector!
#>                                            sector power_dispersion
#> 47 Services provided to families and associations         1.734435
#> 48                              Domestic services         5.588961
#> 49                               Public education         4.622521
#> 50                                  Public health         3.305240
#> 51      Public administration and social security         3.454131
#> 52                                      Household         6.361264
#>    sensitivity_dispersion power_dispersion_cv sensitivity_dispersion_cv
#> 47             0.63892457           -3.322009                -9.4001887
#> 48            -0.09106979           -1.116853               144.2065445
#> 49            -0.75064844           -1.395006                14.7113147
#> 50            -0.74714756           -1.907591                11.2344617
#> 51            -0.59207449           -1.793077                14.3456558
#> 52            46.33444701           -7.959814                -0.2588016
#>                key_sectors
#> 47 Strong Backward Linkage
#> 48 Strong Backward Linkage
#> 49 Strong Backward Linkage
#> 50 Strong Backward Linkage
#> 51 Strong Backward Linkage
#> 52              Key Sector
```

## Multi-region input-output analysis

Calculate multi-regional multipliers and interdependence from the 2000
World Input-Output Database (26 countries, 23 sectors):

``` r
# load included dataset
miom_world <- fiodata::world_2000

# get bilateral trade (from -> to)
miom_world$get_bilateral_trade("BRA", "CHN")[1:5, 1:2]
#>                                                BRA_Agriculture, Hunting, Forestry and Fishing
#> CHN_Agriculture, Hunting, Forestry and Fishing                                    0.868486382
#> CHN_Mining and Quarrying                                                          0.677175460
#> CHN_Food, Beverages and Tobacco                                                   0.784219678
#> CHN_Textiles, leather and footwear                                                0.137408834
#> CHN_Pulp, paper, printing and publishing                                          0.003052195
#>                                                BRA_Mining and Quarrying
#> CHN_Agriculture, Hunting, Forestry and Fishing              0.001110208
#> CHN_Mining and Quarrying                                    1.703217354
#> CHN_Food, Beverages and Tobacco                             0.005707213
#> CHN_Textiles, leather and footwear                          0.129627291
#> CHN_Pulp, paper, printing and publishing                    0.015560710

# compute multi-regional multipliers
miom_world$compute_multiregional_multipliers()

# show multipliers for specific country-sector pairs
# example: Chemicals from Brazil to China and US
bra_chemicals_index <- which(grepl("BRA.*Chemicals", miom_world$multiregional_multipliers$destination_label))[1]
bra_chemicals <- miom_world$multiregional_multipliers[bra_chemicals_index, ]

# Show key multiplier components
multiplier_cols <- c("destination_label", "intra_regional_multiplier", "spillover_multiplier", "total_multiplier", "multiplier_to_CHN", "multiplier_to_USA")
available_cols <- intersect(multiplier_cols, names(bra_chemicals))
bra_chemicals[, available_cols]
#>                       destination_label intra_regional_multiplier
#> 76 BRA_Chemicals and chemicals products                  2.165192
#>    spillover_multiplier total_multiplier multiplier_to_CHN multiplier_to_USA
#> 76            0.3714218         2.536614        0.01258698        0.08826115

# get regional interdependence
miom_world$get_regional_interdependence() |> head()
#>   country self_reliance total_spillover_out total_spillover_in
#> 1     AUS      1.968515           0.3168527        0.006511634
#> 2     AUT      1.614535           0.4900724        0.004048698
#> 3     BEL      1.649908           0.7652207        0.011148228
#> 4     BRA      1.918948           0.2328115        0.004065824
#> 5     CAN      1.650380           0.4280919        0.007634451
#> 6     CHN      2.342241           0.2867934        0.016735715
#>   interdependence_index
#> 1             0.1609602
#> 2             0.3035377
#> 3             0.4637960
#> 4             0.1213225
#> 5             0.2593898
#> 6             0.1224440

# get country summary
miom_world$get_country_summary() |> head()
#>   country multiplier_simple_mean multiplier_simple_sum multiplier_simple_sd
#> 1     AUS               2.285368              52.56346            0.2943434
#> 2     AUT               2.104608              48.40598            0.2595025
#> 3     BEL               2.415129              55.54796            0.3495773
#> 4     BRA               2.151760              49.49047            0.4011159
#> 5     CAN               2.078472              47.80486            0.3334081
#> 6     CHN               2.629034              60.46779            0.4657446
#>   multiplier_direct_mean multiplier_direct_sum multiplier_direct_sd
#> 1              0.5910851              13.59496            0.1243854
#> 2              0.5424757              12.47694            0.1079106
#> 3              0.6272375              14.42646            0.1371100
#> 4              0.5551566              12.76860            0.1760325
#> 5              0.5436337              12.50358            0.1541054
#> 6              0.6247874              14.37011            0.1544596
#>   multiplier_indirect_mean multiplier_indirect_sum multiplier_indirect_sd
#> 1                 1.694283                38.96850              0.1750524
#> 2                 1.562132                35.92904              0.1570810
#> 3                 1.787891                41.12149              0.2174743
#> 4                 1.596603                36.72187              0.2283837
#> 5                 1.534839                35.30129              0.1888710
#> 6                 2.004247                46.09768              0.3222542
```

## Related tools

Other great tools for input-output analysis in R include:

- [{leontief}](https://pachamaltese.github.io/leontief/)
- [{ioanalysis}](https://cran.r-project.org/package=ioanalysis)

</div>
