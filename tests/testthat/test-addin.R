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

  # test if it import colnames correctly
  expect_silent(
    fio_addin_create(
      var = "test_var2",
      source = "input_file",
      number_format = "comma",
      source_file = list(datapath = "mock.xlsx"),
      sheet = "Sheet1",
      range = "A2:C4",
      col_names = "A1:C1"
    )
  )

  # test if it import rownames correctly
  expect_silent(
    fio_addin_create(
      var = "test_var3",
      source = "input_file",
      number_format = "comma",
      source_file = list(datapath = "mock.xlsx"),
      sheet = "Sheet1",
      range = "A2:C4",
      row_names = "A2:A4"
    )
  )

  # Test for invalid source
  expect_error(fio_addin_create(var = "test_var4", source = "invalid_source", number_format = "comma"))

  # Test for invalid number format
  expect_error(fio_addin_create(var = "test_var5", source = "input_file", number_format = "invalid_format"))
})

# dependencies
test_that("Has dependencies", {
  expect_silent({
    rlang::check_installed(
      c("shiny", "miniUI"),
      "in order to use the fio addin"
    )
  })
})

# ui
test_that("ui been generated", {
  resource_path <- fs::path_package("fio", "addins")
  shiny::addResourcePath("addins", resource_path)
  ui <- miniUI::miniPage(
    shiny::tags$head(shiny::includeCSS(fs::path(resource_path, "fio.css"))),
    miniUI::gadgetTitleBar(
      shiny::p(
        "Use",
        shiny::a(href = "https://github.com/albersonmiranda/fio", "{fio}"),
        "to conveniently import input-output data from an Excel file."
      ),
      right = miniUI::miniTitleBarButton("import_but", "Import", primary = TRUE)
    ),
    miniUI::miniContentPanel(
      input_options,
      shiny::conditionalPanel(
        condition = "input.var == 'custom'",
        shiny::textInput(
          inputId = "custom_var",
          label = "Custom variable name"
        )
      ),
      shiny::radioButtons(
        inputId = "source",
        label = "Where is input-output matrix source?",
        choices = c(
          "on the clipboard" = "clipboard",
          "in a Excel file" = "input_file"
        )
      ),
      shiny::conditionalPanel(
        condition = "input.source == 'input_file'",
        shiny::fileInput(
          inputId = "source_file",
          label = "Source file"
        ),
        shiny::textInput(
          inputId = "sheet",
          label = "Which sheet?",
          value = "plan1"
        ),
        shiny::textInput(
          inputId = "range",
          label = "Which range?",
          value = "A1:Z100"
        ),
        shiny::textInput(
          inputId = "col_names",
          label = "Which range for column names?",
          value = FALSE
        ),
        shiny::textInput(
          inputId = "row_names",
          label = "Which range for row names?",
          value = FALSE
        )
      ),
      shiny::radioButtons(
        inputId = "number_format",
        label = "What is the number format of your file?",
        choices = list(
          "1.234,56" = "comma",
          "1,234.56" = "dot"
        ),
        selected = "comma"
      )
    )
  )
  expect_true(all(class(ui) == c("shiny.tag.list", "list")))
})
