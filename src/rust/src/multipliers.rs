use extendr_api::prelude::*;
use rayon::prelude::*;
use faer::Mat;

#[extendr]
/// Computes output multiplier.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of type I output multipliers.
/// @noRd
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
/// Computes direct output multiplier.
/// @param technical_coefficients_matrix The open model technical coefficients matrix.
/// @return A 1xn vector of direct output multipliers.
/// @noRd
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
/// Computes indirect output multiplier.
/// @param technical_coefficients_matrix The open model technical coefficients matrix.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of indirect output multipliers.
/// @noRd
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

#[extendr]
/// @description
/// Computes requirements for a given value-added vector (direct multiplier).
/// 
/// @details
/// For others value-added components that doesn't get dedicated slots in the input-output table,
/// users can calculate multipliers by:
/// 
/// 1. computing the requirements for a given value-added vector;
/// 2. computing the generator matrix for a given value-added vector;
/// 3. and, finally, computing the multiplier for a given value-added vector.
/// 
/// Current implementation follows \insertCite{vale_alise_2020}{fio}.
/// 
/// @param value_added_element A value-added vector.
/// @param total_production The total production vector.
/// @return A 1xn vector of a given value-added coefficients.
/// 
/// @references \insertAllCited{}
/// 
/// @seealso
/// [compute_multiplier_value_added()] for computing multipliers.
/// 
/// @examples
/// # data
/// transporation_revenue <- c(100, 200, 300)
/// total_production <- c(1000, 2000, 3000)
/// # compute requirements
/// reqs <- compute_requirements_value_added(transporation_revenue, total_production)
/// reqs
/// 
/// @noRd
fn compute_requirements_value_added(
  value_added_element: &[f64],
  total_production: &[f64]
) -> Vec<f64> {
  
  value_added_element.iter()
  .zip(total_production.iter())
  .map(|(value_added, production)| value_added / production).collect::<Vec<f64>>()
}

#[extendr]
/// Computes generator matrix for a given value-added vector.
/// @param value_added_requirements The coefficients for a given value-added vector.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A nxn matrix of an value-added vector generator.
/// @noRd
fn compute_generator_value_added(
  value_added_requirements: Vec<f64>,
  leontief_inverse_matrix: RMatrix<f64>
) -> RMatrix<f64> {
  
  let n = leontief_inverse_matrix.nrows();

  let leontief_inverse_matrix_faer = Mat::from_fn(n, n, |row, col| leontief_inverse_matrix[(row, col).into()]);
  let value_added_requirements_matrix = Mat::from_fn(n, 1, |row, _| value_added_requirements[row]);

  // create diagonal matrix from value_added requirements
  let value_added_requirements_matrix_diag = Mat::column_vector_as_diagonal(&value_added_requirements_matrix);

  // calculate generator value_added
  let generator_value_added = value_added_requirements_matrix_diag * leontief_inverse_matrix_faer;

  // convert to R matrix
  RMatrix::new_matrix(n, n, |row, col| generator_value_added[(row, col)])
}

#[extendr]
/// @description
/// Computes multiplier for a given value-added vector.
/// 
/// @details
/// For others value-added components that doesn't get dedicated slots in the input-output table,
/// users can calculate multipliers by:
/// 
/// 1. computing the requirements for a given value-added vector;
/// 2. computing the generator matrix for a given value-added vector;
/// 3. and, finally, computing the multiplier for a given value-added vector.
/// 
/// Current implementation follows \insertCite{vale_alise_2020}{fio}.
/// 
/// @param value_added_requirements The coefficients for a given value-added vector.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// 
/// @return A 1xn vector of a given value-added multipliers.
/// 
/// @references \insertAllCited{}
/// 
/// @seealso
/// [compute_requirements_value_added] for computing multipliers.
/// 
/// @examples
/// # data
/// intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
/// transporation_revenue <- c(100, 200, 300)
/// total_production <- c(1750, 2500, 3800)
/// # get technical coefficients matrix using unexported function
/// tech_coeffs <- fio:::compute_tech_coeff(intermediate_transactions, total_production)
/// # get Leontief inverse matrix using unexported function
/// leontief_inverse <- fio:::compute_leontief_inverse(tech_coeffs)
/// # get requirements
/// reqs <- compute_requirements_value_added(transporation_revenue, total_production)
/// # get multipliers
/// multipliers <- compute_multiplier_value_added(reqs, leontief_inverse)
/// multipliers
/// 
/// @noRd
fn compute_multiplier_value_added(
  value_added_requirements: Vec<f64>,
  leontief_inverse_matrix: RMatrix<f64>
) -> Vec<f64> {
  
  // dimensions
  let n = leontief_inverse_matrix.nrows();
  
  let generator_value_added = compute_generator_value_added(value_added_requirements, leontief_inverse_matrix);

  // convert to faer matrix
  let generator_value_added_faer = Mat::from_fn(n, n, |row, col| generator_value_added[(row, col).into()]);

  // get column sums
  generator_value_added_faer.col_iter().map(|col| col.iter().sum()).collect::<Vec<f64>>()
}

#[extendr]
/// Computes indirect multiplier for a given value-added vector.
/// @param value_added_element An value-added vector.
/// @param total_production The total production vector.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of indirect multipliers for a given value-added vector.
/// @noRd
fn compute_multiplier_value_added_indirect(
  value_added_element: &[f64],
  total_production: &[f64],
  leontief_inverse_matrix: RMatrix<f64>
) -> Vec<f64> {
  
  let value_added_requirements = compute_requirements_value_added(value_added_element, total_production);
  let total_effects = compute_multiplier_value_added(value_added_requirements.clone(), leontief_inverse_matrix);

  // compute indirect effects
  total_effects.iter()
  .zip(value_added_requirements.iter())
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
  fn compute_requirements_value_added;
  fn compute_generator_value_added;
  fn compute_multiplier_value_added;
  fn compute_multiplier_value_added_indirect;
}
