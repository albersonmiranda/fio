use faer::{Mat, prelude::SpSolver};
use extendr_api::prelude::*;
use rayon::prelude::*;

#[extendr]
/// @description
/// Computes technical coefficients matrix.
/// 
/// @details
/// It computes the technical coefficients matrix, a \eqn{n x n} matrix known as `A` matrix which is the column-wise
/// ratio of intermediate transactions to total production \insertCite{leontief_economia_1983}{fio}.
///
/// It takes a \eqn{n x n} matrix of intermediate transactions and a \eqn{1 x n} vector of total production,
/// and populates the `technical_coefficients_matrix` field with the result.
///
/// Underlined Rust code uses Rayon crate to parallelize the computation. So there is no need to use future or
/// async/await to parallelize.
/// 
/// @param intermediate_transactions
/// A \eqn{n x n} matrix of intermediate transactions.
/// @param total_production
/// A \eqn{1 x n} vector of total production.
/// 
/// @details
/// It computes the technical coefficients matrix, which is the columnwise ratio of
/// intermediate transactions to total production \insertCite{leontief_economia_1983}{fio}.
/// 
/// Underlined Rust code uses Rayon crate to parallelize the computation by
/// default, so there is no need to use future or async/await to parallelize.
/// 
/// @return
/// A \eqn{n x n} matrix of technical coefficients, known as A matrix.
/// 
/// @references
/// \insertAllCited{}
/// 
/// @examples
/// intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
/// total_production <- matrix(c(100, 200, 300), 1, 3)
/// # instantiate iom object
/// my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
/// # Calculate the technical coefficients
/// my_iom$compute_tech_coeff()
/// # show the technical coefficients
/// my_iom$technical_coefficients_matrix
/// 
/// @noRd

fn compute_tech_coeff(
  // There's an optional faer feature in extendr-api but it's not working (for the time I'm writing this)
  // see https://github.com/extendr/extendr/discussions/804
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

  RArray::new_matrix(n, n, |row, column| tech_coeff[row + column * n])
}

#[extendr]
/// @description
/// Computes Leontief inverse matrix.
/// 
/// @param tech_coeff
/// A \eqn{n x n} matrix of technical coefficients.
/// 
/// @details
/// It computes the Leontief inverse matrix \insertCite{leontief_economia_1983}{fio}, which is the inverse of the
/// Leontief matrix. Defined as:
/// 
/// \deqn{L = I - A}
/// 
/// where I is the identity matrix and A is the technical coefficients matrix.
/// 
/// The Leontief inverse matrix is calculated by solving the following equation:
/// 
/// \deqn{L^{-1} = (I - A)^{-1}}
/// 
/// Since the Leontief matrix is a square matrix and the subtraction of the
/// technical coefficients matrix from the identity matrix guarantees that the
/// Leontief matrix is invertible, this function computes the Leontief inverse
/// matrix through LU decomposition.
/// 
/// @return
/// A \eqn{n x n} matrix of Leontief inverse.
/// 
/// @references
/// \insertAllCited{}
/// 
/// @examples
/// intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
/// total_production <- matrix(c(100, 200, 300), 1, 3)
/// # instantiate iom object
/// my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
/// # Calculate the technical coefficients
/// my_iom$compute_tech_coeff()
/// # Calculate the Leontief inverse
/// my_iom$compute_leontief_inverse()
/// # show the Leontief inverse
/// my_iom$leontief_inverse_matrix
/// 
/// @noRd

fn compute_leontief_inverse(tech_coeff: &[f64]) -> RArray<f64, [usize;2]> {

  // get dimensions
  let n = (tech_coeff.len() as f64).sqrt() as usize;

  // create faer matrix
  let tech_coeff_matrix = Mat::from_fn(n, n, |row, col| tech_coeff[col * n + row]);

  // calculate Leontief matrix
  let identity_matrix: Mat<f64> = Mat::identity(n, n);
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
  mod leontief;
  fn compute_tech_coeff;
  fn compute_leontief_inverse;
}