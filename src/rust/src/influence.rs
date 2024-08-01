use extendr_api::prelude::*;
use faer::{prelude::SpSolver, Mat};

#[extendr]
/// @description
/// Computes the field of influence for all sectors.
/// 
/// @details
/// The field of influence shows how changes in direct coefficients are
/// distributed throughout the entire economic system, allowing for the
/// determination of which relationships between sectors are most important
/// within the production process.
/// 
/// It determines which sectors have the greatest influence over others,
/// specifically, which coefficients, when altered, would have the greatest
/// impact on the system as a whole \insertCite{vale_alise_2020}{fio}.
/// 
/// @param tech_coeff_matrix A nxn matrix of technical coefficients.
/// @param leontief_inverse_matrix The open model nxn Leontief inverse matrix.
/// @param epsilon The epsilon value.
///
/// @return Field of influence matrix.
/// 
/// @references
/// \insertAllCited{}
/// 
/// @examples
/// intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
/// total_production <- matrix(c(100, 200, 300), 1, 3)
/// # instantiate iom object
/// my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
/// # calculate the technical coefficients
/// my_iom$compute_tech_coeff()
/// # calculate the Leontief inverse
/// my_iom$compute_leontief_inverse()
/// # calculate field of influence
/// my_iom$compute_field_influence(epsilon = 0.01)
/// my_iom$field_influence
/// 
/// @noRd

fn compute_field_influence(
  tech_coeff_matrix: &[f64],
  leontief_inverse_matrix: &[f64],
  epsilon: f64
) -> RArray<f64, [usize;2]> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  // create faer matrix
  let tech_coeff_matrix = Mat::from_fn(n, n, |row, col| tech_coeff_matrix[col * n + row]);
  let leontief_inverse_matrix = Mat::from_fn(n, n, |row, col| leontief_inverse_matrix[col * n + row]);
  let mut incremental_matrix = Mat::zeros(n, n);
  let mut influence_matrix = Mat::zeros(n, n);

  // loop to calculate influence matrix
  for i in 0..n {
    for j in 0..n {
      // create incremental matrix
      incremental_matrix[(i, j)] = epsilon;
      // calculate new technical coefficients matrix
      let new_tech_coeff_matrix = &tech_coeff_matrix + &incremental_matrix;
      // identity matrix
      let identity_matrix: Mat<f64> = Mat::identity(n, n);
      // calculate new Leontief matrix
      let new_leontief_matrix = &identity_matrix - new_tech_coeff_matrix;
      
      // calculate new Leontief inverse
      let lu = new_leontief_matrix.partial_piv_lu();
      let new_leontief_inverse = lu.solve(identity_matrix);

      // calculate field of influence
      let mut influence = new_leontief_inverse - &leontief_inverse_matrix;
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
