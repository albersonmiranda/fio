## 1st resubmission

* NOTE:
```
❯ checking CRAN incoming feasibility ... [5s/32s] NOTE
  Maintainer: ‘Alberson da Silva Miranda <albersonmiranda@hotmail.com>’
  
  Suggests or Enhances not in mainstream repositories:
    fiodata
  
  Size of tarball: 12253105 bytes
```

* Tarball size was successfully reduced from 48.1mb to 12.3mb
  - The `download.rs` module was refactored into base R implementation, allowing for dumping some rust dependencies.
  - Built-in datasets were moved to a companion package `fiodata`, previously submitted.
* All CI and local tests passed.

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
