use extendr_api::prelude::*;

#[extendr]
/// Calculates output multiplier.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of output multipliers.
/// @export

fn compute_multiplier_output(
  leontief_inverse_matrix: Vec<f64>
) -> Vec<f64> {
  
  // get dimensions (square root of length)
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  // get column sums
  let mut mult_out = vec![0.0; n];
  for i in 0..n {
    for j in 0..n {
      let index = i * n + j;
      mult_out[j] += leontief_inverse_matrix[index];
    }
  }

  mult_out
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod multipliers;
  fn compute_multiplier_output;
}
