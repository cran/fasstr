% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/calc_all_annual_stats.R
\name{calc_all_annual_stats}
\alias{calc_all_annual_stats}
\title{Calculate all fasstr annual statistics}
\usage{
calc_all_annual_stats(
  data,
  dates = Date,
  values = Value,
  groups = STATION_NUMBER,
  station_number,
  basin_area,
  water_year_start = 1,
  start_year,
  end_year,
  exclude_years,
  annual_percentiles = c(10, 90),
  monthly_percentiles = c(10, 20),
  stats_days = 1,
  stats_align = "right",
  lowflow_days = c(1, 3, 7, 30),
  lowflow_align = "right",
  timing_percent = c(25, 33, 50, 75),
  normal_percentiles = c(25, 75),
  transpose = FALSE,
  ignore_missing = FALSE
)
}
\arguments{
\item{data}{Data frame of daily data that contains columns of dates, flow values, and (optional) groups (e.g. station numbers).
Leave blank if using \code{station_number} argument.}

\item{dates}{Name of column in \code{data} that contains dates formatted YYYY-MM-DD. Only required if dates column name is not 
'Date' (default). Leave blank if using \code{station_number} argument.}

\item{values}{Name of column in \code{data} that contains numeric flow values, in units of cubic metres per second.
Only required if values column name is not 'Value' (default). Leave blank if using \code{station_number} argument.}

\item{groups}{Name of column in \code{data} that contains unique identifiers for different data sets, if applicable. Only required 
if groups column name is not 'STATION_NUMBER'. Function will automatically group by a column named 'STATION_NUMBER' if 
present. Remove the 'STATION_NUMBER' column beforehand to remove this grouping. Leave blank if using \code{station_number} 
argument.}

\item{station_number}{Character string vector of seven digit Water Survey of Canada station numbers (e.g. \code{"08NM116"}) of
which to extract daily streamflow data from a HYDAT database. Requires \code{tidyhydat} package and a HYDAT database.
Leave blank if using \code{data} argument.}

\item{basin_area}{Upstream drainage basin area, in square kilometres, to apply to observations. Three options:

(1) Leave blank if \code{groups} is STATION_NUMBER with HYDAT station numbers to extract basin areas from HYDAT.

(2) A single numeric value to apply to all observations.

(3) List each basin area for each group/station in groups (can override HYDAT value if listed) as such \code{c("08NM116" = 795, 
"08NM242" = 10)}. If group is not listed the HYDAT area will be applied if it exists, otherwise it will be \code{NA}.}

\item{water_year_start}{Numeric value indicating the month (\code{1} through \code{12}) of the start of water year for
analysis. Default \code{1}.}

\item{start_year}{Numeric value of the first year to consider for analysis. Leave blank to use the first year of the source data.}

\item{end_year}{Numeric value of the last year to consider for analysis. Leave blank to use the last year of the source data.}

\item{exclude_years}{Numeric vector of years to exclude from analysis. Leave blank to include all years.}

\item{annual_percentiles}{Numeric vector of percentiles to calculate annually. Set to \code{NA} if none required. Used for
\code{calc_annual_stats()} function. Default \code{c(10,90)}.}

\item{monthly_percentiles}{Numeric vector of percentiles to calculate monthly for each year. Set to \code{NA} if none required. 
Used for \code{calc_monthly_stats()} function. Default \code{c(10,20)}.}

\item{stats_days}{Numeric vector of the number of days to apply a rolling mean on basic stats. Default \code{c(1)}.
Used for \code{calc_annual_stats()} and \code{calc_monthly_stats()} functions.}

\item{stats_align}{Character string identifying the direction of the rolling mean on basic stats from the specified date, either by 
the first (\code{'left'}), last (\code{'right'}), or middle (\code{'center'}) day of the rolling n-day group of observations.
Default \code{'right'}. Used for \code{calc_annual_stats()}, \code{calc_monthly_stats()}, and \code{calc_annual_outside_normal()}
functions.}

\item{lowflow_days}{Numeric vector of the number of days to apply a rolling mean on low flow stats. Default \code{c(1,3,7,30)}.
Used for \code{calc_lowflow_stats()} function.}

\item{lowflow_align}{Character string identifying the direction of the rolling mean on low flow stats from the specified date,
either by the first (\code{'left'}), last (\code{'right'}), or middle (\code{'center'}) day of the rolling n-day group of 
observations. Default \code{'right'}. Used for \code{calc_lowflow_stats()} function.}

\item{timing_percent}{Numeric vector of percents of annual total flows to determine dates. Used for \code{calc_annual_flow_timing()}
function. Default \code{c(25,33.3,50,75)}.}

\item{normal_percentiles}{Numeric vector of two values, lower and upper percentiles, respectively indicating the limits of the 
normal range. Default \code{c(25,75)}.}

\item{transpose}{Logical value indicating whether to transpose rows and columns of results. Default \code{FALSE}.}

\item{ignore_missing}{Logical value indicating whether dates with missing values should be included in the calculation. If
\code{TRUE} then a statistic will be calculated regardless of missing dates. If \code{FALSE} then only those statistics from
time periods with no missing dates will be returned. Default \code{FALSE}.}
}
\value{
A tibble data frame with column "Year" and then 107 (default) variables from the fasstr annual functions.
   See listed functions above for default variables. Transposing data creates a column of "Statistics" and subsequent
   columns for each year selected.
}
\description{
Calculates annual statistics from all annual \code{fasstr} functions from a daily streamflow data set.
   Data is ideally long-term and continuous with minimal missing/seasonal data as annual statistics are calculated.
   Calculates statistics from all values, unless specified. Returns a tibble with statistics. 
   Data calculated using the following functions:
\itemize{
 \item{\code{calc_annual_stats()}}
 \item{\code{calc_annual_lowflows()}}
 \item{\code{calc_annual_cumulative_stats()}}
 \item{\code{calc_annual_flow_timing()}}
 \item{\code{calc_annual_outside_normal()}}
 \item{\code{calc_monthly_stats()}}
 }
}
\examples{
\dontrun{

# Working examples:

# Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
if (file.exists(tidyhydat::hy_downloaded_db())) {

# Calculate all annual statistics from this package with default arguments
calc_all_annual_stats(station_number = "08NM116") 

# Calculate all annual statistics from this package with default arguments 
# with some default arguments shown to customize metrics
calc_all_annual_stats(station_number = "08NM116",
                      annual_percentiles = c(10,90),
                      monthly_percentiles = c(10,20),
                      stats_days = 1,
                      stats_align = "right",
                      lowflow_days = c(1,3,7,30),
                      lowflow_align = "right",
                      timing_percent = c(25,33,50,75),
                      normal_percentiles = c(25,75)) 

}
}
}
\seealso{
\code{\link{calc_annual_stats}},
         \code{\link{calc_annual_lowflows}}, 
         \code{\link{calc_annual_cumulative_stats}}, 
         \code{\link{calc_annual_flow_timing}}, 
         \code{\link{calc_monthly_stats}}, 
         \code{\link{calc_annual_outside_normal}}
}
