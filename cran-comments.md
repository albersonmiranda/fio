## R CMD check results

0 errors | 0 warnings | 2 notes

* This is a new submission.
* Check on Ubuntu
  - Installed size is 9.3Mb: Rust code and dependencies are compiled and statically linked into the shared library `fio.so`.
  - Build on Ubuntu 24.04 raises non-portable flag due to `-mno-omit-leaf-frame-pointer` which is [set by default in 24.04](https://ubuntu.com/blog/ubuntu-performance-engineering-with-frame-pointers-by-default).
