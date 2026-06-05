# R6 class for multi-regional input-output matrix

R6 class for multi-regional input-output matrix (MRIO). This class
inherits from the `iom` class and extends its functionality to handle
multi-regional input-output tables such as the World Input-Output
Database (WIOD) and EXIOBASE tables.

## Value

A new instance of the `miom` class.

## Super class

[`iom`](https://albersonmiranda.github.io/fio/reference/iom.md) -\>
`miom`

## Public fields

- `countries`:

  (`character`)  
  Vector of region names.

- `sectors`:

  (`character`)  
  Vector of sector names.

- `n_countries`:

  (`integer`)  
  Number of regions in the matrix.

- `n_sectors`:

  (`integer`)  
  Number of sectors per country.

- `bilateral_trade`:

  (`list`)  
  Bilateral trade flows between regions by sector.

- `domestic_intermediate_transactions`:

  (`list`)  
  List of domestic intermediate transaction matrices by region.

- `international_intermediate_transactions`:

  (`list`)  
  List of international intermediate transaction matrices between
  regions.

- `multiregional_multipliers`:

  (`data.frame`)  
  Multi-regional output multipliers including intra-regional,
  inter-regional, and spillover effects.

## Methods

### Public methods

- [`miom$new()`](#method-miom-initialize)

- [`miom$extract_country()`](#method-miom-extract_country)

- [`miom$get_bilateral_trade()`](#method-miom-get_bilateral_trade)

- [`miom$get_country_summary()`](#method-miom-get_country_summary)

- [`miom$compute_multiplier_output()`](#method-miom-compute_multiplier_output)

- [`miom$compute_key_sectors()`](#method-miom-compute_key_sectors)

- [`miom$compute_multiregional_multipliers()`](#method-miom-compute_multiregional_multipliers)

- [`miom$get_spillover_matrix()`](#method-miom-get_spillover_matrix)

- [`miom$get_net_spillover_matrix()`](#method-miom-get_net_spillover_matrix)

- [`miom$get_regional_interdependence()`](#method-miom-get_regional_interdependence)

- [`miom$clone()`](#method-miom-clone)

Inherited methods

- [`iom$add()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-add)
- [`iom$close_model()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-close_model)
- [`iom$compute_allocation_coeff()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_allocation_coeff)
- [`iom$compute_field_influence()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_field_influence)
- [`iom$compute_ghosh_inverse()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_ghosh_inverse)
- [`iom$compute_hypothetical_extraction()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_hypothetical_extraction)
- [`iom$compute_leontief_inverse()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_leontief_inverse)
- [`iom$compute_multiplier_employment()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_multiplier_employment)
- [`iom$compute_multiplier_taxes()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_multiplier_taxes)
- [`iom$compute_multiplier_wages()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_multiplier_wages)
- [`iom$compute_tech_coeff()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-compute_tech_coeff)
- [`iom$remove()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-remove)
- [`iom$set_max_threads()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-set_max_threads)
- [`iom$update_final_demand_matrix()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-update_final_demand_matrix)
- [`iom$update_value_added_matrix()`](https://albersonmiranda.github.io/fio/reference/iom.html#method-update_value_added_matrix)

------------------------------------------------------------------------

### `miom$new()`

Creates a new instance of this
[R6](https://r6.r-lib.org/reference/R6Class.html) class.

#### Usage

    miom$new(
      id,
      intermediate_transactions,
      total_production,
      countries,
      sectors,
      household_consumption = NULL,
      government_consumption = NULL,
      exports = NULL,
      final_demand_others = NULL,
      imports = NULL,
      taxes = NULL,
      wages = NULL,
      operating_income = NULL,
      value_added_others = NULL,
      occupation = NULL
    )

#### Arguments

- `id`:

  (`character`)  
  Identifier for the multi-regional input-output matrix.

- `intermediate_transactions`:

  (`matrix`)  
  Multi-regional intermediate transactions matrix. Rows and columns
  should follow the structure: Country1_Sector1, Country1_Sector2, ...,
  Country2_Sector1 etc.

- `total_production`:

  (`matrix`)  
  Total production vector by country and sector.

- `countries`:

  (`character`)  
  Vector of region names in the matrix.

- `sectors`:

  (`character`)  
  Vector of sector names in the matrix.

- `household_consumption`:

  (`matrix`)  
  Household consumption vector by region and sector.

- `government_consumption`:

  (`matrix`)  
  Government consumption vector by region and sector.

- `exports`:

  (`matrix`)  
  Exports vector by region and sector.

- `final_demand_others`:

  (`matrix`)  
  Other vectors of final demand that doesn't have dedicated slots.

- `imports`:

  (`matrix`)  
  Imports vector by region and sector.

- `taxes`:

  (`matrix`)  
  Taxes vector by region and sector.

- `wages`:

  (`matrix`)  
  Wages vector by region and sector.

- `operating_income`:

  (`matrix`)  
  Operating income vector by region and sector.

- `value_added_others`:

  (`matrix`)  
  Other vectors of value-added that doesn't have dedicated slots.

- `occupation`:

  (`matrix`)  
  Occupation matrix by region and sector.

------------------------------------------------------------------------

### `miom$extract_country()`

Extract domestic input-output matrix for a specific country.

#### Usage

    miom$extract_country(country)

#### Arguments

- `country`:

  (`character`)  
  Country name/code to extract.

#### Returns

An `iom` object for the specified country.

------------------------------------------------------------------------

### `miom$get_bilateral_trade()`

Get bilateral trade flows between two countries by sector.

#### Usage

    miom$get_bilateral_trade(origin_country, destination_country)

#### Arguments

- `origin_country`:

  (`character`)  
  Origin country name/code.

- `destination_country`:

  (`character`)  
  Destination country name/code.

#### Returns

A matrix of trade flows by sector from origin to destination.

------------------------------------------------------------------------

### `miom$get_country_summary()`

Get summary statistics by country for multipliers.

#### Usage

    miom$get_country_summary()

#### Returns

A data.frame with summary statistics by country.

------------------------------------------------------------------------

### `miom$compute_multiplier_output()`

Override the parent compute_multiplier_output to add country/sector
information.

#### Usage

    miom$compute_multiplier_output()

#### Returns

Self (invisibly).

------------------------------------------------------------------------

### `miom$compute_key_sectors()`

Override the parent compute_key_sectors to add country/sector
information.

#### Usage

    miom$compute_key_sectors(matrix = "leontief")

#### Arguments

- `matrix`:

  (`character`)  
  Which matrix to use for forward linkage computation: "leontief" or
  "ghosh".

#### Returns

Self (invisibly).

------------------------------------------------------------------------

### `miom$compute_multiregional_multipliers()`

Compute multi-regional output multipliers following Miller & Blair
(2009), section 6.3.2–6.3.3. For a unit final-demand shock in a
country-sector (a column of the Leontief inverse), returns
intra-regional and inter-regional (spillover) output multipliers.

#### Usage

    miom$compute_multiregional_multipliers()

#### Returns

Self (invisibly).

------------------------------------------------------------------------

### `miom$get_spillover_matrix()`

Compute spillover effects matrix showing how shocks in each
region-sector affect output in all other regions. Returns off-diagonal
regional blocks of the Leontief inverse (Miller & Blair, 2009,
interregional spillover effects; section 6.3.2).

#### Usage

    miom$get_spillover_matrix()

#### Returns

A matrix of spillover effects.

------------------------------------------------------------------------

### `miom$get_net_spillover_matrix()`

Compute net spillover effects for each country pair. For countries `r`
and `s`, `net[r, s] = spillover_{s->r} - spillover_{r->s}` (block sums
from get_spillover_matrix()). A positive value means country `r`
receives more cross-regional output response from shocks in `s` than `s`
receives from shocks in `r`.

#### Usage

    miom$get_net_spillover_matrix()

#### Returns

A matrix showing net spillover effects between countries.

------------------------------------------------------------------------

### `miom$get_regional_interdependence()`

Compute regional self-reliance and cross-regional spillover measures by
country. Sector-level intra-regional multipliers follow Miller & Blair
(2009, section 6.3.2). Country spillover totals are block sums of the
spillover matrix from get_spillover_matrix(): spillover out is foreign
output induced by all unit shocks in the country; spillover in is
domestic output induced by all unit shocks abroad.

#### Usage

    miom$get_regional_interdependence()

#### Returns

A data.frame with self-reliance and spillover measures by country.

------------------------------------------------------------------------

### `miom$clone()`

The objects of this class are cloneable with this method.

#### Usage

    miom$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
# Sample multi-regional data (2 countries, 2 sectors each)
countries <- c("BRA", "CHN")
sectors <- c("Agriculture", "Manufacturing")

# Create country-sector labels
labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")

# Sample intermediate transactions matrix (4x4)
intermediate_transactions <- matrix(
  c(
    10, 5, 2, 1,
    8, 15, 3, 2,
    1, 2, 12, 4,
    2, 3, 6, 18
  ),
  nrow = 4, ncol = 4,
  dimnames = list(labels, labels)
)

# Total production vector
total_production <- matrix(c(100, 120, 80, 110),
  nrow = 1, ncol = 4,
  dimnames = list(NULL, labels)
)

# Create MIOM instance
my_miom <- miom$new(
  id = "sample_miom",
  intermediate_transactions = intermediate_transactions,
  total_production = total_production,
  countries = countries,
  sectors = sectors
)
```
