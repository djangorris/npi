#' @importFrom attempt stop_if_not
#' @importFrom curl has_internet
check_internet <- function() {
  stop_if_not(.x = has_internet(), msg = "Please check your internet connection")
}

#' @importFrom httr status_code
check_status <- function(res) {
  stop_if_not(
    .x = status_code(res),
    .p = ~ .x == 200,
    msg = "The API returned an error"
  )
}


base_url <- "https://npiregistry.cms.hhs.gov/api/"
user_agent <- "http://github.com/frankfarach/npi"


#' Check if candidate NPI number is valid
#'
#' Check whether a number is a valid NPI number per the specifications detailed in the Final Rule for the Standard Unique Health Identifier for Health Care Providers (69 FR 3434).
#'
#' @param x 10-digit candidate NPI number
#' @return Boolean indicating whether \code{npi} is valid
#' @examples
#' is_valid_npi(1234567893)
#' is_valid_npi(1234567898)
#' @seealso \url{https://www.cms.gov/Regulations-and-Guidance/Administrative-Simplification/NationalProvIdentStand/Downloads/NPIcheckdigit.pdf}
#' @references \url{http://scott.sherrillmix.com/blog/tag/luhn-algorithm/}
#' @export
is_valid_npi <- function(x) {
  attempt::stop_if(x, missing, "Please supply an npi as the argument.")
  attempt::stop_if_not(
    x,
    ~ stringr::str_length(.) == 10 &&
      stringr::str_detect(., "\\d{10}"),
    "npi must be a 10-digit number."
  )

  # Prefix the NPI with code for health applications in the US per official
  # requirements
  prefixed_npi <- paste0("80840", x)

  # Validate number using the Luhn algorithm
  luhn_check(prefixed_npi, return_logical = TRUE)
}


#' Validate Luhn check digit
#'
#' \code{luhn_check} validates a number based on the Luhn algorithm.
#' @seealso \url{https://en.wikipedia.org/wiki/Luhn_algorithm}
#' @references \url{http://scott.sherrillmix.com/blog/tag/luhn-algorithm/}
#'
#'
#' @param number Number consisting of digits 0-9
#' @param return_logical Boolean flag to control whether the result is a logical value or remainder
#' @return Boolean. If \code{return_logical} is TRUE, returns a logical value indicating whether the \code{number} validates; if FALSE, returns the remainder from the expected number
luhn_check <- function(number, return_logical = TRUE) {
  numbers <- gsub("[^0-9]", "", as.character(number))
  numbers <- as.numeric(strsplit(numbers, "")[[1]])
  selector <- seq(length(numbers) - 1, 1, -2)
  numbers[selector] <- numbers[selector] * 2
  numbers[numbers > 9] <- numbers[numbers > 9] - 9
  remainder <- sum(numbers) %% 10
  if (return_logical) {
    return(remainder == 0)
  } else {
    remainder
  }
}

#' Clean up credentials
#'
#' @param x Character vector of credentials
#' @return List of cleaned character vectors, with one list element per element of \code{x}
clean_credentials <- function(x) {
  if (!is.character(x))
    stop("x must be a character vector")

  out <- gsub("\\.", "", x)
  out <- stringr::str_split(out, "[,\\s;]+", simplify = FALSE)
  out
}

#' Add hyphen to 9-digit ZIP codes
#'
#' @param x Character or numeric vector containing ZIP code(s)
#'
#' @return Length \code{x} character vector hyphenated for ZIP+4
hyphenate_full_zip <- function(x) {
  ifelse(stringr::str_length(x) > 5 &
           stringr::str_length(x) <= 9 &
           !stringr::str_detect(x, "-"),
         paste0(
           stringr::str_sub(x, 1, 5),
           "-",
           stringr::str_sub(x, 6, 9)
         ),
         x
  )
}

#' Create full address from elements
#'
#' @param df Data frame
#' @param address_1 Quoted column name in \code{df} containing a character vector of first-street-line addresses
#' @param address_2 Quoted column name in \code{df} containing a character vector of second-street-line addresses
#' @param city Quoted column name in \code{df} containing a character vector of cities
#' @param state Quoted column name in \code{df} containing a character vector of two-letter state abbreviations
#' @param postal_code Quoted column name in \code{df} containing a character or numeric vector of postal codes
#'
#' @return Character vector containing full one-line addresses
make_full_address <-
  function(df,
           address_1,
           address_2,
           city,
           state,
           postal_code) {
    stopifnot(is.data.frame(df),
              all(c(
                address_1, address_2, city, state, postal_code
              ) %in% names(df)))

    stringr::str_c(
        stringr::str_trim(df[[address_1]], "both"),
        " ",
        stringr::str_trim(df[[address_2]], "both"),
        ", ",
        stringr::str_trim(df[[city]], "both"),
        ", ",
        stringr::str_trim(df[[state]], "both"),
        " ",
        stringr::str_trim(df[[postal_code]], "both")
      )
  }
