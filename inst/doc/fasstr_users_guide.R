## ----options, include=FALSE---------------------------------------------------
knitr::opts_chunk$set(eval = nzchar(Sys.getenv("hydat_eval")),
# warning = FALSE, 
message = FALSE)

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  install.packages("fasstr")

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  if(!requireNamespace("remotes")) install.packages("remotes")
#  remotes::install_github("bcgov/fasstr")

## ---- echo=TRUE---------------------------------------------------------------
library(fasstr)

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  tidyhydat::download_hydat()

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  tidyhydat::hy_version()

## ----setup, include = FALSE---------------------------------------------------
data <- tidyhydat::hy_daily_flows("08NM116")
data <- data[,c(1,2,4)]

## ----flow_data, echo=FALSE, comment=NA----------------------------------------
data.frame(data[1:6,])

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  calc_longterm_daily_stats(data = flow_data)

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  calc_longterm_daily_stats(data = flow_data,
#                            dates = Dates,
#                            values = Flows,
#                            groups = Stations)

## ---- echo=TRUE, eval=FALSE---------------------------------------------------
#  calc_longterm_daily_stats(station_number = "08NM116")
#  calc_longterm_daily_stats(station_number = c("08NM116", "08NM242"))

## ----exampletidy, comment=NA--------------------------------------------------
fill_missing_dates(station_number = "08HA011") %>% 
  add_date_variables() %>% 
  add_rolling_means(roll_days = 7)

## ---- eval=FALSE--------------------------------------------------------------
#  # Very gappy (early years):
#  tidyhydat::hy_daily_flows(station_number = "08NM116")
#  
#  # Gap filled with NA's
#  tidyhydat::hy_daily_flows(station_number = "08NM116") %>%
#    fill_missing_dates()

## ---- eval=FALSE--------------------------------------------------------------
#  # Just calendar year info
#  add_date_variables(station_number = "08NM116")
#  
#  # If water years are required starting August (use month number)
#  add_date_variables(station_number = "08NM116",
#                     water_year_start = 8)

## ---- eval=FALSE--------------------------------------------------------------
#  #  2 seasons starting January
#  add_seasons(station_number = "08NM116",
#              seasons_length = 6)
#  
#  #  4 seasons starting October
#  add_seasons(station_number = "08NM116",
#              water_year_start = 10,
#              seasons_length = 3)
#  
#  #  4 Seasons starting December
#  add_seasons(station_number = "08NM116",
#              water_year_start = 12,
#              seasons_length = 3)

## ----  echo=FALSE, comment=NA-------------------------------------------------
library(fasstr)
head(add_rolling_means(station_number = "08HA011", roll_days = 5, roll_align = "left") %>% 
       dplyr::rename("Q5Day_left" = Q5Day) %>% 
       add_rolling_means(roll_days = 5, roll_align = "center") %>% 
       dplyr::rename("Q5Day_center" = Q5Day) %>% 
       add_rolling_means(roll_days = 5, roll_align = "right") %>% 
       dplyr::rename("Q5Day_right" = Q5Day) %>% 
       dplyr::select(-STATION_NUMBER, -Parameter, -Symbol))


## ----  echo=FALSE, comment=NA-------------------------------------------------
library(fasstr)
head(add_rolling_means(station_number = "08HA011", roll_days = 6, roll_align = "left") %>% 
       dplyr::rename("Q6Day_left" = Q6Day) %>% 
       add_rolling_means(roll_days = 6, roll_align = "center") %>% 
       dplyr::rename("Q6Day_center" = Q6Day) %>% 
       add_rolling_means(roll_days = 6, roll_align = "right") %>% 
       dplyr::rename("Q6Day_right" = Q6Day) %>% 
       dplyr::select(-STATION_NUMBER, -Parameter, -Symbol))


## ---- eval=FALSE--------------------------------------------------------------
#  # Using the station_number argument or data frame as HYDAT groupings
#  add_basin_area(station_number = "08NM116")
#  
#  # Using the basin_area argument
#  add_basin_area(station_number = "08NM116",
#                 basin_area = 800)
#  
#  # Using the basin_area argument with multiple stations
#  add_basin_area(station_number = c("08NM116","08NM242"),
#                 basin_area = c("08NM116" = 800, "08NM242" = 4))

## ---- eval=FALSE--------------------------------------------------------------
#  # Add a column of converted discharge (m3/s) into volume (m3)
#  add_daily_volume(station_number = "08NM116")
#  
#  # Add a column of converted discharge (m3/s) into yield (mm), with HYDAT station groups
#  add_daily_yield(station_number = "08NM116")
#  
#  # Add a column of converted discharge (m3/s) into yield (mm), with setting the basin area
#  add_daily_yield(station_number = "08NM116",
#                  basin_area = 800)

## ---- eval=FALSE--------------------------------------------------------------
#  # Add a column of cumulative volumes (m3)
#  add_cumulative_volume(station_number = "08NM116")
#  
#  # Add a column of cumulative yield (mm), with HYDAT station number groups
#  add_cumulative_yield(station_number = "08NM116")
#  
#  # Add a column of cumulative yield (mm), with setting the basin area
#  add_cumulative_yield(station_number = "08NM116",
#                       basin_area = 800)

## ---- comment=NA--------------------------------------------------------------
fill_missing_dates(station_number = "08NM116") %>% 
  add_date_variables(water_year_start = 9) %>%
  add_seasons(seasons_length = 3) %>% 
  add_rolling_means() %>%
  add_basin_area() %>% 
  add_daily_volume() %>%
  add_daily_yield() %>%
  add_cumulative_volume() %>% 
  add_cumulative_yield()

## ---- fig.height = 2.5, fig.width = 7, comment=NA, warning=FALSE--------------
plot_flow_data(station_number = "08NM116") 

## ---- fig.height = 2.5, fig.width = 7, comment=NA, warning=FALSE--------------
plot_flow_data(station_number = c("08NM241", "08NM242"),
               one_plot = TRUE) 

## ---- comment=NA--------------------------------------------------------------
screen_flow_data(station_number = "08NM116")

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
plot_data_screening(station_number = "08NM116") 

## ---- fig.height = 4, fig.width = 7, comment=NA-------------------------------
plot_missing_dates(station_number = "08NM116") 

## ---- comment=NA--------------------------------------------------------------
calc_longterm_daily_stats(station_number = "08NM116", 
                          start_year = 1974)

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
plot_longterm_daily_stats(station_number = "08NM116", 
                          start_year = 1974,
                          inner_percentiles = c(25,75),
                          outer_percentiles = c(10,90)) 

## ---- comment=NA--------------------------------------------------------------
calc_longterm_monthly_stats(station_number = "08NM116", 
                            start_year = 1974)

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
plot_longterm_monthly_stats(station_number = "08NM116", 
                            start_year = 1974) 

## ---- comment=NA--------------------------------------------------------------
calc_annual_stats(station_number = "08NM116", 
                  start_year = 1974)

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
plot_annual_stats(station_number = "08NM116", 
                  start_year = 1974) 

## ---- comment=NA--------------------------------------------------------------
calc_monthly_stats(station_number = "08NM116", 
                   start_year = 1974)

## ---- fig.height = 4, fig.width = 7, comment=NA-------------------------------
plot_monthly_stats(station_number = "08NM116", 
                   start_year = 1974)[1]

## ---- comment=NA--------------------------------------------------------------
calc_daily_stats(station_number = "08NM116", 
                 start_year = 1974)

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
plot_daily_stats(station_number = "08NM116", 
                 start_year = 1974) 

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
plot_daily_stats(station_number = "08NM116", 
                 start_year = 1974,
                 add_year = 2000) 

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
plot_flow_duration(station_number = "08NM116",
                   start_year = 1974) 

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
plot_flow_duration(station_number = "08NM116",
                   start_year = 1974,
                   months = 7:9,
                   include_longterm = FALSE) 

## ----  echo=TRUE, comment=NA--------------------------------------------------
calc_longterm_mean(station_number = "08NM116", 
                   start_year = 1974,
                   percent_MAD = c(5,10,20))

## ----  echo=TRUE, comment=NA--------------------------------------------------
calc_longterm_percentile(station_number = "08NM116",
                         start_year = 1974,
                         percentiles = c(25,50,75))

## ----  echo=TRUE, comment=NA--------------------------------------------------
calc_flow_percentile(station_number = "08NM116", 
                     start_year = 1974,
                     flow_value = 6.270)

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
add_daily_volume(station_number = "08NM116") %>%
  plot_annual_stats(values = "Volume_m3",
                    start_year = 1974) 

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
add_daily_yield(station_number = "08NM116") %>%
  plot_daily_stats(values = "Yield_mm",
                   start_year = 1974) 

## ---- comment=NA--------------------------------------------------------------
calc_annual_cumulative_stats(station_number = "08NM116", start_year = 1974)

## ---- comment=NA--------------------------------------------------------------
calc_annual_cumulative_stats(station_number = "08NM116", 
                             start_year = 1974,
                             include_seasons = TRUE)

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
plot_annual_cumulative_stats(station_number = "08NM116", 
                             start_year = 1974) 

## ---- comment=NA--------------------------------------------------------------
calc_monthly_cumulative_stats(station_number = "08NM116", 
                              start_year = 1974)

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
plot_monthly_cumulative_stats(station_number = "08NM116", 
                              start_year = 1974) 

## ---- comment=NA--------------------------------------------------------------
calc_daily_cumulative_stats(station_number = "08NM116", 
                            start_year = 1974)

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
plot_daily_cumulative_stats(station_number = "08NM116", 
                            start_year = 1974,
                            use_yield = TRUE) 

## ---- comment=NA--------------------------------------------------------------
calc_annual_flow_timing(station_number = "08NM116", 
                        start_year = 1974)

## ---- fig.height = 4.5, fig.width = 7, comment=NA-----------------------------
plot_annual_flow_timing(station_number = "08NM116",
                        start_year = 1974) 

## ---- comment=NA--------------------------------------------------------------
calc_annual_lowflows(station_number = "08NM116", 
                     start_year = 1974)

## ---- fig.height = 4.5, fig.width = 7, comment=NA-----------------------------
plot_annual_lowflows(station_number = "08NM116",
                     start_year = 1974) 

## ---- comment=NA--------------------------------------------------------------
calc_annual_peaks(station_number = "08NM116", 
                  start_year = 1974)

## ---- comment=NA--------------------------------------------------------------
calc_annual_outside_normal(station_number = "08NM116", 
                           start_year = 1974)

## ---- fig.height = 4.5, fig.width = 7, comment=NA-----------------------------
plot_annual_outside_normal(station_number = "08NM116", 
                           start_year = 1974) 

## ---- comment=NA--------------------------------------------------------------
colnames(calc_all_annual_stats(station_number = "08NM116",
                               start_year = 1974))

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
plot_annual_means(station_number = "08NM116", 
                  start_year = 1974) 

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116")

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    ignore_missing = TRUE)

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    ignore_missing = TRUE,
#                    water_year_start = 9)

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    ignore_missing = TRUE,
#                    water_year_start = 8)

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    start_year = 1980,
#                    end_year = 2010)

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    start_year = 1980,
#                    end_year = 2010,
#                    exclude_years = 1982)

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    start_year = 1980,
#                    end_year = 2010,
#                    exclude_years = c(1982:1984))

