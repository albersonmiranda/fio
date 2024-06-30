# Test Data Import Functionality
test_that("Data import handles inputs correctly", {
  expect_silent(
    fio_addin_create(
      var = "test_var",
      source = "input_file",
      number_format = "comma",
      source_file = list(datapath = "inst/extdata/iom/br/2020.xlsx"),
      sheet = "MIP",
      range = "D6:F8"
    )
  )

  # Test for invalid source
  expect_error(fio_addin_create(var = "test_var", source = "invalid_source", number_format = "comma"))

  # Test for invalid number format
  expect_error(fio_addin_create(var = "test_var", source = "input_file", number_format = "invalid_format"))
})
