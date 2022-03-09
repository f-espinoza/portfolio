-- Energy production, trade and consumption
-- dataset from data.un.org
-- Updated: 1-Nov-2021
-- SQLite database

-- One of the tables has a name that corresponds
-- to a SQL function, so we can change it from
-- 'Year' to 'Years 

ALTER TABLE un_energia_clean_csv  
RENAME COLUMN Year TO Years;

-- Let's see the first 100 rows to familiarize with this dataset.

SELECT *
FROM un_energia_clean_csv
LIMIT 100;

-- There are Regions, Countries and Areas in the first column
-- let's see what are the years of the reports.

SELECT DISTINCT(Years)
FROM un_energia_clean_csv;


-- We can see that the years of this dataset goes from 1995 to 2018.

-- Let's see what are all the different values for Region, Country and Area.

SELECT DISTINCT(CoReg)
FROM un_energia_clean_csv

-- There are 237 values for this column. 

-- WE WANT TO KNOW THE VALUES FOR: AFRICA, NORTH AMERICA, SOUTH AMERICA, ASIA, EUROPE, AND OCEANIA.

SELECT CoReg, Series, Value
FROM un_energia_clean_csv
WHERE CoReg IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania')

-- Show the values for South America only for 2018.

SELECT CoReg, Years, Series, Value
FROM un_energia_clean_csv
WHERE CoReg = 'South America'
AND Years = 2018


-- COMPARING THE SUPPLY PER CAPITA IN GIGAJOULES BETWEEN SOUTH AMERICA, NORTH AMERICA AND EUROPE.

SELECT CoReg, Years, Series, Value
FROM un_energia_clean_csv
WHERE CoReg IN ('North America', 'South America', 'Europe')
AND Series = 'Supply per capita (gigajoules)'
AND Years = 2018


-- CALCULATING PERCENTAGE DIFFERENCE BETWEEN SOUTH AMERICAN SUPPLY PER CAPITA 
-- AND OTHER REGIONS OF THE WORLD.

WITH south_am AS (
	SELECT *
	FROM un_energia_clean_csv
	WHERE CoReg = 'South America'
	AND Series = 'Supply per capita (gigajoules)'
	AND Years = 2018
	)
SELECT CoReg, Years, Series, (Value-(SELECT Value FROM south_am))*100/(SELECT Value FROM south_am) 
	AS PercentageDifSASupplyPc
FROM un_energia_clean_csv
WHERE CoReg IN ('Africa', 'North America', 'Asia', 'Europe','Oceania')
AND Years = 2018
AND  Series = 'Supply per capita (gigajoules)'
ORDER BY PercentageDifSASupplyPc DESC


-- COMPARING EIGHT COUNTRIES OF SOUTH AMERICA. THEIR PRIMARY ENERGY PRODUCTION AND NET IMPORTS.

-- Note: the first time I tried this query Bolivia didn't appear. That time I wrote 'Bolivia', so I searched for 
-- the country with WHERE:

SELECT *
FROM un_energia_clean_csv
WHERE CoReg LIKE 'Bol%'

-- With this you can see that Bolivia's Official name is 'Bolivia (Plurin. State of)'
-- and with that you can make the correct query now:

SELECT CoReg, Years, Series, Value
FROM (
	SELECT *
	FROM un_energia_clean_csv
	WHERE Series IN ('Primary energy production (petajoules)', 'Net imports [Imports - Exports - Bunkers] (petajoules)', 
			 'Supply per capita (gigajoules)')
	)
WHERE CoReg IN ('Brazil', 'Chile', 'Argentina', 'Peru', 'Uruguay', 'Bolivia (Plurin. State of)', 'Colombia', 'Ecuador')
AND Years = 2018


-- PERCENTAGE DIFFERENCE BETWEEN THE LOWEST SUPPLY PER CAPITA OF THE COUNTRIES SEEN BEFORE.

-- First we find the lowest supply per capita between the selected countries.

