use extendr_api::prelude::*;
use nalgebra as na;

#[extendr]
/// Calculates technical coefficients matrix to R.
/// @param intermediate_transactions A nxn matrix of intermediate transactions.
/// @param total_production A 1xn vector of total production.
/// @return A nxn matrix of technical coefficients, known as A matrix.
/// @examples
/// intermediate_transactions <- matrix(c(1, 2, 3, 4), nrow = 2)
/// total_production <- c(10, 20)
/// tec_coeff(intermediate_transactions, total_production)
/// @export

fn tec_coeff(
  intermediate_transactions: Vec<f64>,
  total_production: Vec<f64>,
) -> RArray<f64, [usize;2]> {
  
  // get dimensions (square root of length)
  let n = (intermediate_transactions.len() as f64).sqrt() as usize;

  // divide each entry of intermediate_transactions by each column of total_production
  let mut tec_coeff = intermediate_transactions.clone();
  for i in 0..n {
    for j in 0..n {
      tec_coeff[i * n + j] = tec_coeff[i * n + j] / total_production[i];
    }
  }

  // convert to R matrix
  let tec_coeff_r = RArray::new_matrix(n, n, |r, c| tec_coeff[r + c * n]);

  tec_coeff_r
}

#[extendr]
/// Calculates Leontief inverse matrix to R.
/// @param tec_coeff A nxn matrix of technical coefficients.
/// @return A nxn matrix of Leontief inverse.
/// @examples
/// tec_coeff <- matrix(c(0.1, 0.2, 0.3, 0.4), nrow = 2)
/// leontief_inverse(tec_coeff)
/// @export

fn leontief_inverse(tec_coeff: Vec<f64>) -> RArray<f64, [usize;2]> {

  // get dimensions
  let n = (tec_coeff.len() as f64).sqrt() as usize;

  // convert to nalgebra matrix
  let tec_coeff_matrix = na::DMatrix::from_vec(n, n, tec_coeff);

  // calculate
  let identity_matrix = na::DMatrix::identity(n, n);
  let leontief_matrix: na::DMatrix<_> = identity_matrix - tec_coeff_matrix;
  let leontief_inverse = leontief_matrix.try_inverse().unwrap();
  
  // convert to R matrix
  let leontief_inverse_r = RArray::new_matrix(n, n, |r, c| leontief_inverse[(r, c)]);
  leontief_inverse_r
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod fio;
  fn tec_coeff;
  fn leontief_inverse;
}
