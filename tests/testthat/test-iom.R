### unit tests for the iom class ###


# create data for testing
intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
total_production <- matrix(c(100, 200, 300), 1, 3)

# iom can be instantiated
test_that("R6 class can be instantiated", {
  expect_s3_class(iom$new("test", intermediate_transactions, total_production), "iom")
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
})

test_that("remove method works correctly", {
  # Instantiate the class and add a dummy matrix
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Add the matrix
  obj$add("exports", matrix(1:3, 3, 1))
  # Remove the matrix
  obj$remove("exports")
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

test_that("update added value method works correctly", {
  # Instantiate the class and add a dummy matrix
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Add the matrix
  obj$add("imports", matrix(1:3, 1, 3))
  obj$add("taxes", matrix(4:6, 1, 3))
  # Update the matrix
  obj$update_added_value_matrix()
  # Check if the matrix is updated
  expect_equal(obj$added_value_matrix, matrix(c(1, 4, 2, 5, 3, 6), 2, 3))
})
