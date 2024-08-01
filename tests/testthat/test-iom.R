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
