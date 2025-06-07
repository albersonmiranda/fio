// module imports
mod extraction;
mod ghosh;
mod influence;
mod leontief;
mod linkages;
mod multipliers;
mod parallel;

use extendr_api::prelude::*;

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
  mod fio;
  use leontief;
  use multipliers;
  use influence;
  use linkages;
  use ghosh;
  use extraction;
  use parallel;
}
