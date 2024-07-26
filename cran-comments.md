## Second Ressubmission

In this version I have:
 
* Rewrite `r6.R` documentation to address Konstanze's instructions.
* Refactor `$set_max_threads()` method for better parallelism control and error handling.
* Comply with CRAN's policies by building offline:
  * Pass "--offline" flag to `cargo build` to avoid online compilation.
  * Included compressed Rust dependencies in order to compile offline.
* Added `configure` and `configure.win` files with 'Cargo' installation instructions when needed but not found.

## Ressubmission

This is a resubmission. Previous submission failed due to parallelization by default.
In this version I have:
 
* Added "-j 2" flag to `cargo build` to avoid parallelism during building (`makevars` and `makevars.win`).
* Added `$set_max_threads()` method to provide parallelism control to the user.
* Added tests.

## R CMD check results

0 errors | 0 warnings | 2 notes

* Check on Ubuntu
  - Installed size is 9.3Mb: Rust code and dependencies are compiled and statically linked into the shared library `fio.so`.
  - Build on Ubuntu 24.04 raises non-portable flag due to `-mno-omit-leaf-frame-pointer` which is [set by default in 24.04](https://ubuntu.com/blog/ubuntu-performance-engineering-with-frame-pointers-by-default).
