## ----options, include=FALSE---------------------------------------------------
knitr::opts_chunk$set(eval = nzchar(Sys.getenv("hydat_eval")))

## ---- include=FALSE-----------------------------------------------------------
library(fasstr)

## ---- echo=TRUE, comment=NA---------------------------------------------------
low_flows <- calc_annual_lowflows(station_number = "08NM116", 
                                  start_year = 1980, 
                                  end_year = 2000,
                                  roll_days = 7)
low_flows <- dplyr::select(low_flows, Year, Value = Min_7_Day)
low_flows <- dplyr::mutate(low_flows, Measure = "7-Day")
low_flows

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  compute_frequency_analysis(data = low_flows,
#                             events = Year,
#                             values = Value,
#                             measures = Measure)

## ---- include=TRUE------------------------------------------------------------
freq_analysis <- compute_annual_frequencies(station_number = "08NM116",
                                            start_year = 1981,
                                            end_year = 2010,
                                            roll_days = 7,
                                            plot_curve = FALSE)

## ---- echo=TRUE, comment=NA---------------------------------------------------
freq_analysis$Freq_Analysis_Data

## ---- echo=TRUE, comment=NA---------------------------------------------------
freq_analysis$Freq_Plot_Data

## ---- echo=TRUE, fig.height = 4, fig.width = 7--------------------------------
freq_analysis$Freq_Plot

## ---- echo=TRUE, fig.height = 4, fig.width = 7--------------------------------
freq_analysis <- compute_annual_frequencies(station_number = "08NM116",
                                            roll_days = 7,
                                            plot_curve = TRUE)
freq_analysis$Freq_Plot

## ---- echo=TRUE, comment=NA---------------------------------------------------
print(freq_analysis$Freq_Fitting$`7-Day`)

## ---- echo=TRUE, comment=NA---------------------------------------------------
summary(freq_analysis$Freq_Fitting$`7-Day`)

## ---- echo=TRUE, comment=NA, fig.height = 6, fig.width = 7--------------------
plot(freq_analysis$Freq_Fitting$`7-Day`)

## ---- echo=TRUE, comment=NA---------------------------------------------------
freq_analysis$Freq_Fitted_Quantiles

