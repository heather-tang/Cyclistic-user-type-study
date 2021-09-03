# Package importing ------------------------------------------------------
# Import required packages
# tidyverse for data import and wrangling
# libridate for date functions
# ggplot for visualization

library(tidyverse) # helps wrangle data
library(lubridate) # helps wrangle data attirbutes
library(ggplot2) # helps visualize date
getwd() # displays working directory
setwd("/Downloads/case-study-1-bike-share/202007-202106-divvy-tripdata")
# sets working directory to simply calls to data


# STEP 1: IMPORT DATA -----------------------------------------------------
## Load twelve months data ----------------------
t2020_07 <- read.csv("202007-divvy-tripdata.csv")
t2020_08 <- read.csv("202008-divvy-tripdata.csv")
t2020_09 <- read.csv("202009-divvy-tripdata.csv")
t2020_10 <- read.csv("202010-divvy-tripdata.csv")
t2020_11 <- read.csv("202011-divvy-tripdata.csv")

t2020_12 <- read.csv("202012-divvy-tripdata.csv")
t2021_01 <- read.csv("202101-divvy-tripdata.csv")
t2021_02 <- read.csv("202102-divvy-tripdata.csv")
t2021_03 <- read.csv("202103-divvy-tripdata.csv")
t2021_04 <- read.csv("202104-divvy-tripdata.csv")
t2021_05 <- read.csv("202105-divvy-tripdata.csv")
t2021_06 <- read.csv("202106-divvy-tripdata.csv")

# Got an error when combining all the files saying
# types of start_station_id and end_station_id are not uniformed in the files

# After inspection, found before Dec 2020, they are integer
# afterwards, character

# So breaking down the rows-binding to two steps
# 202007-202011 to one table, the others to another

rides_a <- bind_rows(
  t2020_07, t2020_08, t2020_09,
  t2020_10, t2020_11
)

rides_b <- bind_rows(
  t2020_12,
  t2021_01, t2021_02, t2021_03,
  t2021_04, t2021_05, t2021_06
)

rides_a$start_station_id <- as.character(rides_a$start_station_id)
rides_a$end_station_id <- as.character(rides_a$end_station_id)

# Then these two tables are joined into df
df <- bind_rows(rides_a, rides_b)
str(df)
# 4,460,151 records found

# STEP 2: CLEAN UP AND ADD DATA TO PREPARE FOR ANALYSIS -------------------
# Add one column to display the length of ride, in min, rounded to an integer
# Add another column to display the length of ride, in sec

rides <- mutate(
  df,
  length_in_sec = (ymd_hms(ended_at) - ymd_hms(started_at)) / dseconds(1),
  length_in_min = round((ymd_hms(ended_at) - ymd_hms(started_at)) / dseconds(60), 0),
  year = year(ymd_hms(started_at)),
  month = month(ymd_hms(started_at), label = TRUE),
  dow = wday(ymd_hms(started_at), label = TRUE),
  date = date(ymd_hms(started_at))
)


# Check how many rides there are below or equal to 10 secs
# They seem to be failed attempts to prepare the bike and should not be counted
# 20,667 records found with length of ride below 10 sec, 0.46% of total
short <- filter(rides, length_in_sec > 0 & length_in_sec <= 10)
short


# Extremely long rides over 72h
# 753 records in total, including 729 casual rides and 24 member rides
# It makes 0.016% of total rides
long <-
  mutate(rides,
    length_in_h = (ymd_hms(rides$ended_at) - ymd_hms(rides$started_at)) / dseconds(3600)
  ) %>%
  filter(length_in_h > 72) %>%
  group_by(member_casual) %>%
  summarize(count = n())
long

# Extreme rides over 24h
# 3,564 records in total, including 3165 casual and 399 member
# Making 0.080% of total rides
long <-
  mutate(rides,
    length_in_h = (ymd_hms(rides$ended_at) - ymd_hms(rides$started_at)) / dseconds(3600)
  ) %>%
  filter(length_in_h > 24) %>%
  group_by(member_casual) %>%
  summarize(count = n())
long

