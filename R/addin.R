#' @noRd

# nocov start
input_options <- shiny::selectInput(
  inputId = "var",
  label = "Variable name",
  choices = list(
    "Intermediate Transactions" = "intermediate_transactions",
    "Total Production" = "total_production",
    "Final Demand" = list(
      "Household Consumption" = "household_consumption",
      "Government Consumption" = "government_consumption",
      "Exports" = "exports",
      "Others" = "final_demand_others"
    ),
    "Value-Added" = list(
      "Imports" = "imports",
      "Taxes" = "taxes",
      "Wages" = "wages",
      "Operating Income" = "operating_income",
      "Others" = "value_added_others"
    ),
    "Occupation" = "occupation",
    "Custom" = "custom"
  )
)

#' Conveniently import data from an Excel file
#'
#' @description `fio_addin()` opens an [RStudio
#'  gadget](https://shiny.rstudio.com/articles/gadgets.html) and
#'  [addin](https://rstudio.github.io/rstudioaddins/) that allows you to say
#'  where the data source is (either clipboard or Excel file) and import the
#'  data into the global environment.
#'  Appears as "Import input-output data" in the RStudio Addins menu.
#' @references This function is based on the [reprex](https://github.com/tidyverse/reprex) package.

fio_addin <- function() {
  rlang::check_installed(
    c("shiny", "miniUI"),
    "in order to use the fio addin"
  )
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

  server <- function(input, output, session) {
    shiny::observeEvent(input$import_but, {
      fio_addin_create(
        input$var,
        input$source,
        input$number_format,
        input$source_file,
        input$sheet,
        input$range,
        input$col_names,
        input$row_names
      )

      shiny::showModal(shiny::modalDialog(
        title = paste("Pronto", emoji::emoji("sparkles")),
        "Data has been imported",
        easyClose = TRUE,
        footer = shiny::tagList(
          shiny::actionButton("but_done", "Done"),
          shiny::modalButton("Import Another")
        )
      ))
    })

    shiny::observeEvent(input$but_done, {
      if (exists(deparse(substitute(intermediate_transactions))) & exists(deparse(substitute(total_production)))) {
        # close the modal
        shiny::removeModal()
        shiny::stopApp()
      } else {
        shiny::showModal(shiny::modalDialog(
          title = "Error",
          "You must import at least the intermediate transactions and total production data",
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      }
    })
  }

  app <- shiny::shinyApp(ui, server, options = list(quiet = TRUE))
  shiny::runGadget(app, viewer = shiny::dialogViewer("Import input-output matrix data"))
}

fio_addin_create <- function(
    var,
    source,
    number_format,
    source_file = NULL,
    sheet = NULL,
    range = NULL,
    col_names = FALSE,
    row_names = FALSE) {
  # Parameter validation
  if (!source %in% c("clipboard", "input_file")) {
    error("Invalid source specified")
  }
  if (!number_format %in% c("comma", "dot")) {
    error("Invalid number format specified")
  }
  if (source == "input_file" && is.null(source_file)) {
    error("Source file must be provided for input_file source")
  }

  fio_input <- switch(source,
    clipboard = NULL,
    input_file = source_file$datapath
  )

  # import data
  tryCatch(
    {
      data <- if (source == "input_file") {
        import_element(
          file = fio_input,
          sheet = sheet,
          range = range,
          col_names = col_names,
          row_names = row_names
        )
      } else {
        temp <- clipr::read_clip_tbl(header = FALSE)
        colnames(temp) <- seq_len(ncol(temp))
        # parse to numeric and correct number format
        temp <- sapply(temp, function(columns) {
          if (number_format == "comma") {
            temp <- gsub("\\.", "", columns)
            temp <- as.numeric(gsub(",", ".", temp))
            return(temp)
          } else {
            temp <- as.numeric(gsub(",", "", columns))
            return(temp)
          }
        })
        temp
      }
    },
    error = function(e) {
      stop("Failed to import data: ", e$message)
    }
  )

  # assign to environment
  if (exists(var)) {
    alert("Variable {var} already exists and will be overwritten.")
  }
  assign(var, data, inherits = TRUE)
}
# nocov end