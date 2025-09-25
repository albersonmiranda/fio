### unit tests for the iom class ###


# create data for testing
intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
total_production <- matrix(c(100, 200, 300), 1, 3)

# iom can be instantiated
test_that("R6 class can be instantiated", {
  expect_s3_class(iom$new("test", intermediate_transactions, total_production), "iom")
})

# fails if element is not matrix
test_that("fails if element is not matrix", {
  expect_error(iom$new("test", as.data.frame(intermediate_transactions), total_production))
})

# fails if intermediate transactions isn't square matrix
test_that("fails if intermediate transactions isn't square", {
  expect_error(iom$new("test", matrix(c(1, 2, 3, 4, 5, 6), 3, 2), total_production))
})

# validate final demand vectors row number
test_that("fails if final demand vectors doesn't have same row number than intermediate transactions", {
  expect_error(
    iom$new("test", intermediate_transactions, total_production, exports = matrix(c(1, 2, 3, 4), 2, 2))
  )
})

# validate value-added vectors column number
test_that("fails if value-added vectors doesn't have same column number than intermediate transactions", {
  expect_error(
    iom$new("test", intermediate_transactions, total_production, taxes = matrix(c(1, 2, 3, 4), 2, 2))
  )
})

# fails if format isn't `double`
test_that("fails if format isn't double", {
  expect_error(iom$new("test", intermediate_transactions, matrix(as.integer(c(100, 200, 300)), 1, 3)))
})

# add and remove methods work correctly
test_that("add method works correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Create a dummy matrix
  exports <- matrix(1:3, 3, 1)
  # Add the matrix
  obj$add("exports", exports)
  # Check if the matrix is added
  expect_true(!is.null(obj$exports))
  # fails if matrix name doesn't comply
  expect_error(obj$add("exportations", exports))
  # fails if it's not matrix class
  expect_error(obj$add("exports", as.data.frame(exports)))
  # fails if dimensions doesn't comply
  expect_error(obj$add("exports", matrix(1:2, 2, 1)))
  expect_error(obj$add("imports", matrix(1:2, 1, 2)))
})

test_that("remove method works correctly", {
  # Instantiate the class and add a dummy matrix
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Add the matrix
  obj$add("exports", matrix(1:3, 3, 1))
  # Remove the matrix
  obj$remove("exports")
  # fails if name doesn't comply
  expect_error(obj$remove("exportations"))
  # Check if the matrix is removed
  expect_true(is.null(obj$exports))
})

# update method works correctly
test_that("update final demand method works correctly", {
  # Instantiate the class and add a dummy matrix
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Add the matrix
  obj$add("exports", matrix(1:3, 3, 1))
  obj$add("household_consumption", matrix(4:6, 3, 1))
  # Update the matrix
  obj$update_final_demand_matrix()
  # Check if the matrix is updated
  expect_equal(obj$final_demand_matrix, matrix(c(4, 5, 6, 1, 2, 3), 3, 2))
})

test_that("update value-added method works correctly", {
  # Instantiate the class and add a dummy matrix
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Add the matrix
  obj$add("imports", matrix(1:3, 1, 3))
  obj$add("taxes", matrix(4:6, 1, 3))
  # Update the matrix
  obj$update_value_added_matrix()
  # Check if the matrix is updated
  expect_equal(obj$value_added_matrix, matrix(c(1, 4, 2, 5, 3, 6), 2, 3))
})

# close_model method works correctly
test_that("close_model with household works correctly", {
  # Instantiate the class with household consumption and wages
  obj <- iom$new("test", intermediate_transactions, total_production)
  obj$add("household_consumption", matrix(c(10, 20, 30), 3, 1))
  obj$add("wages", matrix(c(15, 25, 35), 1, 3))

  # Store original dimensions
  original_rows <- nrow(obj$intermediate_transactions)
  original_cols <- ncol(obj$intermediate_transactions)

  # Close the model with household
  obj$close_model("household")

  # Check that intermediate_transactions expanded by 1 row and 1 column
  expect_equal(nrow(obj$intermediate_transactions), original_rows + 1)
  expect_equal(ncol(obj$intermediate_transactions), original_cols + 1)

  # Check that total_production expanded by 1 column
  expect_equal(ncol(obj$total_production), original_cols + 1)

  # Check that household consumption was added as last column
  expect_equal(obj$intermediate_transactions[1:3, 4], c(10, 20, 30))

  # Check that wages were added as last row (first 3 columns)
  expect_equal(obj$intermediate_transactions[4, 1:3], c(15, 25, 35))

  # Check that household total production is sum of consumption
  expect_equal(obj$intermediate_transactions[4, 4], 60) # 10+20+30
  expect_equal(obj$total_production[1, 4], 60)

  # Check that household_consumption and wages are removed
  expect_null(obj$household_consumption)
  expect_null(obj$wages)
})

