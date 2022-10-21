## ----options, include=FALSE---------------------------------------------------
knitr::opts_chunk$set(eval = nzchar(Sys.getenv("hydat_eval")),
                      warning = FALSE, 
                      message = FALSE)

## ---- include=FALSE-----------------------------------------------------------
library(fasstr)

## ---- eval=FALSE--------------------------------------------------------------
#  mission_creek <- compute_full_analysis(station_number = "08NM116",
#                                         start_year = 1981,
#                                         end_year = 2000)
#  
#  screening_plot <- mission_creek$Screening$Flow_Screening_Plot
#  
#  daily_stats <- mission_creek$Daily$Daily_Summary_Stats
#  
#  daily_stats_with_1985 <- mission_creek$Daily$Daily_Summary_Stats_with_Years$`1985_Daily_Statistics`
#  
#  trends_results <- mission_creek$Trending$Annual_Trends_Results
#  

## ---- eval=FALSE--------------------------------------------------------------
#  write_full_analysis(station_number = "08NM116",
#                      start_year = 1981,
#                      end_year = 2000,
#                      file_name = "Mission Creek")
#  

## ----  echo=FALSE, fig.height = 2.5, fig.width = 7, comment=NA----------------
plot_flow_data(station_number = "08NM116",
               start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(fill_missing_dates(station_number = "08NM116") %>% 
                     add_date_variables() %>%
                     add_rolling_means() %>%
                     add_basin_area() %>% 
                     dplyr::filter(WaterYear >= 1990, WaterYear <= 2001) 
))

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(screen_flow_data(station_number = "08NM116",
                                    start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_data_screening(station_number = "08NM116",
                    start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 5, fig.width = 7, comment=NA------------------
plot_missing_dates(station_number = "08NM116",
                   start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_longterm_monthly_stats(station_number = "08NM116",
                                               start_year = 1990, end_year = 2001,
                                               percentiles = seq(5, 95, by = 5),
                                               transpose = TRUE)))

## ----  echo=FALSE, fig.height = 2.5, fig.width = 7, comment=NA----------------
plot_longterm_monthly_stats(station_number = "08NM116",
                            start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_longterm_daily_stats(station_number = "08NM116",
                                             start_year = 1990, end_year = 2001,
                                             percentiles = 1:99,
                                             transpose = TRUE)))

## ----  echo=FALSE, fig.height = 2.5, fig.width = 7, comment=NA----------------
plot_longterm_daily_stats(station_number = "08NM116",
                          start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_flow_duration(station_number = "08NM116",
                   start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_annual_cumulative_stats(station_number = "08NM116",
                                                start_year = 1990, end_year = 2001,
                                                include_seasons = TRUE)))

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_annual_cumulative_stats(station_number = "08NM116",
                                                start_year = 1990, end_year = 2001,
                                                include_seasons = TRUE,
                                                use_yield = TRUE)))

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_annual_normal_days(station_number = "08NM116",
                                              start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 4.5, fig.width = 7, comment=NA----------------
plot_annual_normal_days(station_number = "08NM116",
                           start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_annual_flow_timing(station_number = "08NM116",
                                           start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 4.5, fig.width = 7, comment=NA----------------
plot_annual_flow_timing(station_number = "08NM116",
                        start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_annual_lowflows(station_number = "08NM116",
                                        start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 4.5, fig.width = 7, comment=NA----------------
plot_annual_lowflows(station_number = "08NM116",
                     start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 4.5, fig.width = 7, comment=NA----------------
plot_annual_lowflows(station_number = "08NM116",
                     start_year = 1990, end_year = 2001)[[2]]

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_annual_means(station_number = "08NM116",
                  start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_annual_stats(station_number = "08NM116",
                  start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_annual_stats(station_number = "08NM116",
                                     start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 2, fig.width = 7, comment=NA------------------
plot_annual_cumulative_stats(station_number = "08NM116",
                             start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 2, fig.width = 7, comment=NA------------------
plot_annual_cumulative_stats(station_number = "08NM116",
                             start_year = 1990, end_year = 2001,use_yield = TRUE)[[1]]

## ----  echo=FALSE, fig.height = 4, fig.width = 7, comment=NA------------------
plot_annual_cumulative_stats(station_number = "08NM116", include_seasons = TRUE,
                             start_year = 1990, end_year = 2001)[[3]]

## ----  echo=FALSE, fig.height = 4, fig.width = 7, comment=NA------------------
plot_annual_cumulative_stats(station_number = "08NM116", include_seasons = TRUE,
                             start_year = 1990, end_year = 2001,use_yield = TRUE)[[3]]

## ----  echo=FALSE, fig.height = 2.5, fig.width = 7, comment=NA----------------
plot_annual_cumulative_stats(station_number = "08NM116", include_seasons = TRUE,
                             start_year = 1990, end_year = 2001)[[2]]

## ----  echo=FALSE, fig.height = 2.5, fig.width = 7, comment=NA----------------
plot_annual_cumulative_stats(station_number = "08NM116", include_seasons = TRUE,
                             start_year = 1990, end_year = 2001,use_yield = TRUE)[[2]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_monthly_stats(station_number = "08NM116",
                                      start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 4.5, fig.width = 7, comment=NA----------------
plot_monthly_stats(station_number = "08NM116", 
                   start_year = 1990, end_year = 2001)[[3]]

## ----  echo=FALSE, fig.height = 4.5, fig.width = 7, comment=NA----------------
plot_monthly_stats(station_number = "08NM116",
                   start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 4.5, fig.width = 7, comment=NA----------------
plot_monthly_stats(station_number = "08NM116", 
                   start_year = 1990, end_year = 2001)[[2]]

## ----  echo=FALSE, fig.height = 4.5, fig.width = 7, comment=NA----------------
plot_monthly_stats(station_number = "08NM116",
                   start_year = 1990, end_year = 2001)[[4]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_monthly_cumulative_stats(station_number = "08NM116",
                                                 start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_monthly_cumulative_stats(station_number = "08NM116",
                              start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_monthly_cumulative_stats(station_number = "08NM116", use_yield = TRUE,
                                                 start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_monthly_cumulative_stats(station_number = "08NM116", use_yield = TRUE,
                              start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_daily_stats(station_number = "08NM116",
                                    start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_daily_stats(station_number = "08NM116",
                 start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_daily_stats(station_number = "08NM116", add_year = 1990,
                 start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_daily_cumulative_stats(station_number = "08NM116",
                                               start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_daily_cumulative_stats(station_number = "08NM116",
                            start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_daily_cumulative_stats(station_number = "08NM116", add_year = 1990,
                            start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(calc_daily_cumulative_stats(station_number = "08NM116", use_yield = TRUE,
                                               start_year = 1990, end_year = 2001)))

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_daily_cumulative_stats(station_number = "08NM116", use_yield = TRUE,
                            start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, fig.height = 3, fig.width = 7, comment=NA------------------
plot_daily_cumulative_stats(station_number = "08NM116", add_year = 1990, use_yield = TRUE,
                            start_year = 1990, end_year = 2001)[[1]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
trends <- compute_annual_trends(station_number = "08NM116", zyp_method = "zhang", zyp_alpha = 0.05,
                                start_year = 1990, end_year = 2001)
head(as.data.frame(trends[[1]]))

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(trends[[2]]))

## ----  echo=FALSE, comment=NA, fig.height = 3, fig.width = 7------------------
trends[[51]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
freq <- compute_annual_frequencies(station_number = "08NM116",
                                   start_year = 1990, end_year = 2001)
head(as.data.frame(freq[[1]]))

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(freq[[2]]))

## ----  echo=FALSE, comment=NA, fig.height = 4, fig.width = 7------------------
freq[[3]]

## ----  echo=FALSE, comment=NA-------------------------------------------------
head(as.data.frame(freq[[5]]))

