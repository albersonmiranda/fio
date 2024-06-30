# create data for testing
intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
total_production <- matrix(c(100, 200, 300), 1, 3)
exports <- matrix(c(10, 20, 30), 3, 1)
imports <- matrix(c(5, 10, 15), 1, 3)

# Test if the Shiny app opens correctly
test_that("Addin opens correctly", {
  # Define a function to run the Shiny app in the background
  run_app_bg <- function() {
    callr::r_bg(function() {
      # Assuming `fio_addin()` runs a Shiny app
      fio:::fio_addin()
    })
  }

  # Start the app in the background
  app_process <- run_app_bg()

  # Check if a Shiny app is running
  expect_true(app_process$is_alive())

  # Stop the background app process
  app_process$kill()
})

# test whether addin has all iom elements names
test_that("Variable names are correctly assigned", {
  # iom
  iom <- iom$new("test", intermediate_transactions, total_production)
  # names
  var_names <- iom$.__enclos_env__$private$iom_elements()
  # test
  lapply(var_names, function(var) {
    expect_true(grepl(var, input_options))
  })
})

# Test Data Import Functionality
test_that("Data import handles inputs correctly", {
  # create mock file
  writexl::write_xlsx(iris, "mock.xlsx")
  expect_silent(
    fio_addin_create(
      var = "test_var",
      source = "input_file",
      number_format = "comma",
      source_file = list(datapath = "mock.xlsx"),
      sheet = "Sheet1",
      range = "A2:C4"
    )
  )

  # Test for invalid source
  expect_error(fio_addin_create(var = "test_var", source = "invalid_source", number_format = "comma"))

  # Test for invalid number format
  expect_error(fio_addin_create(var = "test_var", source = "input_file", number_format = "invalid_format"))
})
