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

#' @title Add a daily cumulative water yield column to daily flows
#'
#' @description Add a column of rolling daily cumulative water yields on an annual basis to a daily streamflow data set. Adds the 
#'    water yields from each day with the previous day(s) for each year, in units of millimetres. Converts cumulative 
#'    discharge to a depth of water based on the upstream drainage basin area from \code{basin_area} argument. The cumulative flows 
#'    restart every year and are only calculated in years with complete data.
#'
#' @inheritParams calc_annual_stats
#' @inheritParams add_basin_area
#' @param months Numeric vector of months to add cumulative flows. For example, \code{3} for March, \code{6:8} for Jun-Aug or 
#'    \code{c(10:12,1)} for first four months (Oct-Jan) when \code{water_year_start = 10} (Oct). Default summarizes all 
#'    months (\code{1:12}).
#'    
#' @return A tibble data frame of the source data with an additional column:
#'   \item{Cumul_Yield_mm}{cumulative yield flows for each day for each year, in units of millimetres}
#'
#' @examples
#' # Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
#' if (file.exists(tidyhydat::hy_downloaded_db())) {
#' 
#' # Add a column based on water years starting in August
#' add_cumulative_yield(station_number = "08NM116", 
#'                      water_year_start = 8)
#'                      
#' # Add a column based on water years starting in August with a custom basin area to calculate yield
#' add_cumulative_yield(station_number = "08NM116", 
#'                      water_year_start = 8,
#'                      basin_area = 800)
#'                      
#' }
#' @export


add_cumulative_yield <- function(data,
                                 dates = Date,
                                 values = Value,
                                 groups = STATION_NUMBER,
                                 station_number,
                                 basin_area,
                                 water_year_start = 1,
                                 months = 1:12){
  
  
  
  ## ARGUMENT CHECKS
  ## ---------------
  if (missing(data)) {
    data <- NULL
  }
  if (missing(station_number)) {
    station_number <- NULL
  }
  if (missing(basin_area)) {
    basin_area <- NA
  }
  
  water_year_checks(water_year_start)
  months_checks(months)
  
  
  ## FLOW DATA CHECKS AND FORMATTING
  ## -------------------------------
  
  # Check if data is provided
  flow_data <- flowdata_import(data = data, 
                               station_number = station_number)
  
  # Save the original columns and groups from the flow_data to remove added columns
  orig_cols <- names(flow_data)
  orig_groups <- dplyr::group_vars(flow_data)
  
  # Check and rename columns
  flow_data <- format_all_cols(data = flow_data,
                               dates = as.character(substitute(dates)),
                               values = as.character(substitute(values)),
                               groups = as.character(substitute(groups)))
  
  
  ## SET UP BASIN AREA
  ## -----------------
  
  flow_data <- add_basin_area(flow_data, basin_area = basin_area)
  flow_data$Basin_Area_sqkm_temp <- flow_data$Basin_Area_sqkm
  

  ## FLOW DATA PREP
  ## --------------
  
  # Fill missing dates, add date variables, and add AnalysisYear
  flow_data_temp <- analysis_prep(data = flow_data, 
                                  water_year_start = water_year_start)
  flow_data_temp <- dplyr::filter(flow_data_temp,
                                  Month %in% months)
  
  ## ADD VOLUME COLUMN
  ## -----------------
  
  # Create cumsum function to not create cumsum if any NA's in a given year
  cumsum_na <- function(x) {
    if (any(is.na(x))) {
      return(rep(NA, length(x)))
    } else {
      cumsum(x)
    }
  }
  
  # Add cumulative volume column and ungroup (remove analysisyear group)
  flow_data_temp <- dplyr::ungroup(flow_data_temp)
  flow_data_temp <- dplyr::mutate(dplyr::group_by(flow_data_temp, STATION_NUMBER, WaterYear, .add = TRUE), 
                                  Cumul_Yield_mm = cumsum_na(Value) * 86400 / (Basin_Area_sqkm_temp * 1000))
  flow_data_temp <- dplyr::ungroup(flow_data_temp)
  
  # Get new column and merge back with
  flow_data_temp <- dplyr::select(flow_data_temp, STATION_NUMBER, Date, Cumul_Yield_mm)
  
  # If column existed, replace it, otherwise add it
  if("Cumul_Yield_mm" %in% orig_cols){
    flow_data <- merge(flow_data, flow_data_temp, by = c("STATION_NUMBER", "Date"), all.x = TRUE)
    flow_data$Cumul_Yield_mm <- flow_data$Cumul_Yield_mm.y
    flow_data <- dplyr::select(flow_data, -Cumul_Yield_mm.y, -Cumul_Yield_mm.x)
  } else {
    flow_data <- merge(flow_data, flow_data_temp, by = c("STATION_NUMBER", "Date"), all.x = TRUE)
  }

  
  ## Reformat to original names and groups
  ## -------------------------------------
  
  # Return the original names of the Date and Value columns
  names(flow_data)[names(flow_data) == "STATION_NUMBER"] <- as.character(substitute(groups))
  names(flow_data)[names(flow_data) == "Date"] <- as.character(substitute(dates))
  names(flow_data)[names(flow_data) == "Value"] <- as.character(substitute(values))
  
  # Return columns to original order plus new column
  if("Cumul_Yield_mm" %in% orig_cols){
    flow_data <-  flow_data[,c(orig_cols)]
  } else {
    flow_data <-  flow_data[,c(orig_cols, paste("Cumul_Yield_mm"))]
  }
  
  # Regroup by the original groups
  flow_data <- dplyr::group_by(flow_data, dplyr::across(dplyr::all_of(orig_groups)))
  #flow_data <- dplyr::group_by_at(flow_data, dplyr::vars(orig_groups))  
  
  
  dplyr::as_tibble(flow_data)
}

