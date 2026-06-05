# Conveniently import data from an Excel file

`fio_addin()` opens an [RStudio
gadget](https://shiny.rstudio.com/articles/gadgets.html) and
[addin](https://rstudio.github.io/rstudioaddins/) that allows you to say
where the data source is (either clipboard or Excel file) and import the
data into the global environment. Appears as "Import input-output data"
in the RStudio Addins menu.

## Usage

``` r
fio_addin()
```

## References

This function is based on the
[reprex](https://github.com/tidyverse/reprex) package.
