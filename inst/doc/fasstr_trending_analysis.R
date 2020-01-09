## ----options, include=FALSE---------------------------------------------------
knitr::opts_chunk$set(eval = nzchar(Sys.getenv("hydat_eval")))

## ---- include=FALSE-----------------------------------------------------------
library(fasstr)

## ---- eval=FALSE--------------------------------------------------------------
#  compute_annual_trends(station_number = "08NM116",
#                        zyp_method = "yuepilon",
#                        start_year = 1973, end_year = 2013)

## ---- eval=FALSE--------------------------------------------------------------
#  compute_annual_trends(station_number = "08NM116",
#                        zyp_method = "yuepilon",
#                        start_year = 1973, end_year = 2013,
#                        annual_percentiles = c(10,90),
#                        monthly_percentiles = c(10,20),
#                        stats_days = 1,
#                        stats_align = "right",
#                        lowflow_days = c(1,3,7,30),
#                        lowflow_align = "right",
#                        timing_percent = c(25,33,50,75),
#                        normal_percentiles = c(25,75))

## ---- comment=NA, echo=FALSE--------------------------------------------------
trends <- compute_annual_trends(station_number = "08NM116",
                                zyp_method = "yuepilon",
                                start_year = 1973, end_year = 2013)

data <- as.data.frame(trends[[1]])[,2:5]
data[2] <- round(data[2],3)
data[3] <- round(data[3],3)
data[4] <- round(data[4],3)
data

## ---- echo=TRUE, include=TRUE-------------------------------------------------
trends_analysis <- compute_annual_trends(station_number = "08NM116",
                                         zyp_method = "yuepilon",
                                         start_year = 1973, end_year = 2013)

## ---- echo=TRUE, comment=NA---------------------------------------------------
trends_analysis$Annual_Trends_Data

## ---- echo=TRUE, comment=NA---------------------------------------------------
trends_analysis$Annual_Trends_Results

## ---- echo = FALSE, include=FALSE---------------------------------------------
trends <- compute_annual_trends(station_number = "08NM116",
                                zyp_method = "yuepilon", zyp_alpha = 0.05,
                                start_year = 1973, end_year = 2013)

## ----  echo=FALSE, comment=NA, fig.height = 3, fig.width = 7------------------
trends[[51]]

## ----  echo=FALSE, comment=NA, fig.height = 3, fig.width = 7------------------
trends$`Sep_Maximum`

