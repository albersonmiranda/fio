use extendr_api::prelude::*;
use faer::{prelude::SpSolver, Mat};

#[extendr]
/// Computes backward linkage extraction.
/// 
/// @description
/// Computes impact on demand structure after extracting a given sector \insertCite{miller_input-output_2009}{fio}.
/// 
/// @param technical_coefficients_matrix
/// A nxn matrix of technical coefficients.
/// @param final_demand_matrix
/// The final demand matrix.
/// @param total_production
/// A 1xn vector of total production.
/// 
/// @references
/// \insertAllCited{}
/// 
/// @noRd
fn compute_extraction_backward(
  technical_coefficients_matrix: &[f64],
  final_demand_matrix: RMatrix<f64>,
  total_production: &[f64]
) -> RMatrix<f64> {

  // get dimensions
  let n = (technical_coefficients_matrix.len() as f64).sqrt() as usize;
  let n_fd = final_demand_matrix.nrows();
  let m_fd = final_demand_matrix.ncols();
  
  // get rowsum of final demand matrix
  let final_demand_rowsum: Vec<f64> = Mat::from_fn(n_fd, m_fd, |row, col| final_demand_matrix[[row, col]])
  .row_iter()
  .map(|x| x.iter().sum::<f64>())
  .collect();

  // initialize objects
  let mut backward_linkage = Mat::zeros(n, n);
  let mut technical_coefficients_matrix_bl = Mat::from_fn(n, n, |row, col| technical_coefficients_matrix[col * n + row]);
  let identity_matrix: &Mat<f64> = &Mat::identity(n, n);
  let sum_output = total_production.iter().sum::<f64>();

  // computes diff in output after extracting a sector demand structure
  for j in 0..n {
    // set j column to zero
    for i in 0..n {
      technical_coefficients_matrix_bl[(i, j)] = 0.0;
    }
    // calculate new Leontief matrix
    let leontief_matrix = identity_matrix - &technical_coefficients_matrix_bl;
    // calculate new Leontief inverse
    let lu = leontief_matrix.partial_piv_lu();
    let leontief_inverse = lu.solve(identity_matrix);
    // calculate new output level
    let new_output: Mat<f64> = leontief_inverse * Mat::from_fn(n, 1, |row, _| final_demand_rowsum[row]);
    // calculate diff in output
    let diff_output = new_output.col_iter().map(|x| x.iter().sum::<f64>()).sum::<f64>() - &sum_output;
    // store diff in output
    backward_linkage[(j, 0)] = diff_output;
    // store relative backward linkage by dividing backward linkage by sum of total production
    backward_linkage[(j, 1)] = diff_output / sum_output;
    // reset j column to original values
    for i in 0..n {
      technical_coefficients_matrix_bl[(i, j)] = technical_coefficients_matrix[j * n + i];
    }
  }

  // return backward linkage
  RArray::new_matrix(n, 2, |rows, cols| backward_linkage[(rows, cols)])

}

