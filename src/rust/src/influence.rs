use extendr_api::prelude::*;
use faer;
use faer::prelude::SpSolver;

#[extendr]
/// Calculates field of influence given a technical change.
/// @param tech_coeff_matrix A nxn matrix of technical coefficients.
/// @param leontief_inverse_matrix The open model nxn Leontief inverse matrix.
/// @param epsilon The epsilon value.
/// @description
/// Calculates total field of influence given a incremental change in the technical coefficients matrix.
/// @return Field of influence matrix.

fn compute_field_influence(
  tech_coeff_matrix: Vec<f64>,
  leontief_inverse_matrix: Vec<f64>,
  epsilon: f64
) -> RArray<f64, [usize;2]> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  // create faer matrix
  let tech_coeff_matrix = faer::Mat::from_fn(n, n, |row, col| tech_coeff_matrix[col * n + row]);
  let leontief_inverse_matrix = faer::Mat::from_fn(n, n, |row, col| leontief_inverse_matrix[col * n + row]);
  let mut incremental_matrix = faer::Mat::zeros(n, n);
  let mut influence_matrix = faer::Mat::zeros(n, n);

  // loop to calculate influence matrix
  for i in 0..n {
    for j in 0..n {
      // create incremental matrix
      incremental_matrix[(i, j)] = epsilon;
      // calculate new technical coefficients matrix
      let new_tech_coeff_matrix = tech_coeff_matrix.clone() + incremental_matrix.clone();
      // identity matrix
      let identity_matrix:faer::Mat<f64> = faer::Mat::identity(n, n);
      // calculate new Leontief matrix
      let new_leontief_matrix = identity_matrix.clone() - new_tech_coeff_matrix;
      
      // calculate new Leontief inverse
      let lu = new_leontief_matrix.partial_piv_lu();
      let new_leontief_inverse = lu.solve(identity_matrix);

      // calculate field of influence
      let mut influence = new_leontief_inverse - leontief_inverse_matrix.clone();
      for x in 0..n {
        for y in 0..n {
          // calculate field of influence
          influence[(x, y)] = f64::powf(influence[(x, y)] / epsilon, 2.0);
          //sum elements
          influence_matrix[(x, y)] += influence[(x, y)];
        }
      }
      // reset incremental matrix
      incremental_matrix[(i, j)] = 0.0; 
    }
  }

  // convert to R matrix
  let influence_matrix_r = RArray::new_matrix(n, n, |r, c| influence_matrix[(c, r)]);
  influence_matrix_r

}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod influence;
  fn compute_field_influence;
}
