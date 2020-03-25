USE divvy;

########################################################################################
############################## Moderately complex Queries ##############################
########################################################################################

# Net influx per station and hour
SELECT 
    tripFrom.station_id,
    tripFrom.stationName,
    tripFrom.TimeOfDay,
    tripFrom.tripFrom,
    tripTo.tripTo,
    AVG(tripTo.tripTo - tripFrom.tripFrom) AS NetInflux
FROM
    (SELECT 
        ds.station_id AS station_id,
            ds.station_name AS stationName,
            ft.weather_date_hour AS date_hour,
            ft.start_time AS start_time,
            HOUR(ft.start_time) AS TimeOfDay,
            COUNT(ft.from_station_id) AS tripFrom
    FROM
        fact_trip ft
    INNER JOIN dim_station ds ON ds.station_id = ft.from_station_id
    GROUP BY ft.weather_date_hour , ds.station_name
    ORDER BY ft.weather_date_hour) AS tripFrom
        INNER JOIN
    (SELECT 
        ds.station_id AS station_id,
            ds.station_name AS stationName,
            ft.weather_date_hour AS date_hour,
            HOUR(ft.start_time) AS TimeOfDay,
            COUNT(ft.to_station_id) AS tripTo
    FROM
        fact_trip ft
    INNER JOIN dim_station ds ON ds.station_id = ft.from_station_id
    GROUP BY ft.weather_date_hour , ds.station_name
    ORDER BY ft.weather_date_hour) AS tripTo ON tripTo.date_hour = tripFrom.date_hour
GROUP BY tripFrom.stationName , TimeOfDay
ORDER BY TimeOfDay;


# Average distance travelled per station and zip code
SELECT 
    FrS.station_id,
    FrS.trip_id,
    FrS.latitude AS lat1,
    FrS.longitude AS long1,
    TrS.station_id,
    TrS.trip_id,
    TrS.latitude AS lat2,
    TrS.longitude AS long2
FROM
    (SELECT 
        ds.station_id, ft.trip_id, dl.latitude, dl.longitude
    FROM
        dim_location dl
    INNER JOIN dim_station ds ON dl.location_id = ds.location_id
    INNER JOIN fact_trip ft ON ds.station_id = ft.from_station_id) AS FrS
        INNER JOIN
    (SELECT 
        ds.station_id, ft.trip_id, dl.latitude, dl.longitude
    FROM
        dim_location dl
    INNER JOIN dim_station ds ON dl.location_id = ds.location_id
    INNER JOIN fact_trip ft ON ds.station_id = ft.to_station_id) AS TrS ON FrS.trip_id = TrS.trip_id
WHERE
    FrS.station_id != TrS.station_id;
    

# Number of trip by month, day, and hour
SELECT 
    ds.station_id,
    ds.station_name AS stationName,
    MONTHNAME(f.start_time) AS Month_Q2,
    DAYNAME(f.start_time) AS dayOfWeek,
    HOUR(f.start_time) AS TimeOfDay,
    COUNT(f.trip_id) AS NoOfTrips
FROM
    fact_trip f
        INNER JOIN
    dim_station ds ON ds.station_id = f.from_station_id
GROUP BY Month_Q2 , TimeOfDay , dayOfWeek , ds.station_id
ORDER BY stationName , Month_Q2 , dayOfWeek , TimeOfDay ASC;


