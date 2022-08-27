/* 

Data Cleaning of Nashville Housing Data

*/


-- Standardize the date

USE CovidProject_1;

SELECT
  SaleDate,
  CONVERT(date, SaleDate)
FROM NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SaleDateConverted date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate);

SELECT
  SaleDateConverted,
  CONVERT(date, SaleDate)
FROM NashvilleHousing;

--------------------------------
-- Populate Property Address Data

SELECT
  *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID;


-- Join the table to itself, finding rows that have a null property address
SELECT
  a.ParcelID,
  a.PropertyAddress,
  b.ParcelID,
  b.PropertyAddress,
  ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Update the necessary rows using above information
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------

-- Separating out Address Into Individual Columns (Address, City, State)

SELECT
  PropertyAddress
FROM NashvilleHousing

SELECT
  PropertyAddress,
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

--SELECT * FROM NashvilleHousing;


------------------------------------------

-- Separating out the OwnerAddress column into Address, City, and State
-- (This time using PARSENAME to avoid using clunky substrings)


-- Check methods for separation first
SELECT
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

-- Update table with new data

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

--SELECT * FROM NashvilleHousing;

---------------------------------------------

-- Fix SoldAsVacant field, which contains different versions of Y and N

SELECT DISTINCT
  (SoldAsVacant),
  COUNT(*)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-- Change Y to Yes and N to No using case statement
SELECT
  SoldAsVacant,
  CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END
FROM NashvilleHousing;

-- Update the table
UPDATE NashvilleHousing
SET SoldAsVacant =
                  CASE
                    WHEN SoldAsVacant = 'Y' THEN 'Yes'
                    WHEN SoldAsVacant = 'N' THEN 'No'
                    ELSE SoldAsVacant
                  END;

-- SELECT * FROM NashvilleHousing;

-------------------------------------------

-- Add a column to indicate multiple owners (may be some exceptions when owner is an entity not a person)

SELECT
  OwnerName,
  CASE
    WHEN OwnerName LIKE '%&%' THEN 'No'
    ELSE 'Yes'
  END
FROM NashvilleHousing;


ALTER TABLE NashvilleHousing
ADD SingleOwner varchar(10);

UPDATE NashvilleHousing
SET SingleOwner =
                 CASE
                   WHEN OwnerName LIKE '%&%' THEN 'No'
                   ELSE 'Yes'
                 END

-------------------------------------

-- Remove duplicates

WITH RowNumCTE
AS (SELECT
  *,
  ROW_NUMBER() OVER (
  PARTITION BY ParcelID,
  PropertyAddress,
  SalePrice,
  SaleDate,
  LegalReference
  ORDER BY
  UniqueID
  ) row_num

FROM NashvilleHousing
--ORDER BY ParcelID
)


-- Delete the duplicates
DELETE FROM RowNumCTE
WHERE row_num > 1

------------------------------------------

-- Delete unused columns created by earlier modifications to data

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate;

-- SELECT * FROM NashvilleHousing;