## code to prepare `world_2000` dataset goes here


# path
path <- "inst/extdata/iom/world/2000.xlsx"

# sheet
sheet <- "2000"

# import elements
countries <- import_element(
  file = path,
  sheet = sheet,
  range = "C7:C604"
) |>
  na.omit()

sectors <- import_element(
  file = path,
  sheet = sheet,
  range = "B7:B29"
)

intermediate_transactions <- import_element(
  file = path,
  sheet = sheet,
  range = "E7:WD604"
)

total_production <- import_element(
  file = path,
  sheet = sheet,
  range = "E612:WD612"
)

final_demand <- import_element(
  file = path,
  sheet = sheet,
  range = "WF7:AAE604"
)

final_demand_names <- import_element(
  file = path,
  sheet = sheet,
  range = "WF5:WI5"
)

value_added_others <- import_element(
  file = path,
  sheet = sheet,
  range = "E606:WD606"
)

taxes <- import_element(
  file = path,
  sheet = sheet,
  range = "E607:WD607"
)

measure_errors <- import_element(
  file = path,
  sheet = sheet,
  range = "E608:WD608"
)

domestic_purchase_non_residents <- import_element(
  file = path,
  sheet = sheet,
  range = "E609:WD609"
)

purchase_residents_abroad <- import_element(
  file = path,
  sheet = sheet,
  range = "E610:WD610"
)

internation_transport_margins <- import_element(
  file = path,
  sheet = sheet,
  range = "E611:WD611"
)

# prepare labels
n_countries <- length(countries)
n_sectors <- nrow(sectors)

# intermediate transactions labels
intermediate_transactions_labels <- c()
for (i in 1:n_countries) {
  country <- countries[i]
  for (j in 1:n_sectors) {
    sector <- sectors[j, 1]
    index <- (i - 1) * n_sectors + j
    intermediate_transactions_labels[index] <- paste(country, sector, sep = "_")
  }
}

rownames(intermediate_transactions) <- intermediate_transactions_labels
colnames(intermediate_transactions) <- intermediate_transactions_labels

colnames(total_production) <- intermediate_transactions_labels

# final demand
household_consumption <- matrix(nrow = nrow(final_demand), ncol = n_countries)
government_consumption <- matrix(nrow = nrow(final_demand), ncol = n_countries)
gfcf <- matrix(nrow = nrow(final_demand), ncol = n_countries)
stock_variation <- matrix(nrow = nrow(final_demand), ncol = n_countries)

for (i in 1:n_countries) {
  # 4 columns per country
  col_start <- (i - 1) * 4 + 1
  col_end <- i * 4

  country_final_demand <- final_demand[, col_start:col_end]

  household_consumption[, i] <- country_final_demand[, 1]
  government_consumption[, i] <- country_final_demand[, 2]
  gfcf[, i] <- country_final_demand[, 3]
  stock_variation[, i] <- country_final_demand[, 4]
}

colnames(household_consumption) <- countries
colnames(government_consumption) <- countries
colnames(gfcf) <- countries
colnames(stock_variation) <- countries

# For the miom class, we need to aggregate consumption across countries
# Each country's consumption becomes the final demand for that country's sectors
household_consumption_vector <- rowSums(household_consumption, na.rm = TRUE)
government_consumption_vector <- rowSums(government_consumption, na.rm = TRUE)

# Convert to single-column matrices as expected by iom class
household_consumption_matrix <- matrix(household_consumption_vector, ncol = 1)
dimnames(household_consumption_matrix) <- list(intermediate_transactions_labels, "Household_Consumption")

government_consumption_matrix <- matrix(government_consumption_vector, ncol = 1)
dimnames(government_consumption_matrix) <- list(intermediate_transactions_labels, "Government_Consumption")

# Aggregate final demand components
final_demand_others <- cbind(gfcf, stock_variation)
final_demand_others_colnames <- c(
  paste("GFCF", countries, sep = "_"),
  paste("Stock_Variation", countries, sep = "_")
)
dimnames(final_demand_others) <- list(intermediate_transactions_labels, final_demand_others_colnames)

# Create multi-regional input-output matrix object
world_2000 <- miom$new(
  id = "world_2000",
  intermediate_transactions = intermediate_transactions,
  total_production = total_production,
  countries = countries[, 1],
  sectors = sectors[, 1],
  household_consumption = household_consumption_matrix,
  government_consumption = government_consumption_matrix,
  final_demand_others = final_demand_others,
  taxes = taxes,
  value_added_others = value_added_others
)

# Aggregate final demand matrix
world_2000$update_final_demand_matrix()

# Aggregate value-added matrix
world_2000$update_value_added_matrix()

# Save data
usethis::use_data(world_2000, overwrite = TRUE, compress = "zstd")
