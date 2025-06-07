use extendr_api::prelude::*;
use faer::Par;
use core::num;
use std::panic;

/// @description
/// Get the global parallelism settings from faer
/// @noRd
fn get_parallelism_settings() -> Result<usize> {
    let result = panic::catch_unwind(|| faer::get_global_parallelism());

    match result {
        Ok(faer::Par::Rayon(n)) => Ok(n.get()),
        Ok(faer::Par::Seq) => Ok(1),
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
///
/// @noRd
fn set_max_threads(max_threads: usize) {

    let threads = get_parallelism_settings().unwrap_or(0);
    let num_threads = if max_threads == 0 {
        num_cpus::get()
    } else {
      max_threads
    };

    match panic::catch_unwind(|| faer::set_global_parallelism(Par::rayon(num_threads))) {
      Ok(_) => (),
      Err(_) => panic!(
        "Global thread pool was already initialized with {} threads. Cannot change it in this session.",
        threads
      ),
    }
  }

extendr_module! {
  mod parallel;
  fn set_max_threads;
}