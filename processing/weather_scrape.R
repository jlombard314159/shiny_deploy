library(dbplyr)
library(dplyr)

#SEE: https://wcc.sc.egov.usda.gov/awdbRestApi/swagger-ui.html#/

## SEE https://www.nrcs.usda.gov/sites/default/files/2023-03/AWDB%20Web%20Service%20User%20Guide.pdf

#' Query the last x days for SNOTEL
#'
#' Grab SNOTEL data from a given set of stations for a period of time. NOTE:
#' there is a limit of 1000 calls ata time so best to run this function
#' multiple times
#'
#' @param date_start Provide a character of dates to start the daa collection
#' for 
#'
#' @param duration Option for the time breakdown of date. valid options are
#' daily, hourly, semimonthly, monthly
#'
#' @param num_days The number of days for the data to span over
#'
#' @param stations
#' @return A list (JSON) of measurements
#' @export
query_snotel <- function(date_start, duration = "DAILY",
                         num_days = 5,
                         station = "*:CO:SNTL",
                         element = "WTEQ") {

  date_start <- as.Date(date_start, format = "%m-%d-%Y")

  begin_date <- date_start - num_days

  current_date <- format(date_start, "%m/%d/%Y")
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
    stationTriplets = station
  )

  ping_api <- httr2::request(snotel_api) %>%
    httr2::req_url_query(!!!params) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json()

  return(ping_api)
}

#' Query multiple items from SNOTEL
#'
#' In order to avoid getting an overload error to the API, we will query one
#' element at a time.
#'
#' @param elements A vector of values to query the SNOTEL api multiple times
#' @return A list of lists (JSON)
#' @export
query_multiple <- function(elements, ...) {

  results <- list()
  for (value in elements){
    api_result <- query_snotel(element = value, ...)
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

  # convert R vector to the API format
  station_api <- paste(station_names, collapse = ",")

  params <- list(
    activeOnly = "true",
    stationTriplets = station_api
  )

  station_ping_api <- httr2::request(meta_api) %>%
    httr2::req_url_query(!!!params) %>%
    httr2::req_perform(.) %>%
    httr2::resp_body_json()

  station_df <- dplyr::bind_rows(station_ping_api)

  return(station_df)
}


#' Convert JSON to a pretty dataframe
#'
#' Weather data needs to be extracted to be usable. In JSON format
#'
#' @param A list (JSON) that has measurements for a given set of elements
#' @return A dataframe of measurements
#' @export
extract_weather <- function(weather_list) {

  final_data <- data.frame()
  for (element in weather_list) {

    measurements <- dplyr::bind_rows(element$data[[1]]$values)

    output_data <- data.frame("station_name" = element$stationTriplet,
                              "element" = element$data[[1]]$stationElement$elementCode,
                              "duration" = element$data[[1]]$stationElement$durationName,
                              "dates" = measurements$date,
                              "values" = measurements$value)

    final_data <- rbind(final_data, output_data)

  }

  return(final_data)

}

#------------------------
# Run the code 
# TODO: Run multiple years

results <- query_multiple(elements = c("WTEQ", "SNWD", "TAVG"),
                          num_days = 30,
                          date_start = "12-20-2023")

weather_data <- extract_weather(results)

station_data <- query_snotel_meta(unique(weather_data$station_name)) %>%
  select(c("stationTriplet",
           "stateCode", "name", "elevation", "latitude", "longitude"))

weather_complete <- weather_data %>%
  left_join(station_data, by = c("station_name" = "stationTriplet"))

saveRDS(weather_complete, "weather_test.rds")
