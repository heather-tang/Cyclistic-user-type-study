library(tidyverse)
library(lubridate)

# Load the view created in SQL of 12 months combined
df <- read_csv("C:/Users/Daniel-Windows/Downloads/case-study-1-bike-share/aggregated-twelve-months.csv")

# Make a smaller table and add some columns with mutate() 
# Use make_date() to create a short date

rides<- select(df, ride_id, started_at, ended_at, 
                member_casual) %>% 
  mutate(year = as.integer(year(started_at)), 
         month = as.integer(month(started_at)),
         day = day(started_at), 
         dow = wday(started_at),
         length = ended_at - started_at) %>% 
  mutate(md = make_date(year, month)) %>% 
  filter(length > 0)


# Futher trimmed the table

slim <- select(rides, ride_id, member_casual, year, month, day, dow, length, md)  
slim

# Check how the total rides change over the past 12 months
# Ride total grouped by month and customer type

slim_group <- group_by(slim, md, member_casual)
slim_count <- summarize(slim_group, ride_total = n())

ggplot(slim_count) + 
  geom_line(mapping=aes(x=md, y=ride_total/1000, color = member_casual)) +
  labs(title = "total rides by month, casual vs. member") +
  ylab("total rides, 000")


# Check how the length of ride change over the past 12 months
slim_length <- summarize(slim_group, count = n(), avg_length = mean(length))

ggplot(slim_length) + 
  geom_line(mapping=aes(x=md, y=avg_length/60, color = member_casual)) +
  labs(title = "Average ride length, casual vs member") +
  ylab("length of ride, min") +
  xlab("Jul 2020 through Jun 2021")

# check in which hour most rides occur
slim_hour <- mutate(slim, hour = as.integer(hour(rides$started_at))) 
slim_hour_count <- group_by(slim_hour, hour) %>% 
  summarize(count = n())

ggplot(slim_hour_grouped) + 
  geom_point(mapping = aes(x = hour, y = count))

# Check the distribution of length of ride
# Because most rides are shorter than 200 min, 
# I filtered the data to exclude those longer
slim_filtered <- filter (slim, length < 12000)

ggplot(slim_filtered) + 
  geom_histogram(mapping = aes(x=length/60), bindwith = 10) +
  xlab("length of ride, min")

# Check how total rides vary through the week over the past 12 months
slim_dow <- group_by(slim, dow, member_casual) %>% 
  summarize(total_ride = n())
slim_dow

ggplot(slim_dow) +
  geom_line(mapping = aes(x = dow, y = total_ride/1000, 
                          color = member_casual)) +
  ylab("Total rides, 000") +
  xlab("Day of week") +
  labs(title = "Rides double on the weekend")

# Check how ride length vary through the week over the past 12 months
slim_dow_filtered <- filter(slim, length > 0) %>% 
  group_by(dow, member_casual)

summary <- summarize(slim_dow_filtered, avg_length = mean(length))
summary

ggplot(summary) + 
  geom_point(mapping = aes(x = dow, y = avg_length/60, 
                           color = member_casual)) +
  ylab("Average ride length, min") +
  xlab("Day of week") +
  labs(title = "Average ride length by week of day")
