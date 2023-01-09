---Cleaning Data in SQL queries----

---Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types


--1. Standardize Date Format

Select SaleDateConverted, CONVERT(date, SaleDate)
From DataCleaning_PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set	SaleDateConverted = CONVERT(Date, SaleDate)




--2. Populate Property Address data
----In this I detected NULL values and accordingly assigned value to the cell
----To do that, I executed the Join function to join two tables:

--2.1
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning_PortfolioProject.dbo.NashvilleHousing a --(assigned the value "a" to simplify the task)
Join DataCleaning_PortfolioProject.dbo.NashvilleHousing b --(assigned the value "b" to simplify the task)
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] ---- (the sign "<>" denote "not equal to")
Where a.PropertyAddress is null ----(by executing the query, it was discovered that there are 35 rows with NULL values) 

--2.2
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleaning_PortfolioProject.dbo.NashvilleHousing a --(assigned the value "a" to simplify the task)
Join DataCleaning_PortfolioProject.dbo.NashvilleHousing b --(assigned the value "b" to simplify the task)
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ] ---- (the sign "<>" denote "not equal to")
Where a.PropertyAddress is null ---(Executed the query 1.2 and once the executation was complete then re-ran the query 1.1)

------------------------------------------------------------------------------

--3. Breaking out Address into Individual Columns (Address, City, State)
----For this query SUBSTRING and CHARINDEX is used

--3.1
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,	
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address ---(Adding +1 get rid of comma)
From DataCleaning_PortfolioProject.dbo.NashvilleHousing

--3.2

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(225); ---(Execute)

Update NashvilleHousing
Set	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) ---(Execute)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(225); ---(Execute)

Update NashvilleHousing
Set	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) ---(Execute)

--3.3

Select*
From DataCleaning_PortfolioProject.dbo.NashvilleHousing --(executed this query to check if two new individual columns were updated at the end)


--3.4 updating the owner address and splitting it into separate columns using PARSENAME function... (PARSENAME function was preferred for this because its easy to use however PARSENAME looks for period, hence it was supplimented by REPLACE function in this query)


Select OwnerAddress
From DataCleaning_PortfolioProject.dbo.NashvilleHousing  --(1)

Select
PARSENAME(REPLACE(OwnerAddress, ',', ','), 3) ----(PARSENAME operates backwards, hence to place the columns in right sequence, reverse numbering is done)
PARSENAME(REPLACE(OwnerAddress, ',', ','), 2)
PARSENAME(REPLACE(OwnerAddress, ',', ','), 1) 
From DataCleaning_PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(225);

Update NashvilleHousing
Set	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', ','), 3) ---(Executed this query from Alter Table)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(225);

Update NashvilleHousing
Set	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', ',', 2) ---(Execute this query from Alter Table)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(225); 

Update NashvilleHousing
Set	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', ','), 1) ---(Execute this query from Alter Table)



--4. Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From DataCleaning_PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2 ------(Execute) .....(1)

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'    ---Here CASE WHEN THEN ELSE expressions are used to replace Y/N to Yes/No
	   Else SoldAsVacant
	   End
From DataCleaning_PortfolioProject.dbo.NashvilleHousing ----(Execute).....(2)

--Now "Update" and "Set" statements are used to update update and refresh the column and replace the Y/N with Yes/No

update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	   When SoldAsVacant = 'N' then 'No'    ---Here CASE WHEN THEN ELSE expressions are used to replace Y/N to Yes/No
	   Else SoldAsVacant
	   End -----------(Execute and recheck by executing 1st query)....(3)





--5. Remove Duplicates


With RowNumCTE AS(
Select*,
	Row_Number() Over (                   ----(to identify rows)
	Partition by ParcelID,
			     PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				  UniqueID
				  ) row_num
From DataCleaning_PortfolioProject.dbo.NashvilleHousing
)
delete
From RowNumCTE
Where row_num > 1 ----(Execute)
---------------------------------------------------------------------------
Select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress -----(Executed to filter the duplicates)
----------------------------------------------------------------------------




--6. Delete Unused Columns

----through "Alter table" and "Drop column"

Select*
From DataCleaning_PortfolioProject.dbo.NashvilleHousing


Alter table DataCleaning_PortfolioProject.dbo.NashvilleHousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress  -------(Execute)


--------------------------------------------------------------------------
--------------------------------------------------------------------------



