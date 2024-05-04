/*

Cleaning Data in SQL Queries

*/

Select *
From [PortfolioProject ].dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardise Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From [PortfolioProject ].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (using ParcelID)

Select *
From [PortfolioProject ].dbo.NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [PortfolioProject ].dbo.NashvilleHousing a
JOIN [PortfolioProject ].dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [PortfolioProject ].dbo.NashvilleHousing a
JOIN [PortfolioProject ].dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out address into individual coloumns (Address, City, State)

Select PropertyAddress
From [PortfolioProject ].dbo.NashvilleHousing

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City

From [PortfolioProject ].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From [PortfolioProject ].dbo.NashvilleHousing

Select OwnerAddress
From [PortfolioProject ].dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From [PortfolioProject ].dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From [PortfolioProject ].dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "SoldAsVacant" field

Select distinct(SoldAsVacant), Count(SoldAsVacant)
From [PortfolioProject ].dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
CASE when SoldAsVacant = 'Y' THEN 'Yes'
    when SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END
From [PortfolioProject ].dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
    When SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
    END

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
                PropertyAddress,
                SalePrice,
                SaleDate,
                LegalReference
                ORDER BY
                    UniqueID
                    ) row_num
From [PortfolioProject ].dbo.NashvilleHousing
)
Select *
From RowNumCTE
where row_num >1

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From [PortfolioProject ].dbo.NashvilleHousing

ALTER TABLE [PortfolioProject ].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
