# case-study-01
Code used to solve business tasks posed in case study 01 for a bike-share company Cyclistic/Divvy

This file includes first glimpse at the dataset for 2021 Jun.
The major question to be answered is "how do annual members and casual riders use Cyclistic bikes different".

In Process phase, two columns are suggested to be added in the table: 1) ride_length and 2)day_of_week.
It was suggested in GDAC course to open with Google Sheets the dataset but due to its giant size for Sheets or Excel, 
I opted to explore the data with SQL.

Because importing .csv file into SQL Server takes a few minutes, during the loading time, I skimmed the data in R.

Note that to import .csv file into SQL, use **Import Flat File** instead of **Import Data**.
During the importing process, an error prompted on the data type of nvarchar for some columns.
Turns out data stored in cols *start_station_name* and *end_station_name* exceeded the storage limit of the default type nvarchar(50).
I changed them to nvarchar(max) as a solution. 

[SQL Server data types](https://www.w3schools.com/sql/sql_datatypes.asp) for reference. 
