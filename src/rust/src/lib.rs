// module imports
mod extraction;
mod ghosh;
mod influence;
mod leontief;
mod linkages;
mod multipliers;

use extendr_api::prelude::*;
use rayon::ThreadPoolBuilder;
use std::panic;

/// @description
/// Get the global parallelism settings from faer
/// @noRd
fn get_parallelism_settings() -> Result<usize> {
    let result = panic::catch_unwind(|| faer::get_global_parallelism());

    match result {
        Ok(faer::Parallelism::Rayon(n)) => Ok(n),
        Ok(_) => Err("Received unexpected parallelism setting".into()),
        Err(_) => Err("Parallelism via faer was not set yet".into()),
    }
}

#[extendr]
/// Sets max number of threads used by fio
///
/// @details
/// Calling this function sets a global limit of threads to Rayon crate, affecting
/// all computations that runs in parallel by default.
///
/// Default behavior of Rayon is to use all available threads (including logical).
/// Setting to 1 will result in single threaded (sequential) computations.
///
/// Initialization of the global thread pool happens exactly once.
/// Once started, the configuration cannot be changed in the current session.
/// If `set_max_threads()` is called again in the same session, it'll result
/// in an error.
///
/// @param max_threads Int.
/// Default is 0 (all threads available). 1 means single threaded.
///
/// @return
/// This functions does not return a value.
///
/// @examples
/// intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
/// total_production <- matrix(c(100, 200, 300), 1, 3)
/// # instantiate iom object
/// my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
/// # to run single threaded (sequential)
/// my_iom$set_max_threads(1L)
/// my_iom$threads
///
/// @noRd
fn set_max_threads(max_threads: usize) {
    // Declare threads variable
    let mut threads: usize = 0;

    // check if global parallelism is set via faer
    match get_parallelism_settings() {
        Ok(value) => {
            threads = value;
        }
        Err(e) => eprintln!("faer parallelism not set yet: {:?}", e),
    }

    // If max_threads is 0, use the maximum number of available threads
    let num_threads = if max_threads == 0 {
        num_cpus::get()
    } else {
        max_threads
    };

    // set rayon global thread pool
    let rayon_settings = ThreadPoolBuilder::new()
        .num_threads(num_threads)
        .build_global();

    match rayon_settings {
        Ok(_) => println!("Global thread pool successfully set."),
        Err(_) => println!(
            "Global thread pool has already been initialized via faer, and is set to {:?}. Cannot change settings in this session.",
            threads
        ),
    };
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
