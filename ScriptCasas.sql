USE PortfolioProject

SELECT * 
FROM PortfolioProject..NashvilleHousing;

-- Estandarizar el formato de Fecha

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHousing;

--Actualizar el campo o crea una nueva columna y se rellena con los datos convertidos.
--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(date,SaleDate);

ALTER TABLE NashvilleHousing
ADD SaleDateConvert Date;

UPDATE NashvilleHousing
SET SaleDateConvert = CONVERT(date,SaleDate);


-- Llenar los campos vacios de Direccion de la propiedad

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL;


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing as A
JOIN PortfolioProject..NashvilleHousing as B
ON A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET
	PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM 
	PortfolioProject..NashvilleHousing as A
	JOIN PortfolioProject..NashvilleHousing as B
ON 
	A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE 
	A.PropertyAddress IS NULL;


-- Dividir la columna de Direccion de la Propiedad

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT PropertyAddress, 
	SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)) as City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD SplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1);

UPDATE NashvilleHousing
SET SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress));


-- Dividir la columna de Direccion de dueño

SELECT 
	OwnerAddress, 
	PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM
	PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SplitOwnerAddress  Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD SplitOwnerCity Nvarchar(255)

ALTER TABLE NashvilleHousing
ADD SplitOwnerState Nvarchar(255)

UPDATE NashvilleHousing
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

UPDATE NashvilleHousing
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

UPDATE NashvilleHousing
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

--Reemplazar las Y / N por Yes y No.

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
	SoldAsVacant,
	CASE 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
	ELSE
		SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant =
	CASE 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
	ELSE
		SoldAsVacant
	END


--Remover Duplicados

WITH RownumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					) row_num
FROM PortfolioProject..NashvilleHousing
)
--DELETE
--FROM RownumCTE 
--WHERE row_num > 1

SELECT *
FROM RownumCTE
WHERE row_num > 1


--Remover columnas

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, SaleDate, TaxDistrict

--Final

SELECT * 
FROM PortfolioProject..NashvilleHousing
ORDER BY SaleDateConvert DESC