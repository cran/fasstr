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

#' @title Plot annual (and seasonal) total cumulative flows
#' 
#' @description Plots annual and seasonal (if \code{include_seaons = TRUE}) total flows, volumetric discharge or water yields, from a 
#'    daily streamflow data set. Calculates statistics from all values, unless specified. Data calculated from 
#'    \code{plot_annual_cumulative_stats()} function. For water year and seasonal data, the designated year is the year in which the 
#'    year or season ends. Returns a list of plots.
#'    
#' @inheritParams calc_annual_cumulative_stats
#' @inheritParams plot_annual_stats
#' @param months Numeric vector of months to include in analysis. For example, \code{3} for March, \code{6:8} for Jun-Aug or 
#'    \code{c(10:12,1)} for first four months (Oct-Jan) when \code{water_year_start = 10} (Oct). Default summarizes all 
#'    months (\code{1:12}). If not all months, seasonal total yield and volumetric flows will not be included.
#' @param plot_type Type of plot, either \code{"bar"} or \code{"line"} styles. Default \code{"bar"}. 
#'     Use \code{"line"} for previous version of plot.
#'    
#' @return A list of ggplot2 objects with the following for each station provided:
#'   \item{Annual_Total_Volume}{annual total volumetric discharge, in cubic metres}
#'   \item{Two_Seasons_Total_Volume}{if include_seasons = TRUE, two seasons total volumetric discharges, in cubic metres}
#'   \item{Four_Seasons_Total_Volume}{if include_seasons = TRUE, four seasons total volumetric discharges, in cubic metres}
#'   If \code{use_yield} argument is used the list will contain the following objects:
#'   \item{Annual_Yield}{annual water yield, in millimetres}
#'   \item{Two_Seasons_Yield}{if include_seasons = TRUE, two seasons water yield, in millimetres}
#'   \item{Four_Seasons_Yield}{if include_seasons = TRUE, four seasons water yield, in millimetres}
#'   
#' @seealso \code{\link{calc_annual_cumulative_stats}}
#'   
#' @examples
#' # Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
#' if (file.exists(tidyhydat::hy_downloaded_db())) {
#' 
#' # Plot annual cumulative yield statistics with default HYDAT basin area
#' plot_annual_cumulative_stats(station_number = "08NM116",
#'                              use_yield = TRUE) 
#' 
#' # Plot annual cumulative yield statistics with custom basin area
#' plot_annual_cumulative_stats(station_number = "08NM116",
#'                              use_yield = TRUE,
#'                              basin_area = 800) 
#'                              
#' }
#' @export



