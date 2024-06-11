
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {fio}

<div style="text-align: justify">

Friendly & Fast Input-Output Analysis
<img src="man/figures/leontief.jpg" align="right" width="240px" style="margin-left: 20px;" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/albersonmiranda/fio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/albersonmiranda/fio/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Outline

`{fio}` (*Friendly Input-Output*) is a R package for input-output
analysis, focusing on two key aspects: ease of use for Excel users and
performance. It provides an [RStudio
Addin](https://rstudio.github.io/rstudioaddins/) and a set of functions
for easy import of input-output tables from Excel, either
programmatically or direclty from clipboard.

The package is designed to be fast and efficient. It embraces [R6
class](https://r6.r-lib.org/) for a clean, memory-efficient
object-oriented programming. Additionally, all linear algebra
computations are written in [Rust](https://www.rust-lang.org/) for
highly optimized performance.

## Installation

Install the lastest development version from **Github**:

``` r
devtools::install_github("albersonmiranda/fio")
```

## Getting Started

If you are just getting started with `{fio}`, we recommend you to read
the
[vignettes](https://albersonmiranda.github.io/fio/articles/index.html)
for a comprehensive overview of the package.

## Examples

Calculate Leontief’s inverse from brazilian 2020 input-output matrix:

``` r
# load included dataset
iom_br <- fio::br_2020

# calculate technical coefficients matrix
iom_br$compute_tech_coeff()

# calculate Leontief's inverse
iom_br$compute_leontief_inverse()
```

And pronto\! 🎉, you’re all good to carry on with your analysis. You can
evoke the Data Viewer to inspect the results with
`iom_br$technical_coefficients_matrix |> View()` and
`iom_br$leontief_inverse_matrix |> View()`.

![](man/figures/example_leontief_inverse.png) *<small>Leontief’s inverse
from brazilian 2020 input-output matrix</small>*

</div>