#' @title
#' Brazil input-output matrix, year 2020, 51 sectors
#'
#' @description
#' This dataset contains the Brazilian input-output matrix for the year 2020, with 51 sectors.
#' The data is based on the Brazilian Institute of Geography and Statistics (IBGE) and
#' the Brazilian Institute of Applied Economic Research (IPEA).
#'
#' @format ## `br_2020`
#' A R6 class containing a set of matrices:
#' \describe{
#'   \item{\code{id}}{Identifier of the new instance}
#'   \item{\code{intermediate_transactions}}{Intermediate transactions matrix.}
#'   \item{\code{total_production}}{Total production matrix.}
#'   \item{\code{final_demand}}{Final demand matrix.}
#'   \item{\code{exports}}{Exports matrix.}
#'   \item{\code{imports}}{Imports matrix.}
#'   \item{\code{taxes}}{Taxes matrix.}
#'   \item{\code{value_added}}{Value added matrix.}
#' }
#'
"br_2020"