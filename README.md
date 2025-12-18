
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
<!-- badges: end -->

`{fio}` (*Friendly Input-Output*) is a R package designed for
input-output analysis, emphasizing usability for Excel users and
performance. It includes an [RStudio
Addin](https://rstudio.github.io/rstudioaddins/) and a suite of
functions for straightforward import of input-output tables from Excel,
either programmatically or directly from the clipboard.

The package is optimized for speed and efficiency. It leverages the [R6
class](https://r6.r-lib.org/) for clean, memory-efficient
object-oriented programming. Furthermore, all linear algebra
computations are implemented in [Rust](https://www.rust-lang.org/) to
achieve highly optimized performance.

## Installation

### CRAN Release

You can install the latest release of {fio} from CRAN with:

``` r
install.packages("fio")
```

### R-universe version

You can install the latest version from the [main
branch](https://github.com/albersonmiranda/fio/tree/main), using the
precompiled binaries available on
[R-universe](https://albersonmiranda.r-universe.dev/fio):

``` r
install.packages("fio", repos = c("https://albersonmiranda.r-universe.dev", "https://cloud.r-project.org"))
```

### Development version

For the cutting-edge development branches from Github (other than the
main branch), you’ll need to compile it from source. This requires
[Rust](https://www.rust-lang.org/) to be installed on your system. You
can install Rust using the following commands:

- Debian/Ubuntu: `sudo apt install cargo`
- Fedora/CentOS: `sudo dnf install cargo`
- macOS: `brew install rust`
- Windows: <https://www.rust-lang.org/tools/install>

## Getting Started

If you are just getting started with `{fio}`, we recommend you to read
the
[vignettes](https://albersonmiranda.github.io/fio/articles/index.html)
for a comprehensive overview of the package.

## Single-region input-output analysis

Calculate Leontief’s inverse from brazilian 2020 input-output matrix:

``` r
# load included dataset
iom_br <- fio::br_2020

# calculate technical coefficients matrix
iom_br$compute_tech_coeff()

# calculate Leontief's inverse
iom_br$compute_leontief_inverse()
```

And pronto! 🎉, you’re all good to carry on with your analysis. You can
evoke the Data Viewer to inspect the results with
`iom_br$technical_coefficients_matrix |> View()` and
`iom_br$leontief_inverse_matrix |> View()`.

![](man/figures/example_leontief_inverse.png) *<small>Leontief’s inverse
from brazilian 2020 input-output matrix</small>*

## Multi-region input-output analysis

Calculate multi-regional multipliers and interdependence from the 2000
World Input-Output Database (26 countries, 23 sectors):

``` r
# load included dataset
miom_world <- fio::world_2000

# calculate multi-regional multipliers
miom_world$compute_multiregional_multipliers()

# get regional interdependence
miom_world$get_regional_interdependence()
#>    country self_reliance total_spillover_out total_spillover_in
#> 1      AUS      1.968515           0.3168527       0.0065116342
#> 2      AUT      1.614535           0.4900724       0.0040486980
#> 3      BEL      1.649908           0.7652207       0.0111482277
#> 4      BRA      1.918948           0.2328115       0.0040658244
#> 5      CAN      1.650380           0.4280919       0.0076344511
#> 6      CHN      2.342241           0.2867934       0.0167357151
#> 7      DEU      1.750123           0.4072660       0.0461095519
#> 8      DNK      1.588219           0.5336860       0.0045789821
#> 9      ESP      1.872652           0.4035966       0.0127873685
#> 10     FIN      1.814946           0.4446499       0.0051829261
#> 11     FRA      1.870104           0.3975701       0.0258689073
#> 12     GBR      1.880823           0.3553086       0.0323988530
#> 13     GRC      1.450459           0.4766389       0.0008403844
#> 14     HKG      1.456702           1.0297257       0.0050721423
#> 15     IND      1.930336           0.2933663       0.0030570998
#> 16     IRL      1.473624           0.7271773       0.0035162918
#> 17     ITA      1.975659           0.3413902       0.0210409652
#> 18     JPN      1.928339           0.1351515       0.0269893283
#> 19     KOR      1.988313           0.4362860       0.0102672586
#> 20     MEX      1.562506           0.3542938       0.0025632750
#> 21     NDL      1.579268           0.6539386       0.0170240366
#> 22     PRT      1.813322           0.5236525       0.0017732553
#> 23     SWE      1.725532           0.5043674       0.0103124186
#> 24     TWN      1.676048           0.5120606       0.0073320388
#> 25     USA      1.878020           0.1923963       0.0655620433
#> 26     ROW      1.756742           0.4076203       0.0956546757
#>    interdependence_index
#> 1             0.16096024
#> 2             0.30353773
#> 3             0.46379603
#> 4             0.12132247
#> 5             0.25938982
#> 6             0.12244405
#> 7             0.23270710
#> 8             0.33602791
#> 9             0.21552141
#> 10            0.24499350
#> 11            0.21259247
#> 12            0.18891127
#> 13            0.32861241
#> 14            0.70688863
#> 15            0.15197676
#> 16            0.49346193
#> 17            0.17279815
#> 18            0.07008703
#> 19            0.21942515
#> 20            0.22674721
#> 21            0.41407711
#> 22            0.28878074
#> 23            0.29229676
#> 24            0.30551677
#> 25            0.10244637
#> 26            0.23203195

# get country summary
miom_world$get_country_summary()
#>    country multiplier_simple_mean multiplier_simple_sum multiplier_simple_sd
#> 1      AUS               2.285368              52.56346            0.2943434
#> 2      AUT               2.104608              48.40598            0.2595025
#> 3      BEL               2.415129              55.54796            0.3495773
#> 4      BRA               2.151760              49.49047            0.4011159
#> 5      CAN               2.078472              47.80486            0.3334081
#> 6      CHN               2.629034              60.46779            0.4657446
#> 7      DEU               2.157389              49.61994            0.2843985
#> 8      DNK               2.121905              48.80382            0.3295126
#> 9      ESP               2.276249              52.35372            0.3673208
#> 10     FIN               2.259596              51.97070            0.3496083
#> 11     FRA               2.267674              52.15651            0.3314330
#> 12     GBR               2.236131              51.43102            0.2534105
#> 13     GRC               1.927098              44.32326            0.3743875
#> 14     HKG               2.486427              57.18783            0.6228530
#> 15     IND               2.223703              51.14516            0.5532397
#> 16     IRL               2.200801              50.61843            0.2742686
#> 17     ITA               2.317049              53.29214            0.3875865
#> 18     JPN               2.063490              47.46027            0.3292166
#> 19     KOR               2.424599              55.76579            0.4950520
#> 20     MEX               1.916799              44.08638            0.4216234
#> 21     NDL               2.233206              51.36375            0.3128269
#> 22     PRT               2.336974              53.75041            0.3771554
#> 23     ROW               2.164363              49.78034            0.3800173
#> 24     SWE               2.229899              51.28768            0.3076712
#> 25     TWN               2.188108              50.32649            0.4428694
#> 26     USA               2.070416              47.61957            0.2678378
#>    multiplier_direct_mean multiplier_direct_sum multiplier_direct_sd
#> 1               0.5910851              13.59496            0.1243854
#> 2               0.5424757              12.47694            0.1079106
#> 3               0.6272375              14.42646            0.1371100
#> 4               0.5551566              12.76860            0.1760325
#> 5               0.5436337              12.50358            0.1541054
#> 6               0.6247874              14.37011            0.1544596
#> 7               0.5735571              13.19181            0.1257155
#> 8               0.5483842              12.61284            0.1627911
#> 9               0.5818832              13.38331            0.1514225
#> 10              0.5861276              13.48093            0.1504276
#> 11              0.6003713              13.80854            0.1365743
#> 12              0.5768597              13.26777            0.1178258
#> 13              0.4795222              11.02901            0.1730478
#> 14              0.6955571              15.99781            0.2574222
#> 15              0.5776381              13.28568            0.2488502
#> 16              0.5622517              12.93179            0.1102378
#> 17              0.5974856              13.74217            0.1545091
#> 18              0.5343955              12.29110            0.1212272
#> 19              0.5993085              13.78410            0.1704651
#> 20              0.4865362              11.19033            0.2019697
#> 21              0.5973635              13.73936            0.1482268
#> 22              0.6045684              13.90507            0.1527213
#> 23              0.5388760              12.39415            0.1530084
#> 24              0.5772032              13.27567            0.1396862
#> 25              0.5741787              13.20611            0.1716934
#> 26              0.5416578              12.45813            0.1136737
#>    multiplier_indirect_mean multiplier_indirect_sum multiplier_indirect_sd
#> 1                  1.694283                38.96850              0.1750524
#> 2                  1.562132                35.92904              0.1570810
#> 3                  1.787891                41.12149              0.2174743
#> 4                  1.596603                36.72187              0.2283837
#> 5                  1.534839                35.30129              0.1888710
#> 6                  2.004247                46.09768              0.3222542
#> 7                  1.583832                36.42813              0.1655095
#> 8                  1.573521                36.19098              0.1887727
#> 9                  1.694365                38.97040              0.2259730
#> 10                 1.673468                38.48977              0.2052737
#> 11                 1.667303                38.34797              0.2014659
#> 12                 1.659271                38.16324              0.1512847
#> 13                 1.447576                33.29425              0.2108174
#> 14                 1.790870                41.19001              0.3712546
#> 15                 1.646065                37.85949              0.3214000
#> 16                 1.638549                37.68664              0.1695499
#> 17                 1.719564                39.54997              0.2418168
#> 18                 1.529095                35.16918              0.2148490
#> 19                 1.825291                41.98169              0.3412776
#> 20                 1.430263                32.89605              0.2357968
#> 21                 1.635843                37.62439              0.1784893
#> 22                 1.732406                39.84534              0.2372139
#> 23                 1.625487                37.38619              0.2330413
#> 24                 1.652696                38.01201              0.1776820
#> 25                 1.613930                37.12038              0.2780501
#> 26                 1.528758                35.16144              0.1606822
```

## Related tools

Other great tools for input-output analysis in R include:

- [{leontief}](https://pachamaltese.github.io/leontief/)
- [{ioanalysis}](https://cran.r-project.org/package=ioanalysis)

</div>
