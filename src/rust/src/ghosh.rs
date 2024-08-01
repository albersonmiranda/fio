use faer::{Mat, prelude::SpSolver};
use extendr_api::prelude::*;
use rayon::prelude::*;

#[extendr]
/// Computes allocation coefficients matrix.
/// 
/// @param intermediate_transactions
/// A nxn matrix of intermediate transactions.
/// @param total_production
/// A 1xn vector of total production.
/// 
/// @details
/// Allocation coefficients matrix is the rowwise ratio of
/// intermediate transactions to total production \insertCite{miller_input-output_2009}{fio}.
/// 
/// @references
/// \insertAllCited{}
/// 
/// @examples
/// intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
/// total_production <- matrix(c(100, 200, 300), 1, 3)
/// # instantiate iom object
/// my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
/// # Calculate the allocation coefficients
/// my_iom$compute_allocation_coeff()
/// # show the allocation coefficients
/// my_iom$allocation_coefficients_matrix
/// 
/// @return A nxn matrix of allocation coefficients, known as F matrix.
/// 
/// @noRd
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
/// 
/// @param allocation_coeff
/// A \eqn{n x n} matrix of allocation coefficients.
/// 
/// @details
/// The Ghosh inverse matrix is the inverse of the
/// difference \eqn{(I - F)} where I is the identity matrix and F is the
/// allocation coefficients matrix \insertCite{miller_input-output_2009}{fio}.
/// 
/// @return
/// A \eqn{n x n} matrix of Ghoshian inverse.
/// 
/// @references
/// \insertAllCited{}
/// 
/// @noRd
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