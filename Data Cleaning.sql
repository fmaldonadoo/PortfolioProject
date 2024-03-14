-- Cleaning data in SQL Queries
Select* 
from NashvilleHousing


--Standardize Date Format
Select SaleDateConverted, convert(date, SaleDate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate)

alter table nashvillehousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date, saledate)



--Population property Address data
Select a.propertyaddress, a.parcelid, b.propertyaddress, b.parcelid, ISNULL(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
from NashvilleHousing a
join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

select parcelid, propertyaddress
from NashvilleHousing



--breaking out adress into individual columns (adress, city, state)
Select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) as  address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) as  city
from NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

select parcelid, propertysplitaddress, propertysplitcity
from NashvilleHousing







Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
from NashvilleHousing

alter table nashvillehousing
add ownersplitaddress nvarchar(255)

update NashvilleHousing
set ownersplitaddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


alter table nashvillehousing
add ownersplitcity nvarchar(255)

update NashvilleHousing
set ownersplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


alter table nashvillehousing
add ownersplitstate nvarchar(255)

update NashvilleHousing
set ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select parcelid, ownersplitaddress, ownersplitcity, ownersplitstate
from NashvilleHousing




-- change y and n  to Yes and No in 'Sold as Vacant' field
Select distinct(soldasvacant), count(soldasvacant)
from NashvilleHousing
group by soldasvacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'y' then 'Yes'
       when SoldAsVacant = 'n' then 'No'
	   else soldasvacant
       end
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant =  case when SoldAsVacant = 'y' then 'Yes'
       when SoldAsVacant = 'n' then 'No'
	   else soldasvacant
       end



--remove duplicates 
select *
from NashvilleHousing

With RowNumCTE as(
Select *,
    ROW_NUMBER() OVER (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) ROW_NUM
FROM NashvilleHousing)
DELETE 
FROM RowNumCTE
WHERE ROW_NUM > 1

With RowNumCTE as(
Select *,
    ROW_NUMBER() OVER (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) ROW_NUM
FROM NashvilleHousing)
SELECT * 
FROM RowNumCTE
WHERE ROW_NUM > 1



--DELETE UNUSED COLUMNS 
ALTER TABLE NASHVILLEHOUSING
DROP COLUMN OWNERADDRESS, TAXDISTRICT, PROPERTYADDRESS

ALTER TABLE NASHVILLEHOUSING
DROP COLUMN SaleDate