SELECT CoReg, Years, Series, MIN(Value)
FROM un_energia_clean_csv
WHERE CoReg IN ('Brazil', 'Chile', 'Argentina', 'Peru', 'Uruguay', 
	'Bolivia (Plurin. State of)', 'Colombia', 'Ecuador')
AND Series = 'Supply per capita (gigajoules)'
AND Years = 2018


-- After that we can apply the same method that we used before.

WITH min_value as (
	SELECT MIN(Value) AS sa_min
	FROM un_energia_clean_csv
	WHERE CoReg IN ('Brazil', 'Chile', 'Argentina', 'Peru', 'Uruguay', 
		'Bolivia (Plurin. State of)', 'Colombia', 'Ecuador')
	AND Series = 'Supply per capita (gigajoules)'
	AND Years = 2018
)
SELECT CoReg, Years, Series, ((Value-(SELECT * FROM min_value))*100)/(SELECT * FROM min_value) 
	AS PercentageDifSouthAmerica
FROM un_energia_clean_csv
WHERE CoReg IN ('Brazil', 'Chile', 'Argentina', 'Uruguay', 
	'Bolivia (Plurin. State of)', 'Colombia','Ecuador')
AND Series = 'Supply per capita (gigajoules)'
AND Years = 2018
ORDER BY PercentageDifSouthAmerica DESC



-- RETURNING TO THE ENTIRE DATASET

-- THE AVERAGE PRIMARY ENERGY PRODUCTION BY COUNTRY from 1995 to 2018 comparing with the value of each year.

SELECT CoReg, Years, Series, Value,
       AVG(Value) OVER (PARTITION BY CoReg ORDER BY CoReg) AS CountryAvg
FROM un_energia_clean_csv
WHERE Series = 'Primary energy production (petajoules)'  

-- NUMBER OF COUNTRIES WITH NEGATIVE AND POSITIVE CHANGES OF STOCK IN 2018

SELECT Series, Years, COUNT(CASE WHEN Value > 0 THEN 'Positive' END) AS PosValues,
	COUNT(CASE WHEN Value < 0 THEN 'Negative' END) AS NegValues
FROM un_energia_clean_csv
WHERE CoReg NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania', 
		    'Total, all countries or areas')
AND Series = 'Changes in stocks (petajoules)'
AND Years=2018


--List of countries with negative change of stock in 2018

SELECT CoReg, Years, CAST(Value AS numeric) AS Value
FROM un_energia_clean_csv
WHERE CoReg NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania', 
		    'Total, all countries or areas')
AND series = 'Changes in stocks (petajoules)' 
AND value < 0
AND Years = 2018
ORDER BY Value


-- We can see WHICH COUNTRY HAS THE HIGHEST SUPPLY PER CAPITA, THE LOWEST IMPORTS AND THE HIGHEST ONES
-- from 1995 to 2018.

-- HIGHEST SUPPLY PER CAPITA

SELECT CoReg, Years, Series, MAX(Value) AS MaxVal
FROM un_energia_clean_csv
WHERE Series = 'Supply per capita (gigajoules)'

-- Qatar in 1995 was the country with the highest supply per capita with 1,090 gigajoules.

-- Let's try it again, but with the year 2018:

-- HIGHEST SUPPLY PER CAPITA in 2018

SELECT CoReg, Years, Series, MAX(Value) AS MaxVal
FROM un_energia_clean_csv
WHERE Series = 'Supply per capita (gigajoules)'
AND Years = 2018

-- Iceland, with 1087 gigajoules per capita.


-- NET IMPORTS: a POSITIVE value means that a country or region imports more than it exports. 


-- The LOWEST NET IMPORTS in 2018.

SELECT CoReg, Years, Series, MIN(Value)
FROM un_energia_clean_csv
WHERE Series = 'Net imports [Imports - Exports - Bunkers] (petajoules)'
AND Years = 2018

-- Russian Federation, with -29,521 petajoules. Which means that the Russian Federation was, in 2018, 
-- world's biggest energy exporter.


