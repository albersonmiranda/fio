## code to prepare `iom_br_2020_51` dataset goes here


# input-output matrix for Brazil in 2020 (51 sectors)
iom = "inst/extdata/MIP-BR (2020).xlsx"

# intermediate transactions matrix
Z = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "D6:BB56",
  col_names = "D4:BB4",
  row_names = "D4:BB4"
)

# final demand matrix
f = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "BD6:BJ56",
  col_names = "BD4:BJ4",
  row_names = "D4:BB4"
)

# total production matrix
x = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "D79:BB79",
  col_names = "D4:BB4"
)

# added value
v = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "D78:BB78",
  col_names = "D4:BB4"
)

# remuneration # TODO: melhorar a tradução
r = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "D69:BB69",
  col_names = "D4:BB4"
)

# employment
e = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "D80:BB80",
  col_names = "D4:BB4"
)

# family consumption # TODO: melhorar a tradução
C = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "BH6:BH56",
  # TODO: criar asserção para informar erro se tentar informar col_name para vetor linha ou row_name para vetor coluna
  row_names = "D4:BB4"
)

# imports
m = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "D58:BB58",
  col_names = "D4:BB4"
)

# exports
E = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "BD6:BD56",
  row_names = "D4:BB4"
)

# taxes
taxes = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "D59:BB59",
  col_names = "D4:BB4"
)

# formação bruta de capital fixo
fbcf = fio::import_element(
  file = iom,
  sheet = "MIP",
  range = "BI6:BI56",
  row_names = "D4:BB4"
)

iom_br_2020_51 = list(
  Z = Z,
  f = f,
  x = x,
  v = v,
  r = r,
  e = e,
  C = C,
  m = m,
  E = E,
  taxes = taxes,
  fbcf = fbcf
)

usethis::use_data(iom_br_2020_51, overwrite = TRUE)
