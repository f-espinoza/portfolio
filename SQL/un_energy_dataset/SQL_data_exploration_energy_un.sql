-- Energy production, trade and consumption
-- dataset from data.un.org
-- Updated: 1-Nov-2021

-- One of the tables has a name that corresponds
-- to a SQL function, so we can change it from
-- 'Year' to 'Years 

ALTER TABLE energia_un_csv 
RENAME COLUMN Year TO Years;

-- Let's see the first 100 rows to familiarize with this dataset.

SELECT *
FROM energia_un_csv
LIMIT 100;

-- There are Regions, Countries and Areas in the first column
-- let's see what are the years of the reports.

SELECT DISTINCT(Years)
FROM energia_un_csv;

-- We can see that the years of this dataset goes from 1995 to 2018.

-- Let's see what are all the diferent values for Region, Country and Area.

SELECT DISTINCT("Region-Country-Area")
FROM energia_un_csv

-- There are 237 values for this column. 

-- WE WANT TO KNOW THE VALUES FOR: AFRICA, NORTH AMERICA, SOUTH AMERICA, ASIA, EUROPE, AND OCEANIA.

SELECT "Region-Country-Area", Series, Value
FROM energia_un_csv
WHERE "Region-Country-Area" IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania')

-- Show the values for South America only for 2018.

SELECT "Region-Country-Area", Years, Series, Value
FROM energia_un_csv
WHERE "Region-Country-Area" == 'South America'
AND Years == 2018


-- COMPARING THE SUPPLY PER CAPITA IN GIGAJOULES BETWEEN SOUTH AMERICA, NORTH AMERICA AND EUROPE.

SELECT "Region-Country-Area", Years, Series, Value
FROM (
	SELECT *
	FROM energia_un_csv
	WHERE Series == 'Supply per capita (gigajoules)'
	)
WHERE "Region-Country-Area" IN ('North America', 'South America', 'Europe')
AND Years == 2018


-- CALCULATING PERCENTAGE DIFFERENCE BETWEEN SOUTH AMERICAN SUPPLY PER CAPITA 
-- AND OTHER REGIONS OF THE WORLD.

SELECT "Region-Country-Area", Years, Series, (((Value*100)/55)-100) as percentage_diff_SouthAmerica_supply_pc
FROM (
	SELECT *
	FROM energia_un_csv
	WHERE Series == 'Supply per capita (gigajoules)'
	)
WHERE "Region-Country-Area" IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania')
AND Years == 2018
ORDER BY percentage_diff_SouthAmerica_supply_pc DESC


-- COMPARING EIGHT COUNTRIES OF SOUTH AMERICA. THEIR PRIMARY ENERGY PRODUCTION AND NET IMPORTS.

-- Note: the first time I tried this query Bolivia didn't appear. That time I writed 'Bolivia', so I searched for the country with WHERE:

SELECT *
FROM energia_un_csv
WHERE "Region-Country-Area" LIKE 'Bol%'

-- With this you can see that Bolivia's Official name is 'Bolivia (Plurin. State of)'
-- and with that you can make the correct query now:

SELECT "Region-Country-Area", Years, Series, Value
FROM (
	SELECT *
	FROM energia_un_csv
	WHERE Series IN ('Primary energy production (petajoules)', 'Net imports [Imports - Exports - Bunkers] (petajoules)', 'Supply per capita (gigajoules)')
	)
WHERE "Region-Country-Area" IN ('Brazil', 'Chile', 'Argentina', 'Peru', 'Uruguay', 'Bolivia (Plurin. State of)', 'Colombia', 'Ecuador')
AND Years == 2018


-- PERCENTAGE DIFFERENCE BETWEEN THE LOWEST SUPPLY PER CAPITA OF THE COUNTRIES SEEN BEFORE.

-- First we find the lowest supply per capita between the selected countries.

SELECT "Region-Country-Area", Years, Series, MIN(Value)
FROM (
	SELECT *
	FROM energia_un_csv
	WHERE Series == 'Supply per capita (gigajoules)'
	)
WHERE "Region-Country-Area" IN ('Brazil', 'Chile', 'Argentina', 'Peru', 'Uruguay', 'Bolivia (Plurin. State of)', 'Colombia', 'Ecuador')
AND Years == 2018


-- After that we can apply the same method that we did before.

SELECT "Region-Country-Area", Years, Series, (((Value*100)/31)-100) as percentage_diff_SouthAmerica
FROM (
	SELECT *
	FROM energia_un_csv
	WHERE Series == 'Supply per capita (gigajoules)'
	)
WHERE "Region-Country-Area" IN ('Brazil', 'Chile', 'Argentina', 'Peru', 'Uruguay', 'Bolivia (Plurin. State of)', 'Colombia','Ecuador')
AND Years == 2018
ORDER BY percentage_diff_SouthAmerica DESC