test_that("close_model with government works correctly", {
  # Instantiate the class with government consumption and taxes
  obj <- iom$new("test", intermediate_transactions, total_production)
  obj$add("government_consumption", matrix(c(5, 15, 25), 3, 1))
  obj$add("taxes", matrix(c(8, 12, 20), 1, 3))

  # Store original dimensions
  original_rows <- nrow(obj$intermediate_transactions)
  original_cols <- ncol(obj$intermediate_transactions)

  # Close the model with government
  obj$close_model("government")

  # Check that intermediate_transactions expanded by 1 row and 1 column
  expect_equal(nrow(obj$intermediate_transactions), original_rows + 1)
  expect_equal(ncol(obj$intermediate_transactions), original_cols + 1)

  # Check that total_production expanded by 1 column
  expect_equal(ncol(obj$total_production), original_cols + 1)

  # Check that government consumption was added as last column
  expect_equal(obj$intermediate_transactions[1:3, 4], c(5, 15, 25))

  # Check that taxes were added as last row (first 3 columns)
  expect_equal(obj$intermediate_transactions[4, 1:3], c(8, 12, 20))

  # Check that government total production is sum of consumption
  expect_equal(obj$intermediate_transactions[4, 4], 45) # 5+15+25
  expect_equal(obj$total_production[1, 4], 45)

  # Check that government_consumption and taxes are removed
  expect_null(obj$government_consumption)
  expect_null(obj$taxes)
})

test_that("close_model with both household and government works correctly", {
  # Instantiate the class with both sectors
  obj <- iom$new("test", intermediate_transactions, total_production)
  obj$add("household_consumption", matrix(c(10, 20, 30), 3, 1))
  obj$add("wages", matrix(c(15, 25, 35), 1, 3))
  obj$add("government_consumption", matrix(c(5, 15, 25), 3, 1))
  obj$add("taxes", matrix(c(8, 12, 20), 1, 3))

  # Store original dimensions
  original_rows <- nrow(obj$intermediate_transactions)
  original_cols <- ncol(obj$intermediate_transactions)

  # Close the model with both sectors
  obj$close_model(c("household", "government"))

  # Check that intermediate_transactions expanded by 2 rows and 2 columns
  expect_equal(nrow(obj$intermediate_transactions), original_rows + 2)
  expect_equal(ncol(obj$intermediate_transactions), original_cols + 2)

  # Check that total_production expanded by 2 columns
  expect_equal(ncol(obj$total_production), original_cols + 2)

  # All consumption and value-added vectors should be removed
  expect_null(obj$household_consumption)
  expect_null(obj$wages)
  expect_null(obj$government_consumption)
  expect_null(obj$taxes)
})

test_that("close_model fails with missing household_consumption", {
  obj <- iom$new("test", intermediate_transactions, total_production)
  obj$add("wages", matrix(c(15, 25, 35), 1, 3))

  expect_error(obj$close_model("household"), "household_consumption must be present")
})

test_that("close_model fails with missing wages", {
  obj <- iom$new("test", intermediate_transactions, total_production)
  obj$add("household_consumption", matrix(c(10, 20, 30), 3, 1))

  expect_error(obj$close_model("household"), "wages must be present")
})

test_that("close_model fails with missing government_consumption", {
  obj <- iom$new("test", intermediate_transactions, total_production)
  obj$add("taxes", matrix(c(8, 12, 20), 1, 3))

  expect_error(obj$close_model("government"), "government_consumption must be present")
})

test_that("close_model fails with missing taxes", {
  obj <- iom$new("test", intermediate_transactions, total_production)
  obj$add("government_consumption", matrix(c(5, 15, 25), 3, 1))

  expect_error(obj$close_model("government"), "taxes must be present")
})

test_that("close_model fails with invalid sectors argument", {
  obj <- iom$new("test", intermediate_transactions, total_production)

  expect_error(obj$close_model("invalid"), "sectors must be one or both of")
  expect_error(obj$close_model(c("household", "invalid")), "sectors must be one or both of")
  expect_error(obj$close_model(character(0)), "sectors must be a character vector with at least one element")
  expect_error(obj$close_model(123), "sectors must be a character vector with at least one element")
})
