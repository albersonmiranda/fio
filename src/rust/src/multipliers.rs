use extendr_api::prelude::*;
use rayon::prelude::*;
use faer::Mat;

// * MARK: output multipliers

#[extendr]
/// Calculates type I output multiplier.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of type I output multipliers.

fn compute_multiplier_output(
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  // get dimensions (square root of length)
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  // get column sums
  leontief_inverse_matrix
    .par_chunks(n)
    .map(|col| col.iter().sum())
    .collect::<Vec<f64>>()
}

#[extendr]
/// Calculates direct output multiplier.
/// @param technical_coefficients_matrix The open model technical coefficients matrix.
/// @return A 1xn vector of direct output multipliers.

fn compute_multiplier_output_direct(
  technical_coefficients_matrix: &[f64]
) -> Vec<f64> {
  
  // get dimensions (square root of length)
  let n = (technical_coefficients_matrix.len() as f64).sqrt() as usize;

  // get column sums
  technical_coefficients_matrix
    .par_chunks(n)
    .map(|col| col.iter().sum())
    .collect::<Vec<f64>>()
}

#[extendr]
/// Calculates indirect output multiplier.
/// @param technical_coefficients_matrix The open model technical coefficients matrix.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of indirect output multipliers.

fn compute_multiplier_output_indirect(
  technical_coefficients_matrix: &[f64],
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  let total_effects = compute_multiplier_output(leontief_inverse_matrix);
  let direct_effects = compute_multiplier_output_direct(technical_coefficients_matrix);

  // get indirect effects
  total_effects.iter()
  .zip(direct_effects.iter())
  .map(|(total, direct)| total - direct)
  .collect::<Vec<f64>>()
}

// * MARK: other multipliers

#[extendr]
/// Calculates requirements for a given added value vector
/// @param added_value_element An added value vector.
/// @param total_production The total production vector.
/// @return A 1xn vector of a given added value coefficients.

fn compute_requirements_added_value(
  added_value_element: &[f64],
  total_production: &[f64]
) -> Vec<f64> {
  
  added_value_element.iter()
  .zip(total_production.iter())
  .map(|(added_value, production)| added_value / production).collect::<Vec<f64>>()
}

#[extendr]
/// Calculates generator matrix for a given added value vector.
/// @param added_value_requirements The coefficients for a given added value vector.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A nxn matrix of an added value vector generator.

fn compute_generator_added_value(
  added_value_requirements: Vec<f64>,
  leontief_inverse_matrix: RMatrix<f64>
) -> RMatrix<f64> {
  
  let n = leontief_inverse_matrix.nrows();

  let leontief_inverse_matrix_faer = Mat::from_fn(n, n, |row, col| leontief_inverse_matrix[(row, col).into()]);
  let added_value_requirements_matrix = Mat::from_fn(n, 1, |row, _| added_value_requirements[row]);

  // create diagonal matrix from added_value requirements
  let added_value_requirements_matrix_diag = Mat::column_vector_as_diagonal(&added_value_requirements_matrix);

  // calculate generator added_value
  let generator_added_value = added_value_requirements_matrix_diag * leontief_inverse_matrix_faer;

  // convert to R matrix
  RMatrix::new_matrix(n, n, |row, col| generator_added_value[(row, col)])
}

#[extendr]
/// Calculates multiplier for a given added value vector.
/// @param added_value_requirements The coefficients for a given added value vector.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.

fn compute_multiplier_added_value(
  added_value_requirements: Vec<f64>,
  leontief_inverse_matrix: RMatrix<f64>
) -> Vec<f64> {
  
  // dimensions
  let n = leontief_inverse_matrix.nrows();
  
  let generator_added_value = compute_generator_added_value(added_value_requirements, leontief_inverse_matrix);

  // convert to faer matrix
  let generator_added_value_faer = Mat::from_fn(n, n, |row, col| generator_added_value[(row, col).into()]);

  // get column sums
  generator_added_value_faer.col_iter().map(|col| col.iter().sum()).collect::<Vec<f64>>()
}

#[extendr]
/// Calculates indirect multiplier for a given added value vector.
/// @param added_value_element An added value vector.
/// @param total_production The total production vector.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of indirect multipliers for a given added value vector.

fn compute_multiplier_added_value_indirect(
  added_value_element: &[f64],
  total_production: &[f64],
  leontief_inverse_matrix: RMatrix<f64>
) -> Vec<f64> {
  
  let added_value_requirements = compute_requirements_added_value(added_value_element, total_production);
  let total_effects = compute_multiplier_added_value(added_value_requirements.clone(), leontief_inverse_matrix);

  // compute indirect effects
  total_effects.iter()
  .zip(added_value_requirements.iter())
  .map(|(total, direct)| total - direct)
  .collect::<Vec<f64>>()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod multipliers;
  fn compute_multiplier_output;
  fn compute_multiplier_output_direct;
  fn compute_multiplier_output_indirect;
  fn compute_requirements_added_value;
  fn compute_generator_added_value;
  fn compute_multiplier_added_value;
  fn compute_multiplier_added_value_indirect;
}
