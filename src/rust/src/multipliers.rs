use extendr_api::prelude::*;
use rayon::prelude::*;

#[extendr]
/// Calculates output multiplier.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of output multipliers.

fn compute_multiplier_output(
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  // get dimensions (square root of length)
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  // get column sums
  leontief_inverse_matrix
    .par_chunks(n)
    .map(|col| col.iter().sum())
    .collect::<Vec<f64>>()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod multipliers;
  fn compute_multiplier_output;
}
