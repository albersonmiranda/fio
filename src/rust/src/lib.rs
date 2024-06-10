// module imports
mod multipliers;
mod influence;
mod linkages;

use faer;
use faer::prelude::SpSolver;
use extendr_api::prelude::*;
use rayon::prelude::*;

#[extendr]
/// Computes technical coefficients matrix to R.
/// @param intermediate_transactions A nxn matrix of intermediate transactions.
/// @param total_production A 1xn vector of total production.
/// @return A nxn matrix of technical coefficients, known as A matrix.

fn compute_tech_coeff(
  intermediate_transactions: &[f64],
  total_production: &[f64],
) -> RArray<f64, [usize;2]> {
  
  // get dimensions (square root of length)
  let n = (intermediate_transactions.len() as f64).sqrt() as usize;

  // divide each entry of intermediate_transactions by each column of total_production
  let tech_coeff: Vec<f64> = intermediate_transactions
    .par_iter()
    .enumerate()
    .map(|(i, value)| value / total_production[i / n])
    .collect();

  RArray::new_matrix(n, n, |r, c| tech_coeff[r + c* n])
}

#[extendr]
/// Computes Leontief inverse matrix to R.
/// @param tech_coeff A nxn matrix of technical coefficients.
/// @return A nxn matrix of Leontief inverse.

fn compute_leontief_inverse(tech_coeff: &[f64]) -> RArray<f64, [usize;2]> {

  // get dimensions
  let n = (tech_coeff.len() as f64).sqrt() as usize;

  // create faer matrix
  let tech_coeff_matrix = faer::Mat::from_fn(n, n, |row, col| tech_coeff[col * n + row]);

  // calculate Leontief matrix
  let identity_matrix: faer::Mat<f64> = faer::Mat::identity(n, n);
  let leontief_matrix = &identity_matrix - tech_coeff_matrix;

  // calculate Leontief inverse
  let leontief_inverse = leontief_matrix.partial_piv_lu().solve(identity_matrix);

  // convert to R matrix
  RArray::new_matrix(n, n, |row, col| leontief_inverse[(row, col)])
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod fio;
  use multipliers;
  use influence;
  use linkages;
  fn compute_tech_coeff;
  fn compute_leontief_inverse;
}