plot_annual_cumulative_stats <- function(data,
                                         dates = Date,
                                         values = Value,
                                         groups = STATION_NUMBER,
                                         station_number,
                                         use_yield = FALSE, 
                                         basin_area,
                                         water_year_start = 1,
                                         start_year,
                                         end_year,
                                         exclude_years, 
                                         months = 1:12, 
                                         include_seasons = FALSE,
                                         include_title = FALSE,
                                         complete_years = FALSE,
                                         plot_type = "bar"){
  
  
  
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
  if (missing(basin_area)) {
    basin_area <- NA
  }
  
  logical_arg_check(include_title)   
  
  plot_type <- plot_type[1]
  if (!any(c("bar", "line") %in% plot_type)) 
    stop("plot_type must be one of 'bar' or 'line' plots.", call. = FALSE)
  
  if (include_seasons & !all(1:12 %in% months)) {
    warning("Since not all months are selected, seasonal totals will not be included.", call. = FALSE)
  }
  
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
  
  cumulative_stats <- calc_annual_cumulative_stats(data = flow_data,
                                                   use_yield = use_yield, 
                                                   basin_area = ifelse(use_yield, basin_area, 0),
                                                   water_year_start = water_year_start,
                                                   start_year = start_year,
                                                   end_year = end_year,
                                                   exclude_years = exclude_years,
                                                   months = months,
                                                   complete_years = complete_years, 
                                                   include_seasons = include_seasons & all(1:12 %in% months))
  
  # Remove all leading NA years
  cumulative_stats <- dplyr::filter(dplyr::group_by(cumulative_stats, STATION_NUMBER),
                              Year >= Year[min(which(!is.na(.data[[names(cumulative_stats)[3]]])))])
  
  # Extract each annual/seasonal datasets
  annual_data <- cumulative_stats[,1:3]
  annual_data <- tidyr::gather(annual_data, Statistic, Value, -STATION_NUMBER, -Year)
  annual_data <- dplyr::mutate(annual_data, Statistic = substr(Statistic, 1, 6))
  
  # Calc seasonal data if specified
  if(include_seasons & all(1:12 %in% months)) {
    
    # Two Seasons
    seasons2_data <- cumulative_stats[,c(1,2,4,5)]
    seasons2_data <- tidyr::gather(seasons2_data, Statistic, Value, -STATION_NUMBER, -Year)
    seasons2_data <- dplyr::mutate(seasons2_data, Statistic = substr(Statistic, 1, 7))
    seasons2_data$Statistic <- factor(seasons2_data$Statistic, levels = unique(seasons2_data$Statistic))
    
    # Four Seasons
    seasons4_data <- cumulative_stats[,c(1,2,6:9)]
    seasons4_data <- tidyr::gather(seasons4_data, Statistic, Value, -STATION_NUMBER, -Year)
    seasons4_data <- dplyr::mutate(seasons4_data, Statistic = substr(Statistic, 1, 7))
    seasons4_data$Statistic <- factor(seasons4_data$Statistic, levels = unique(seasons4_data$Statistic))
  }
  
  ## PLOT STATS
  ## ----------
  
  if (plot_type == "line") {
    annual_plots <- dplyr::group_by(annual_data, STATION_NUMBER)
    annual_plots <- tidyr::nest(annual_plots)
    annual_plots <- dplyr::mutate(
      annual_plots,
      ann_plot = purrr::map2(
        data, STATION_NUMBER, 
        ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, colour = Statistic)) +
          ggplot2::geom_line(alpha = 0.5,na.rm = TRUE) +
          ggplot2::geom_point(na.rm = TRUE)+
          ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 6)) +
          ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                                      labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)))+
          ggplot2::ylab(expression(Volume~(m^3))) +
          {if (use_yield) ggplot2::ylab("Yield (mm)")} +
          ggplot2::xlab(ifelse(water_year_start ==1, "Year", "Water Year"))+
          ggplot2::scale_color_brewer(palette = "Set1") +
          ggplot2::theme_bw() +
          ggplot2::guides(colour = 'none') +
          {if (include_title & .y != "XXXXXXX") ggplot2::ggtitle(paste(.y)) } +
          ggplot2::theme(panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
                         panel.grid = ggplot2::element_line(size = .2),
                         axis.title = ggplot2::element_text(size = 12),
                         axis.text = ggplot2::element_text(size = 10),
                         plot.title = ggplot2::element_text(hjust = 1, size = 9, colour = "grey25"))
      ))
    
    # Create a list of named plots extracted from the tibble
    plots <- annual_plots$ann_plot
    if (nrow(annual_plots) == 1) {
      names(plots) <- paste0(ifelse(use_yield, "Total_Yield", "Total_Volume"))
    } else {
      names(plots) <- paste0(annual_plots$STATION_NUMBER, ifelse(use_yield, "_Total_Yield", "_Total_Volume"))
    }
    
    
    # If include seasons, then add them to the list of plots
    if (include_seasons & all(1:12 %in% months)) {
      
      # Plot 2-seasons
      s2_plots <- dplyr::group_by(seasons2_data, STATION_NUMBER)
      s2_plots <- tidyr::nest(s2_plots)
      s2_plots <- dplyr::mutate(
        s2_plots,
        s2_plot = purrr::map2(
          data, STATION_NUMBER, 
          ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, colour = Statistic)) +
            ggplot2::geom_line(alpha = 0.5, na.rm = TRUE) +
            ggplot2::geom_point(na.rm = TRUE) +
            ggplot2::facet_wrap(~Statistic, ncol = 1, strip.position = "top") +
            ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 8))+
            {if(length(unique(seasons2_data$Year)) < 8) ggplot2::scale_x_continuous(breaks = unique(seasons2_data$Year))}+
            ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                                        labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)))+
            ggplot2::ylab("Volume (cubic metres)") +
            {if (use_yield) ggplot2::ylab("Yield (mm)")} +
            ggplot2::xlab("Year")+
            ggplot2::scale_color_brewer(palette = "Set1") +
            ggplot2::theme_bw() +
            ggplot2::guides(colour = 'none') +
            {if (include_title & .y != "XXXXXXX") ggplot2::ggtitle(paste(.y)) } +
            ggplot2::theme(panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
                           panel.grid = ggplot2::element_line(size = .2),
                           axis.title = ggplot2::element_text(size = 12),
                           axis.text = ggplot2::element_text(size = 10),
                           plot.title = ggplot2::element_text(hjust = 1, size = 9, colour = "grey25"),
                           strip.background = ggplot2::element_blank(),
                           strip.text = ggplot2::element_text(hjust = 0, face = "bold", size = 10))
        ))
      
      # Plot 4-seasons
      s4_plots <- dplyr::group_by(seasons4_data, STATION_NUMBER)
      s4_plots <- tidyr::nest(s4_plots)
      s4_plots <- dplyr::mutate(
        s4_plots,
        s4_plot = purrr::map2(
          data, STATION_NUMBER,
          ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, colour = Statistic)) +
            ggplot2::geom_line(alpha = 0.5, na.rm = TRUE) +
            ggplot2::geom_point(na.rm = TRUE) +
            ggplot2::facet_wrap(~Statistic, ncol = 1, strip.position = "top") +
            ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 8))+
            {if(length(unique(seasons4_data$Year)) < 8) ggplot2::scale_x_continuous(breaks = unique(seasons4_data$Year))}+
            ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                                        labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)))+
            ggplot2::ylab("Volume (cubic metres)") +
            {if (use_yield) ggplot2::ylab("Yield (mm)")} +
            ggplot2::xlab("Year")+
            ggplot2::scale_color_brewer(palette = "Set1") +
            ggplot2::theme_bw() +
            ggplot2::guides(colour = 'none')+
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
      s2_plots <- s2_plots$s2_plot
      s4_plots <- s4_plots$s4_plot
      
      if (nrow(annual_plots) == 1) {
        names(s2_plots) <- paste0(ifelse(use_yield, "Two_Seasons_Yield", "Two_Seasons_Volume"))
        names(s4_plots) <- paste0(ifelse(use_yield, "Four_Seasons_Yield", "Four_Seasons_Volume"))
      } else {
        names(s2_plots) <- paste0(annual_plots$STATION_NUMBER, ifelse(use_yield, "_Two_Seasons_Yield", "_Two_Seasons_Volume"))
        names(s4_plots) <- paste0(annual_plots$STATION_NUMBER, ifelse(use_yield, "_Four_Seasons_Yield", "_Four_Seasons_Volume"))
      }
      
      # Add the seasonal plots to the plot list
      plots <- c(plots, s2_plots, s4_plots)
      
    }
    
    ## PLOT AS BAR GRAPH
  } else {
    annual_plots <- dplyr::group_by(annual_data, STATION_NUMBER)
    annual_plots <- tidyr::nest(annual_plots)
    annual_plots <- dplyr::mutate(
      annual_plots,
      ann_plot = purrr::map2(
        data, STATION_NUMBER, 
        ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, fill = Statistic)) +
          ggplot2::geom_bar(position = "stack", stat = "identity", na.rm = TRUE, width=1, colour = "black") +
          ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 6)) +
          ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                                      labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)),
                                      expand = ggplot2::expansion(mult = c(0, 0.05)))+
          ggplot2::ylab("Volume (cubic metres)") +
          {if (use_yield) ggplot2::ylab("Yield (mm)")} +
          ggplot2::xlab(ifelse(water_year_start ==1, "Year", "Water Year"))+
          ggplot2::scale_fill_viridis_d(name = "Season", begin = 0.5) +
          ggplot2::theme_bw() +
          ggplot2::guides(fill = 'none') +
          {if (include_title & .y != "XXXXXXX") ggplot2::ggtitle(paste(.y)) } +
          ggplot2::theme(panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
                         panel.grid = ggplot2::element_line(size = .2),
                         axis.title = ggplot2::element_text(size = 12),
                         axis.text = ggplot2::element_text(size = 10),
                         plot.title = ggplot2::element_text(hjust = 1, size = 9, colour = "grey25"))
      ))
    
    # Create a list of named plots extracted from the tibble
    plots <- annual_plots$ann_plot
    if (nrow(annual_plots) == 1) {
      names(plots) <- paste0(ifelse(use_yield, "Total_Yield", "Total_Volume"))
    } else {
      names(plots) <- paste0(annual_plots$STATION_NUMBER, ifelse(use_yield, "_Total_Yield", "_Total_Volume"))
    }
    
    
    # If include seasons, then add them to the list of plots
    if (include_seasons & all(1:12 %in% months)) {
      
      # Plot 2-seasons
      s2_plots <- dplyr::group_by(seasons2_data, STATION_NUMBER)
      s2_plots <- tidyr::nest(s2_plots)
      s2_plots <- dplyr::mutate(
        s2_plots,
        s2_plot = purrr::map2(
          data, STATION_NUMBER, 
          ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, fill = Statistic)) +
            ggplot2::geom_bar(position = "stack", stat = "identity", na.rm = TRUE, width=1, colour = "black") +
            ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 8))+
            {if(length(unique(seasons2_data$Year)) < 8) ggplot2::scale_x_continuous(breaks = unique(seasons2_data$Year))}+
            ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                                        labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)),
                                        expand = ggplot2::expansion(mult = c(0, 0.05)))+
            ggplot2::ylab("Volume (cubic metres)") +
            {if (use_yield) ggplot2::ylab("Yield (mm)")} +
            ggplot2::xlab("Year")+
            ggplot2::scale_fill_viridis_d(name = "Season", begin = 0.3, end = 0.7) +
            ggplot2::theme_bw() +
            ggplot2::guides(colour = 'none') +
            {if (include_title & .y != "XXXXXXX") ggplot2::ggtitle(paste(.y)) } +
            ggplot2::theme(panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 1),
                           panel.grid = ggplot2::element_line(size = .2),
                           axis.title = ggplot2::element_text(size = 12),
                           axis.text = ggplot2::element_text(size = 10),
                           plot.title = ggplot2::element_text(hjust = 1, size = 9, colour = "grey25"),
                           strip.background = ggplot2::element_blank(),
                           strip.text = ggplot2::element_text(hjust = 0, face = "bold", size = 10))
        ))
      
      # Plot 4-seasons
      s4_plots <- dplyr::group_by(seasons4_data, STATION_NUMBER)
      s4_plots <- tidyr::nest(s4_plots)
      s4_plots <- dplyr::mutate(
        s4_plots,
        s4_plot = purrr::map2(
          data, STATION_NUMBER,
          ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, fill = Statistic)) +
            ggplot2::geom_bar(position = "stack", stat = "identity", na.rm = TRUE, width=1, colour = "black") +
            
            ggplot2::scale_x_continuous(breaks = scales::pretty_breaks(n = 8))+
            {if(length(unique(seasons4_data$Year)) < 8) ggplot2::scale_x_continuous(breaks = unique(seasons4_data$Year))}+
            ggplot2::scale_y_continuous(breaks = scales::pretty_breaks(n = 6),
                                        labels = scales::label_number(scale_cut = append(scales::cut_short_scale(),1,1)),
                                        expand = ggplot2::expansion(mult = c(0, 0.05)))+
            ggplot2::ylab("Volume (cubic metres)") +
            {if (use_yield) ggplot2::ylab("Yield (mm)")} +
            ggplot2::xlab("Year")+
            ggplot2::scale_fill_viridis_d(name = "Season", begin = 0.15) +
            ggplot2::theme_bw() +
            ggplot2::guides(colour = 'none')+
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
      s2_plots <- s2_plots$s2_plot
      s4_plots <- s4_plots$s4_plot
      
      if (nrow(annual_plots) == 1) {
        names(s2_plots) <- paste0(ifelse(use_yield, "Two_Seasons_Yield", "Two_Seasons_Volume"))
        names(s4_plots) <- paste0(ifelse(use_yield, "Four_Seasons_Yield", "Four_Seasons_Volume"))
      } else {
        names(s2_plots) <- paste0(annual_plots$STATION_NUMBER, ifelse(use_yield, "_Two_Seasons_Yield", "_Two_Seasons_Volume"))
        names(s4_plots) <- paste0(annual_plots$STATION_NUMBER, ifelse(use_yield, "_Four_Seasons_Yield", "_Four_Seasons_Volume"))
      }
      
      # Add the seasonal plots to the plot list
      plots <- c(plots, s2_plots, s4_plots)
      
    }
  }
  
  
  
  plots
  
}
