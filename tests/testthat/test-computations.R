### unit tests for computations ###


# create data for testing
intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
total_production <- matrix(c(100, 200, 300), 1, 3)
exports <- matrix(c(10, 20, 30), 3, 1)
imports <- matrix(c(5, 10, 15), 1, 3)

# technical coefficients are calculated correctly
test_that("technical coefficients are calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # solution
  a <- intermediate_transactions %*% diag(1 / as.vector(total_production))
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
  b <- solve(diag(1, nrow = nrow(intermediate_transactions)) - obj$technical_coefficients_matrix)
  # Check if the leontief matrix is calculated correctly
  expect_equal(obj$leontief_inverse_matrix, b)
})

# output multiplier is calculated correctly
test_that("output multiplier is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # Calculate the output multiplier
  obj$compute_multiplier_output()
  # solution
  b <- solve(diag(1, nrow = nrow(intermediate_transactions)) - obj$technical_coefficients_matrix)
  mult_out = matrix(colSums(b), nrow = 1)
  colnames(mult_out) <- c(1, 2, 3)
  # Check if the output multiplier is calculated correctly
  expect_equal(obj$multiplier_output, mult_out)
})

# field of influence is calculated correctly
test_that("field of influence is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # Calculate the field of influence
  obj$compute_field_influence(0.001)
  # solution
  n <- nrow(intermediate_transactions)
  im <- diag(1, nrow = n)
  a <- intermediate_transactions %*% diag(1 / as.vector(total_production))
  b <- solve(im - a)
  ee <- 0.001
  e <- matrix(0, ncol = n, nrow = n)
  si <- matrix(0, ncol = n, nrow = n)
  for (i in 1:n) {
    for (j in 1:n) {
      e[i, j] = ee
      ae = a + e
      be = solve(im - ae)
      fe = (be - b) / ee
      feq = fe * fe
      s = sum(feq)
      si[i, j] = s
      e[i, j] = 0
    }
  }
  dimnames(si) <- list(c(1, 2, 3), c(1, 2, 3))
  # Check if the field of influence is calculated correctly
  expect_equal(obj$field_influence, si, tolerance = 1e-5)
})

# key sectors are calculated correctly
test_that("key sectors are calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # Calculate the key sectors
  obj$compute_key_sectors()
  # solution
  key_sectors = c("Non-Key Sector", "Strong Backward Linkage", "Key Sector")
  # Check if the key sectors are calculated correctly
  expect_equal(obj$key_sectors$key_sectors, key_sectors)
})

# allocation coefficients are calculated correctly
test_that("allocation coefficients are calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_allocation_coeff()
  # solution
  f <- diag(1 / as.vector(total_production)) %*% intermediate_transactions
  dimnames(f) <- list(c(1, 2, 3), c(1, 2, 3))
  # Check if the allocation coefficients are calculated correctly
  expect_equal(obj$allocation_coefficients_matrix, f)
})

# ghosh inverse matrix is calculated correctly
test_that("ghosh inverse matrix is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_allocation_coeff()
  # Calculate the ghosh inverse matrix
  obj$compute_ghosh_inverse()
  # solution
  g <- solve(diag(1, nrow = nrow(intermediate_transactions)) - obj$allocation_coefficients_matrix)
  # Check if the ghosh inverse matrix is calculated correctly
  expect_equal(obj$ghosh_inverse_matrix, g)
})

# hypothetical extraction works
test_that("hypothetical extraction is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production, exports = exports, imports = imports)
  # Calculate prerequisites
  obj$compute_tech_coeff()
  obj$compute_allocation_coeff()
  obj$update_added_value_matrix()
  obj$update_final_demand_matrix()
  # Calculate the hypothetical extraction
  obj$compute_hypothetical_extraction()
  # solution
  n <- nrow(intermediate_transactions)
  im <- diag(1, nrow = n)
  blextrac = matrix(NA, ncol = 1, nrow = n)
  flextrac = matrix(NA, ncol = 1, nrow = n)
  for (i in 1:n) {
    for (j in 1:n) {
      abl = obj$technical_coefficients_matrix
      abl[, j] = 0
      bbl = solve(im - abl)
      xbl = bbl %*% obj$final_demand_matrix
      tbl = sum(xbl) - sum(obj$total_production)
      blextrac[j] = tbl
      blextracp = blextrac / sum(obj$total_production)

      ffl = obj$allocation_coefficients_matrix
      ffl[i, ] = 0
      gfl = solve(im - ffl)
      xfl = obj$added_value_matrix %*% gfl
      tfl = sum(xfl) - sum(obj$total_production)
      flextrac[i] = tfl
      flextracp = flextrac / sum(obj$total_production)
    }
  }
  extrac = cbind(blextrac, blextracp, flextrac, flextracp)
  colnames(extrac) = c("backward_absolute", "backward_relative", "forward_absolute", "forward_relative")
  rownames(extrac) = c(1, 2, 3)
  # Check if the hypothetical extraction is calculated correctly
  expect_equal(obj$hypothetical_extraction[, 1:4], extrac)
})
