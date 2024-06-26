use extendr_api::prelude::*;
use faer::{prelude::SpSolver, Mat};

#[extendr]
/// Calculates backward linkage extraction.
/// @param technical_coefficients_matrix A nxn matrix of technical coefficients.
/// @param final_demand_matrix The final demand matrix.
/// @param total_production A 1xn vector of total production.
/// @description
/// Computes impact on demand structure after extracting a given sector.

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
  let final_demand_rowsum: Vec<f64> = Mat::from_fn(n_fd, m_fd, |row, col| final_demand_matrix[(row, col).into()])
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
/// Calculates forward linkage extraction.
/// @param allocation_coefficients_matrix A nxn matrix of allocation coefficients.
/// @param added_value_matrix The added value matrix.
/// @param total_production A 1xn vector of total production.
/// @description
/// Computes impact on supply structure after extracting a given sector.

fn compute_extraction_forward(
  allocation_coefficients_matrix: &[f64],
  added_value_matrix: RMatrix<f64>,
  total_production: &[f64]
) -> RMatrix<f64> {

  // get dimensions
  let n = (allocation_coefficients_matrix.len() as f64).sqrt() as usize;
  let n_av = added_value_matrix.nrows();
  let m_av = added_value_matrix.ncols();
  
  // get rowsum of added value matrix
  let added_value_colsum: Vec<f64> = Mat::from_fn(n_av, m_av, |row, col| added_value_matrix[(row, col).into()])
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
    let new_output: Mat<f64> = Mat::from_fn(1, n, |_, col| added_value_colsum[col]) * ghosh_inverse;
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
/// Calculates total extraction
/// @param backward_linkage_matrix A nx2 matrix of backward linkage.
/// @param forward_linkage_matrix A nx2 matrix of forward linkage.
/// @description
/// Computes total impact after extracting a given sector.

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
    total_linkage[(i, 0)] = backward_linkage_matrix[(i, 0).into()] + forward_linkage_matrix[(i, 0).into()];
  }

  // computes relative total linkage
  for i in 0..n_bl {
    total_linkage[(i, 1)] = backward_linkage_matrix[(i, 1).into()] + forward_linkage_matrix[(i, 1).into()];
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
