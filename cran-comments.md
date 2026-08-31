## R CMD check results (local macOS)

0 errors | 0 warnings | 1 notes

* NOTE:
```
❯ checking CRAN incoming feasibility ... [3s/38s] NOTE
  Maintainer: ‘Alberson da Silva Miranda <albersonmiranda@gmail.com>’
  
  New maintainer:
    Alberson da Silva Miranda <albersonmiranda@gmail.com>
  Old maintainer(s):
    Alberson da Silva Miranda <albersonmiranda@hotmail.com>
  
  Found the following (possibly) invalid URLs:
    URL: https://www.cambridge.org/core/product/identifier/9780511626982/type/book
      From: man/iom.Rd
      Status: 429
      Message: Too Many Requests
  
  Size of tarball: 13432824 bytes

0 errors ✔ | 0 warnings ✔ | 1 note ✖
```
  
  - tarball 13.4Mb mostly due to vendored Rust dependencies as per CRAN policy.
  
* All CI tests passed:
  - macOS 15 and 26; R release, devel and oldrel-1.
  - Windows-11-arm, Windows Server 2022 and 2025; R release, devel and oldrel-1.
  - Ubuntu 22.04, 24.04 and 24.04-arm; R release, devel and oldrel-1.
  - Fedora 45; R and all dependencies installed from default repository (`dnf install`).
