% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/screen_flow_data.R
\name{screen_flow_data}
\alias{screen_flow_data}
\title{Calculate annual summary and missing data statistics for screening data}
\usage{
screen_flow_data(
  data,
  dates = Date,
  values = Value,
  groups = STATION_NUMBER,
  symbols = "Symbol",
  station_number,
  roll_days = 1,
  roll_align = "right",
  water_year_start = 1,
  start_year,
  end_year,
  months = 1:12,
  transpose = FALSE,
  include_symbols = TRUE
)
}
\arguments{
\item{data}{Data frame of daily data that contains columns of dates, flow values, and (optional) groups (e.g. station numbers).
Leave blank or set to \code{NULL} if using \code{station_number} argument.}

\item{dates}{Name of column in \code{data} that contains dates formatted YYYY-MM-DD. Only required if dates column name is not 
'Date' (default). Leave blank or set to \code{NULL} if using \code{station_number} argument.}

\item{values}{Name of column in \code{data} that contains numeric flow values, in units of cubic metres per second.
Only required if values column name is not 'Value' (default). Leave blank if using \code{station_number} argument.}

\item{groups}{Name of column in \code{data} that contains unique identifiers for different data sets, if applicable. Only required 
if groups column name is not 'STATION_NUMBER'. Function will automatically group by a column named 'STATION_NUMBER' if 
present. Remove the 'STATION_NUMBER' column beforehand to remove this grouping. Leave blank if using \code{station_number} 
argument.}

\item{symbols}{Name of column in \code{data} that contains symbols. Only required if symbols column name is not 
'Symbol' (default). Leave blank or set to \code{NULL} if using \code{station_number} argument.}

\item{station_number}{Character string vector of seven digit Water Survey of Canada station numbers (e.g. \code{"08NM116"}) of
which to extract daily streamflow data from a HYDAT database. Requires \code{tidyhydat} package and a HYDAT database.
Leave blank if using \code{data} argument.}

\item{roll_days}{Numeric value of the number of days to apply a rolling mean. Default \code{1}.}

\item{roll_align}{Character string identifying the direction of the rolling mean from the specified date, either by the first 
(\code{'left'}), last (\code{'right'}), or middle (\code{'center'}) day of the rolling n-day group of observations. 
Default \code{'right'}.}

\item{water_year_start}{Numeric value indicating the month (\code{1} through \code{12}) of the start of water year for
analysis. Default \code{1}.}

\item{start_year}{Numeric value of the first year to consider for analysis. Leave blank or set well before start date (i.e.
\code{1800}) to use from the first year of the source data.}

\item{end_year}{Numeric value of the last year to consider for analysis. Leave blank or set well after end date (i.e.
\code{2100}) to use up to the last year of the source data.}

\item{months}{Numeric vector of months to include in analysis. For example, \code{3} for March, \code{6:8} for Jun-Aug or 
\code{c(10:12,1)} for first four months (Oct-Jan) when \code{water_year_start = 10} (Oct). Default summarizes all 
months (\code{1:12}).}

\item{transpose}{Logical value indicating whether to transpose rows and columns of results. Default \code{FALSE}.}

\item{include_symbols}{Logical. Include columns of counts of symbol categories from the symbols column.}
}
\value{
A tibble data frame with the following columns:
  \item{Year}{calendar or water year selected}
  \item{n_days}{number of days per year}
  \item{n_Q}{number of days per year with flow data}
  \item{n_missing_Q}{number of days per year with no flow data}
  \item{No_Symbol}{number of days with no symbol category, if include_symbol=TRUE}
  \item{x_Symbol}{number of days with a specific symbol category (x) from symbols column, if include_symbol=TRUE}
  \item{Maximum}{annual maximum of all daily flows for a given year}
  \item{Mean}{annual mean of all daily flows for a given year}
  \item{Median}{annual median of all daily flows for a given year}
  \item{StandardDeviation}{annual 1 standard deviation of all daily flows for a given year}
  and the following monthly missing columns (order will depend on water_year_month):
  \item{Jan_missing_Q}{number of Jan days per year with no flow data}
  \item{Feb_missing_Q}{number of Feb days per year with no flow data}
  \item{Mar_missing_Q}{number of Mar days per year with no flow data}
  \item{Apr_missing_Q}{number of Apr days per year with no flow data}
  \item{May_missing_Q}{number of May days per year with no flow data}
  \item{Jun_missing_Q}{number of Jun days per year with no flow data}
  \item{Jul_missing_Q}{number of Jul days per year with no flow data}
  \item{Aug_missing_Q}{number of Aug days per year with no flow data}
  \item{Sep_missing_Q}{number of Sep days per year with no flow data}
  \item{Oct_missing_Q}{number of Oct days per year with no flow data}
  \item{Nov_missing_Q}{number of Nov days per year with no flow data}
  \item{Dec_missing_Q}{number of Dec days per year with no flow data}
  Transposing data creates a column of "Statistics" and subsequent columns for each year selected.
}
\description{
Calculates means, medians, maximums, minimums, standard deviations of annual flows and data availability and missing 
   data statistics, and symbol counts (if column exists) for each year and month of each year. Calculates the statistics from all 
   daily discharge values from all years, unless specified. Returns a tibble with statistics.
}
\examples{
# Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
if (file.exists(tidyhydat::hy_downloaded_db())) {

# Calculate screening statistics using data frame and data argument with defaults
flow_data <- tidyhydat::hy_daily_flows(station_number = "08NM116")
screen_flow_data(data = flow_data)

# Calculate screening statistics using station_number argument with defaults
screen_flow_data(station_number = "08NM116")
                  
# Calculate screening statistics for water years starting in October
screen_flow_data(station_number = "08NM116",
                 water_year_start = 9)
                  
# Calculate screening statistics for 7-day flows for July-September months only
screen_flow_data(station_number = "08NM116",
                 roll_days = 7,
                 months = 7:9)
                 
}
}
