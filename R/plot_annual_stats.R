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


#' @title Plot annual summary statistics (as lines)
#'
#' @description Plots means, medians, maximums, minimums, and percentiles for each year from all years of a daily streamflow 
#'    data set. Calculates statistics from all values, unless specified. Data calculated using \code{calc_annual_stats()} function.
#'    Returns a list of plots.
#'
#' @inheritParams calc_annual_stats
#' @param log_discharge Logical value to indicate plotting the discharge axis (Y-axis) on a logarithmic scale. Default \code{FALSE}.
#' @param log_ticks Logical value to indicate plotting logarithmic scale ticks when \code{log_discharge = TRUE}. Ticks will not
#'    appear when \code{log_discharge = FALSE}. Default to \code{TRUE} when \code{log_discharge = TRUE}.
#' @param include_title Logical value to indicate adding the group/station number to the plot, if provided. Default \code{FALSE}.
#' @param percentiles Numeric vector of percentiles to calculate. Set to \code{NA} if none required. Default \code{NA}.
#' 
#'
#' @return A list of ggplot2 objects for with the following plots (percentile plots optional) for each station provided:
#'   \item{Annual_Stats}{a plot that contains annual statistics}
#'   Default plots on each object:  
#'   \item{Mean}{annual mean of all daily flows}
#'   \item{Median}{annual median of all daily flows}
#'   \item{Maximum}{annual maximum of all daily flows}
#'   \item{Minimum}{annual minimum of all daily flows}
#'   
#' @seealso \code{\link{calc_annual_stats}}
#'   
#' @examples
#' # Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
#' if (file.exists(tidyhydat::hy_downloaded_db())) {
#' 
#' # Plot annual statistics using a data frame and data argument with defaults
#' flow_data <- tidyhydat::hy_daily_flows(station_number = "08NM116")
#' plot_annual_stats(data = flow_data)
#' 
#' # Plot annual statistics using station_number argument with defaults
#' plot_annual_stats(station_number = "08NM116")
#' 
#' # Plot annual statistics regardless if there is missing data for a given year
#' plot_annual_stats(station_number = "08NM116",
#'                   ignore_missing = TRUE)
#'                   
#' # Plot annual statistics for water years starting in October
#' plot_annual_stats(station_number = "08NM116",
#'                   water_year_start = 10)
#'                   
#' # Plot annual statistics with custom years and percentiles
#' plot_annual_stats(station_number = "08NM116",
#'                   start_year = 1981,
#'                   end_year = 2010,
#'                   exclude_years = c(1991,1993:1995),
#'                   percentiles = c(25,75))
#' 
#'                   
#' }
#' @export