-- The HIGHEST NET IMPORTS, 2018.

SELECT CoReg, Years, Series, MAX(Value)
FROM un_energia_clean_csv
WHERE Series = 'Net imports [Imports - Exports - Bunkers] (petajoules)'
AND Years = 2018

-- China, with 27,176 petajoules was, in 2018, the biggest importer of energy in the world.

-- How many importer and exporter countries were in the world in 2018

SELECT Series, Years, COUNT(CASE WHEN Value > 0 THEN 'Importer' END) AS Importer,
	COUNT(CASE WHEN Value < 0 THEN 'Exporter' END) AS Exporter
FROM un_energia_clean_csv
WHERE Series = 'Net imports [Imports - Exports - Bunkers] (petajoules)'
AND Years=2018

-- 167 importers and 48 exporters.

-- What are these exporter countries?
-- List of the 48 exporter countries in 2018:

SELECT Series, Years, CoReg, Value
FROM un_energia_clean_csv
WHERE Series = 'Net imports [Imports - Exports - Bunkers] (petajoules)'
AND CoReg NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania',
 'Total, all countries or areas')
AND Value < 0
AND Years = 2018



-- With the current crisis in mind. What are the differences between Germany and the Russian Federation in terms
-- of energy dependence.

-- WHAT IS THE EVOLUTION OF ENERGY PRODUCTION IN GERMANY?

SELECT CoReg, Years, Series, Value
FROM un_energia_clean_csv
WHERE CoReg = 'Germany'

-- As we can see, the supply per capita in Germany has been decreasing since 2010.
-- we can calculate the percentage of the reduction compared with base year 2010:

WITH ger_prev as (
	SELECT Value
	FROM un_energia_clean_csv
	WHERE Series = 'Supply per capita (gigajoules)'
	AND CoReg = 'Germany'
	AND Years = 2000
	)
SELECT CoReg, Years, Series, (Value-(SELECT Value FROM ger_prev))*100/(SELECT Value FROM ger_prev) as PercentageDiff
FROM un_energia_clean_csv
WHERE CoReg = 'Germany'
AND Series = 'Supply per capita (gigajoules)'
AND Years BETWEEN 2010 AND 2018

-- With base year 2010, the supply per capita reduction for Germany was 11% in 2018.

-- We can see that the primary energy production also decreased, but the Net imports were really stable.
-- Let's calculate the percentage variation of primary energy production from 1995 to 2018.

WITH ger_prev as (
	SELECT Value
	FROM un_energia_clean_csv
	WHERE Series = 'Primary energy production (petajoules)'
	AND CoReg = 'Germany'
	AND Years = 1995
	)
SELECT CoReg, Years, Series,  (Value-(SELECT Value FROM ger_prev))*100/(SELECT Value FROM ger_prev) as PercentageDiff
FROM un_energia_clean_csv
WHERE CoReg = 'Germany'
AND Series = 'Primary energy production (petajoules)'

-- The difference between primary energy production from 1995 to 2018 is -22%.


-- IN CONTRAST, THE RUSSIAN FEDERATION ENERGY PRODUCTION AND SUPPLY HAS BEEN INCREASING SINCE 1995.

SELECT CoReg, Years, Series, Value
FROM un_energia_clean_csv
WHERE CoReg = 'Russian Federation'

-- We can calculate in the same way we did with Germany:

WITH russ_prev as(
	SELECT Value
	FROM un_energia_clean_csv
	WHERE CoReg = 'Russian Federation'
	AND Series = 'Primary energy production (petajoules)'
	AND Years = 1995
	)
SELECT CoReg, Years, Series, (Value-(SELECT Value FROM russ_prev))*100/(SELECT Value FROM russ_prev) as PercentageDiff
FROM un_energia_clean_csv
WHERE CoReg = 'Russian Federation'
AND Series = 'Primary energy production (petajoules)'

