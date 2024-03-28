## ----options, include=FALSE---------------------------------------------------
knitr::opts_chunk$set(eval = nzchar(Sys.getenv('hydat_eval')))
library(fasstr)


## ----eval=FALSE---------------------------------------------------------------
#  # Check if data is provided and import it
#  flow_data <- flowdata_import(data = data,
#                               station_number = station_number)
#  
#  # Save the original columns (to check for STATION_NUMBER col at end) and ungroup if necessary
#  orig_cols <- names(flow_data)
#  flow_data <- dplyr::ungroup(flow_data)
#  
#  # Check and rename columns
#  flow_data <- format_all_cols(data = flow_data,
#                               dates = as.character(substitute(dates)),
#                               values = as.character(substitute(values)),
#                               groups = as.character(substitute(groups)),
#                               rm_other_cols = TRUE)

## ----eval=FALSE---------------------------------------------------------------
#  ## SET UP BASIN AREA
#  suppressWarnings(flow_data <- add_basin_area(flow_data, basin_area = basin_area))
#  flow_data$Basin_Area_sqkm_temp <- flow_data$Basin_Area_sqkm
#  
#  ## ADD YIELD COLUMN
#  flow_data <- dplyr::mutate(flow_data, Yield_mm = Value * 86400 / (Basin_Area_sqkm_temp * 1000))
#  
#  # Return the original names of the Date and Value columns
#  names(flow_data)[names(flow_data) == 'Value'] <- as.character(substitute(values))
#  names(flow_data)[names(flow_data) == 'STATION_NUMBER'] <- as.character(substitute(groups))
#  
#  
#  ## Reformat to original names and groups
#  ## -------------------------------------
#  
#  # Return columns to original order plus new column
#  if('Yield_mm' %in% orig_cols){
#    flow_data <-  flow_data[, c(orig_cols)]
#  } else {
#    flow_data <-  flow_data[, c(orig_cols, paste('Yield_mm'))]
#  }
#  
#  dplyr::as_tibble(flow_data)

## ----eval=FALSE---------------------------------------------------------------
#  # Fill missing dates, add date variables
#  flow_data <- analysis_prep(data = flow_data,
#                             water_year_start = water_year_start)
#  
#  # Add rolling means to end of dataframe
#  flow_data <- add_rolling_means(data = flow_data, roll_days = roll_days, roll_align = roll_align)
#  colnames(flow_data)[ncol(flow_data)] <- 'RollingValue'

## ----eval=FALSE---------------------------------------------------------------
#  # Filter for the selected year (remove excluded years after)
#  flow_data <- dplyr::filter(flow_data, WaterYear >= start_year & WaterYear <= end_year)
#  flow_data <- dplyr::filter(flow_data, Month %in% months)

## ----eval=FALSE---------------------------------------------------------------
#  # Calculate basic stats
#  annual_stats <-   dplyr::summarize(dplyr::group_by(flow_data, STATION_NUMBER, WaterYear),
#                                     Mean = mean(RollingValue, na.rm = ignore_missing),
#                                     Median = stats::median(RollingValue, na.rm = ignore_missing),
#                                     Maximum = max (RollingValue, na.rm = ignore_missing),
#                                     Minimum = min (RollingValue, na.rm = ignore_missing))
#  annual_stats <- dplyr::ungroup(annual_stats)
#  
#  #Remove Nans and Infs
#  annual_stats$Mean[is.nan(annual_stats$Mean)] <- NA
#  annual_stats$Maximum[is.infinite(annual_stats$Maximum)] <- NA
#  annual_stats$Minimum[is.infinite(annual_stats$Minimum)] <- NA
#  
#  # Calculate annual percentiles
#  if(!all(is.na(percentiles))) {
#    for (ptile in percentiles) {
#      # Calculate percentiles
#      annual_stats_ptile <- dplyr::summarise(dplyr::group_by(flow_data, STATION_NUMBER, WaterYear),
#                                             Percentile = stats::quantile(RollingValue, ptile / 100, na.rm = TRUE))
#      annual_stats_ptile <- dplyr::ungroup(annual_stats_ptile)
#      names(annual_stats_ptile)[names(annual_stats_ptile) == 'Percentile'] <- paste0('P', ptile)
#  
#      # Merge with stats
#      annual_stats <- merge(annual_stats, annual_stats_ptile, by = c('STATION_NUMBER', 'WaterYear'))
#  
#      # Remove percentile if mean is NA (workaround for na.rm=FALSE in quantile)
#      annual_stats[, ncol(annual_stats)] <- ifelse(is.na(annual_stats$Mean), NA, annual_stats[, ncol(annual_stats)])
#    }
#  }

## ----eval=FALSE---------------------------------------------------------------
#  # Rename year column
#  annual_stats <- dplyr::rename(annual_stats, Year = WaterYear)
#  
#  # Remove selected excluded years
#  annual_stats[annual_stats$Year %in% exclude_years, -(1:2)] <- NA
#  
#  
#  # If transpose if selected
#  if (transpose) {
#    # Get list of columns to order the Statistic column after transposing
#    stat_levels <- names(annual_stats[-(1:2)])
#  
#    # Transpose the columns for rows
#    annual_stats <- tidyr::gather(annual_stats, Statistic, Value, -STATION_NUMBER, -Year)
#    annual_stats <- tidyr::spread(annual_stats, Year, Value)
#  
#    # Order the columns
#    annual_stats$Statistic <- factor(annual_stats$Statistic, levels = stat_levels)
#    annual_stats <- dplyr::arrange(annual_stats, STATION_NUMBER, Statistic)
#  }
#  
#  # Give warning if any NA values
#  missing_values_warning(annual_stats[, 3:ncol(annual_stats)])
#  
#  
#  # Recheck if station_number/grouping was in original data and rename or remove as necessary
#  if(as.character(substitute(groups)) %in% orig_cols) {
#    names(annual_stats)[names(annual_stats) == 'STATION_NUMBER'] <- as.character(substitute(groups))
#  } else {
#    annual_stats <- dplyr::select(annual_stats, -STATION_NUMBER)
#  }
#  
#  dplyr::as_tibble(annual_stats)

## ----fig.height = 3, fig.width = 7, comment=NA--------------------------------
# Calculate the statistics
annual_stats <- calc_annual_stats(station_number = c('08NM116', '08NM240'),
                                  start_year = 1985, end_year = 2015)

# Wrangle statistics for plotting
annual_stats <- tidyr::gather(annual_stats, Statistic, Value, -Year, -STATION_NUMBER)

# Group data by grouping
tidy_plots <- dplyr::group_by(annual_stats, STATION_NUMBER)

# Create a tibble with a column of STATION_NUMBERs and a column of data for each STATION_NUMBER
tidy_plots <- tidyr::nest(tidy_plots)

# Create a new column of plots using mutate and purrr::map2
tidy_plots <- dplyr::mutate(tidy_plots,
                            plot = purrr::map2(data, STATION_NUMBER, 
                                               ~ggplot2::ggplot(data = ., ggplot2::aes(x = Year, y = Value, color = Statistic)) +
                                                 ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5)) +
                                                 ggplot2::geom_line(alpha = 0.5, na.rm = TRUE) +
                                                 ggplot2::geom_point(na.rm = TRUE) +
                                                 ggplot2::ylab('Discharge (cms)')

                            ))


# Create a list of named plots extracted from the tibble
plots <- tidy_plots$plot
if (nrow(tidy_plots) == 1) {
  names(plots) <- 'Annual_Statistics'
} else {
  names(plots) <- paste0(tidy_plots$STATION_NUMBER, '_Annual_Statistics')
}

# Return the plots
plots

