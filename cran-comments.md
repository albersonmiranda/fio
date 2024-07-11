## Ressubmission

This is a resubmission. In this version I have:

* Previous submission failed due to parallelization by default
* Added `$set_max_threads()` method to provide control to the user.
* Set `$max_threads(1)` for examples, tests and vignettes.
* Added tests.

## R CMD check results

0 errors | 0 warnings | 2 notes

* Check on Ubuntu
  - Installed size is 9.3Mb: Rust code and dependencies are compiled and statically linked into the shared library `fio.so`.
  - Build on Ubuntu 24.04 raises non-portable flag due to `-mno-omit-leaf-frame-pointer` which is [set by default in 24.04](https://ubuntu.com/blog/ubuntu-performance-engineering-with-frame-pointers-by-default).
