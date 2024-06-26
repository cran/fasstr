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



#' @title Plot flow duration curves
#'
#' @description Plots flow duration curves of flow data from a daily streamflow data set. Plots the percent time flows are 
#'    equalled or exceeded. Calculates statistics from all values, unless specified. Data calculated using 
#'    \code{calc_longterm_stats()} function then converted for plotting. Returns a list of plots.
#'
#' @inheritParams calc_longterm_daily_stats
#' @inheritParams plot_annual_stats
#' @param months Numeric vector of month curves to plot. \code{NA} if no months required. Default \code{1:12}.
#' @param include_longterm Logical value indicating whether to include long-term curve of all data. Default \code{TRUE}.
#'
#' @return A list of ggplot2 objects with the following for each station provided:
#'   \item{Flow_Duration}{a plot that contains flow duration curves for each month, long-term, and (option) customized months}
#'   
#' @seealso \code{\link{calc_longterm_daily_stats}}
#'   
#' @examples
#' \dontrun{
#' 
#' # Working examples:
#' 
#' # Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
#' if (file.exists(tidyhydat::hy_downloaded_db())) {
#' 
#' # Plot flow durations using a data frame and data argument with defaults
#' flow_data <- tidyhydat::hy_daily_flows(station_number = "08NM116")
#' plot_flow_duration(data = flow_data,
#'                     start_year = 1980)
#' 
#' # Plot flow durations using station_number argument with defaults
#' plot_flow_duration(station_number = "08NM116",
#'                    start_year = 1980)
#' 
#' # Plot flow durations and add custom stats for July-September
#' plot_flow_duration(station_number = "08NM116",
#'                    start_year = 1980,
#'                    custom_months = 7:9,
#'                    custom_months_label = "Summer")
#'                    
#' }
#' }
#' @export



