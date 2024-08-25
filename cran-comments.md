## R CMD check results

0 errors | 0 warnings | 1 notes

* NOTE:
  - installed size is 8.2Mb due to vendored Rust dependencies as per CRAN policy.

* CI tests include:
  - macOS 12, 13 and 14; R release, devel and oldrel-1.
  - Windows Server 2019, 2022; R release, devel and oldrel-1.
  - Ubuntu 20.04, 22.04, 24.04; R release, devel and oldrel-1.
  - Fedora 36; R 4.2 built from source. `cargo` and other dependencies installed from Fedora 36 default repository (`dnf install`).
  - Fedora 37, 38, 39, 40; R and all dependencies installed from default repository (`dnf install`).
* All tests passed successfully, except macOS 13 (R-devel). Transitive dependency `fs` could not be installed due to a compilation error. The error is not related to `fio`. The error is being tracked in the following issue: [Compilation fail macOS 13 (R 4.5)](https://github.com/r-lib/fs/issues/467)

## Resubmission

This is a resubmission. In this version I have:

* Fixed empty URL in README.md.

## CRAN requests

In this version I have addressed CRAN requests (e-mail received in 2024-08-23):

* Update messages in `msrv.R`:
  - Now, when `rustc` or `cargo` are not found, besides giving the user install instructions, also prints minimum version required.
* Update error handling in `msrv.R`:
  - Problem: System checks wasn't correctly handling errors when Rust and Cargo were not found. The `tryCatch()` bit were using the `warning` argument instead of the `error` argument. Since `Command not found` is an error, it have been ignored by the `warning` arg.
  - Fix: Update `msrv.R` script to use the `error` arg instead of `warning` in `tryCatch()`. This ensures that appropriate error messages are displayed when the `cargo` or `rustc` installations are not found.
  - Evidence: Evidence of the fix can be found in the following CI run:
    - [GitHub Actions - Rust-check](https://github.com/albersonmiranda/fio/actions/runs/10536150893)
    - Job `no-install` for evidence that build fails when `cargo` and `rustc` are not found and install instructions are displayed along with the minimum version required.
    - Job `msrv-lower` for evidence that build fails when `cargo` and `rustc` are found but the minimum version required is not met and an error message is displayed containing both installed and required Rust versions.
