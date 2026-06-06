## R CMD check results (local macOS)

0 errors | 0 warnings | 1 notes

* NOTE:
```
❯ checking CRAN incoming feasibility ... [3s/37s] NOTE
  Maintainer: ‘Alberson da Silva Miranda <albersonmiranda@hotmail.com>’
  
  Version contains large components (1.0.0.9000)
  
  Size of tarball: 12376878 bytes

0 errors ✔ | 0 warnings ✔ | 1 note ✖
```
  
  - tarball 12.4Mb mostly due to vendored Rust dependencies as per CRAN policy.
  
* All CI tests passed:
  - macOS 15 and 26; R release, devel and oldrel-1.
  - Windows Server 2022 and 2025; R release, devel and oldrel-1.
  - Ubuntu 22.04, 24.04 and 24.04-arm; R release, devel and oldrel-1.
  - Fedora 45; R and all dependencies installed from default repository (`dnf install`).
