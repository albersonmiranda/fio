# Import IOM data

Import data from a input-output matrix (IOM) from Excel format.

## Usage

``` r
import_element(file, sheet, range, col_names = FALSE, row_names = FALSE)
```

## Arguments

- file:

  Path to the Excel file.

- sheet:

  Name of the sheet in the Excel file.

- range:

  Range of cells in the Excel file.

- col_names:

  Range of cells with column names.

- row_names:

  Range of cells with row names.

## Value

A (`matrix`).

## Examples

``` r
if (isNamespaceLoaded("fiodata")) {
 # Excel file with IOM data
 path_to_xlsx <- system.file("extdata", "/2020.xlsx", package = "fiodata")
 # Import IOM data
 intermediate_transactions <- import_element(
   file = path_to_xlsx,
   sheet = "iom",
   range = "D6:BB56",
   col_names = "D4:BB4",
   row_names = "B6:B56"
 )
 # Show the first 6 rows and 6 columns
 intermediate_transactions[1:6, 1:6]
}
#>                                    Agriculture, forestry, and logging
#> Agriculture, forestry, and logging                        15729.02613
#> Livestock and fishing                                      1642.35645
#> Oil and natural gas                                          70.89870
#> Iron ore                                                      1.21006
#> Other extractive industry                                   180.24666
#> Food and beverages                                         2497.73033
#>                                    Livestock and fishing Oil and natural gas
#> Agriculture, forestry, and logging          1.061966e+04            10.34312
#> Livestock and fishing                       9.535874e+03            21.79848
#> Oil and natural gas                         8.020926e+01          7047.29897
#> Iron ore                                    9.055116e-01            47.32121
#> Other extractive industry                   5.160716e+02           763.78770
#> Food and beverages                          2.195603e+04           602.43626
#>                                      Iron ore Other extractive industry
#> Agriculture, forestry, and logging   19.44415                  4.343077
#> Livestock and fishing                33.71232                  6.937231
#> Oil and natural gas                 344.44456                 43.813661
#> Iron ore                           3821.34527                101.653985
#> Other extractive industry            19.24599               1896.366168
#> Food and beverages                  145.23811                256.198553
#>                                    Food and beverages
#> Agriculture, forestry, and logging       157978.22476
#> Livestock and fishing                    127236.57743
#> Oil and natural gas                         627.54015
#> Iron ore                                     17.38346
#> Other extractive industry                   416.92205
#> Food and beverages                       130104.95245
```
