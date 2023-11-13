-- Retrieve all data from the NashvilleHousing table
SELECT
    *
FROM
    ProjectPortfolio..NashvilleHousing;

-- Standardize Date Format	
SELECT
    SaleDate,
    CONVERT(date, SaleDate) AS SaleDateconverted
FROM
    ProjectPortfolio..NashvilleHousing;

-- Add a new column for converted SaleDate
ALTER TABLE ProjectPortfolio..NashvilleHousing
ADD SaleDateconverted DATE;

-- Update SaleDate with the converted values
UPDATE ProjectPortfolio..NashvilleHousing
SET SaleDate = SaleDateconverted;

-- Display the converted SaleDate along with the original SaleDate
SELECT
    SaleDateconverted, SaleDate
FROM
    ProjectPortfolio..NashvilleHousing;

-- Retrieve records with null PropertyAddress
SELECT
    *
FROM
    ProjectPortfolio..NashvilleHousing
WHERE
    PropertyAddress IS NULL;

-- Update PropertyAddress with non-null values from matching ParcelID records
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM ProjectPortfolio..NashvilleHousing a
JOIN ProjectPortfolio..NashvilleHousing b ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Breaking Address into individual Columns (Address, City)
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM
    NashvilleHousing;

-- Add new columns for split address components
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- Update split address components
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Display the updated table with split address components
SELECT
    *
FROM
    NashvilleHousing;


-- Parse owneraddress into individual columns (Address, City, State)
SELECT
    PARSENAME(REPLACE(owneraddress, ',', '.'), 3) AS OwnerSplitState,
    PARSENAME(REPLACE(owneraddress, ',', '.'), 2) AS OwnerSplitCity,
    PARSENAME(REPLACE(owneraddress, ',', '.'), 1) AS OwnerSplitAddress
FROM NashvilleHousing;

-- Add new columns for owner's split address components
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);

-- Update owner's split address components
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 1),
    OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
    OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.'), 3);


-- Clean up and standardize the SoldAsVacant column
UPDATE NashvilleHousing
SET SoldAsVacant = CASE
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'NO'
                        ELSE SoldAsVacant
                    END;

-- Display distinct values in the cleaned SoldAsVacant column
SELECT DISTINCT SoldAsVacant
FROM NashvilleHousing;


-- Delete Duplicates
WITH RowNumCTE AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice ORDER BY UniqueID) AS Row_Num
    FROM
        NashvilleHousing
)

DELETE FROM
    RowNumCTE
WHERE
    Row_Num > 1;

-- Delete Unused Column
Alter Table NashvilleHousing
Drop Column TaxDisTrict