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


#' @title Plot annual high flows and dates
#'
#' @description Plot annual n-day maximum values, and the day of year and date of occurrence of daily flow values from a daily 
#'    streamflow data set. Calculates statistics from all values, unless specified. Data calculated from \code{calc_annual_highflows()}
#'    function. Returns a list of plots.
#'
#' @inheritParams calc_annual_highflows
#' @inheritParams plot_annual_stats
#'    
#' @return A list of ggplot2 objects with the following for each station provided:
#'   \item{Annual_Maximums}{ggplot2 object of annual maximums of selected n-day rolling means}
#'   \item{Annual_Maximums_Days}{ggplot2 object of the day of years of annual maximums of selected n-day rolling means}
#'   
#' @seealso \code{\link{calc_annual_highflows}}
#' 
#' @examples
#' # Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
#' if (file.exists(tidyhydat::hy_downloaded_db())) {
#' 
#' # Plot annual 1, 3, 7, and 30-day (default) high flow statistics with default alignment
#' plot_annual_highflows(station_number = "08NM116") 
#' 
#' # Plot annual custom 3 and 7-day high flow statistics with "center" alignment
#' plot_annual_highflows(station_number = "08NM116",
#'                       roll_days = c(3,7),
#'                       roll_align = "center")
#'                      
#' }
#' @export



plot_annual_highflows <- function(data,
                                  dates = Date,
                                  values = Value,
                                  groups = STATION_NUMBER,
                                  station_number,
                                  roll_days = c(1, 3, 7, 30),
                                  roll_align = "right",
                                  water_year_start = 1,
                                  start_year,
                                  end_year,
                                  exclude_years,
                                  months = 1:12,
                                  complete_years = FALSE,
                                  ignore_missing = FALSE,
                                  allowed_missing = ifelse(ignore_missing,100,0),
                                  include_title = FALSE){
  
  
  
  ## ARGUMENT CHECKS 
  ## others will be check in calc_ function
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
  
  highflow_stats <- calc_annual_highflows(data = flow_data,
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
  highflow_stats <- dplyr::filter(dplyr::group_by(highflow_stats, STATION_NUMBER),
                                Year >= Year[min(which(!is.na(.data[[names(highflow_stats)[3]]])))])
  
  # Gather data and plot the maximums day
  highflow_doy <- dplyr::select(highflow_stats, STATION_NUMBER, Year, dplyr::contains("DoY"))
  stat_levels <- names(highflow_doy[-(1:2)])
  stat_levels <- substr(stat_levels, 5, nchar(as.character(stat_levels)))
  stat_levels <- paste0(gsub("_Day_DoY", "", stat_levels), " Day Maximum")
  
  highflow_doy <- tidyr::gather(highflow_doy, Statistic, Value, -STATION_NUMBER, -Year)
  highflow_doy <- dplyr::mutate(highflow_doy, Statistic = substr(Statistic, 5, nchar(as.character(Statistic))))
  highflow_doy <- dplyr::mutate(highflow_doy, Statistic = paste0(gsub("_Day_DoY", "", Statistic), " Day Maximum"))
  highflow_doy <- dplyr::mutate(highflow_doy, Statistic = factor(Statistic, levels = stat_levels))

    # Gather data and plot the maximums values
  highflow_values <- dplyr::select(highflow_stats, STATION_NUMBER, Year, dplyr::contains("Day"), 
                                  -dplyr::contains("DoY"), -dplyr::contains("Date"))
  
  highflow_values <- tidyr::gather(highflow_values, Statistic, Value, -STATION_NUMBER, -Year)
  highflow_values <- dplyr::mutate(highflow_values, Statistic = substr(Statistic, 5, nchar(Statistic)))
  highflow_values <- dplyr::mutate(highflow_values, Statistic = paste0(gsub("_Day", "", Statistic), " Day Maximum"))
  highflow_values <- dplyr::mutate(highflow_values, Statistic = factor(Statistic, levels = stat_levels))

  
  ## PLOT STATS
  ## ----------
  
  # Create axis label based on input columns
  y_axis_title <- ifelse(as.character(substitute(values)) == "Volume_m3", "Volume (cubic metres)", #expression(Volume~(m^3))
                         ifelse(as.character(substitute(values)) == "Yield_mm", "Yield (mm)", 
                                "Discharge (cms)")) #expression(Discharge~(m^3/s))
  
  # Create plots for each STATION_NUMBER in a tibble (see: http://www.brodrigues.co/blog/2017-03-29-make-ggplot2-purrr/)
  doy_plots <- dplyr::group_by(highflow_doy, STATION_NUMBER)
  doy_plots <- tidyr::nest(doy_plots)
  doy_plots <- dplyr::mutate(
    doy_plots,
    plot = purrr::map2(data, STATION_NUMBER, 
                       ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, color = Statistic, fill = Statistic)) +
                         ggplot2::geom_line(alpha = 0.5, na.rm = TRUE)+
                         ggplot2::geom_point(na.rm = TRUE, shape = 21, colour = "black", size = 2) +
                         ggplot2::facet_wrap(~Statistic, ncol = 1, strip.position = "top")+
                         ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 8))+
                         {if(length(unique(highflow_doy$Year)) < 8) ggplot2::scale_x_continuous(breaks = unique(highflow_doy$Year))}+
                         ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 6), expand = ggplot2::expansion(mult = c(0.1, 0.1)))+
                         ggplot2::ylab(ifelse(water_year_start == 1, "Day of Year", "Day of Water Year"))+
                         ggplot2::xlab(ifelse(water_year_start ==1, "Year", "Water Year"))+
                         ggplot2::scale_color_viridis_d()+
                         ggplot2::scale_fill_viridis_d()+
                         ggplot2::theme_bw() +
                         ggplot2::guides(colour = 'none', fill = "none")+
                         {if (include_title & .y != "XXXXXXX") ggplot2::ggtitle(paste(.y)) } +
                         ggplot2::theme(panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
                                        panel.grid = ggplot2::element_line(size = .2),
                                        axis.title = ggplot2::element_text(size = 12),
                                        axis.text = ggplot2::element_text(size = 10),
                                        plot.title = ggplot2::element_text(hjust = 1, size = 9, colour = "grey25"),
                                        strip.background = ggplot2::element_blank(),
                                        strip.text = ggplot2::element_text(hjust = 0, face = "bold", size = 10))
    ))
  
  flow_plots <- dplyr::group_by(highflow_values, STATION_NUMBER)
  flow_plots <- tidyr::nest(flow_plots)
  flow_plots <- dplyr::mutate(
    flow_plots,
    plot = purrr::map2(data, STATION_NUMBER, 
                       ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, color = Statistic, fill = Statistic)) +
                         ggplot2::geom_line(alpha = 0.5, na.rm = TRUE)+
                         ggplot2::geom_point(na.rm = TRUE, shape = 21, colour = "black", size = 2) +
                         ggplot2::facet_wrap(~Statistic, ncol = 1, strip.position = "top")+
                         ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 8))+
                         {if(length(unique(highflow_values$Year)) < 8) ggplot2::scale_x_continuous(breaks = unique(highflow_values$Year))}+
                         ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                                                     labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)),
                                                     expand = ggplot2::expansion(mult = c(0.1, 0.1))) +
                         ggplot2::ylab(y_axis_title)+
                         ggplot2::xlab("Year")+
                         ggplot2::scale_color_viridis_d()+
                         ggplot2::scale_fill_viridis_d()+
                         ggplot2::theme_bw() +
                         ggplot2::guides(colour = 'none', fill = "none")+
                         {if (include_title & .y != "XXXXXXX") ggplot2::ggtitle(paste(.y)) } +
                         ggplot2::theme(panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
                                        panel.grid = ggplot2::element_line(size = .2),
                                        axis.title = ggplot2::element_text(size = 12),
                                        axis.text = ggplot2::element_text(size = 10),
                                        plot.title = ggplot2::element_text(hjust = 1, size = 9, colour = "grey25"),
                                        strip.background = ggplot2::element_blank(),
                                        strip.text = ggplot2::element_text(hjust = 0, face = "bold", size = 10))
    ))
  
  
  # Create a list of named plots extracted from the tibble
  plots_1 <- flow_plots$plot
  plots_2 <- doy_plots$plot
  
  if (nrow(flow_plots) == 1) {
    names(plots_1) <- "Annual_High_Flows"
    names(plots_2) <- "Annual_High_Flows_Dates"
  } else {
    names(plots_1) <- paste0(flow_plots$STATION_NUMBER, "_Annual_High_Flows")
    names(plots_2) <- paste0(doy_plots$STATION_NUMBER, "_Annual_High_Flows_Dates")
  }
  
  # Add the plots to the plot list
  plots <- c(plots_1, plots_2)
  
  
  
  plots
  
  
}

