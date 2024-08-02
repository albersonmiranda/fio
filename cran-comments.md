## R CMD check results

0 errors | 0 warnings | 0 notes

* Addresses CRAN removal:
  - Update `extraction.rs`and `multipliers.rs` in order to lower MSRV from 1.71 to 1.67.
  - Set minimum version of rustc >= 1.67.1 in `SystemRequirements`. **NOTE** this will result in build errors on Fedora due to outdated Rust installation. That specific version is due to dependency `faer-entity v0.19.0`, which requires rustc >= 1.67.0.
  - Update `configure` and `configure.win` to check rustc version and prompt users to update when version is lower than specified in `DESCRIPTION`.
* The large tarball size is due to vendored dependencies.