# Because single pass supports longest session of 3h
# I calculated the rides beyond this
# There are 29,356 rides in total, including 25,745 of casual type and 3,611 of member
# It makes 0.66% of total rides
long <-
  mutate(rides,
    length_in_h = (ymd_hms(rides$ended_at) - ymd_hms(rides$started_at)) / dseconds(3600)
  ) %>%
  filter(length_in_h > 72) %>%
  group_by(member_casual) %>%
  summarize(count = n())
long

# Histogram showing how over 72h long rides distribute
rides %>%
  mutate(
    length_in_h = (ymd_hms(rides$ended_at) - ymd_hms(rides$started_at)) / dseconds(3600)
  ) %>%
  filter(length_in_h > 72) %>%
  group_by(member_casual) %>%
  ggplot(aes(x = length_in_h, color = member_casual)) +
  geom_freqpoly(binwidth = 2)


# STEP 3: CONDUCT DESCRIPTIVE ANALYSIS ------------------------------------

## 1 Average & median lengths ---------------------------------------------

# Making a filtered table without extremely long or short rides 
filtered <- filter(rides, length_in_sec > 10 & length_in_min < 1440)
filtered %>%
  select(length_in_sec, length_in_min) %>%
  arrange(length_in_sec)

mean(filtered$length_in_min)
# average(total ride length / rides)
# 657.8273 min

median(filtered$length_in_min)
# midpoint number
# 609 min

max(filtered$length_in_min)
# longest ride
# 1439 min (because ceiling is set at 24h, not very informative now)

min(filtered$length_in_min)
# shortest ride
# 11 sec (because of floor set at 10s,not very informative now)

summary(filtered$length_in_min)

# Compare member and casual uers
aggregate(filtered$length_in_min ~ filtered$member_casual, FUN = mean)
aggregate(filtered$length_in_min ~ filtered$member_casual, FUN = median)
aggregate(filtered$length_in_min ~ filtered$member_casual, FUN = max)
aggregate(filtered$length_in_min ~ filtered$member_casual, FUN = min)



## 2 How rides vary through the week -----------------------------
rides %>%
  filter(length_in_sec > 10 & length_in_min < 1440) %>%
  group_by(dow, member_casual) %>%
  summarize(total_ride = n())

write.csv(by_dow, file = "C:/Users/Daniel-Windows/Downloads/case-study-1-bike-share/rides-by-week.csv")

rides %>%
  filter(length_in_sec > 10 & length_in_min < 1440) %>%
  group_by(dow, member_casual) %>%
  summarize(total_ride = n()) %>%
  ggplot() +
  geom_col(mapping = aes(
    x = dow, y = total_ride / 1000,
    fill = member_casual
  )) +
  ylab("Total rides, '000") +
  labs(title = "More casual rides on the weekend")

## 3 How ride length varies through the week -----------------------------

# 3.1 Average length

# Notes on functions:
# wday() and goem_bar function notes:
# Arguments in wday(), label = TRUE, abbr = TRUE, helps to transform number
# of day into the name of days
# Argument postion = "dodge" in geom_col() helps to unstack the bars

# Discovery:
#Length is slightly longer on the weekend
# Casual type is two times that of member
rides %>%
  filter(length_in_sec > 10 & length_in_min < 1440) %>%
  group_by(dow, member_casual) %>%
  summarize(avg_length = mean(length_in_min)) %>%
  ggplot() +
  geom_col(
    mapping = aes(
      x = dow,
      y = avg_length,
      fill = member_casual
    ),
    position = "dodge"
  ) +
  # facet_grid(rows = vars(member_casual)) +
  ylab("Average ride length, min") +
  xlab("") +
  labs(title = "Average ride length through the week")


# 3.2 Length median, casual vs member

# With geom_boxplot
rides %>%
  filter(length_in_sec > 10 & length_in_min < 180) %>%
  group_by(member_casual) %>%
  ggplot(aes(x = dow, y = length_in_min)) +
  geom_boxplot() +
  facet_wrap(~member_casual)


