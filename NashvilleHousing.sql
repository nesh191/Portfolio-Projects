/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  --SELECT EVERYTHING
  select *
  from PortfolioProject..NashvilleHousing

  --Standardize Date Format

  select SaleDateConverted, CONVERT(date,SaleDate)
  from PortfolioProject..NashvilleHousing

  Update NashvilleHousing
  set SaleDate = CONVERT(date,SaleDate)

  Alter Table NashvilleHousing
  Add SaleDateConverted Date

  Update NashvilleHousing
  set SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data

select *
  from PortfolioProject..NashvilleHousing
  --where PropertyAddress is null
  order by ParcelID

  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PortfolioProject..NashvilleHousing a
  join PortfolioProject..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  update a
  set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
  from PortfolioProject..NashvilleHousing a
  join PortfolioProject..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

--Breaking out Address into Individual columns (Address, City, State)

select PropertyAddress
  from PortfolioProject..NashvilleHousing 
  --where PropertyAddress is not null
  --order by ParcelID

  select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) -1) as address,
  SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) +1, LEN(PropertyAddress)) as address

  from PortfolioProject..NashvilleHousing 

  Alter Table NashvilleHousing
  Add PropertySplitAddress Nvarchar(255);

  Update NashvilleHousing
  set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) -1)

  Alter Table NashvilleHousing
  Add PropertySplitCity Nvarchar(255);

  Update NashvilleHousing
  set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' ,PropertyAddress) + 1, LEN(PropertyAddress))

  select *
  from PortfolioProject..NashvilleHousing

select OwnerAddress
from PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

from PortfolioProject..NashvilleHousing

  Alter Table NashvilleHousing
  Add OwnerSplitAddress Nvarchar(255);

  Update NashvilleHousing
  set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

  Alter Table NashvilleHousing
  Add OwnerSplitCity Nvarchar(255);

  Update NashvilleHousing
  set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

   Alter Table NashvilleHousing
  Add OwnerSplitState Nvarchar(255);

  Update NashvilleHousing
  set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

select *
  from PortfolioProject..NashvilleHousing

  --Change Y and N to Yes and No in "Sold as Vacant" field

  select Distinct(SoldAsVacant), count(SoldAsVacant)
  from PortfolioProject..NashvilleHousing
  group by SoldAsVacant
  order by 2

  select SoldAsVacant
  , case when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' then 'No'
       else SoldAsVacant
  end
  from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' then 'No'
       else SoldAsVacant
  end

  --Remove duplicates

  with RowNumCTE as(
  select *
  ,row_number () over (
  partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
  order by UniqueID
  ) row_num
               
  from PortfolioProject..NashvilleHousing
  --order by ParcelID
  )
  Select *
From RowNumCTE
where row_num > 1
--order by PropertyAddress

  select *
  from PortfolioProject..NashvilleHousing

  --Delete Unused columns

  select *
  from PortfolioProject..NashvilleHousing

  alter table PortfolioProject..NashvilleHousing
  drop column OwnerAddress, TaxDistrict, PropertyAddress

  alter table PortfolioProject..NashvilleHousing
  drop column SaleDate