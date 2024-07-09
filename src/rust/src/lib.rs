// module imports
mod leontief;
mod multipliers;
mod influence;
mod linkages;
mod ghosh;
mod extraction;

use extendr_api::prelude::*;
use rayon::ThreadPoolBuilder;

#[extendr]
/// Sets max number of threads used by {fio}.
/// @param max_threads
/// Max number of threads enable globally for {fio}

fn set_max_threads(max_threads: usize) {
  ThreadPoolBuilder::new()
      .num_threads(max_threads)
      .build_global()
      .expect("Failed to build global thread pool");
}

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
  fn set_max_threads;
}
