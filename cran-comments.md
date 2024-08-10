## R CMD check results

0 errors | 0 warnings | 1 notes

* NOTE:
 - installed size is 8.2Mb due to vendored Rust dependencies as per CRAN policy.

In this version I have:

* Addressed CRAN removal:
  - Update `extraction.rs`and `multipliers.rs` in order to lower MSRV from 1.71 to 1.67. That fixes previous failure, assuming CRAN lowest 'rustc' version is 1.69.0 (last release in Fedora 36 default repository).
  - Set minimum version of rustc >= 1.67.1 in `SystemRequirements`. That specific version is due to dependency `faer-entity v0.19.0`.
  - Update `configure` and `configure.win` to check `SystemRequirements` field in `DESCRIPTION` and performe a system check for both `Rust` and `Cargo` tools. If any of them is not found, build fails with a message to install them. If they are found, it checks for the minimum version of `rustc`. If it is lower than specified in `SystemRequirements`, build fails with a message stating both installed and minimum version required. Finally, if all tests pass, it prints the version of `cargo` and `rustc` found, which will be used to build the package.
  - CI tests include (all passed R CMD check):
    - macOS 12, 13 and 14; R release, devel and oldrel-1.
    - Windows Server 2019, 2022; R release, devel and oldrel-1.
    - Ubuntu 20.04, 22.04, 24.04; R release, devel and oldrel-1.
    - Fedora 36; R 4.2 built from source. `cargo` and other dependencies installed from Fedora 36 default repository.
    - Fedora 37, 38, 39, 40; R and all dependencies installed from each version default repository (`dnf install`).