-- Since 1995 the primary energy production in the Russian Federation has increased 53%.


WITH prev_value as (
	SELECT MIN(Value) AS min_value
	FROM un_energia_clean_csv 
	WHERE Series = 'Supply per capita (gigajoules)' 
	AND CoReg = 'Russian Federation'
	AND Years = 1995)
SELECT CoReg, Years, Series, Value,
	(Value-(SELECT min_value from prev_value))*100/(SELECT min_value from prev_value) AS PercentageDiff
FROM un_energia_clean_csv
WHERE CoReg = 'Russian Federation'
AND Series = 'Supply per capita (gigajoules)'

-- Other method you could use, a little more populated is to insert the complete subquery where 
--'Value-(SELECT min_value from prev_value' is. 

SELECT CoReg, Years, Series, Value,
	(
	Value-(
		SELECT MIN(Value) 
		FROM un_energia_clean_csv 
		WHERE Series = 'Supply per capita (gigajoules)' 
		AND CoReg = 'Russian Federation'
		AND Years = 1995))*100/(
			SELECT MIN(Value) 
			FROM un_energia_clean_csv 
			WHERE Series = 'Supply per capita (gigajoules)' 
			AND CoReg = 'Russian Federation'
			AND Years = 1995) AS PercentageDiff
FROM un_energia_clean_csv
WHERE CoReg = 'Russian Federation'
AND Series = 'Supply per capita (gigajoules)'


-- In the Russian Federation the supply per capita has increased 26% since 1995.
-- The change is remarkable between 2017 and 2018, let's see the percentage difference between 
-- supply per capita from 2017 to 2018:

WITH russ_2017 as (
	SELECT Value
	FROM un_energia_clean_csv
	WHERE CoReg = 'Russian Federation'
	AND Series = 'Supply per capita (gigajoules)'
	AND Years = 2017
	)
SELECT CoReg, Years, Series, (Value-(SELECT Value FROM russ_2017))*100/(SELECT Value FROM russ_2017) 
	AS PercentageDiff
FROM un_energia_clean_csv
WHERE CoReg = 'Russian Federation'
AND Series = 'Supply per capita (gigajoules)'
AND Years = 2018

-- From 2017 to 2018 the energy supply per capita in the Russian Federation 
-- increased by 8%.

-- Compare the previous data with the European Union data.
-- NET IMPORTS AND ENERGY PRODUCTION OF THE EUROPEAN UNION:

-- NET IMPORTS FOR EACH COUNTRY OF THE EUROPEAN UNION

SELECT Series, CoReg, Years, Value
FROM un_energia_clean_csv
WHERE CoReg IN ('Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 
'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 
'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 
'Slovakia', 'Slovenia', 'Spain', 'Sweden')
AND Years = 2018
AND Series = 'Net imports [Imports - Exports - Bunkers] (petajoules)'

-- AVERAGE NET IMPORTS FOR THE ENTIRE EU

SELECT Series, AVG(Value)
FROM un_energia_clean_csv
WHERE CoReg IN ('Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 
	'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 
	'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 
	'Slovakia', 'Slovenia', 'Spain', 'Sweden')
AND Years = 2018
AND Series = 'Net imports [Imports - Exports - Bunkers] (petajoules)'

-- The average Net imports for the EU is 1,240.14 petajoules.

-- AVERAGE ENERGY PRODUCTION IN THE EU

SELECT Series, AVG(Value)
FROM un_energia_clean_csv
WHERE CoReg IN ('Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 
	'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 
	'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 
	'Slovakia', 'Slovenia', 'Spain', 'Sweden')
AND Years = 2018
AND Series = 'Primary energy production (petajoules)'

-- Average of 967.85 petajoules 


-- WHAT IS THE DIFFERENCE BETWEEN AVERAGE EU ENERGY PRODUCTION AND 
-- THE RUSSIAN FEDERATION PRODUCTION?

