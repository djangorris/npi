% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{make_full_address}
\alias{make_full_address}
\title{Create full address from elements}
\usage{
make_full_address(df, address_1, address_2, city, state, postal_code)
}
\arguments{
\item{df}{Data frame}

\item{address_1}{Quoted column name in \code{df} containing a character vector of first-street-line addresses}

\item{address_2}{Quoted column name in \code{df} containing a character vector of second-street-line addresses}

\item{city}{Quoted column name in \code{df} containing a character vector of cities}

\item{state}{Quoted column name in \code{df} containing a character vector of two-letter state abbreviations}

\item{postal_code}{Quoted column name in \code{df} containing a character or numeric vector of postal codes}
}
\value{
Character vector containing full one-line addresses
}
\description{
Create full address from elements
}
