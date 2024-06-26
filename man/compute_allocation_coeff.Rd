% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extendr-wrappers.R
\name{compute_allocation_coeff}
\alias{compute_allocation_coeff}
\title{Computes allocation coefficients matrix.}
\usage{
compute_allocation_coeff(intermediate_transactions, total_production)
}
\arguments{
\item{intermediate_transactions}{A nxn matrix of intermediate transactions.}

\item{total_production}{A 1xn vector of total production.}
}
\value{
A nxn matrix of allocation coefficients, known as F matrix.
}
\description{
Computes allocation coefficients matrix.
}
