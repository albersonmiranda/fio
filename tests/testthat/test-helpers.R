# Test for set_colnames
test_that("set_colnames works correctly", {
  # Create a matrix with one column
  mat <- matrix(1:10, ncol = 1)
  # Test setting colnames
  mat <- set_colnames(mat)
  expect_equal(colnames(mat), "mat")

  # Test with a data frame
  df <- data.frame(a = 1:10)
  df = set_colnames(df)
  expect_equal(colnames(df), "a")

  # Test with invalid input (more than one column)
  mat2 <- matrix(1:10, ncol = 2)
  expect_error(set_colnames(mat2), "vec must have only one column")

  # Test with non-matrix/data frame input
  expect_error(set_colnames(list(a = 1)), "vec must be a matrix or a data frame")
})

# Test for set_rownames
test_that("set_rownames works correctly", {
  # Create a matrix with one row
  mat <- matrix(1:10, nrow = 1)
  # Test setting rownames
  mat <- set_rownames(mat)
  expect_equal(rownames(mat), "mat")

  # Test with a data frame
  df <- data.frame(a = 1, b = 2, c = 3, d = 4, e = 5)
  df = set_rownames(df)
  expect_equal(rownames(df), "1")

  # Test with invalid input (more than one row)
  mat2 <- matrix(1:10, nrow = 2)
  expect_error(set_rownames(mat2), "vec must have only one row")

  # Test with non-matrix/data frame input
  expect_error(set_rownames(list(a = 1)), "vec must be a matrix or a data frame")
})

# test if alerts works correctly
test_that("alert works correctly", {
  expect_message(alert("This is an alert"))
})

# test if errors works correctly
test_that("error works correctly", {
  expect_error(error("This is an error"))
})
