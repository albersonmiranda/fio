# intermediate transactions
data <- data.table::fread(
  "/home/albersonmiranda/Downloads/IOT_2022_ixi/Z.txt",
  sep = "\t",
  header = FALSE,
  skip = 3,
  drop = 1:2
) |>
  as.matrix()