plot_annual_stats <- function(data,
                              dates = Date,
                              values = Value,
                              groups = STATION_NUMBER,
                              station_number,
                              percentiles,
                              roll_days = 1,
                              roll_align = "right",
                              water_year_start = 1,
                              start_year,
                              end_year,
                              exclude_years,
                              months = 1:12,
                              complete_years = FALSE,
                              ignore_missing = FALSE,
                              allowed_missing = ifelse(ignore_missing,100,0),
                              log_discharge = FALSE,
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
  if (missing(percentiles)) {
    percentiles <- NA
  }
  if (missing(exclude_years)) {
    exclude_years <- NULL
  }
  if (missing(start_year)) {
    start_year <- 0
  }
  if (missing(end_year)) {
    end_year <- 9999
  }
  
  logical_arg_check(log_discharge) 
  log_ticks_checks(log_ticks, log_discharge)
  logical_arg_check(include_title)
  
  
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
  
  annual_stats <- calc_annual_stats(data = flow_data,
                                    percentiles = percentiles,
                                    roll_days = roll_days,
                                    roll_align = roll_align,
                                    water_year_start = water_year_start,
                                    start_year = start_year,
                                    end_year = end_year,
                                    exclude_years = exclude_years, 
                                    months = months,
                                    complete_years = complete_years,
                                    ignore_missing = ignore_missing,
                                    allowed_missing = allowed_missing)
  
  # Remove all leading NA years
  annual_stats <- dplyr::filter(dplyr::group_by(annual_stats, STATION_NUMBER),
                                Year >= Year[min(which(!is.na(.data[[names(annual_stats)[3]]])))])
  
  annual_stats_plot <- tidyr::gather(annual_stats, Statistic, Value, -Year, -STATION_NUMBER)
  annual_stats_plot <- dplyr::mutate(annual_stats_plot, 
                                     Statistic = factor(Statistic, levels = colnames(annual_stats[-(1:2)])))
  
  ## PLOT STATS
  ## ----------
  
  # Create axis label based on input columns
  y_axis_title <- ifelse(as.character(substitute(values)) == "Volume_m3", "Volume (cubic metres)", #expression(Volume~(m^3))
                         ifelse(as.character(substitute(values)) == "Yield_mm", "Yield (mm)", 
                                "Discharge (cms)")) #expression(Discharge~(m^3/s))
  
  # Create plots for each STATION_NUMBER in a tibble (see: http://www.brodrigues.co/blog/2017-03-29-make-ggplot2-purrr/)
  tidy_plots <- dplyr::group_by(annual_stats_plot, STATION_NUMBER)
  tidy_plots <- tidyr::nest(tidy_plots)
  tidy_plots <- dplyr::mutate(
    tidy_plots,
    plot = purrr::map2(
      data, STATION_NUMBER, 
      ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, color = Statistic, fill = Statistic)) +
        ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
        ggplot2::geom_line(na.rm = TRUE) +
        ggplot2::geom_point(na.rm = TRUE, shape = 21, size = 2, colour = "black") +
        {if(!log_discharge) ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.02)),
                                                        breaks = scales::pretty_breaks(n = 8),
                                                        labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)))} +
        {if(log_discharge) ggplot2::scale_y_log10(expand = ggplot2::expansion(mult = c(0.02, 0.02)),
                                                  breaks = scales::log_breaks(n = 8, base = 10),
                                                  labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)))} +
        {if(log_discharge & log_ticks) ggplot2::annotation_logticks(
          base = 10, "l", colour = "grey25", size = 0.3, short = ggplot2::unit(.07, "cm"), 
          mid = ggplot2::unit(.15, "cm"), long = ggplot2::unit(.2, "cm"))} +
        ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 8))+
        {if(length(unique(annual_stats_plot$Year)) < 8) ggplot2::scale_x_continuous(breaks = unique(annual_stats_plot$Year))}+
        ggplot2::expand_limits(y = 0) +
        ggplot2::ylab(y_axis_title)+
        ggplot2::xlab(ifelse(water_year_start ==1, "Year", "Water Year"))+
        ggplot2::scale_fill_viridis_d()+
        ggplot2::scale_colour_viridis_d()+
        ggplot2::theme_bw() +
        ggplot2::labs(fill = 'Annual Statistics') +  
        ggplot2::guides(colour = "none")+
        {if (include_title & .y != "XXXXXXX") ggplot2::labs(color = paste0(.y,'\n \nAnnual Statistics')) }+    
        ggplot2::theme(legend.position = "right", 
                       legend.spacing = ggplot2::unit(0, "cm"),
                       legend.justification = "right",
                       legend.text = ggplot2::element_text(size = 9),
                       panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
                       panel.grid = ggplot2::element_line(size = .2),
                       axis.title = ggplot2::element_text(size = 12),
                       axis.text = ggplot2::element_text(size = 10))
    ))
  
  
  # Create a list of named plots extracted from the tibble
  plots <- tidy_plots$plot
  if (nrow(tidy_plots) == 1) {
    names(plots) <- "Annual_Statistics"
  } else {
    names(plots) <- paste0(tidy_plots$STATION_NUMBER, "_Annual_Statistics")
  }
  
  plots
  
}