#[extendr]
/// Computes forward linkage extraction.
/// 
/// @description
/// Computes impact on supply structure after extracting a given sector \insertCite{miller_input-output_2009}{fio}.
/// 
/// @param allocation_coefficients_matrix A nxn matrix of allocation coefficients.
/// @param value_added_matrix The value-added matrix.
/// @param total_production A 1xn vector of total production.
/// 
/// @references
/// \insertAllCited{}
/// 
/// @noRd
fn compute_extraction_forward(
  allocation_coefficients_matrix: &[f64],
  value_added_matrix: RMatrix<f64>,
  total_production: &[f64]
) -> RMatrix<f64> {

  // get dimensions
  let n = (allocation_coefficients_matrix.len() as f64).sqrt() as usize;
  let n_av = value_added_matrix.nrows();
  let m_av = value_added_matrix.ncols();
  
  // get rowsum of value-added matrix
  let value_added_colsum: Vec<f64> = Mat::from_fn(n_av, m_av, |row, col| value_added_matrix[[row, col]])
  .col_iter()
  .map(|x| x.iter().sum::<f64>())
  .collect();

  // initialize objects
  let mut forward_linkage = Mat::zeros(n, n);
  let mut allocation_coefficients_matrix_bl = Mat::from_fn(n, n, |row, col| allocation_coefficients_matrix[col * n + row]);
  let identity_matrix: &Mat<f64> = &Mat::identity(n, n);
  let sum_output = total_production.iter().sum::<f64>();

  // computes diff in output after extracting a sector demand structure
  for i in 0..n {
    // set j column to zero
    for j in 0..n {
      allocation_coefficients_matrix_bl[(i, j)] = 0.0;
    }
    // calculate new Ghosh matrix
    let ghosh_matrix = identity_matrix - &allocation_coefficients_matrix_bl;
    // calculate new Ghosh inverse
    let lu = ghosh_matrix.partial_piv_lu();
    let ghosh_inverse = lu.solve(identity_matrix);
    // calculate new output level
    let new_output: Mat<f64> = Mat::from_fn(1, n, |_, col| value_added_colsum[col]) * ghosh_inverse;
    // calculate diff in output
    let diff_output = new_output.col_iter().map(|x| x.iter().sum::<f64>()).sum::<f64>() - &sum_output;
    // store diff in output
    forward_linkage[(i, 0)] = diff_output;
    // store relative forward linkage by dividing backward linkage by sum of total production
    forward_linkage[(i, 1)] = diff_output / sum_output;
    // reset j column to original values
    for j in 0..n {
      allocation_coefficients_matrix_bl[(i, j)] = allocation_coefficients_matrix[j * n + i];
    }
  }

  // return backward linkage
  RArray::new_matrix(n, 2, |rows, cols| forward_linkage[(rows, cols)])

}

#[extendr]
/// Computes total impact after extracting a given sector.
/// @param backward_linkage_matrix A nx2 matrix of backward linkage.
/// @param forward_linkage_matrix A nx2 matrix of forward linkage.
/// @details
/// Here we define total impact as the sum of impact on demand and supply structures
/// after removal of a given sector.
/// 
/// @seealso `compute_extraction_backwards()` and `compute_extraction_forward()`.
/// 
/// @examples
/// intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
/// total_production <- matrix(c(100, 200, 300), 1, 3)
/// exports <- matrix(c(10, 20, 30), 3, 1)
/// imports <- matrix(c(5, 10, 15), 1, 3)
/// # instantiate iom object
/// my_iom <- fio::iom$new(
///   "test",
///   intermediate_transactions,
///   total_production,
///   exports = exports,
///   imports = imports
/// )
/// 
/// # Calculate the technical coefficients
/// my_iom$compute_tech_coeff()
/// # calculate the Leontief inverse
/// my_iom$compute_allocation_coeff()
/// # aggregate final demand and value-added matrices
/// my_iom$update_value_added_matrix()
/// my_iom$update_final_demand_matrix()
/// # Calculate effects on both demand and supply structures after extracting a sector
/// my_iom$compute_hypothetical_extraction()
/// # show results
/// my_iom$hypothetical_extraction
/// 
/// @noRd
fn compute_extraction_total(
  backward_linkage_matrix: RMatrix<f64>,
  forward_linkage_matrix: RMatrix<f64>
) -> RMatrix<f64> {

  // get dimensions
  let n_bl = backward_linkage_matrix.nrows();

  // initialize objects
  let mut total_linkage = Mat::zeros(n_bl, 2);

  // computes absolute total linkage
  for i in 0..n_bl {
    total_linkage[(i, 0)] = backward_linkage_matrix[[i, 0]] + forward_linkage_matrix[[i, 0]];
  }

  // computes relative total linkage
  for i in 0..n_bl {
    total_linkage[(i, 1)] = backward_linkage_matrix[[i, 1]] + forward_linkage_matrix[[i, 1]];
  }

  // return total linkage
  RArray::new_matrix(n_bl, 2, |rows, cols| total_linkage[(rows, cols)])

}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod extraction;
  fn compute_extraction_backward;
  fn compute_extraction_forward;
  fn compute_extraction_total;
}
