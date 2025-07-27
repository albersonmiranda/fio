# Summary of Changes for Issue #81

## Issue Description
Add option for using Ghosh or Leontief matrices in forward linkages for both hypothetical extraction and key sectors analysis.

## Files Modified

### 1. Rust Implementation (`src/rust/src/`)
**`linkages.rs`**: Added 3 new functions
- `compute_sensitivity_dispersion_ghosh()` - Computes sensitivity of dispersion using Ghosh matrix
- `compute_sensitivity_dispersion_cv_ghosh()` - Computes sensitivity of dispersion CV using Ghosh matrix  
- `compute_ghosh_inverse_average()` - Helper function for Ghosh-based average calculations

**`extraction.rs`**: Added 1 new function
- `compute_extraction_forward_leontief()` - Computes forward linkage extraction using Leontief matrix

### 2. R Interface (`R/`)
**`extendr-wrappers.R`**: Added wrappers for the new Rust functions

**`r6.R`**: Updated R6 class methods
- `compute_key_sectors(matrix = "leontief")` - Added matrix parameter, default preserves current behavior
- `compute_hypothetical_extraction(matrix = "ghosh")` - Added matrix parameter, default preserves current behavior

### 3. Tests (`tests/testthat/`)
**`test-computations.R`**: Added comprehensive tests
- Test that different matrices produce different results for forward linkage
- Test that backward linkage remains consistent (always uses Leontief)
- Test error handling for invalid matrix parameters
- Test backward compatibility

### 4. Documentation
**`NEWS.md`**: Added feature announcement
**`vignettes/getting_started.Rmd`**: Added section explaining matrix selection
**`test_manual.R`**: Created manual test script for validation

## Implementation Details

### Backward Compatibility
- All existing behavior is preserved through default parameters
- `compute_key_sectors()` defaults to "leontief" (current behavior)
- `compute_hypothetical_extraction()` defaults to "ghosh" (current behavior)

### Parameter Behavior
- **Forward linkage**: Controlled by the `matrix` parameter in both methods
- **Backward linkage**: Always uses Leontief matrix (consistent with established theory)

### Error Handling
- Validates matrix parameter values ("leontief" or "ghosh" only)
- Checks for required matrices (e.g., ghosh_inverse_matrix when using "ghosh")
- Provides clear error messages for missing dependencies

### New Functionality
Users can now:
1. Use Ghosh matrix for forward linkage in key sectors analysis
2. Use Leontief matrix for forward linkage in hypothetical extraction
3. Compare results between different methodological approaches
4. Maintain consistency with their preferred theoretical framework

## Testing
- Added unit tests covering all new functionality
- Tests verify different matrices produce different results
- Tests ensure backward linkage consistency
- Tests validate error handling and backward compatibility
- Manual test script created for comprehensive validation

## Impact
- **Minimal**: Changes are surgical and preserve all existing behavior
- **Backward Compatible**: Default parameters maintain current functionality  
- **Extensible**: Framework allows easy addition of other matrices in future
- **Well Documented**: Clear documentation and examples provided

This implementation fully addresses the requirements in issue #81 while maintaining the package's design principles of clarity, minimal changes, and backward compatibility.