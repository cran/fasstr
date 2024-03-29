# Copyright 2019 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' @title Add year, month, and day of year variable columns to daily flows
#' 
#' @description Add columns of CalendarYear (YYYY), Month (MM), MonthName (e.g. 'Jan'), WaterYear (YYYY), and DayofYear (1-365 or 366; 
#'    of WaterYear); to a data frame with a column of dates called 'Date'. Water years are designated by the year in which they end. 
#'    For example, Water Year 1999 (starting Oct) is from 1 Oct 1998 (DayofYear 1) to 30 Sep 1999 (DayofYear 365)).
#' 
#' @inheritParams calc_annual_stats
#' 
#' @return A tibble data frame of the source data with additional columns:
#'   \item{CalendarYear}{calendar year}
#'   \item{Month}{numeric month (1 to 12)}
#'   \item{MonthName}{month abbreviation (Jan-Dec)}
#'   \item{WaterYear}{year starting from the selected month start, water_year_start}
#'   \item{DayofYear}{day of the year from the selected month start (1-365 or 366)}
#'
#' @examples
#' # Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
#' if (file.exists(tidyhydat::hy_downloaded_db())) {
#' 
#' # Add date variables using calendar years
#' add_date_variables(station_number = "08NM116")
#' 
#' # Add date variables using water years starting in August
#' add_date_variables(station_number = "08NM116", 
#'                    water_year_start = 8)
#'                    
#' }
#' @export


add_date_variables <- function(data,
                               dates = Date,
                               station_number,
                               water_year_start = 1){  
  
  
  ## ARGUMENT CHECKS
  ## ---------------
  if (missing(data)) {
    data <- NULL
  }
  if (missing(station_number)) {
    station_number <- NULL
  }
  
  water_year_checks(water_year_start)

  ## FLOW DATA CHECKS AND FORMATTING
  ## -------------------------------
  
  # Check if data is provided and import it
  flow_data <- flowdata_import(data = data, station_number = station_number)
  
  # Check and rename columns
  flow_data <-   format_dates_col(data = flow_data, dates = as.character(substitute(dates)))
  
  
  ## ADD CALENDAR YEAR VARIABLES
  ## ---------------------------
  
  # Calculate each date variable
  flow_data$CalendarYear  <- as.numeric(format(as.Date(flow_data$Date), format = "%Y"))
  flow_data$Month  <- as.numeric(format(as.Date(flow_data$Date), format = "%m"))
  flow_data$MonthName <- month.abb[flow_data$Month]
  flow_data$MonthName <- factor(flow_data$MonthName, levels = month.abb[c(water_year_start:12, 1:water_year_start-1)])
  flow_data$WaterYear <- flow_data$CalendarYear
  flow_data$DayofYear <- as.numeric(format(as.Date(flow_data$Date), format = "%j"))
  
  
  ## ADD WATER YEAR VARIABLES (if selected)
  ## --------------------------------------
  
  if (water_year_start > 1){
    # Create values used to calculate the water year day of year
    if (water_year_start == 2) {doy_temp <- c(31, 31)}
    if (water_year_start == 3) {doy_temp <- c(59, 60)}
    if (water_year_start == 4) {doy_temp <- c(90, 91)}
    if (water_year_start == 5) {doy_temp <- c(120, 121)}
    if (water_year_start == 6) {doy_temp <- c(151, 152)}
    if (water_year_start == 7) {doy_temp <- c(181, 182)}
    if (water_year_start == 8) {doy_temp <- c(212, 213)}
    if (water_year_start == 9) {doy_temp <- c(243, 244)}
    if (water_year_start == 10) {doy_temp <- c(273, 274)}
    if (water_year_start == 11) {doy_temp <- c(304, 305)}
    if (water_year_start == 12) {doy_temp <- c(334, 335)}
    
    flow_data$WaterYear <- as.numeric(ifelse(flow_data$Month >= water_year_start,
                                             flow_data$CalendarYear + 1,
                                             flow_data$CalendarYear))
    flow_data$DayofYear <- ifelse(flow_data$Month < water_year_start,
                                  flow_data$DayofYear + (365 - doy_temp[1]),
                                  ifelse((as.Date(with(flow_data, paste(CalendarYear + 1, 01, 01, sep = "-")), "%Y-%m-%d")
                                          - as.Date(with(flow_data, paste(CalendarYear, 01, 01, sep = "-")), "%Y-%m-%d")) == 366,
                                         flow_data$DayofYear-doy_temp[2],
                                         flow_data$DayofYear-doy_temp[1]))
  }
  
  
   ## Reformat to original names and groups
  ## -------------------------------------
  
  # Return the original names of the Date column
  names(flow_data)[names(flow_data) == "Date"] <- as.character(substitute(dates))
  
  
  dplyr::as_tibble(flow_data)
}

