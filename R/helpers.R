### HELPERS ###


# input-output matrix elements list
iom_elements <- function() {
  elements <- c(
    "intermediate_transactions",
    "total_production",
    "final_demand",
    "exports",
    "imports",
    "taxes",
    "wages",
    "operating_income",
    "added_value_final_demand",
    "added_value",
    "occupation"
  )
  return(elements)
}
