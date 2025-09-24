use extendr_api::prelude::*;
use reqwest::blocking::get;
use std::fs::File;
use std::io::copy;
use indicatif::{ProgressBar, ProgressStyle};

#[extendr(invisible)]
/// @title
/// Download WIOD tables
/// @description
/// Downloads World Input-Output Database tables.
/// 
/// @details
/// It downloads multi-region input-output tables from the World Input-Output Database (WIOD) from University of Groningen, Netherlands.
/// 
/// @param year (`string`)\cr
/// Release year from WIOD. One of "2016", "2013" or "long-run".
/// @param out_dir (`string`)\cr
/// Path to download.
/// 
/// @return
/// A message indicating the result of the download operation.
/// 
/// @examples
/// # Download WIOD 2016 tables to temporary directory
/// fio::download_wiod("2016", getwd())
fn download_wiod(
  #[default = r#""2016""#] year: &str,
  #[default = "getwd()"] out_dir: &str,
) -> Result<()> {

  let valid_years = vec!["2016", "2013", "long-run"];
  if !valid_years.contains(&year) {
    return Err("year must be one of 2016, 2013 or long-run".into());
  }
  
  let file = match year {
    "2016" => "199104",
    "2013" => "199123",
    "long-run" => "268666",
    _ => unreachable!("Invalid year")
  };

  let url = format!(
    "https://dataverse.nl/api/access/datafile/{}/",
    file
  );
  
  let out_path = format!("{}/{}.zip", out_dir, year);
  
  // Create progress bar with spinner style
  let pb = ProgressBar::new_spinner();
  pb.set_style(
    ProgressStyle::default_spinner()
      .template("{spinner:.green} {msg}")
      .unwrap()
      .tick_strings(&[
        "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏",
      ])
  );
  pb.set_message(format!("Downloading WIOD data for year {}", year));
  
  // Enable steady tick to make spinner move
  pb.enable_steady_tick(std::time::Duration::from_millis(100));
  
  let mut response = get(&url)
    .map_err(|e| {
      pb.finish_with_message("Download failed!");
      format!("Failed to download file: {}", e)
    })?;
    
  let mut out_file = File::create(&out_path)
    .map_err(|e| {
      pb.finish_with_message("Download failed!");
      format!("Failed to create output file: {}", e)
    })?;
    
  copy(&mut response, &mut out_file)
    .map_err(|e| {
      pb.finish_with_message("Download failed!");
      format!("Failed to copy content: {}", e)
    })?;

  pb.finish_with_message("Done!");

  rprintln!("File successfully saved to: {}", out_path);

  Ok(())
}

extendr_module! {
  mod download;
  fn download_wiod;
}