-- Returning to the entire dataset. We can see WHICH COUNTRY HAS THE HIGHEST SUPPLY PER CAPITA, THE LOWEST IMPORTS AND THE HIGHEST ONES.

-- Highest supply per capita

SELECT "Region-Country-Area", Years, Series, MAX(Value)
FROM energia_un_csv
WHERE Series == 'Supply per capita (gigajoules)'

-- Poland in 2000 was the country with the highest supply per capita with 99 gigajoules.

-- Let's try it again, but with the year 2018:

SELECT "Region-Country-Area", Years, Series, MAX(Value)
FROM energia_un_csv
WHERE Series == 'Supply per capita (gigajoules)'
AND Years == 2018

-- This time Bhutan has the highest value, with 94 gigajoules per capita.


-- The lowest Net imports, 2018.

SELECT "Region-Country-Area", Years, Series, MIN(Value)
FROM energia_un_csv
WHERE Series == 'Net imports [Imports - Exports - Bunkers] (petajoules)'
AND Years == 2018

-- Azerbaijan, with -1,735 petajoules.

-- The highest Net imports, 2018.

SELECT "Region-Country-Area", Years, Series, MAX(Value)
FROM energia_un_csv
WHERE Series == 'Net imports [Imports - Exports - Bunkers] (petajoules)'
AND Years == 2018

-- Belarus, with 989 petajoules.

-- WHAT IS THE EVOLUTION OF ENERGY PRODUCTION IN GERMANY?

SELECT "Region-Country-Area", Years, Series, Value
FROM energia_un_csv
WHERE "Region-Country-Area" == 'Germany'

-- As we can see, the supply per capita in Germany has been decreasing since 2010.
-- we can calculate the percentage of the reduction compared with base year 2010:

SELECT "Region-Country-Area", Years, Series, ((Value*100/171)-100) as percentage_diff
FROM energia_un_csv
WHERE "Region-Country-Area" == 'Germany'
AND Series == 'Supply per capita (gigajoules)'
AND Years BETWEEN 2010 AND 2018

-- With base year 2010, the supply per capita reduction was 12% in 2018.

-- We can also see that the primary energy production also decreased, but the Net imports were really stable.
-- Let's calculate the percentage variation of primary energy procution from 1995 to 2018.
-- We rounded the value of 6.05 to 6.

SELECT "Region-Country-Area", Years, Series,  ((Value*100/6)-100) as percentage_diff
FROM energia_un_csv
WHERE "Region-Country-Area" == 'Germany'
AND Series == 'Primary energy production (petajoules)'

-- The difference between primary energy production from 1995 to 2018 is -34%.


-- IN CONTRAST, THE RUSSIAN FEDERATION ENERGY PRODUCTION AND SUPPLY HAS BEEN INCREASING SINCE 1995.

SELECT "Region-Country-Area", Years, Series, Value
FROM energia_un_csv
WHERE "Region-Country-Area" == 'Russian Federation'

-- We can calculate in the same way we did with Germany:

SELECT "Region-Country-Area", Years, Series, ((Value*100/180)-100) as percentage_diff
FROM energia_un_csv
WHERE "Region-Country-Area" == 'Russian Federation'
AND Series == 'Supply per capita (gigajoules)'

-- Since 1995 the supply per capita in The Russian Federation has increased 26%.

-- We can get the variable value for the base year with a function, with this we don't need to type the specific number for the function.

SELECT "Region-Country-Area", Years, Series, Value,
	Value*100/(SELECT MIN(Value) FROM energia_un_csv WHERE Series == 'Primary energy production (petajoules)' AND "Region-Country-Area" == 'Russian Federation')-100 AS BaseValue 
FROM energia_un_csv
WHERE "Region-Country-Area" == 'Russian Federation'
AND Series == 'Primary energy production (petajoules)'

-- In the Russian Federation the primary energy production increased 55% since 1995.


-- WHAT IS THE AVERAGE PRIMARY ENERGY PRODUCTION IN THE WORLD?

SELECT Series, AVG(Value) as Avg_value
FROM energia_un_csv
WHERE "Region-Country-Area" NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania', 'Total, all countries or areas')
AND Series == 'Primary energy production (petajoules)'
AND Years == 2018

-- Avg_value is 130,99

-- HAS THIS VALUE INCREASED SINCE 1995?

SELECT Series, AVG(Value) as Avg_value
FROM energia_un_csv
WHERE "Region-Country-Area" NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania','Total, all countries or areas')
AND Series == 'Primary energy production (petajoules)'
AND Years == 1995

-- Avg_value for 1995 was 127,46.

-- THE AVERAGE GLOBAL PRIMARY ENERGY PRODUCTION HAS INCREASED SINCE 1995.
