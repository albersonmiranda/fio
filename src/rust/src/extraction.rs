use extendr_api::prelude::*;
use faer::{prelude::SpSolver, Mat};

#[extendr]
/// Calculates backward linkage extraction.
/// @param tech_coeff_matrix A nxn matrix of technical coefficients.
/// @param total_production A 1xn vector of total production.
/// @param final_demand_matrix The final demanda matrix.
/// @description
/// Computes impact on demand structure after extracting a given sector.

fn extraction_backward(
  tech_coeff_matrix: &[f64],
  total_production: &[f64],
  final_demand_matrix: RMatrix<f64>
) -> Vec<f64> {

  // get dimensions
  let n = (tech_coeff_matrix.len() as f64).sqrt() as usize;
  let n_fd = final_demand_matrix.nrows();
  let m_fd = final_demand_matrix.ncols();
  
  // get rowsum of final demand matrix
  let final_demand_rowsum: Vec<f64> = Mat::from_fn(n_fd, m_fd, |row, col| final_demand_matrix[(row, col).into()])
  .row_iter()
  .map(|x| x.iter().sum::<f64>())
  .collect();

  // initialize objects
  let mut backward_linkage = vec![0.0; n];
  let mut tech_coeff_matrix_bl = Mat::from_fn(n, n, |row, col| tech_coeff_matrix[col * n + row]);
  let identity_matrix: &Mat<f64> = &Mat::identity(n, n);

  // computes diff in output after extracting a sector demand structure
  for j in 0..n {
    // set j column to zero
    for i in 0..n {
      tech_coeff_matrix_bl[(i, j)] = 0.0;
    }
    // calculate new Leontief matrix
    let leontief_matrix = identity_matrix - &tech_coeff_matrix_bl;
    // calculate new Leontief inverse
    let lu = leontief_matrix.partial_piv_lu();
    let leontief_inverse = lu.solve(identity_matrix);
    // calculate new output level
    let new_output: Mat<f64> = leontief_inverse * Mat::from_fn(n, 1, |row, _| final_demand_rowsum[row]);
    // calculate diff in output
    let diff_output = new_output.col_iter().map(|x| x.iter().sum::<f64>()).sum::<f64>() - total_production.iter().sum::<f64>();
    // store diff in output
    backward_linkage[j] = diff_output;
    }

  // return backward linkage
  backward_linkage

}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod extraction;
  fn extraction_backward;
}
