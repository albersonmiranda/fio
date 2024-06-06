use extendr_api::prelude::*;
use faer;
use faer::prelude::SpSolver;

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

  // create faer matrix
  let tec_coeff_matrix = faer::Mat::from_fn(n, n, |r, c| (r + c) as f64);

  // calculate Leontief matrix
  let identity_matrix: faer::Mat<f64> = faer::Mat::identity(n, n);
  let leontief_matrix = identity_matrix.clone() - tec_coeff_matrix;

  // calculate Leontief inverse
  let leontief_lu = leontief_matrix.partial_piv_lu();
  let leontief_inverse = leontief_lu.solve(&identity_matrix);

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