# Net number of trips per Weekday, Weekend by station
SELECT 
    ds.station_id,
    ds.station_name AS stationName,
    CASE
        WHEN DAYNAME(start_time) IN ('Saturday' , 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS DateType,
    COUNT(f.trip_id) AS NoOfTrips
FROM
    fact_trip f
        INNER JOIN
    dim_station ds ON ds.station_id = f.from_station_id
GROUP BY ds.station_id , DateType
ORDER BY stationName , DateType ASC;



########################################################################################
################################### All other Queries ##################################
########################################################################################

# Number of trips by day of the week
SELECT 
    DAYNAME(start_time) AS dayOfWeek,
    COUNT(trip_id) AS NoOfTrips
FROM
    fact_trip
GROUP BY dayOfWeek
ORDER BY NoOfTrips DESC;


# Number of trips by weekday and weekend
SELECT 
    CASE
        WHEN DAYNAME(start_time) IN ('Saturday' , 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS DateType,
    COUNT(trip_id) AS NumberOfTrips
FROM
    fact_trip
GROUP BY DateType
ORDER BY NumberOfTrips DESC;


# Number of trips by hour
SELECT 
    HOUR(start_time) AS TimeOfDay, COUNT(trip_id) AS NoOfTrips
FROM
    fact_trip
GROUP BY TimeOfDay
ORDER BY TimeOfDay;


# Number of trips by hour by weekay and weekend.
SELECT 
    CASE
        WHEN DAYNAME(start_time) IN ('Saturday' , 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS DateType,
    HOUR(start_time) AS TimeOfDay,
    COUNT(trip_id) AS NoOfTrips
FROM
    fact_trip
GROUP BY TimeOfDay , DateType
ORDER BY TimeOfDay DESC;


# Number of trips by hour within Month + weekay and weekend.
SELECT 
    MONTHNAME(start_time) AS Month_Q2,
    CASE
        WHEN DAYNAME(start_time) IN ('Saturday' , 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS DateType,
    HOUR(start_time) AS TimeOfDay,
    COUNT(trip_id) AS NoOfTrips
FROM
    fact_trip
GROUP BY Month_Q2 , TimeOfDay , DateType
ORDER BY Month_Q2 , DateType , TimeOfDay DESC;


# Number of trips by hour within Month + DayOfWeek.
SELECT 
    MONTHNAME(start_time) AS Month_Q2,
    DAYNAME(start_time) AS dayOfWeek,
    HOUR(start_time) AS TimeOfDay,
    COUNT(trip_id) AS NoOfTrips
FROM
    fact_trip
GROUP BY Month_Q2 , TimeOfDay , dayOfWeek
ORDER BY Month_Q2 , dayOfWeek , TimeOfDay ASC;


# number of trips per month by from_station
SELECT 
    ds.station_id,
    ds.station_name AS stationName,
    MONTHNAME(start_time) AS Month_Q2,
    COUNT(f.trip_id) AS NoOfTrips
FROM
    fact_trip f
        INNER JOIN
    dim_station ds ON ds.station_id = f.from_station_id
GROUP BY ds.station_id , Month_Q2
ORDER BY stationName , Month_Q2 ASC;


# number of trips per month by to_station
SELECT 
    ds.station_id,
    ds.station_name AS stationName,
    MONTHNAME(start_time) AS Month_Q2,
    COUNT(f.trip_id) AS NoOfTrips
FROM
    fact_trip f
        INNER JOIN
    dim_station ds ON ds.station_id = f.to_station_id
WHERE
    ds.station_id = 22
GROUP BY ds.station_id , Month_Q2
ORDER BY stationName , Month_Q2 ASC;


# Net number of trips per day by station
SELECT 
    ds.station_id,
    ds.station_name AS stationName,
    DAYNAME(start_time) AS dayOfWeek,
    COUNT(f.trip_id) AS NoOfTrips
FROM
    fact_trip f
        INNER JOIN
    dim_station ds ON ds.station_id = f.from_station_id
GROUP BY ds.station_id , dayOfWeek
ORDER BY stationName , dayOfWeek ASC;


# Net number of trips per hour and station
SELECT 
    ds.station_id,
    ds.station_name AS stationName,
    HOUR(f.start_time) AS TimeOfDay,
    COUNT(f.trip_id) AS NoOfTrips
FROM
    fact_trip f
        INNER JOIN
    dim_station ds ON ds.station_id = f.from_station_id
GROUP BY ds.station_id , TimeOfDay
ORDER BY stationName , TimeOfDay ASC;


# Number of docks by zip
SELECT 
    zip, SUM(total_docks) AS NoOfBike
FROM
    dim_station ds
        LEFT JOIN
    dim_location dl ON dl.location_id = ds.location_id
GROUP BY zip
ORDER BY NoOfBike;


# % of Male, Female by trip
SELECT 
    gender,
    CONCAT((COUNT(*) * 100 / (SELECT 
                    COUNT(*)
                FROM
                    fact_trip)),
            '%') AS perGenderTrip
FROM
    fact_trip
WHERE
    gender = 'Male' OR gender = 'Female'
GROUP BY gender;


# Trip end by zipcode
SELECT 
    dl.zip, COUNT(ft.to_station_id) AS TripEnd
FROM
    fact_trip ft
        INNER JOIN
    dim_station ds ON ds.station_id = ft.to_station_id
        LEFT JOIN
    dim_location dl ON dl.location_id = ds.location_id
GROUP BY zip
ORDER BY TripEnd DESC;


#Number of bike rack by zip
SELECT 
    dl.zip, COUNT(br.rack_id) AS noOfRack
FROM
    dim_bike_racks br
        LEFT JOIN
    dim_location dl ON dl.location_id = br.location_id
GROUP BY zip
ORDER BY noOfRack;


#Total population by zip
SELECT 
    zip,
    0_19_M + 0_19_F + 20_29_M + 20_29_F + 30_39_M + 30_39_F + 40_49_M + 40_49_F + 50plus_M + 50plus_F AS totalPop
FROM
    dim_population
ORDER BY totalPop DESC;


# Number of stations per zip code
SELECT 
    dl.zip, COUNT(ds.station_id) AS NumberOfStations
FROM
    dim_station ds
        INNER JOIN
    dim_location dl ON ds.location_id = dl.location_id
GROUP BY dl.zip
ORDER BY NumberOfStations DESC;


# Avergage Number of docks per station
SELECT 
    AVG(total_docks)
FROM
    dim_station;


# Subscribers vs. non-subscribers (percentage)
SELECT 
    user_type, COUNT(user_type) AS Total
FROM
    fact_trip
GROUP BY user_type;


# Trip started by zip code (station)
SELECT 
    dl.zip, COUNT(ft.from_station_id) AS NumberOfTripsStarted
FROM
    fact_trip ft
        INNER JOIN
    dim_station ds ON ft.from_station_id = ds.station_id
        INNER JOIN
    dim_location dl ON ds.location_id = dl.location_id
GROUP BY dl.zip
ORDER BY NumberOfTripsStarted DESC;


# Trip ended by zip code (station)
SELECT
	dl.zip,
    COUNT(ft.to_station_id) AS NumberOfTripsEnded
FROM
	fact_trip ft
		INNER JOIN
	dim_station ds ON ft.to_station_id=ds.station_id
		INNER JOIN
	dim_location dl ON ds.location_id=dl.location_id
GROUP BY
	dl.zip
ORDER BY
	NumberOfTripsEnded DESC;


# Number of trips and temperature
SELECT 
    dw.temperature, COUNT(ft.trip_id)
FROM
    fact_trip ft
        INNER JOIN
    dim_weather dw ON ft.weather_date_hour = dw.weather_date_hour
GROUP BY dw.temperature
ORDER BY temperature;


# Number of passing cars by zip
SELECT 
    dl.zip, (dt.count_from + dt.count_to) AS VehicleVolume
FROM
    dim_traffic dt
        INNER JOIN
    dim_location dl ON dt.location_id = dl.location_id
GROUP BY dl.zip
ORDER BY VehicleVolume DESC;


# Age group by zip
SELECT 
    zip,
    (0_19_M + 0_19_F) AS 0_19,
    (20_29_M + 20_29_F) AS 20_29,
    (30_39_M + 30_39_F) AS 30_39,
    (40_49_M + 40_49_F) AS 40_49,
    (50plus_M + 50plus_F) AS 50plus
FROM
    dim_population;


# Correlation between traffic and bike racks by zip
SELECT 
    dl.zip,
    SUM(dt.count_from + dt.count_from) AS 'Total traffic',
    COUNT(db.rack_id)
FROM
    dim_location dl
        LEFT JOIN
    dim_bike_racks db ON dl.location_id = db.location_id
        LEFT JOIN
    dim_traffic dt ON dl.location_id = dt.location_id
GROUP BY dl.zip;


# average duration of bike ride
SELECT 
    AVG(trip_duration) / 60 AS AverageTripDurationInMinutes
FROM
    fact_trip;


# age_groups (Total by age_group)
SELECT
	SUM(0_19_M), SUM(20_29_M), SUM(30_39_M), SUM(40_49_M), SUM(50plus_M),
    SUM(0_19_F), SUM(20_29_F), SUM(30_39_F), SUM(40_49_F), SUM(50plus_F)
FROM
	dim_population;


# total population
SELECT 
    (SUM(0_19_M) + SUM(20_29_M) + SUM(30_39_M) + SUM(40_49_M) + SUM(50plus_M) + SUM(0_19_F) + SUM(20_29_F) + SUM(30_39_F) + SUM(40_49_F) + SUM(50plus_F)) AS TotalPopulation
FROM
    dim_population;


# Population by zip
SELECT 
    zip,
    0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F AS TotalPopulation
FROM
    dim_population
ORDER BY TotalPopulation DESC;


# age_group in percentages for total population
SELECT 
    SUM(0_19_M) / 2695821 AS PercentOf_0_19_M,
    SUM(20_29_M) / 2695821 AS PercentOf_20_29_M,
    SUM(30_39_M) / 2695821 AS PercentOf_30_39_M,
    SUM(40_49_M) / 2695821 AS PercentOf_40_49_M,
    SUM(50plus_M) / 2695821 AS PercentOf_50plus_M,
    SUM(0_19_F) / 2695821 AS PercentOf_0_19_F,
    SUM(20_29_F) / 2695821 AS PercentOf_20_29_F,
    SUM(30_39_F) / 2695821 AS PercentOf_30_39_F,
    SUM(40_49_F) / 2695821 AS PercentOf_40_49_F,
    SUM(50plus_F) / 2695821 AS PercentOf_50plus_F
FROM
    dim_population;


# age_group in percentages by zipcode
SELECT 
    zip,
    0_19_M / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_0_19_M,
    20_29_M / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_20_29_M,
    30_39_M / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_30_39_M,
    40_49_M / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_40_49_M,
    50plus_M / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_50plus_M,
    0_19_F / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_0_19_F,
    20_29_F / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_20_29_F,
    30_39_F / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_30_39_F,
    40_49_F / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_40_49_F,
    50plus_F / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS PercentOf_50plus_F
FROM
    dim_population;


# Male vs Female by zip
SELECT 
    zip,
    0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M AS Male,
    (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M) / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS MalePercent,
    0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F AS Female,
    (0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) / (0_19_M + 20_29_M + 30_39_M + 40_49_M + 50plus_M + 0_19_F + 20_29_F + 30_39_F + 40_49_F + 50plus_F) AS FemalePercent
FROM
    dim_population
ORDER BY MalePercent DESC;


# percentages of days in q2 with precipitation, average temperature
SELECT 
    DATE_FORMAT(date, '%Y/%m/%d') AS DateNew,
    SUM(precipitation) / 100 AS HavePrecipitation
FROM
    dim_weather
GROUP BY DateNew
HAVING DateNew > '2018/03/01'
    AND DateNew < '2018/06/01';


# traffic by day of the week
SELECT 
    DAYNAME(date) AS WeekDayName,
    (SUM(count_from) + SUM(count_to)) AS VehicleVolumn
FROM
    dim_traffic
GROUP BY WeekDayName
ORDER BY VehicleVolumn;