## Ressubmission

This is a resubmission. Previous submission failed due to parallelization by default.
In this version I have:
 
* Added "-j 2" flag to `cargo build` to avoid parallelization (`makevars` and `makevars.win`).
* Added `$set_max_threads()` method to provide control to the user.
* Added tests.

## R CMD check results

0 errors | 0 warnings | 2 notes

* Check on Ubuntu
  - Installed size is 9.3Mb: Rust code and dependencies are compiled and statically linked into the shared library `fio.so`.
  - Build on Ubuntu 24.04 raises non-portable flag due to `-mno-omit-leaf-frame-pointer` which is [set by default in 24.04](https://ubuntu.com/blog/ubuntu-performance-engineering-with-frame-pointers-by-default).
