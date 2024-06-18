use faer::{Mat, prelude::SpSolver};
use extendr_api::prelude::*;
use rayon::prelude::*;

#[extendr]
/// Computes allocation coefficients matrix.
/// @param intermediate_transactions A nxn matrix of intermediate transactions.
/// @param total_production A 1xn vector of total production.
/// @return A nxn matrix of allocation coefficients, known as F matrix.

fn compute_allocation_coeff(
  intermediate_transactions: &[f64],
  total_production: &[f64],
) -> RArray<f64, [usize;2]> {
  
  // get dimensions (square root of length)
  let n = (intermediate_transactions.len() as f64).sqrt() as usize;

  // divide each entry of intermediate_transactions by each row of total_production
  let allocation_coeff: Vec<f64> = intermediate_transactions
    .par_iter()
    .enumerate()
    .map(|(i, value)| value / total_production[i % n])
    .collect();

  RArray::new_matrix(n, n, |row, column| allocation_coeff[row + column * n])
}

#[extendr]
/// Computes Ghosh inverse matrix.
/// @param allocation_coeff A nxn matrix of allocation coefficients.
/// @return A nxn matrix of Ghosh inverse.

fn compute_ghosh_inverse(allocation_coeff: &[f64]) -> RArray<f64, [usize;2]> {

  // get dimensions
  let n = (allocation_coeff.len() as f64).sqrt() as usize;

  // create faer matrix
  let allocation_coeff_matrix = Mat::from_fn(n, n, |row, col| allocation_coeff[col * n + row]);

  // calculate Ghosh inverse
  let identity_matrix: Mat<f64> = Mat::identity(n, n);
  let ghosh_matrix = &identity_matrix - allocation_coeff_matrix;
  let ghosh_inverse = ghosh_matrix.partial_piv_lu().solve(identity_matrix);

  // convert to R matrix
  RArray::new_matrix(n, n, |row, col| ghosh_inverse[(row, col)])
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod ghosh;
  fn compute_allocation_coeff;
  fn compute_ghosh_inverse;
}