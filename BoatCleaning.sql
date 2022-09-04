-- Ensure database is selected 
USE BoatProject;

-- Check data import
-- SELECT TOP 20 * FROM BoatData;


--------------DATA CLEANING--------------


------------------------------------------

-- Standardize all currencies to Euros

-- Make a column of original currency and a column of original price 
SELECT TOP 20
  PARSENAME(REPLACE(Price, ' ', '.'), 2),
  PARSENAME(REPLACE(Price, ' ', '.'), 1)
FROM BoatData;

ALTER TABLE BoatData
ADD Currency varchar(5);

ALTER TABLE BoatData
ADD PriceOG int;

UPDATE BoatData
SET Currency = PARSENAME(REPLACE(Price, ' ', '.'), 2);

UPDATE BoatData
SET PriceOG = PARSENAME(REPLACE(Price, ' ', '.'), 1);

-- Check that separation was successful
-- SELECT TOP 5 * FROM BoatData;

-- Convert all prices to euros and add to table (Conversions as of 8/29/22)
SELECT TOP 20
  Price,
  CASE
    WHEN Currency = 'CHF' THEN ROUND(PriceOG * 1.0330234, 0)
    WHEN Currency = 'DKK' THEN ROUND(PriceOG * 0.1344529, 0)
    WHEN Currency = 'Â£' THEN ROUND(PriceOG * 1.1708918, 0)
    ELSE PriceOG
  END AS EuroPrice
FROM BoatData;


ALTER TABLE BoatData
ADD EuroPrice int;

UPDATE BoatData
SET EuroPrice =
               CASE
                 WHEN Currency = 'CHF' THEN ROUND(PriceOG * 1.0330234, 0)
                 WHEN Currency = 'DKK' THEN ROUND(PriceOG * 0.1344529, 0)
                 WHEN Currency = 'Â£' THEN ROUND(PriceOG * 1.1708918, 0)
                 ELSE PriceOG
               END;

-- Check that conversion was successful
-- SELECT Price, Currency, PriceOG, EuroPrice FROM BoatData;

------------------------------------------

-- Attempt to extract useful information from the Type field, which is cluttered


-- Find if boat is new, used, or display model
-- SELECT BoatType, COUNT(BoatType) AS Num FROM BoatData GROUP BY BoatType ORDER BY Num DESC;


SELECT TOP 20
  Type,
  CASE
    WHEN Type LIKE '%Used%' THEN 'Used'
    WHEN Type LIKE '%New%' THEN 'New'
    WHEN Type LIKE '%Display%' THEN 'Display'
    ELSE NULL
  END
FROM BoatData;

ALTER TABLE BoatData
ADD BoatCondition varchar(255);

UPDATE BoatData
SET BoatCondition =
                   CASE
                     WHEN Type LIKE '%Used%' THEN 'Used'
                     WHEN Type LIKE '%New%' THEN 'New'
                     WHEN Type LIKE '%Display%' THEN 'Display'
                     ELSE NULL
                   END;

--SELECT Type, BoatCondition FROM BoatData;

------------------------------------------

-- Find fuel type of boat
-- SELECT Type, COUNT(Type) FROM BoatData GROUP BY Type

SELECT TOP 20
  Type,
  CASE
    WHEN Type LIKE '%Electric%' THEN 'Electric'
    WHEN Type LIKE '%Diesel%' THEN 'Diesel'
    WHEN Type LIKE '%Unleaded%' OR
      Type LIKE '%Gas%' THEN 'Unleaded'
    ELSE NULL
  END
FROM BoatData;


ALTER TABLE BoatData
ADD FuelType varchar(255);

UPDATE BoatData
SET FuelType =
              CASE
                WHEN Type LIKE '%Electric%' THEN 'Electric'
                WHEN Type LIKE '%Diesel%' THEN 'Diesel'
                WHEN Type LIKE '%Unleaded%' OR
                  Type LIKE '%Gas%' THEN 'Unleaded'
                ELSE NULL
              END

-- SELECT FuelType, COUNT(FuelType) FROM BoatData GROUP BY FuelType
-- SELECT Type, FuelType FROM BoatData 

------------------------------------------

-- Separate out country from location
-- SELECT DISTINCT Location FROM BoatData;

SELECT TOP 30
  Location,
  CASE
    WHEN Location LIKE 'United States%' THEN 'United States'
    WHEN Location LIKE 'United Kingdom%' THEN 'United Kingdom'
    WHEN Location LIKE 'United Arab%' THEN 'United Arab Emirates'
    WHEN Location LIKE '%�%' OR
      Location LIKE '%(%' THEN SUBSTRING(Location, 1, CHARINDEX(' ', Location))
    ELSE Location
  END
FROM BoatData;

ALTER TABLE BoatData
ADD Country varchar(255);

-- United States, United Kingdom, and United Arab Emirates are exceptions because they have spaces in the name, they get their own separate cases
UPDATE BoatData
SET Country =
             CASE
               WHEN Location LIKE 'United States%' THEN 'United States'
               WHEN Location LIKE 'United Kingdom%' THEN 'United Kingdom'
               WHEN Location LIKE 'United Arab%' THEN 'United Arab Emirates'
               WHEN Location LIKE '%�%' OR
                 Location LIKE '%(%' THEN SUBSTRING(Location, 1, CHARINDEX(' ', Location))
               ELSE Location
             END

-- SELECT Location, Country FROM BoatData;

------------------------------------------

-- Change pound symbol to something more readable
SELECT
  *
FROM BoatData
WHERE Currency = 'Â£';

UPDATE BoatData
SET Currency = REPLACE(Currency, 'Â£', 'GBP');

UPDATE BoatData
SET Price = REPLACE(Price, 'Â£', 'GBP');

------------------------------------------
-- Clean up NULL values
UPDATE BoatData
SET Country = 'Unknown'
WHERE Country IS NULL;

UPDATE BoatData
SET Country = 'Unknown'
WHERE Country = ' ';

UPDATE BoatData
SET Manufacturer = 'Unknown'
WHERE Manufacturer IS NULL;

UPDATE BoatData
SET Material = 'Unknown'
WHERE Material IS NULL;

UPDATE BoatData
SET FuelType = 'Unknown'
WHERE FuelType IS NULL;

UPDATE BoatData
SET BoatCondition = ISNULL(BoatCondition, 'Unknown');

UPDATE BoatData
SET Type = ISNULL(Type, 'Unknown');

UPDATE BoatData
SET Location = 'Unknown'
WHERE Location IS NULL;

------------------------------------------
-- This concludes data cleaning necessary
-- SELECT * FROM BoatData;