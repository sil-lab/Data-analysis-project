--Cleaning Data in SQL queries

select *
from Portfolioproject.dbo.NashvilleHousing

--Standardize Date Format
select SaleDateConverted, CONVERT(Date, SaleDate)
from Portfolioproject.dbo.NashvilleHousing
update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;
update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

--Populate proptery address
select *
from Portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
   from Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null  


--Breaking out address into individual colunm (Address, City, state)

select PropertyAddress
from Portfolioproject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

from Portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertSplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertSplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


select *
from Portfolioproject.dbo.NashvilleHousing


select OwnerAddress
from Portfolioproject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

from Portfolioproject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from Portfolioproject.dbo.NashvilleHousing

--Change 'Y' and 'N' to 'Yes' and 'No'in SoldAsvacant

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from Portfolioproject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from Portfolioproject.dbo.NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Remove duplicates
With RowNumCTE AS(
select *
, ROW_NUMBER() OVER (
  Partition BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			     UniqueID
			   ) row_num
from Portfolioproject.dbo.NashvilleHousing
--order by ParcelID
)
select *
From RowNumCTE
where row_num > 1
order by PropertyAddress

--Delete unused column

select *
from Portfolioproject.dbo.NashvilleHousing

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN SaleDate

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN SalesDate, SalesDate2