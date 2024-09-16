## R CMD check results

0 errors | 0 warnings | 1 notes

* NOTE:
  - installed size is 8.2Mb due to vendored Rust dependencies as per CRAN policy.
* `set_max_threads()` now throws an error instead of a message when it's called more than once in the session. For that reason, it's example is now enclosed with `\dontrun{}` because thread pool builder can only be initialized once per session and it's already called during tests.
* CI tests include:
  - macOS 12, 13 and 14; R release, devel and oldrel-1.
  - Windows Server 2019, 2022; R release, devel and oldrel-1.
  - Ubuntu 20.04, 22.04, 24.04; R release, devel and oldrel-1.
  - Fedora 36; R 4.2 built from source. `cargo` and other dependencies installed from Fedora 36 default repository (`dnf install`).
  - Fedora 37, 38, 39, 40; R and all dependencies installed from default repository (`dnf install`).
