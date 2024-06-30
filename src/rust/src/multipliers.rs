use extendr_api::prelude::*;
use rayon::prelude::*;
use faer::Mat;

/// * MARK: Output Multipliers

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
/// Calculates type I direct output multiplier.
/// @param technical_coefficients_matrix The open model technical coefficients matrix.
/// @return A 1xn vector of type I direct output multipliers.

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
/// Calculates type I indirect output multiplier.
/// @param technical_coefficients_matrix The open model technical coefficients matrix.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of type I indirect output multipliers.

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

/// * MARK: Employment Multipliers

#[extendr]
/// Calculates employment requirements.
/// @param employment_levels The employment levels.
/// @param total_production The total production.
/// @return A 1xn vector of employment requirements.

fn compute_requirements_employment(
  employment_levels: &[f64],
  total_production: &[f64]
) -> Vec<f64> {
  
  employment_levels.iter()
  .zip(total_production.iter())
  .map(|(employment, production)| employment / production).collect::<Vec<f64>>()
}

#[extendr]
/// Calculates employment generator matrix.
/// @param employment_requirements The employment requirements vector.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A nxn matrix of employment generator.

fn compute_generator_employment(
  employment_requirements: Vec<f64>,
  leontief_inverse_matrix: RMatrix<f64>
) -> RMatrix<f64> {
  
  let n = leontief_inverse_matrix.nrows();

  let leontief_inverse_matrix_faer = Mat::from_fn(n, n, |row, col| leontief_inverse_matrix[(row, col).into()]);
  let employment_requirements_matrix = Mat::from_fn(n, 1, |_, col| employment_requirements[col]);

  // create diagonal matrix from employment requirements
  let employment_requirements_matrix_diag = Mat::column_vector_as_diagonal(&employment_requirements_matrix);

  // calculate generator employment
  let generator_employment = employment_requirements_matrix_diag * leontief_inverse_matrix_faer;

  // convert to R matrix
  RMatrix::new_matrix(n, n, |row, col| generator_employment[(row, col)])
}

#[extendr]
/// Calculates type I employment multiplier.
/// @param employment_requirements The employment requirements.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.

fn compute_multiplier_employment(
  employment_requirements: Vec<f64>,
  leontief_inverse_matrix: RMatrix<f64>
) -> Vec<f64> {
  
  // dimensions
  let n = leontief_inverse_matrix.nrows();
  
  let generator_employment = compute_generator_employment(employment_requirements, leontief_inverse_matrix);

  // convert to faer matrix
  let generator_employment_faer = Mat::from_fn(n, n, |row, col| generator_employment[(row, col).into()]);

  // get column sums
  generator_employment_faer.col_iter().map(|col| col.iter().sum()).collect::<Vec<f64>>()
}

#[extendr]
/// Calculates type I indirect employment multiplier.
/// @param employment_requirements The employment requirements.
/// @param leontief_inverse_matrix The open model Leontief inverse matrix.
/// @return A 1xn vector of type I indirect employment multipliers.

fn compute_multiplier_employment_indirect(
  employment_levels: &[f64],
  total_production: &[f64],
  leontief_inverse_matrix: RMatrix<f64>
) -> Vec<f64> {
  
  let employment_requirements = compute_requirements_employment(employment_levels, total_production);
  let total_effects = compute_multiplier_employment(employment_requirements.clone(), leontief_inverse_matrix);

  // compute indirect effects
  total_effects.iter()
  .zip(employment_requirements.iter())
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
  fn compute_requirements_employment;
  fn compute_generator_employment;
  fn compute_multiplier_employment;
  fn compute_multiplier_employment_indirect;
}
