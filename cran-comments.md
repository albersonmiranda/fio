## 2nd RESSUBMISSION

In this version I have:

* Added $(SHLIB) to rust_clean in makevars(.win).in to avoid race conditions with parallel make.
* Bump minimal Rust version to 1.77 due to faer crate dependency.

## RESUBMISSION

This is a resubmission. In this version I have:

* Removed invalid URLs.

## CRAN REMOVAL WARNING (R-devel 4.5)

* This release addresses CRAN Team e-mail from 2025-03-24 and fixes WARNING about calling bad entry points in the "compiled code" check.

## R CMD check results

0 errors | 0 warnings | 2 notes

* NOTE:
  - installed size is 6.7Mb due to vendored Rust dependencies as per CRAN policy.
  - Found the following CITATION file in a non-standard place: src/vendor/faer/CITATION.cff. That's a CITATION of a Rust dependency, not the citation of this package itself.

* CI tests include:
  - macOS 13, 14 and 15; R release, devel and oldrel-1.
  - Windows Server 2019 and 2022; R release, devel and oldrel-1.
  - Ubuntu 22.04 and 24.04; R release, devel and oldrel-1.
  - Fedora 36; R 4.2 built from source. `cargo` and other dependencies installed from Fedora 36 default repository (`dnf install`).
  - Fedora 39, 40 and 41; R and all dependencies installed from default repository (`dnf install`).
