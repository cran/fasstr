% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_annual_flow_timing_year.R
\name{plot_annual_flow_timing_year}
\alias{plot_annual_flow_timing_year}
\title{Plot annual timing of flows for a specific year}
\usage{
plot_annual_flow_timing_year(
  data,
  dates = Date,
  values = Value,
  groups = STATION_NUMBER,
  station_number,
  percent_total = c(25, 33.3, 50, 75),
  year_to_plot = NA,
  water_year_start = 1,
  start_year,
  end_year,
  exclude_years,
  months = 1:12,
  log_discharge = TRUE,
  log_ticks = FALSE,
  include_title = FALSE,
  plot_vlines = TRUE,
  plot_normal_percentiles = TRUE,
  normal_percentiles = c(25, 75)
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

\item{percent_total}{Numeric vector of percents of total annual flows to determine dates. Default \code{c(25,33.3,50,75)}.}

\item{year_to_plot}{Numeric value indicating the year/water year to plot flow data with normal category colours. Default \code{NA}.}

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

\item{log_discharge}{Logical value to indicate plotting the discharge axis (Y-axis) on a logarithmic scale. Default \code{FALSE}.}

\item{log_ticks}{Logical value to indicate plotting logarithmic scale ticks when \code{log_discharge = TRUE}. Ticks will not
appear when \code{log_discharge = FALSE}. Default to \code{TRUE} when \code{log_discharge = TRUE}.}

\item{include_title}{Logical value to indicate adding the group/station number to the plot, if provided. Default \code{FALSE}.}

\item{plot_vlines}{Logical value indicating whether to plot the vertical lines indicating dates of flow timing. Default \code{TRUE}.}

\item{plot_normal_percentiles}{Logical value indicating whether to plot the normal percentiles ribbon. Default \code{TRUE}.}

\item{normal_percentiles}{Numeric vector of two values, lower and upper percentiles, respectively indicating the limits of the 
normal range. Default \code{c(25,75)}.}
}
\value{
A list of ggplot2 objects with the following for each station provided:
  \item{Annual_Normal_Days_Year}{a plot that contains the above, below, and normal colour daily flow points}
}
\description{
Plots an annual hydrograph for a specific year with the dates of flow timing of portions of total annual flow identified.
   The 'normal' range of percentiles also plotted for reference and are calculated from only years of complete data. 
   Shows the dates of flow timing for a specific year from the counts from the \code{plot_annual_flow_timing()} function. 
   Returns a list of plots.
}
\examples{
# Run if HYDAT database has been downloaded (using tidyhydat::download_hydat())
if (file.exists(tidyhydat::hy_downloaded_db())) {

# Plot the year 2000 and change the flow timing percent totals        
plot_annual_flow_timing_year(station_number = "08NM116",
                             percent_total = 50,
                             year_to_plot = 2000)
                 
}
}
\seealso{
\code{\link{calc_annual_flow_timing}}

\code{\link{plot_annual_flow_timing}}
}
