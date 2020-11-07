## ----options, include=FALSE---------------------------------------------------
knitr::opts_chunk$set(eval = nzchar(Sys.getenv("hydat_eval")),
# warning = FALSE, 
message = FALSE)
library(fasstr)

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  install.packages("fasstr")

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  if(!requireNamespace("remotes")) install.packages("remotes")
#  remotes::install_github("bcgov/fasstr")

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  tidyhydat::download_hydat()

## ----setup, include = FALSE---------------------------------------------------
data <- tidyhydat::hy_daily_flows("08NM116")
data <- data[,c(1,2,4)]

## ----flow_data, echo=FALSE----------------------------------------------------
head(data.frame(data))

## ----example1-----------------------------------------------------------------
calc_longterm_daily_stats(station_number = "08NM116", 
                          start_year = 1981, 
                          end_year = 2010,
                          custom_months = 7:9, 
                          custom_months_label = "Summer")

## ----plot1, fig.height = 4, fig.width = 10------------------------------------
plot_daily_stats(station_number = "08NM116",
                 start_year = 1981,
                 end_year = 2010,
                 log_discharge = TRUE,
                 add_year = 1991)

## ----plot2, fig.height = 4, fig.width = 7-------------------------------------
plot_flow_duration(station_number = "08NM116",
                   start_year = 1981,
                   end_year = 2010)

## ----example2-----------------------------------------------------------------
freq_results <- compute_annual_frequencies(station_number = "08NM116",
                                           start_year = 1981,
                                           end_year = 2010,
                                           roll_days = 7,
                                           fit_distr = "PIII",
                                           fit_distr_method = "MOM")
freq_results$Freq_Fitted_Quantiles

## ----plot3, fig.height = 4, fig.width = 7-------------------------------------
freq_results <- compute_annual_frequencies(station_number = "08NM116",
                                           start_year = 1981,
                                           end_year = 2010,
                                           roll_days = c(1,3,7,30))
freq_results$Freq_Plot