WITH eu_prod AS(
	SELECT AVG(Value) as AvgEu
	FROM un_energia_clean_csv
	WHERE CoReg IN ('Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 
		'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 
		'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 
		'Slovakia', 'Slovenia', 'Spain', 'Sweden')
	AND Years = 2018
	AND Series = 'Primary energy production (petajoules)'
	),
	russ_prod AS (
	SELECT Value
	FROM un_energia_clean_csv
	WHERE CoReg = 'Russian Federation'
	AND Series = 'Primary energy production (petajoules)'
	AND Years = 2018
	)
SELECT ((SELECT AvgEu FROM eu_prod)/(SELECT Value FROM russ_prod))*100
	AS PercOfRuss 

-- The EU average energy production in 2018 is 1.5% of the Russian energy production for the same period.

-- AND THE DIFFERENCE BETWEEN THE TOTAL PRIMARY ENERGY PRODUCTION OF THE EU AND THE RUSSIAN FEDERATION?

	WITH eu_prod AS(
	SELECT CAST(SUM(Value) AS FLOAT) AS SumEu
	FROM un_energia_clean_csv
	WHERE CoReg IN ('Austria', 'Belgium', 'Bulgaria', 'Croatia', 'Cyprus', 'Czechia', 
		'Denmark', 'Estonia', 'Finland', 'France', 'Germany', 'Greece', 'Hungary', 'Ireland', 'Italy', 
		'Latvia', 'Lithuania', 'Luxembourg', 'Malta', 'Netherlands', 'Poland', 'Portugal', 'Romania', 
		'Slovakia', 'Slovenia', 'Spain', 'Sweden')
	AND Years = 2018
	AND Series = 'Primary energy production (petajoules)'
	),
	russ_prod AS (
	SELECT Value
	FROM un_energia_clean_csv
	WHERE CoReg = 'Russian Federation'
	AND Series = 'Primary energy production (petajoules)'
	AND Years = 2018
	)
SELECT ((SELECT SumEu FROM eu_prod)/(SELECT Value FROM russ_prod))*100
	AS PercOfRuss 

-- The sum of the entire EU energy production is about 41% of the Russian production. 


-- WHAT IS THE AVERAGE PRIMARY ENERGY PRODUCTION IN THE WORLD?

SELECT Series, AVG(Value) as AvgWorld
FROM un_energia_clean_csv
WHERE CoReg NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania', 
		    'Total, all countries or areas')
AND Series = 'Primary energy production (petajoules)'
AND Years = 2018

-- The average primary energy production in the world is 2,752 petajoules.

-- HAS THIS VALUE INCREASED SINCE 1995?

SELECT Series, AVG(Value) as AvWorld
FROM un_energia_clean_csv
WHERE CoReg NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania',
		    'Total, all countries or areas')
AND Series = 'Primary energy production (petajoules)'
AND Years = 1995

-- Avgerage primary energy production in the world in 1995 was 1,903.44.

-- THE AVERAGE GLOBAL PRIMARY ENERGY PRODUCTION HAS INCREASED SINCE 1995. 
-- We can see the percentage difference.

WITH AvWorld_95 AS (
	SELECT Series, AVG(Value) as AvWorld
	FROM un_energia_clean_csv
	WHERE CoReg NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania',
		'Total, all countries or areas')
	AND Series = 'Primary energy production (petajoules)'
	AND Years = 1995 
	),
	AvWorld_18 AS (
	SELECT Series, AVG(Value) as AvWorld
	FROM un_energia_clean_csv
	WHERE CoReg NOT IN ('Africa', 'North America', 'South America', 'Asia', 'Europe','Oceania',
		'Total, all countries or areas')
	AND Series = 'Primary energy production (petajoules)'
	AND Years = 2018 
	)
SELECT ((SELECT AvWorld FROM AvWorld_18)-(SELECT AvWorld FROM AvWorld_95))*100/(SELECT AvWorld FROM AvWorld_95) 
	as PercentageDiff

-- The global average primary energy production has increased aprox. by 44.57%.
