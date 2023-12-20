library(dbplyr)

#SEE: https://wcc.sc.egov.usda.gov/awdbRestApi/swagger-ui.html#/

## SEE https://www.nrcs.usda.gov/sites/default/files/2023-03/AWDB%20Web%20Service%20User%20Guide.pdf

user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) 
                         AppleWebKit/537.36 (KHTML, like Gecko) 
                         Chrome/80.0.3987.149 Safari/537.36 
                         JAL is pinging your API."


#' Query the last x days for SNOTEL
#'
#' Grab SNOTEL data from a given set of stations for a period of time. NOTE:
#' there is a limit of 1000 calls ata time so best to run this function
#' multiple times
#'
#' @param duration Option for the time breakdown of date. valid options are
#' daily, hourly, semimonthly, monthly
#'
#' @param num_days The number of days for the data to span over
#'
#' @param stations
#' @return A list (JSON) of measurements
#' @export
query_snotel <- function(duration = "DAILY",
                         num_days = 5,
                         stations = "*:CO:SNTL",
                         element = "WTEQ") {

  current_date <- Sys.Date()
  begin_date <- current_date - num_days

  current_date <- format(current_date, "%m/%d/%Y")
  begin_date <- format(begin_date, "%m/%d/%Y")

  snotel_api <- "https://wcc.sc.egov.usda.gov/awdbRestApi/services/v1/data?"

  params <- list(
    beginDate = begin_date,
    centralTendencyType = "NONE",
    duration = duration,
    elements = element,
    endDate = current_date,
    periodRef = "END",
    returnFlags = "false",
    returnOriginalValues = "false",
    returnSuspectData = "false",
    stationTriplets = stations
  )
  browser()
  ping_api <- httr2::request(snotel_api) %>%
    httr2::req_url_query(!!!params) %>%
    httr2::req_headers("user-agent" = user_agent) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json()

  return(ping_api)
}

##NOTE: currently a bug with the asterisk symbol in station tripelts ( ithin)

#' Query multiple items from SNOTEL
#'
#' In order to avoid getting an overload error to the API, we will query one
#' element at a time.
#'
#' @param elements A vector of values to query the SNOTEL api multiple times
#' @return A list of lists (JSON)
#' @export
query_multiple <- function(elements) {

  results <- list()
  for (value in elements){
    api_result <- query_snotel(element = value)
    results <- append(results, api_result)
  }

  return(results)
}

#' Query metadata for a given station
#'
#' Some information for stations are constant and we can query after we get
#' all of the information from our weather query
#'
#' @param station_names A vector of string to get the metadata for a given
#' station
#'
#' @return A dataframe of station information
#' @export
query_snotel_meta <- function(station_names) {

  meta_api <- "https://wcc.sc.egov.usda.gov/awdbRestApi/services/v1/stations?"

  params <- list(
    activeOnly = "true",
    stationNames = station_names
  )

  station_ping_api <- httr2::request(meta_api) %>%
    httr2::req_url_query(!!!params) %>%
    httr2::req_headers("user-agent" = user_agent) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json()

  return(station_ping_api)
}


#' Convert JSON to a pretty dataframe
#'
#' xx
#'
#' @param xx
#' @return A dataframe of measurements
#' @export
format_results <- function() {

}



test<- 'https://wcc.sc.egov.usda.gov/awdbRestApi/services/v1/data?beginDate=12%2F15%2F2023&centralTendencyType=NONE&duration=DAILY&elements=WTEQ&endDate=12%2F20%2F2023&periodRef=END&returnFlags=false&returnOriginalValues=false&returnSuspectData=false&stationTriplets=*%3ACO%3ASNTL'

test_response <- httr2::request(test) %>% 
  httr2::req_perform(.)