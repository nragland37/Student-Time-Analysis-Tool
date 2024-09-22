# libraries ----
library(tidyverse)
library(hms)
library(lubridate)
library(viridis)
library(shiny)
library(plotly)

# dependencies ----
original <- read_csv("student_data.csv")

#*******************************************************************************
# sample data ----

# student_data_sample <- original %>%
#   select(id, days, beg_tm, end_tm, beg_date, end_date, sess, yr,
#          cl, major1_majortext, major1_conctext, crs_dept) %>%
#   filter(id == 4201937)

#*******************************************************************************
# data cleaning ----

## remove online classes ----
student_data <- original %>%
  filter(!(beg_tm == 0 & end_tm == 0 | days == "-------")) %>%
  select(id, sess, yr, cl, major1_majortext, major1_conctext, 
         crs_dept, days, beg_tm, end_tm, beg_date, end_date) %>%
  distinct()

## convert times ----
student_data <- student_data %>%
  mutate(
    beg_tm = hms::hms(hour = beg_tm %/% 100, minute = beg_tm %% 100), # time obj
    end_tm = hms::hms(hour = end_tm %/% 100, minute = end_tm %% 100),
    beg_date = mdy(beg_date),                                         # date obj
    end_date = mdy(end_date),
  )

## invalid days ----
invalid_days <- student_data %>%
  filter(days == "#NAME?") %>%
  arrange(id)

## semester terms ----
student_data <- student_data %>%
  mutate(term = case_when(
    month(beg_date) %in% c(1, 2, 3, 8, 9, 10) &
      month(end_date) %in% c(1, 2, 3, 8, 9, 10) ~ "1",
    month(beg_date) %in% c(3, 4, 5, 10, 11, 12) &
      month(end_date) %in% c(3, 4, 5, 10, 11, 12) ~ "2",
    TRUE ~ "full"
  ))

## separate days ----
student_data <- student_data %>%
  filter(days != "#NAME?") %>%                        # remove invalid days
  mutate(days = str_replace_all(days, "-", "")) %>%   # replace all occurrences
  separate_rows(days, sep = "") %>%                   # splits into mult rows
  filter(days != "") %>%                              # remove empty strings
  mutate(days = case_when(
    days == "M" ~ "Mon",
    days == "T" ~ "Tues",
    days == "W" ~ "Wed",
    days == "R" ~ "Thurs",
    days == "F" ~ "Fri",
    days == "S" ~ "Sat",
    days == "U" ~ "Sun",
    TRUE ~ days
  ))

## term gap times and intervals ----
get_term_gaps <- function(data, term_filter) {
  term_gaps <- data %>%
    filter(term %in% c(term_filter, "full")) %>%
    group_by(id, days) %>%
    arrange(beg_tm) %>%
    mutate(
      gap_beg_tm = end_tm,
      gap_end_tm = lead(beg_tm)
    ) %>%
    mutate(gap = as.numeric(lead(beg_tm) - end_tm) / 60) %>%
    arrange(id, days, beg_tm) %>%
    ungroup() %>%
    
    return(term_gaps)
}
term1_data <- get_term_gaps(student_data, "1")
term2_data <- get_term_gaps(student_data, "2")

## negative gaps ----
negative_gaps <- bind_rows(term1_data, term2_data) %>%
  filter(gap <= 0) %>%          
  arrange(id, days, beg_tm)

## concat terms ----
student_data <- bind_rows(term1_data, term2_data) %>%
  filter(gap > 0) %>%                                     # remove negatives
  distinct() %>%
  arrange(id, days, beg_tm)

#*******************************************************************************
## max gap times ----

filter_max_gap <- function(data, max_gap) {
  student_data <- data %>%
    filter(gap <= max_gap) %>%
    arrange(id, days, beg_tm)
  
  return(student_data)
}

#*******************************************************************************
# align gaps with intervals ----

gap_interval_matching <- function(inc) {
  ## structure time intervals (in seconds) ----
  seconds_in_day <- seq(from = 0, to = 24 * 60 * 60 - 1, by = inc * 60)
  day_beg_tm <- hms::hms(seconds_in_day)
  day_end_tm <- hms::hms(seconds_in_day + (inc * 60) - 1)
  
  ## create tibble (tidyverse data frame) of intervals ----
  intervals <- tibble(
    day_beg_tm = day_beg_tm,
    day_end_tm = day_end_tm,
    day_inc = format(day_beg_tm, "%H:%M:%S"), 
    day_mins = seq(inc, by = inc, length.out = length(day_beg_tm)),
    join = "join"                           # temp key for joining tables
  )
  
  ## join intervals with student data ----
  student_results <- student_data %>%
    mutate(join = "join") %>%                 
    left_join(intervals,                    # cartesian product (join all rows)
              relationship = "many-to-many") %>%          
    select(-join) %>%
    mutate(day_index = gap_beg_tm <= day_beg_tm &
             gap_end_tm >= day_end_tm) %>%         # logical condition
    filter(day_index == TRUE) %>%
    select(-day_index)
  
  return(student_results)
}

#*******************************************************************************
# heatmaps ----

get_heatmap <- function(data, term_filter) {
  p <- ggplot(data, aes(x = days, y = day_inc, fill = student_count)) +
    geom_tile() +
    geom_text(aes(label = student_count),
              size = 3, color = "white", fontface = "bold") +
    scale_fill_gradientn(
      colors = viridis(5),
      name = "Student Count",
    ) +
    labs(
      title = paste("Student Availability Between Classes: ",
                    student_data$sess[1], 
                    term_filter," ", 
                    student_data$yr[1]),
      x = "Day of Week",
      y = "Hour of Day"
    ) +
    theme_minimal(base_size = 12) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "right",
      legend.title = element_text(size = 12),
      legend.text = element_text(size = 10),
      plot.title = element_text(face = "bold", hjust = 0.5)
    )
  
  return(p)
}

#*******************************************************************************
# term increment counts ----

get_term_counts <- function(data, term_filter) {
  term_count <- data %>%
    filter(term %in% c(term_filter, "full")) %>%
    group_by(days, day_inc) %>%
    summarise(student_count = n(), .groups = "drop") %>%
    ungroup() %>%
    mutate(
      day_inc = as.POSIXct(sprintf("1970-04-01 %s", day_inc), 
                           format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
      day_inc = factor(format(day_inc, "%I:%M %p"),
                       levels = format(sort(unique(day_inc)), "%I:%M %p")),
      days = factor(days, levels = c(
        "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat", "Sun"))
    )
  
  return(term_count)
}

#*******************************************************************************