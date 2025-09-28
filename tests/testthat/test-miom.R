# sample multi-regional data (2 countries, 2 sectors each)
countries <- c("USA", "CHN")
sectors <- c("Agriculture", "Manufacturing")

# Create country-sector labels
labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")

# Sample intermediate transactions matrix (4x4)
intermediate_transactions <- matrix(
  c(
    10, 5, 2, 1,
    8, 15, 3, 2,
    1, 2, 12, 4,
    2, 3, 6, 18
  ),
  nrow = 4, ncol = 4,
  dimnames = list(labels, labels)
)

# Total production vector
total_production <- matrix(c(100, 120, 80, 110),
  nrow = 1, ncol = 4,
  dimnames = list(NULL, labels)
)

test_that("miom class can be instantiated", {

  # Create MIOM instance
  my_miom <- miom$new(
    id = "test_miom",
    intermediate_transactions = intermediate_transactions,
    total_production = total_production,
    countries = countries,
    sectors = sectors
  )

  # Test basic properties
  expect_equal(my_miom$id, "test_miom")
  expect_equal(my_miom$countries, countries)
  expect_equal(my_miom$sectors, sectors)
  expect_equal(my_miom$n_countries, 2)
  expect_equal(my_miom$n_sectors, 2)
})
