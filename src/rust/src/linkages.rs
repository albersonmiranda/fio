use extendr_api::prelude::*;
use rayon::prelude::*;
use faer::Mat;

#[extendr]
/// Computes average of all elements of Leontief inverse matrix
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A single value of average of elements of Leontief inverse matrix.
/// @noRd
fn compute_leontief_inverse_average(
  leontief_inverse_matrix: &[f64]
) -> f64 {
  leontief_inverse_matrix.par_iter().sum::<f64>() / (leontief_inverse_matrix.len() as f64)
}

#[extendr]
/// Computes row averages of Leontief inverse matrix
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A vector of row averages.
/// @noRd
fn compute_row_average(
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  // convert to faer matrix
  let leontief_inverse_matrix_faer = Mat::from_fn(n, n, |row, col| leontief_inverse_matrix[col * n + row]);

  // get row means
  let mut indexed_results: Vec<(usize, f64)> = leontief_inverse_matrix_faer.row_iter()
  .enumerate()
  .par_bridge()
  .map(|(index, row)| {
    let sum: f64 = row.iter().sum();
    (index, sum / n as f64)
  })
  .collect();

  // sort by index to ensure order
  indexed_results.sort_by_key(|&(index, _)| index);

  // extract values
  indexed_results.into_iter().map(|(_, value)| value).collect()
}

#[extendr]
/// Computes column averages of Leontief inverse matrix
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A vector of column averages
/// @noRd
fn compute_col_average(
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  leontief_inverse_matrix
    .par_chunks(n)
    .map(|col| col.iter().sum::<f64>() / n as f64)
    .collect()
}

#[extendr]
/// @description Computes sensitivity of dispersion
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A vector of sensitivity of dispersion.
/// @noRd
fn compute_sensitivity_dispersion(
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  // get average of the matrix
  let leontief_average = compute_leontief_inverse_average(leontief_inverse_matrix);
  
  // get row averages
  let rows_average = compute_row_average(leontief_inverse_matrix);

  // divide each row sum by the average of the matrix
  rows_average.par_iter().map(|x| x / leontief_average).collect()
}

#[extendr]
/// Computes power of dispersion
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A vector of power of dispersion.
/// @noRd
fn compute_power_dispersion(
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  // get average of the matrix
  let leontief_average = compute_leontief_inverse_average(leontief_inverse_matrix);
  
  // get column averages
  let cols_average = compute_col_average(leontief_inverse_matrix);

  // divide each row sum by the average of the matrix
  cols_average.par_iter().map(|x| x / leontief_average).collect::<Vec<f64>>()
}

#[extendr]
/// Computes power of dispersion coefficients of variation
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A vector of power of dispersion coefficients of variation.
/// @noRd
fn compute_power_dispersion_cv(
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  // get column averages
  let cols_average = compute_col_average(leontief_inverse_matrix);

  // create faer matrix
  let leontief_inverse_matrix_faer = faer::Mat::from_fn(n, n, |row, col| leontief_inverse_matrix[col * n + row]);

  // leontief_inverse_matrix - column averages
  let lim_minus_ca: Vec<f64> = leontief_inverse_matrix_faer
    .row_iter()
    .flat_map(|row| {
      row.iter()
      .zip(cols_average.iter().cycle())
      .map(|(a, b)| a - b)
    })
    .collect();

  // get square of row sums of lim_minus_ca
  let row_sums = faer::Mat::from_fn(n, n, |row, col| lim_minus_ca[row * n + col])
    .row_iter()
    .map(|row| row.iter().map(|x| x.powi(2)).sum::<f64>())
    .collect::<Vec<f64>>();

  // multiply row_sums by 1 / (n - 1), take the square root and divide by column averages
  row_sums.par_iter()
    .map(|x| (x / (n as f64 - 1.0)).sqrt())
    .zip(&cols_average)
    .map(|(a, b)| a / b)
    .collect::<Vec<f64>>()

}

#[extendr]
/// Computes sensitivity of dispersion coefficients of variation
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A vector of sensitivity of dispersion coefficients of variation.
/// @noRd
fn compute_sensitivity_dispersion_cv(
  leontief_inverse_matrix: &[f64]
) -> Vec<f64> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.len() as f64).sqrt() as usize;

  // get rows averages
  let rows_average = compute_row_average(leontief_inverse_matrix);

  // leontief_inverse_matrix - row averages
  let lim_minus_ra: Vec<f64> = leontief_inverse_matrix.par_iter()
    .enumerate()
    .map(|(i, &value)| value - rows_average[i % n])
    .collect();

  // get column sums of squared elements of lim_minus_ra
  let mut col_sums = lim_minus_ra.par_chunks(n)
    .map(|col| col.iter().map(|x| x.powi(2)).sum::<f64>())
    .collect::<Vec<f64>>();

  // multiply col_sums by 1 / (n - 1), take the square root and divide by row averages
  col_sums.par_iter_mut()
    .map(|x| ((*x * (1.0 / (n as f64 - 1.0))).sqrt()))
    .zip(rows_average.par_iter())
    .map(|(a, b)| a / b)
    .collect::<Vec<f64>>()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod linkages;
  fn compute_power_dispersion_cv;
  fn compute_sensitivity_dispersion_cv;
  fn compute_power_dispersion;
  fn compute_sensitivity_dispersion;
}