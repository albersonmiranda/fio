#' @title
#' World input-output matrix, year 2000, 26 countries, 23 sectors.
#'
#' @description
#' This dataset contains a world input-output matrix for the year 2000, with 26 countries and 23 sectors.
#' The data was compiled by the Computational General Equilibrium Study Center (CEGEC) at the Federal University of Espírito Santo (Brazil).
#'
#' @format ## `world_2000`
#' A R6 class containing a set of matrices:
#' \describe{
#' \item{\code{id}}{Identifier of the new instance}
#' \item{\code{intermediate_transactions}}{Intermediate transactions matrix.}
#' \item{\code{total_production}}{Total production matrix.}
#' \item{\code{household_consumption}}{Household consumption matrix.}
#' \item{\code{government_consumption}}{Government consumption matrix.}
#' \item{\code{final_demand_others}}{Other final demand components matrix (GFCF and Stock Variation).}
#' \item{\code{taxes}}{Taxes matrix.}
#' \item{\code{value_added_others}}{Other value added components matrix (Labor, Capital, Other).}
#' \item{\code{countries}}{Vector with country names.}
#' \item{\code{sectors}}{Vector with sector names.}
#' }