## 4 How rides vary through the months -------------------------------
rides %>%
  filter(length_in_sec > 10 & length_in_min < 1440) %>%
  group_by(month, member_casual) %>%
  summarize(ride_total = n()) %>%
  ggplot() +
  geom_col(mapping = aes(x = month, y = ride_total / 1000, fill = member_casual)) +
  labs(title = "Rides by month", subtitle = "casual vs. member") +
  ylab("Total of rides, '000") +
  xlab("")


## 5 How length of ride changes by the month ----------------------------

# 5.1 Average length
rides %>%
  filter(length_in_sec > 10 & length_in_min < 1440) %>%
  group_by(month, member_casual) %>%
  summarize(avg_length = mean(length_in_min)) %>%
  ggplot() +
  geom_col(mapping = aes(
    x = month,
    y = avg_length,
    fill = member_casual
  )) +
  facet_grid(rows = vars(member_casual)) +
  labs(title = "Average ride length", subtitle = "casual vs member") +
  ylab("Length of ride, min") +
  xlab("")
?facet_grid

rides %>%
  group_by(month, member_casual) %>%
  summarize(median_length = median(length_in_min)) %>%
  write.csv(file = "/Users/Daniel-Windows/Downloads/median-length-by-month.csv")

rides %>%
  group_by(wday(dow, label = TRUE), member_casual) %>%
  summarize(median_length = median(length)) %>%
  write.csv(file = "/Users/Daniel-Windows/Downloads/median-length-by-dow.csv")


# 5.2 Length median, casual
# With geom_boxplot
rides %>%
  filter(
    member_casual == "casual",
    length_in_sec > 10 & length_in_min < 180
  ) %>%
  ggplot(
    aes(x = month, y = length_in_min)
  ) +
  geom_boxplot()

## 6 How rides vary by the hour -----------------------------------------
rides %>%
  filter(length_in_sec > 10 & length_in_min < 1440) %>%
  mutate(hour = hour(started_at)) %>%
  group_by(member_casual, hour) %>%
  summarize(count = n()) %>%
  ggplot(aes(x = hour, y = count / 1000, fill = member_casual)) +
  geom_col() +
  ylab("Total rides, '000")


## 7 How length of ride vary by the hour --------------------------------
rides %>%
  filter(length_in_sec > 10 & length_in_min < 1440) %>%
  mutate(hour = hour(started_at)) %>%
  group_by(member_casual, hour) %>%
  summarize(avg_length = mean(length_in_min)) %>%
  ggplot(aes(x = hour, y = avg_length, color = member_casual)) +
  geom_line()
ylab("Length of ride, min")


## 8 Length distribution ------------------------------------------------
# 8.1 Casual vs member
rides %>%
  filter(length_in_sec > 10 & length_in_min < 1440) %>%
  group_by(date, member_casual) %>%
  summarize(avg_length = round(mean(length_in_min), 0), count = n()) %>%
  ggplot(aes(x = date, y = avg_length, size = count, color = member_casual)) +
  geom_point(alpha = 1 / 3)


# 8.2 Casual
# To study the effect of single pass on casual rides
# First check the distribution within 24h
rides %>%
  filter(member_casual == "casual", length_in_sec > 10 & length_in_min < 1440) %>%
  mutate(
    length_in_h = (ymd_hms(ended_at) - ymd_hms(started_at)) / dseconds(3600)
  ) %>%
  ggplot(aes(x = length_in_h, binwidth = 1)) +
  geom_histogram()

# Then disctribution within 3h
# Discovery: 
# most casual rides are within 3h (matching the single pass 3h session limit)
rides %>%
  filter(member_casual == "casual", length_in_sec > 10 & length_in_min < 600) %>%
  mutate(
    length_in_h = (ymd_hms(ended_at) - ymd_hms(started_at)) / dseconds(3600)
  ) %>%
  ggplot(aes(x = length_in_h, binwidth = 0.5)) +
  geom_histogram()



# STEP 4: EXPORT SUMMARY FILE FOR FURTHER ANALYSIS ------------------------
counts <- aggregate(rides$length ~ rides$member_casual + rides$dow, FUN = mean)
write.csv(counts, file = "C:/Users/Daniel-Windows/Downloads/case-study-1-bike-share/avg_ride_length.csv")
# line break in file path may cause an error and stop execution

