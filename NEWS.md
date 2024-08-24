# fio 0.1.2

## 🛠️ Other improvements

* Fixes system checks scripts to correctly handle errors when Rust and Cargo are not found.

# fio 0.1.1

## 🛠️ Other improvements

* Update `extraction.rs`and `multipliers.rs` in order to lower minimum supported Rust version from 1.71 to 1.67.
* Set minimum version of rustc >= 1.67.1 in `SystemRequirements`.
* Add system checks to rustc and prompt users either install, if missing, or update when version is lower than specified in `DESCRIPTION`.

# fio 0.1.0

## ✨ Enhancements

* New `import_element()` to programmatically import data from an Excel file
* New data import addin makes easy to import data from clipboard or an Excel file
* New `iom` uses the efficiency of R6 classes
* New `add` and `remove` methods to add and remove elements from an `iom` object
* New `br_2020` dataset with a 51 sector Brazilian input-output table for 2020
* New `compute_tech_coeff()` and `compute_leontief_inverse()` methods uses the power of Rust and `faer` crate to substantially increase performance
* New `compute_multiplier_*()` methods to compute multipliers from a given input-output table:
  * `compute_multiplier_output()` for the output multiplier
  * `compute_multiplier_employment()` for the employment multiplier
  * `compute_multiplier_wages()` for the wages multiplier
  * `compute_multiplier_taxes()` for the taxes multiplier
* New `compute_influence_field()` method to compute the field of influence of each sector
* New `compute_key_sectors()` method to compute the key sectors of an input-output table, based on power of dispersion and sensitivity of dispersion, and their coefficients of variations
* New `compute_allocation_coeff()` method to compute the allocation coefficients of an input-output table
* New `compute_ghosh_inverse()` method to compute the Ghosh inverse of an input-output table
* New `compute_hypothetical_extraction()` method to compute impact on demand, supply and both structures after hypothetical extraction of a sector
* New `set_max_threads()` method to allow the user to control number of threads used by {fio} (required by CRAN).

## 🚀 Performance improvements

* Use Rust instead of base R for `compute_*()` functions
* Use `faer` crate instead of `nalgebra` for faster linear algebra calculations
* Use R6 classes for a clean, object state-changes, memory-efficient object-oriented programming

## 🛠️ Other improvements

* Added assertions to check if elements imported into slots are matrices at initialization of `iom` object and at `add()` method
* Added assertions to check matrices dimensions at initialization of `iom` object and at `add()` method
* More informative warnings and errors messages with {cli} package
* Added assertions to check if number format of slots is `double` at initialization of `iom` object and at `add()` method
* Fix build configuration to comply with CRAN policies
