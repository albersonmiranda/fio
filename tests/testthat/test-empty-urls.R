# CRAN requires that URLs in the documentation are valid and not empty, including badges
test_that("No empty URLs in markdown files", {
  # Specify the path to the package directory
  package_path <- file.path(c(".", "man"))  # Adjust this if your tests directory is nested

  # Find all documentation files in the package directory
  files <- list.files(package_path, pattern = "\\.Rmd$|\\.md$|\\.Rd$", recursive = TRUE, full.names = TRUE)

  # Check each markdown file for empty URLs
  for (file in files) {
    empty_urls <- check_empty_urls(file)

    # Expect no empty URLs in the file
    expect_length(empty_urls, 0)
  }
})
