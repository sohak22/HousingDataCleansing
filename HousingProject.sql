/*
Cleaning data in SQL Queries 
*/

Select *
From portfolioProject.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From portfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address data 

Select *
From portfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

-- When its the same parcel ID it is the same address, hence create a query where if address is null but parcel IDs match populate null address with the one that matched 


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolioProject.dbo.NashvilleHousing a 
JOIN portfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

-- Check: Run query below, if no results show up (no null values) table has updated
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From portfolioProject.dbo.NashvilleHousing a
JOIN portfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

-- Breaking out Property Address into Individual Columns (Address, City, State)
Select PropertyAddress
From portfolioProject.dbo.NashvilleHousing

SELECT 
-- Going one place behind the common to get rid of it 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From portfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From portfolioProject.DBO.NashvilleHousing

-- Breaking out Owner Address into Individual Columns (Address, City, State)
Select OwnerAddress
From portfolioProject.DBO.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
From portfolioProject.DBO.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerAddressSplit Nvarchar(255);

update NashvilleHousing
set OwnerAddressSplit = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)



ALTER TABLE NashvilleHousing
Add OwnerAddressSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerAddressSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)



ALTER TABLE NashvilleHousing
Add OwnerAddressSplitState Nvarchar(255);

update NashvilleHousing
set OwnerAddressSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)


Select *
From portfolioProject.DBO.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From portfolioProject.DBO.NashvilleHousing
Group by SoldAsVacant
oRDER BY 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From portfolioProject.DBO.NashvilleHousing

Update NashvilleHousing 
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End


-- Remove Duplicates 

With RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress, 
				SalePrice,
				SaleDate, 
				LegalReference
				ORDER BY UniqueID
				) row_num
From portfolioProject.DBO.NashvilleHousing
--order By ParcelID
)
Delete 
From RowNumCTE
Where row_num > 1 
--Order by PropertyAddress


-- Delete Unused Coloumns 
-- Since we split the addresses and updated the sale date we can remove the OwnerAddress, PropertyAddress, sale date columns 

Select *
From portfolioProject.DBO.NashvilleHousing

ALTER TABLE portfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress


ALTER TABLE portfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate