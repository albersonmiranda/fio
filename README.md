
<!-- README.md is generated from README.Rmd. Please edit that file -->
<style>
figcaption {
  position: absolute;
  top: 305px;
  left: 0;
  right: 20px;
  text-align: right;
  font-size: 8px;
  font-style: italic;
  line-height: 1.5;
  color: #777;
  padding-right: 10px;
  /*adjust this to control how far it should be from egde*/
}

figure {
  position: relative;
}
</style>
# fio
<figure>
<img src="img/leontief.jpg" align="right" width="240px">
<figcaption>
1973 Economics Nobel Prize Laureate Wassily Leontief
</figcaption>
</figure>
<!-- badges: start -->

[![R-CMD-check](https://github.com/albersonmiranda/fio/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/albersonmiranda/fio/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

### Outline

{fio} (*Friendly Input-Output*) is a R package for input-output
analysis, focusing on two key aspects: ease of use for Excel users and
performance. It provides an [RStudio
Addin](https://rstudio.github.io/rstudioaddins/) and a set of functions
for easy import of input-output tables from Excel, either
programmatically or from clipboard.

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

## Usage

Import included complete brazilian 2020 input-output matrix:
