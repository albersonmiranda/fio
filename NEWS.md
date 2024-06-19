# fio 0.0.0.9001

## Development version
* New `import_element()` to programmatically import data from an Excel file
* New data import addin makes easy to import data from clipboard or an Excel file
* New `iom` uses the efficiency of R6 classes to store data reducing memory footprint
* New `add` and `remove` methods to add and remove elements from an `iom` object
* New `br_2020` dataset with a 51 sector Brazilian input-output table for 2020
* New `compute_tech_coeff()` and `compute_leontief_inverse()` methods uses the power of Rust and `faer` crate to substantially increase performance
* New `compute_multiplier_*()` methods to compute multipliers from a given input-output table:
  * `compute_multiplier_output()` for the output multiplier
* New `compute_influence_field()` method to compute the field of influence of each sector
* New `compute_key_sectors()` method to compute the key sectors of an input-output table, based on power of dispersion and sensitivity of dispersion, and their coefficients of variations
* New `compute_allocation_coeff()` method to compute the allocation coefficients of an input-output table
* New `compute_ghosh_inverse()` method to compute the Ghosh inverse of an input-output table
