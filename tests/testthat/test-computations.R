### unit tests for computations ###


# create data for testing
intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
total_production <- matrix(c(100, 200, 300), 1, 3)

# technical coefficients are calculated correctly
test_that("technical coefficients are calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # solution
  a <- obj$intermediate_transactions %*% diag(1 / colSums(obj$total_production))
  dimnames(a) <- list(c(1, 2, 3), c(1, 2, 3))
  # Check if the technical coefficients are calculated correctly
  expect_equal(obj$technical_coefficients_matrix, a)
})

# leontief matrix is calculated correctly
test_that("leontief matrix is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # solution
  b <- solve(diag(1, nrow = nrow(obj$intermediate_transactions)) - obj$technical_coefficients_matrix)
  # Check if the leontief matrix is calculated correctly
  expect_equal(obj$leontief_inverse_matrix, b)
})
