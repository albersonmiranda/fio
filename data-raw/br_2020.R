## code to prepare `br_2020` dataset goes here


# path
path = "inst/extdata/iom/br/2020.xlsx"

# sheet
sheet = "MIP"

# names
col_names = "D4:BB4"
row_names = "B6:B56"

# import elements
intermediate_transactions <- import_element(
  file = path,
  sheet = sheet,
  range = "D6:BB56",
  col_names = col_names,
  row_names = row_names
)

total_production <- import_element(
  file = path,
  sheet = sheet,
  range = "D79:BB79",
  col_names = col_names
)

exports_goods <- import_element(
  file = path,
  sheet = sheet,
  range = "BD6:BD56",
  row_names = row_names
)

exports_services <- import_element(
  file = path,
  sheet = sheet,
  range = "BE6:BE56",
  row_names = row_names
)

household_consumption <- import_element(
  file = path,
  sheet = sheet,
  range = "BH6:BH56",
  row_names = row_names
)

government_consumption <- import_element(
  file = path,
  sheet = sheet,
  range = "BF6:BF56",
  row_names = row_names
)

isflsf_consumption <- import_element(
  file = path,
  sheet = sheet,
  range = "BG6:BG56",
  row_names = row_names,
  col_names = "BG4:BG4"
)

fbcf <- import_element(
  file = path,
  sheet = sheet,
  range = "BI6:BI56",
  row_names = row_names,
  col_names = "BI4:BI4"
)

stock_var <- import_element(
  file = path,
  sheet = sheet,
  range = "BJ6:BJ56",
  row_names = row_names,
  col_names = "BJ4:BJ4"
)

imports <- import_element(
  file = path,
  sheet = sheet,
  range = "D58:BB58",
  col_names = col_names
)

taxes <- import_element(
  file = path,
  sheet = sheet,
  range = "D59:BB59",
  col_names = col_names
)

wages <- import_element(
  file = path,
  sheet = sheet,
  range = "D69:BB69",
  col_names = col_names
)

operating_income <- import_element(
  file = path,
  sheet = sheet,
  range = "D75:BB75",
  col_names = col_names
)

occupation <- import_element(
  file = path,
  sheet = sheet,
  range = "D80:BB80",
  col_names = col_names
)

other_margins <- import_element(
  file = path,
  sheet = sheet,
  range = "D65:BB66",
  col_names = col_names,
  row_names = "A65:A66"
)

other_taxes_subsidies <- import_element(
  file = path,
  sheet = sheet,
  range = "D76:BB77",
  col_names = col_names,
  row_names = "A76:A77"
)

# create input-output matrix object
br_2020 <- iom$new(
  id = "br_2020",
  intermediate_transactions = intermediate_transactions,
  total_production = total_production,
  household_consumption = household_consumption,
  government_consumption = government_consumption,
  exports = as.matrix(rowSums(cbind(exports_goods, exports_services))),
  final_demand_others = cbind(
    isflsf_consumption,
    fbcf,
    stock_var
  ),
  imports = imports,
  taxes = taxes,
  wages = wages,
  operating_income = operating_income,
  added_value_others = rbind(
    other_margins,
    other_taxes_subsidies
  ),
  occupation = occupation
)

usethis::use_data(br_2020, overwrite = TRUE)