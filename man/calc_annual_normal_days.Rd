% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_annual_normal_days.R
\name{calc_annual_normal_days}
\alias{calc_annual_normal_days}
\title{Calculate annual days above and below normal}
\usage{
calc_annual_normal_days(
  data,
  dates = Date,
  values = Value,
  groups = STATION_NUMBER,
  station_number,
  normal_percentiles = c(25, 75),
  roll_days = 1,
  roll_align = "right",
  water_year_start = 1,
  start_year,
  end_year,
  exclude_years,
  months = 1:12,
  transpose = FALSE
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

\item{station_number}{Character string vector of seven digit Water Survey of Canada station numbers (e.g. \code{"08NM116"}) of
which to extract daily streamflow data from a HYDAT database. Requires \code{tidyhydat} package and a HYDAT database.
Leave blank if using \code{data} argument.}

\item{normal_percentiles}{Numeric vector of two values, lower and upper percentiles, respectively indicating the limits of the 
normal range. Default \code{c(25,75)}.}

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

\item{exclude_years}{Numeric vector of years to exclude from analysis. Leave blank or set to \code{NULL} to include all years.}

\item{months}{Numeric vector of months to include in analysis. For example, \code{3} for March, \code{6:8} for Jun-Aug or 
\code{c(10:12,1)} for first four months (Oct-Jan) when \code{water_year_start = 10} (Oct). Default summarizes all 
months (\code{1:12}).}

\item{transpose}{Logical value indicating whether to transpose rows and columns of results. Default \code{FALSE}.}
}
\value{
A tibble data frame with the following columns:
  \item{Year}{calendar or water year selected}
  \item{Below_Normal_Days}{number of days per year below the daily normal (default 25th percentile)}
  \item{Above_Normal_Days}{number of days per year above the daily normal (default 75th percentile)}
  \item{Days_Outside_Normal}{number of days per year below and above the daily normal (default 25/75th percentile)}
  Transposing data creates a column of "Statistics" and subsequent columns for each year selected.
}
\description{
Calculates the number of days per year outside of the 'normal' range (typically between 25 and 75th percentiles) for
   each day of the year. Upper and lower-range percentiles are calculated for each day of the year of from all years, and then each 
   daily flow value for each year is compared. All days above or below the normal range are included. Analysis methodology is based on
   Environment and Climate Change Canada's 
   \href{https://www.canada.ca/en/environment-climate-change/services/environmental-indicators/water-quantity-canadian-rivers.html}{Water Quantity indicator}
   from the Canadian Environmental Sustainability Indicators. Calculates statistics from all values from complete years, unless 
   specified. Returns a tibble with statistics.
}
\examples{
# Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
if (file.exists(tidyhydat::hy_downloaded_db())) {

# Calculate statistics with default limits of normal (25 and 75th percentiles)
calc_annual_normal_days(station_number = "08NM116") 

# Calculate statistics with custom limits of normal
calc_annual_normal_days(station_number = "08NM116",
                        normal_percentiles = c(10,90),
                        start_year = 1980)
                           
}
}
