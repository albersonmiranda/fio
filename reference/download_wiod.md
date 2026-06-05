# Download WIOD tables

Downloads World Input-Output Database tables.

## Usage

``` r
download_wiod(year = "2016", out_dir = tempdir())
```

## Arguments

- year:

  (`string`)  
  Release year from WIOD. One of "2016", "2013" or "long-run". Defaults
  to "2016".

- out_dir:

  (`string`)  
  Path to download. Defaults to
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html).

## Value

Invisibly returns the path to the downloaded file.

## Details

Multi-region input-output tables from the World Input-Output Database
(WIOD) from University of Groningen, Netherlands.

## Examples

``` r
if (FALSE) { # \dontrun{
fio::download_wiod("2016")
} # }
```
