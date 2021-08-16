
##########################################
# Install required packages
# tidyverse for data import and wrangling
# libridate for date functions
# ggplot for visualization
##########################################

library(tidyverse) # helps wrangle data
library(lubridate) # helps wrangle data attirbutes
library(ggplot2) # helps visualize date
getwd() # displays working directory
setwd("/Users/Daniel-Windows/Downloads/case-study-1-bike-share/") 
# sets working directory to simply calls to data



#====================
# STEP 1: IMPORT DATA
#====================

# Load the view created in SQL of 12 months combined
df <- read_csv("aggregated-twelve-months.csv")

# Check what columns there are 
colnames(df)


# Remove the columns not needed for analysis with mutate() 
# Use make_date() to create a short date

#======================================================
# STEP 2: CLEAN UP AND ADD DATA TO PREPARE FOR ANALYSIS
#======================================================

rides<- select(df, ride_id, started_at, ended_at, 
                member_casual) %>% 
  mutate(year = as.integer(year(started_at))
         , month = as.integer(month(started_at))
         , day = day(started_at)
         , dow = wday(started_at) 
         # in place of dow = weekdays(as.Date(started_at)), 
         # for a numeric output
         , length = ended_at - started_at) %>% 
  mutate(md = make_date(year, month)) %>% 
  filter(length > 0)

head(rides)


# Further modify the table to exclude columns of started_at
# Filter out the negative lengths if any
slim <- select(rides, ride_id, member_casual, 
               year, month, day, dow, length, md) %>% 
  filter(length > 0)
slim


# ====================================
# STEP 3: CONDUCT DESCRIPTIVE ANALYSIS
# ====================================

mean(slim$length) # average(total ride length / rides)
median(slim$length) # midpoint number 
max(slim$length) # longest ride
min(slim$length) # shortest ride

summary(slim$length)

# Compare member and casual uers
aggregate(slim$length ~ slim$member_casual, FUN = mean)
aggregate(slim$length ~ slim$member_casual, FUN = median)
aggregate(slim$length ~ slim$member_casual, FUN = max)
aggregate(slim$length ~ slim$member_casual, FUN = min)

aggregate(slim$length ~ slim$member_casual + slim$dow, FUN = mean)

# Check how total rides vary through the week 
slim %>%
  group_by(dow, member_casual) %>%
  summarize(total_ride = n()) %>%
  ggplot() +
  geom_col(mapping = aes(
    x = dow, y = total_ride / 1000,
    fill = member_casual
  )) +
  ylab("Total rides, '000") +
  xlab("Day of week, 1 = Sun") +
  labs(title = "More casual rides on the weekend")

# Check how ride length vary through the week 
slim %>% 
  group_by(dow, member_casual) %>% 
  summarize(avg_length = mean(length)) %>% 
  ggplot() + 
  geom_col(mapping = aes(x = dow, 
                         y = avg_length/60, 
                         fill = member_casual)) +
  ylab("Average ride length, min") +
  xlab("Day of week, 1 = Sun") +
  labs(title = "Average ride length through the week")


# Check how the total rides change by month
# Ride total grouped by month and customer type

slim %>%  
  group_by(md, member_casual) %>% 
  summarize(ride_total = n()) %>% 
  ggplot() +
  geom_col(mapping = aes(x = md, y = ride_total / 1000, fill = member_casual)) +
  labs(title = "Rides by month", subtitle = "casual vs. member") +
  ylab("Total of rides, '000") +
  xlab("")

?labs

# Check how the length of ride change by month
slim %>% 
  group_by(md, member_casual) %>% 
  summarize(avg_length = mean(length)) %>% 
  ggplot() +
  geom_col(mapping = aes(
    x = md, y = avg_length / 60,
    fill = member_casual
  )) +
  labs(title = "Average ride length", subtitle = "casual vs member") +
  ylab("Length of ride, min") +
  xlab("")


# check in which hour most rides occur
slim %>%  
  mutate(hour = as.integer(hour(rides$started_at))) %>% 
  group_by(hour) %>% 
  summarize(count = n()) %>% 
  ggplot() + 
  geom_col(mapping = aes(x = hour, y = count/1000)) +
  ylab("Total rides, '000")


# Check the distribution of length of ride
# Because most rides are shorter than 200 min, 
# I filtered the data to exclude those longer
slim %>% 
  filter (length < 12000) %>% 
  ggplot() + 
  geom_histogram(mapping = aes(x=length/60), bindwith = 5) +
  xlab("Length of ride, min") 

#=================================================
# STEP 4: EXPORT SUMMARY FILE FOR FURTHER ANALYSIS
#=================================================

counts <- aggregate(slim$length ~ slim$member_casual + slim$dow, FUN = mean)
write.csv(counts, file = 'C:/Users/Daniel-Windows/Downloads/
          case-study-1-bike-share/avg_ride_length.csv')