plot_flow_duration <- function(data,
                               dates = Date,
                               values = Value,
                               groups = STATION_NUMBER,
                               station_number,
                               roll_days = 1,
                               roll_align = "right",
                               water_year_start = 1,
                               start_year,
                               end_year,
                               exclude_years,
                               custom_months,
                               custom_months_label,
                               complete_years = FALSE,
                               ignore_missing = FALSE,
                               months = 1:12,
                               include_longterm = TRUE,
                               log_discharge = TRUE,
                               log_ticks = ifelse(log_discharge, TRUE, FALSE),
                               include_title = FALSE){
  
  
  
  ## ARGUMENT CHECKS
  ## ---------------
  
  if (missing(data)) {
    data <- NULL
  }
  if (missing(station_number)) {
    station_number <- NULL
  }
  if (missing(start_year)) {
    start_year <- 0
  }
  if (missing(end_year)) {
    end_year <- 9999
  }
  if (missing(exclude_years)) {
    exclude_years <- NULL
  }
  if (missing(custom_months)) {
    custom_months <- NULL
  }
  if (missing(custom_months_label)) {
    custom_months_label <- "Custom-Months"
  }
  
  logical_arg_check(log_discharge)
  log_ticks_checks(log_ticks, log_discharge)
  custom_months_checks(custom_months, custom_months_label)
  logical_arg_check(include_title)
  logical_arg_check(include_longterm)
  
  
  
  ## FLOW DATA CHECKS AND FORMATTING
  ## -------------------------------
  
  # Check if data is provided and import it
  flow_data <- flowdata_import(data = data, station_number = station_number)
  
  # Check and rename columns
  flow_data <- format_all_cols(data = flow_data,
                               dates = as.character(substitute(dates)),
                               values = as.character(substitute(values)),
                               groups = as.character(substitute(groups)),
                               rm_other_cols = TRUE)
  
  ## CALC STATS
  ## ----------
  
  percentiles_data <- calc_longterm_daily_stats(data = flow_data,
                                                percentiles = c(.01,.1,.2:9.8,10:90,90.2:99.8,99.9,99.99),
                                                roll_days = roll_days,
                                                roll_align = roll_align,
                                                water_year_start = water_year_start,
                                                start_year = start_year,
                                                end_year = end_year,
                                                exclude_years = exclude_years,
                                                complete_years = complete_years,
                                                custom_months = custom_months,
                                                ignore_missing = ignore_missing)
  
  
  
  # Setup and calculate the probabilites
  percentiles_data <- dplyr::select(percentiles_data, -Mean, -Median, -Maximum, -Minimum)
  percentiles_data <- tidyr::gather(percentiles_data, Percentile, Value, -STATION_NUMBER, -Month)
  percentiles_data <- dplyr::mutate(percentiles_data, Percentile = 100 - as.numeric(gsub("P", "", Percentile)))
  
  # Filter for months and longterm selected to plot
  include <- month.abb[months]
  if (include_longterm) { include <- c(include, "Long-term") }
  if (!is.null(custom_months)) { include <- c(include, "Custom-Months") }
  percentiles_data <- dplyr::filter(percentiles_data, Month %in% include)
  
  # Rename the custom months
  if (!is.null(custom_months)) { 
    levels(percentiles_data$Month) <- c(levels(percentiles_data$Month), custom_months_label)    
    percentiles_data <- dplyr::mutate(percentiles_data,
                                      Month = replace(Month, Month == "Custom-Months", custom_months_label))
  }
  
  # Create list of colours for plot, and add custom_months if necessary
  colour_list <-  c("Jan" = "dodgerblue3", "Feb" = "skyblue1", "Mar" = "turquoise",
                    "Apr" = "forestgreen", "May" = "limegreen", "Jun" = "gold", "Jul" = "orange",
                    "Aug" = "red", "Sep" = "darkred", "Oct" = "orchid", "Nov" = "purple3",
                    "Dec" = "midnightblue", "Long-term" = "black")
  
  colour_list <- colour_list[c(months, 13)]
  
  if (!include_longterm) {
    colour_list <- colour_list[names(colour_list) != "Long-term"]
  }
  
  if (!is.null(custom_months)) { 
    colour_list[[ custom_months_label ]] <- "grey60"
  }
  
  if (all(is.na(percentiles_data$Value))) {
    percentiles_data[is.na(percentiles_data)] <- 1
  }
  
  ## PLOT STATS
  ## ----------
  
  # Create axis label based on input columns
  y_axis_title <- ifelse(as.character(substitute(values)) == "Volume_m3", "Volume (cubic metres)", #expression(Volume~(m^3))
                         ifelse(as.character(substitute(values)) == "Yield_mm", "Yield (mm)", 
                                "Discharge (cms)")) #expression(Discharge~(m^3/s))
  
  flow_plots <- dplyr::group_by(percentiles_data, STATION_NUMBER)
  flow_plots <- tidyr::nest(flow_plots)
  flow_plots <- dplyr::mutate(
    flow_plots,
    plot = purrr::map2(
      data, STATION_NUMBER,
      ~ggplot2::ggplot(data = ., ggplot2::aes(x = Percentile, y = Value, colour = Month)) +
        ggplot2::geom_line(na.rm = TRUE) +
        {if(!log_discharge) ggplot2::scale_y_continuous(expand = c(0,0), breaks = scales::pretty_breaks(n = 8),
                                                        labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)))} +
        {if(log_discharge) ggplot2::scale_y_log10(expand = c(0, 0), breaks = scales::log_breaks(n = 8, base = 10),
                                                  labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)))} +  
        ggplot2::scale_x_continuous(expand = c(0,0), breaks = scales::pretty_breaks(n = 10)) +
        ggplot2::ylab(y_axis_title) +
        ggplot2::xlab("% Time flow equalled or exceeded") +
        ggplot2::scale_color_manual(values = colour_list) +
        {if (log_discharge & log_ticks) ggplot2:: annotation_logticks(sides = "l", base = 10, colour = "grey25", size = 0.3, short = ggplot2::unit(.07, "cm"),
                                                                      mid = ggplot2::unit(.15, "cm"), long = ggplot2::unit(.2, "cm"))}+
        ggplot2::labs(color = 'Period') +
        {if (include_title & unique(.y) != "XXXXXXX") ggplot2::labs(color = paste0(.y,'\n \nPeriod')) } +
        ggplot2::theme_bw() +
        ggplot2::theme(panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
                       panel.grid = ggplot2::element_line(size = .2),
                       legend.justification = "right",
                       axis.text = ggplot2::element_text(size = 10, colour = "grey25"),
                       axis.title = ggplot2::element_text(size = 12, colour = "grey25"),
                       legend.text = ggplot2::element_text(size = 9, colour = "grey25"))
    ))
  
  # Create a list of named plots extracted from the tibble
  plots <- flow_plots$plot
  if (nrow(flow_plots) == 1) {
    names(plots) <- "Flow_Duration"
  } else {
    names(plots) <- paste0(flow_plots$STATION_NUMBER, "_Flow_Duration")
  }
  
  plots
  
}
