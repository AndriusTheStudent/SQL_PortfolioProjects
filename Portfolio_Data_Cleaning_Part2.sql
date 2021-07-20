--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--Import data using OPENROWSET and BULK INSERT
--Can be used as STORED PROCEDURE

--More advanced but have to configure server appropriately to do correctly

--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO

--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO

--USE PortfolioProject

--GO

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1

--GO

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1

--GO


---- USING BULK INSERT

--USE PortfolioProject;
--GO;
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning.csv'
--	WITH (
--		FIELDTERMINATOR = ',',
--		ROWTERMINATOR = '\n'
--	);
--	GO;


/*
Cleaning Nashville Housing data in SQL Queries
*/


-- 1. Format SaleDate column data
SELECT 
SaleDateConverted
FROM PortfolioProject.dbo.NashvilleHousing

GO

--#Convert SaleDate from datetime to date as time does not serve any purpose here
--#Update NashvilleHousing table with converted datatype values
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

GO

--#Work-a-round CONVERT and UPDATE method as sometimes SQL Server does not convert date to specified date format 
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
GO
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- 2. Populate Property Address data


--#ParcelID ties closely down Property Address. ParcelID can be referenced to extract address from rows with same ParcelID and populate ProPertyAddress column where Address IS NULL
--#Populate cell with address from self join if address is null
SELECT 
NH.ParcelID,
ISNULL(NH.PropertyAddress, NH2.PropertyAddress), 
NH2.ParcelID,
NH2.PropertyAddress

FROM PortfolioProject.dbo.NashvilleHousing NH

--#Self Join to extract address based on ParcelID
JOIN PortfolioProject.dbo.NashvilleHousing NH2
ON NH.ParcelID = NH2.ParcelID
--#Distinguish Propery Address where address is same for two or more identical ParcelID's
AND NH.[UniqueID ] <> NH2.[UniqueID ] 

WHERE NH.PropertyAddress IS NULL

GO

--#Update NashvilleHousing table NULL PropertyAddress cells with address
UPDATE NH
SET PropertyAddress = ISNULL(NH.PropertyAddress, NH2.PropertyAddress)

FROM PortfolioProject.dbo.NashvilleHousing NH

JOIN PortfolioProject.dbo.NashvilleHousing NH2
ON NH.ParcelID = NH2.ParcelID
AND NH.UniqueID <> NH2.UniqueID

WHERE NH.PropertyAddress IS NULL


-- 3. Breaking out Address into Individual Columns (Address, City, State)

--# Only Delimiter in PropertyAddress is comma
SELECT 
	--# Start looking from first character of the string until first comma. Reduce finishing position by one to remove comma from results.
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS [PropertySplitAddress],
	--#Start looking for characters FROM first encountered coma in the string. Stop looking until last character in the string
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS [PropertySplitCity]

FROM PortfolioProject.dbo.NashvilleHousing

GO

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);
GO

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
GO

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);
GO

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))
GO

--#Cleaning OwnerAddress column with PARSENAME and REPLACE functions
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
GO

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
GO

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);
GO

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
GO

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(4);
GO

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
GO

SELECT 
	OwnerSplitAddress, 
	OwnerSplitCity, 
	OwnerSplitState
FROM PortfolioProject.dbo.NashvilleHousing

-- 4. Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT 
	SoldAsVacant, 
	COUNT(SoldAsVacant) AS NoOfResults
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

GO

SELECT
	SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing

GO

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END;
GO


-- 5. Remove Duplicates

--#Put SELECT statement in Common Table Expression for simpler filtering

WITH RowNumCTE AS (
SELECT
	*,
	--#Partition by unique values per each dataset row. Let's pretend UniqueID is not available or is just random data.
	ROW_NUMBER() OVER (PARTITION BY ParcelID, 
									PropertyAddress, 
									SalePrice, 
									SaleDate, 
									LegalReference 

									ORDER BY UniqueID
						) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)


SELECT
*
FROM RowNumCTE
WHERE row_num > 1

--#DELETE all dublicate records
--DELETE FROM RowNumCTE
--WHERE row_num > 1


-- 6. Delete Unused Columns

--ALTER TABLE PortfolioProject.dbo.NashvilleHousing
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate