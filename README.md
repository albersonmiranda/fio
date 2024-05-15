
<!-- README.md is generated from README.Rmd. Please edit that file -->

# fio

<!-- badges: start -->
<!-- badges: end -->

A set of functions to help with input-output analysis, including
international and brazilian matrices data, and a convenient addin for
easy input.

The goal of fio is to provide a friedly interface to read in data from
input-output matrices in Microsoft Excel to R. Additionally, it provides
brazilian and international input-output matrices.

## Installation

You can install the development version of fio like so:

``` r
devtools::install_github("albersonmiranda/fio")
```

## Usage

Import complete brazilian 2020 input-output matrix:

``` r
iom = fio::iom_br_2020_51

# show 3 first row and columns from intermediate transactions matrix
iom[["Z"]][1:3, 1:3]
#>                                               Agricultura silvicultura exploração florestal
#> Agricultura silvicultura exploração florestal                                    15729.0261
#> Pecuária e pesca                                                                  1642.3564
#> Petróleo e gás natural                                                              70.8987
#>                                               Pecuária e pesca
#> Agricultura silvicultura exploração florestal      10619.66262
#> Pecuária e pesca                                    9535.87391
#> Petróleo e gás natural                                80.20926
#>                                               Petróleo e gás natural
#> Agricultura silvicultura exploração florestal               10.34312
#> Pecuária e pesca                                            21.79848
#> Petróleo e gás natural                                    7047.29897
```

Import only intermediate transactions matrix from brazilian 2020
input-output matrix:

``` r
Z = fio::import_element(
  file = "excel_file.xlsx",
  sheet = "MIP",
  range = "D6:BB56",
  col_names = "D4:BB4",
  row_names = "D4:BB4"
)
```