## ---- eval=FALSE--------------------------------------------------------------
#  calc_longterm_daily_stats(station_number = "08NM116",
#                            complete_years = TRUE)

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_flow_timing(station_number = "08NM116")

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    start_year = 1980,
#                    end_year = 2010,
#                    months = 6:8)

## ---- eval=FALSE--------------------------------------------------------------
#  calc_longterm_daily_stats(station_number = "08NM116",
#                            start_year = 1980,
#                            end_year = 2010,
#                            custom_months = 6:8,
#                            custom_months_label = "Summer")

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    start_year = 1980,
#                    end_year = 2010,
#                    roll_days = 7)

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
plot_annual_lowflows(station_number = "08NM116", 
                     start_year = 1980, 
                     end_year = 2010,
                     roll_days = c(7,30))[[1]]

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    start_year = 1980,
#                    end_year = 2010)

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_stats(station_number = "08NM116",
#                    start_year = 1980,
#                    end_year = 2010,
#                    percentiles = c(5,25))

## ---- eval=FALSE--------------------------------------------------------------
#  calc_annual_flow_timing(station_number = "08NM116",
#                          start_year = 1980,
#                          end_year = 2010,
#                          percent_total = c(10,20))

## ---- fig.height = 4.5, fig.width = 7, comment=NA-----------------------------
plot_annual_outside_normal(station_number = "08NM116", 
                           start_year = 1980, 
                           end_year = 2010,
                           normal_percentiles = c(10,90))

## ---- comment=NA--------------------------------------------------------------
calc_longterm_daily_stats(station_number = "08NM116", 
                          start_year = 1980, 
                          end_year = 2010)

## ---- comment=NA--------------------------------------------------------------
calc_longterm_daily_stats(station_number = "08NM116", 
                          start_year = 1980, 
                          end_year = 2010,
                          transpose = TRUE)

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
plot_annual_stats(station_number = "08NM116", 
                  start_year = 1980,
                  end_year = 2010)

## ---- fig.height = 2.5, fig.width = 7, comment=NA, warning=FALSE--------------
plot_annual_stats(station_number = "08NM116", 
                  start_year = 1980,
                  end_year = 2010,
                  log_discharge = TRUE)

## ---- fig.height = 2.5, fig.width = 7, comment=NA-----------------------------
plot_annual_stats(station_number = "08NM116", 
                  start_year = 1980,
                  end_year = 2010,
                  include_title = TRUE)

## ---- fig.height = 4, fig.width = 7, comment=NA-------------------------------
plot_monthly_stats(station_number = "08NM116", 
                   start_year = 1980,
                   end_year = 2010,
                   include_title = TRUE)[[1]]

## ---- fig.height = 3, fig.width = 7, comment=NA-------------------------------
library(ggplot2)

# Create the plot list and extract the plot using [[1]]
plot <- plot_daily_stats(station_number = "08NM116", start_year = 1980)[[1]]

# Customize the plot with various `ggplot2` functions
plot + 
  geom_hline(yintercept = 1.5, colour = "red", linetype = 2, size = 1) +
  geom_vline(xintercept = as.Date("1900-03-01"), colour = "darkgray", linetype = 1, size = 0.5) +
  geom_vline(xintercept = as.Date("1900-08-05"), colour = "darkgray", linetype = 1, size = 0.5) +
  ggtitle("Mission Creek Annual Hydrograph") +
  ylab("Flow (cms)")


## ---- eval=FALSE--------------------------------------------------------------
#  write_flow_data(station_number = "08NM116")

## ---- eval=FALSE--------------------------------------------------------------
#  write_flow_data(station_number = "08NM116",
#                  start_year = 1960,
#                  end_year = 1970
#                  fill_missing = TRUE,
#                  file_name = "mission_creek.csv")

## ---- eval=FALSE--------------------------------------------------------------
#  annual_data <- calc_annual_stats(station_number = "08NM116")
#  
#  write_results(data = annual_data,
#                digits = 3,
#                file_name = "mission_creek_annual_flows.xlsx")

## ---- eval=FALSE--------------------------------------------------------------
#  annual_plots <- plot_annual_stats(station_number = c("08NM116","08NM242"))
#  
#  write_plots(plots = annual_data,
#              folder_name = "Annual Plots",
#              plot_filetype = "png")

## ---- eval=FALSE--------------------------------------------------------------
#  annual_plots <- plot_annual_stats(station_number = c("08NM116","08NM242"))
#  
#  write_plots(plots = annual_data,
#              folder_name = "Annual Plots",
#              combined_pdf = TRUE)

## ---- eval=FALSE--------------------------------------------------------------
#  freq_analysis <- compute_annual_frequencies(station_number = "08NM116")
#  
#  write_objects_list(list = freq_analysis,
#                     folder_name = "Frequency Analysis",
#                     plot_filetype = "png",
#                     table_filetype = "xlsx")

