### unit tests for computations ###


# create data for testing
intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
total_production <- matrix(c(100, 200, 300), 1, 3)
exports <- matrix(c(10, 20, 30), 3, 1)
imports <- matrix(c(5, 10, 15), 1, 3)
occupation <- matrix(c(10, 12, 15), 1, 3)
taxes <- matrix(c(2, 5, 10), 1, 3)
wages <- matrix(c(11, 12, 13), 1, 3)

# parallelization
test_that("parallelization can be disabled", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # set number of threads to 1
  obj$set_max_threads(1L)
  # Check if the number of threads is set to 1
  expect_equal(obj$threads, 1)
})

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
  # fails if technical coefficients aren't available
  expect_error(obj$compute_leontief_inverse())
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
  # fails if leontief matrix isn't available
  expect_error(obj$compute_multiplier_output())
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # Calculate the output multiplier
  obj$compute_multiplier_output()
  # solution
  b <- solve(diag(1, nrow = nrow(intermediate_transactions)) - obj$technical_coefficients_matrix)
  mult_out = colSums(b)
  # Check if the output multiplier is calculated correctly
  expect_equal(obj$multiplier_output[["multiplier_simple"]], as.vector(mult_out))
})

# multiplier generator is calculated correctly
test_that("multiplier generator is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production, occupation = occupation)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # Calculate employment requirements
  employment_reqs <- compute_requirements_value_added(obj$occupation, obj$total_production)
  # Calculate employment generator
  employment_generator <- compute_generator_value_added(employment_reqs, obj$leontief_inverse_matrix)
  dimnames(employment_generator) <- list(NULL, c(1, 2, 3))
  # solution
  c_j <- occupation / total_production
  c_j_diag <- diag(as.vector(c_j))
  e <- c_j_diag %*% obj$leontief_inverse_matrix
  # check if employment generator is calculated correctly
  expect_equal(e, employment_generator)
})

# employment multiplier is calculated correctly
test_that("employment multiplier is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production, occupation = occupation)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # fails if leontief matrix isn't available
  expect_error(obj$compute_multiplier_employment())
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # Calculate the employment multiplier
  obj$compute_multiplier_employment()
  # solution
  c_j <- occupation / total_production
  c_j_diag <- diag(as.vector(c_j))
  e <- c_j_diag %*% obj$leontief_inverse_matrix
  mult_emp <- colSums(e)
  # Check if the employment multiplier is calculated correctly
  expect_equal(obj$multiplier_employment[["multiplier_simple"]], as.vector(mult_emp))
})

# wages multiplier is calculated correctly
test_that("wages multiplier is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production, wages = wages)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # fails if leontief matrix isn't available
  expect_error(obj$compute_multiplier_wages())
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # Calculate the wages multiplier
  obj$compute_multiplier_wages()
  # solution
  c_j = wages / total_production
  c_j_diag = diag(as.vector(c_j))
  e = c_j_diag %*% obj$leontief_inverse_matrix
  mult_wages = colSums(e)
  # Check if the wages multiplier is calculated correctly
  expect_equal(obj$multiplier_wages[["multiplier_simple"]], as.vector(mult_wages))
})

# taxes multiplier is calculated correctly
test_that("taxes multiplier is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production, taxes = taxes)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # fails if leontief matrix isn't available
  expect_error(obj$compute_multiplier_taxes())
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # Calculate the taxes multiplier
  obj$compute_multiplier_taxes()
  # solution
  c_j = taxes / total_production
  c_j_diag = diag(as.vector(c_j))
  e = c_j_diag %*% obj$leontief_inverse_matrix
  mult_taxes = colSums(e)
  # Check if the taxes multiplier is calculated correctly
  expect_equal(obj$multiplier_taxes[["multiplier_simple"]], as.vector(mult_taxes))
})

# field of influence is calculated correctly
test_that("field of influence is calculated correctly", {
  # Instantiate the class
  obj <- iom$new("test", intermediate_transactions, total_production)
  # Calculate the technical coefficients
  obj$compute_tech_coeff()
  # fails if leontief matrix isn't available
  expect_error(obj$compute_field_influence(0.001))
  # Calculate the leontief matrix
  obj$compute_leontief_inverse()
  # fails if epsilon arg is misising
  expect_error(obj$compute_field_influence())
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
  # fails if leontief matrix isn't available
  expect_error(obj$compute_key_sectors())
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
  # fails if allocation coefficients aren't available
  expect_error(obj$compute_ghosh_inverse())
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
  # fails if tech coeff matrix isn't available
  expect_error(obj$compute_hypothetical_extraction())
  # Calculate prerequisites
  obj$compute_tech_coeff()
  obj$compute_allocation_coeff()
  # fails if aggregated matrices isn't available
  expect_error(obj$compute_hypothetical_extraction())
  # set aggregated matrices
  obj$update_value_added_matrix()
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
      xfl = obj$value_added_matrix %*% gfl
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
