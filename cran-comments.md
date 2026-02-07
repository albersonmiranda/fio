## R CMD check results (local Fedora 43 Workstation)

0 errors | 0 warnings | 1 notes

* NOTE:
```
❯ checking CRAN incoming feasibility ... [10s/83s] NOTE
  Maintainer: ‘Alberson da Silva Miranda <albersonmiranda@hotmail.com>’
  
  Version contains large components (0.1.6.9005)
  
  Size of tarball: 48140968 bytes
```
  
  - installed size is 20.8Mb mostly due to vendored Rust dependencies as per CRAN policy (10.2Mb).
  
* All CI tests passed:
  - macOS 15 and 26; R release, devel and oldrel-1.
  - Windows Server 2022 and 2025; R release, devel and oldrel-1.
  - Ubuntu 22.04, 24.04 and 24.04-arm; R release, devel and oldrel-1.
  - Fedora 42; R and all dependencies installed from default repository (`dnf install`).
