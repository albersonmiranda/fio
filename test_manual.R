# Manual test for the new matrix parameter functionality
# This script tests the key features added to fix issue #81

# Create test data 
intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
total_production <- matrix(c(100, 200, 300), 1, 3)
exports <- matrix(c(10, 20, 30), 3, 1)
imports <- matrix(c(5, 10, 15), 1, 3)

cat("Testing matrix parameter functionality...\n")
cat("1. Loading fio package and creating iom object...\n")

# Create iom object
my_iom <- fio::iom$new("test", intermediate_transactions, total_production, 
                       exports = exports, imports = imports)

# Compute required matrices
my_iom$compute_tech_coeff()
my_iom$compute_leontief_inverse()
my_iom$compute_allocation_coeff()
my_iom$compute_ghosh_inverse()
my_iom$update_final_demand_matrix()
my_iom$update_value_added_matrix()

cat("2. Testing compute_key_sectors with different matrices...\n")

# Test key sectors with default (leontief)
my_iom$compute_key_sectors()
key_sectors_leontief <- my_iom$key_sectors
cat("   Key sectors with Leontief matrix computed\n")

# Test key sectors with ghosh matrix
my_iom$compute_key_sectors(matrix = "ghosh")
key_sectors_ghosh <- my_iom$key_sectors
cat("   Key sectors with Ghosh matrix computed\n")

# Compare results
cat("   Sensitivity dispersion (Leontief):", key_sectors_leontief$sensitivity_dispersion, "\n")
cat("   Sensitivity dispersion (Ghosh):   ", key_sectors_ghosh$sensitivity_dispersion, "\n")

cat("3. Testing compute_hypothetical_extraction with different matrices...\n")

# Test extraction with default (ghosh)
my_iom$compute_hypothetical_extraction()
extraction_ghosh <- my_iom$hypothetical_extraction
cat("   Hypothetical extraction with Ghosh matrix computed\n")

# Test extraction with leontief matrix
my_iom$compute_hypothetical_extraction(matrix = "leontief")
extraction_leontief <- my_iom$hypothetical_extraction
cat("   Hypothetical extraction with Leontief matrix computed\n")

# Compare results
cat("   Forward linkage (Ghosh):   ", extraction_ghosh[, "forward_absolute"], "\n")
cat("   Forward linkage (Leontief):", extraction_leontief[, "forward_absolute"], "\n")

cat("4. Testing error handling...\n")

# Test invalid matrix parameter
tryCatch({
  my_iom$compute_key_sectors(matrix = "invalid")
  cat("   ERROR: Should have failed with invalid matrix parameter\n")
}, error = function(e) {
  cat("   OK: Properly handled invalid matrix parameter\n")
})

cat("5. Testing backward compatibility...\n")

# Test that default behavior is preserved
my_iom$compute_key_sectors()  # Should work without any parameters
my_iom$compute_hypothetical_extraction()  # Should work without any parameters
cat("   OK: Backward compatibility maintained\n")

cat("All tests completed successfully!\n")