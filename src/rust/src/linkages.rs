use extendr_api::prelude::*;

#[extendr]
/// Computes average of elements of Leontief inverse matrix
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A single value of average of elements of Leontief inverse matrix.

fn compute_leotief_inverse_average(
  leontief_inverse_matrix: Vec<f64>
) -> f64 {
  leontief_inverse_matrix.iter().sum::<f64>() / (leontief_inverse_matrix.len() as f64)
}

#[extendr]
/// Computes row averages of Leontief inverse matrix
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A vector of row averages.

fn compute_row_average(
  leontief_inverse_matrix: Vec<f64>
) -> Vec<f64> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.clone().len() as f64).sqrt() as usize;

  // get row sums
  let row_sums = leontief_inverse_matrix.clone().chunks(n)
    .fold(vec![0.0; n], |acc, col| {
      acc.iter().zip(col).map(|(a, b)| a + b).collect()
  });

  // divide each row sum by n
  row_sums.iter().map(|x| x / n as f64).collect::<Vec<f64>>()
}

#[extendr]
/// Computes foward linkages
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @description
/// Computes forward linkages from a Leontief inverse matrix.
/// @return A vector of forward linkages.

fn compute_forward_linkages(
  leontief_inverse_matrix: Vec<f64>
) -> Vec<f64> {
  
  // get average of the matrix
  let leontief_average = compute_leotief_inverse_average(leontief_inverse_matrix.clone());
  
  // get row averages
  let rows_average = compute_row_average(leontief_inverse_matrix);

  // divide each row sum by the average of the matrix
  rows_average.iter().map(|x| x / leontief_average).collect::<Vec<f64>>()
}

#[extendr]
/// Computes column averages of Leontief inverse matrix
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @return A vector of column averages

fn compute_col_average(
  leontief_inverse_matrix: Vec<f64>
) -> Vec<f64> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.clone().len() as f64).sqrt() as usize;

  // get column sums
  let column_sums = leontief_inverse_matrix.chunks(n)
    .map(|col| col.iter().sum::<f64>())
    .collect::<Vec<f64>>();

  // divide each col sum by n
  column_sums.iter().map(|x| x / n as f64).collect::<Vec<f64>>()
}

#[extendr]
/// Computes backward linkages
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @description
/// Computes backward linkages from a Leontief inverse matrix.
/// @return A vector of backward linkages.

fn compute_backward_linkages(
  leontief_inverse_matrix: Vec<f64>
) -> Vec<f64> {
  
  // get average of the matrix
  let leontief_average = compute_leotief_inverse_average(leontief_inverse_matrix.clone());
  
  // get column averages
  let cols_average = compute_col_average(leontief_inverse_matrix);

  // divide each row sum by the average of the matrix
  cols_average.iter().map(|x| x / leontief_average).collect::<Vec<f64>>()
}

#[extendr]
/// Computes power of dispersion coefficients of variation
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @description
/// Computes power of dispersion coefficients of variation of an economy.
/// @return A vector of power of dispersion coefficients of variation.

fn compute_power_dispersion(
  leontief_inverse_matrix: Vec<f64>
) -> Vec<f64> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.clone().len() as f64).sqrt() as usize;

  // get column averages
  let cols_average = compute_col_average(leontief_inverse_matrix.clone());

  // leontief_inverse_matrix - column averages
  let leontief_inverse_matrix_minus_col_average = leontief_inverse_matrix.iter()
    .zip(cols_average.iter().cycle())
    .map(|(a, b)| a - b)
    .collect::<Vec<f64>>();

  // get square of each element of leontief_inverse_matrix_minus_col_average
  let leontief_inverse_matrix_minus_col_average_squared = leontief_inverse_matrix_minus_col_average.iter()
    .map(|x| x.powi(2))
    .collect::<Vec<f64>>();

  // get sum of the rows of squared elements
  let sum_of_rows_squared: Vec<f64> = (0..n).map(|i| {
    (0..n).map(|j| {
      let index = i + j * n; // calculate index for column-major order
      leontief_inverse_matrix_minus_col_average_squared[index]
    }).sum()
  }).collect();

  // multiply each element of sum of rows squared by 1 / (n - 1)
  let ratio = sum_of_rows_squared.iter()
    .map(|x| x * (1.0 / (n as f64 - 1.0)))
    .collect::<Vec<f64>>();

  // get square root of ratio
  let ratio_sqrt = ratio.iter()
    .map(|x| x.sqrt())
    .collect::<Vec<f64>>();

  // divide each element of ratio_sqrt by cols averages
  ratio_sqrt.iter()
    .zip(cols_average.iter())
    .map(|(a, b)| a / b)
    .collect::<Vec<f64>>()

}

#[extendr]
/// Computes sensitivity of dispersion coefficients of variation
/// @param leontief_inverse_matrix A nxn matrix of Leontief inverse.
/// @description
/// Computes sensitivity of dispersion coefficients of variation of an economy.
/// @return A vector of sensitivity of dispersion coefficients of variation.

fn compute_sensitivity_dispersion(
  leontief_inverse_matrix: Vec<f64>
) -> Vec<f64> {
  
  // get dimensions
  let n = (leontief_inverse_matrix.clone().len() as f64).sqrt() as usize;

  // get rows averages
  let rows_average = compute_row_average(leontief_inverse_matrix.clone());

  // leontief_inverse_matrix - row averages
  let leontief_inverse_matrix_minus_row_average = leontief_inverse_matrix.iter()
    .zip(rows_average.iter().cycle())
    .map(|(a, b)| a - b)
    .collect::<Vec<f64>>();
  
  // get square of each element of leontief_inverse_matrix_minus_row_average
  let leontief_inverse_matrix_minus_row_average_squared = leontief_inverse_matrix_minus_row_average.iter()
    .map(|x| x.powi(2))
    .collect::<Vec<f64>>();

  // get sum of the columns of squared elements
  let sum_of_cols_squared: Vec<f64> = (0..n).map(|i| {
    (0..n).map(|j| {
      let index = i * n + j; // calculate index for column-major order
      leontief_inverse_matrix_minus_row_average_squared[index]
    }).sum()
  }).collect();

  // multiply each element of sum of cols squared by 1 / (n - 1)
  let ratio = sum_of_cols_squared.iter()
    .map(|x| x * (1.0 / (n as f64 - 1.0)))
    .collect::<Vec<f64>>();

  // get square root of ratio
  let ratio_sqrt = ratio.iter()
    .map(|x| x.sqrt())
    .collect::<Vec<f64>>();

  // divide each element of ratio_sqrt by rows averages
  ratio_sqrt.iter()
    .zip(rows_average.iter())
    .map(|(a, b)| a / b)
    .collect::<Vec<f64>>()

}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod linkages;
  fn compute_forward_linkages;
  fn compute_backward_linkages;
  fn compute_power_dispersion;
  fn compute_sensitivity_dispersion;
}