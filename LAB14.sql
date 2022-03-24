--1.1 ��������� �������� ����� ������ �� �������
--����� ������ ��������� ������ ��� �������� ��� ����� �����, ������� ������� �� �����������
--�������� �����. ������� ��� ������ �������� ������� � ������ fn_GetOrdersTotalDueForCustomer,
--����������� ���� ������� �������� @CustomerID (������������� �������) � ������������
--����� �����, ����������� �������� �� ������ ���� ������� (�.�. ����� TotalDue). ���������
--������� ������������� ���������� ������� ��� �������� � ���������������� 1 � 30113.

CREATE OR ALTER FUNCTION dbo.fn_GetOrdersTotalDueForCustomer (@CustomerID int)
RETURNS float AS
BEGIN
	DECLARE @Result float
	SELECT @Result = SUM(TotalDue) FROM SalesLT.SalesOrderHeader WHERE CustomerID = @CustomerID
	RETURN @Result
END
GO

PRINT dbo.fn_GetOrdersTotalDueForCustomer(1)
PRINT dbo.fn_GetOrdersTotalDueForCustomer(30113)
GO

--1.2 ��������� ���� ����� ������� ��������
--����� ������ �������� ������� ������� �������� � ��� �������� ������� �������������
--vAllAddresses ��� ����������� ���� ����� ������� ���� ��������. ������������� ������ ���������
--��������� ��������: CustomerID, AddressType, AddressID, AddressLine1, AddressLine2, City,
--StateProvince, CountryRegion, PostalCode. ������������� ��������� �������������.

CREATE VIEW SalesLT.vAllAddresses
WITH SCHEMABINDING
AS
	SELECT C.CustomerID, AddressType, Ad.AddressID, AddressLine1, AddressLine2, City, StateProvince, CountryRegion, PostalCode
	FROM SalesLT.Customer as C
	JOIN SalesLT.CustomerAddress as CA on CA.CustomerID = C.CustomerID
	JOIN SalesLT.Address as Ad on Ad.AddressID = CA.AddressID
GO

SELECT * FROM SalesLT.vAllAddresses
GO

--1.3 ��������� ���� ������� �������
--��� ���������� ��� ���������� �������� ������� ����������� �������
--fn_GetAddressesForCustomer, ������������ ��� ������ ��� ����������� ������� (������� ��������
--@CustomerID � ������������� �������) �� ����� ���������� ������������� vAllAddresses.
--������������ ����� ������ ������ ��������� ��� ��������� �������� �� �������������.
--������������� ��������� ������� � �������� ������, ������������ ������ �������� � ����
--������ ������ ������ ��� �������� � ���������������� 0, 29502 � 29503.

CREATE OR ALTER FUNCTION dbo.fn_GetAddressesForCustomer (@CustomerID int)
RETURNS TABLE AS
RETURN (
	SELECT * FROM SalesLT.vAllAddresses WHERE CustomerID = @CustomerID
	)
GO

SELECT * FROM dbo.fn_GetAddressesForCustomer(29545)
UNION
SELECT * FROM dbo.fn_GetAddressesForCustomer(29502)
UNION
SELECT * FROM dbo.fn_GetAddressesForCustomer(29503)
GO

--1.4 ����������� ������������ � ����������� ����� ������� ������
--��� ��������� ���������� �� �������� ������� �������� ��� ������ ������� �������
--fn_GetMinMaxOrderPricesForProduct, ����������� �� ���� ������������� ������ @ProductID �
--������������ ������ � ����� ���������: MinUnitPrice � MaxUnitPrice, ���������� ��������������
--����������� � ������������ ���� (�� ������� UnitPrice) �� ������� ��� ������ ������ �����.
--�������� ������������ ������� ��� ������� � ���������������� 0 � 711.

CREATE FUNCTION dbo.fn_GetMinMaxOrderPricesForProduct (@ProductID int)
RETURNS TABLE AS
RETURN (
	SELECT MIN(UnitPrice) as MinUnitPrice, MAX(UnitPrice) as MaxUnitPrice
	FROM SalesLT.SalesOrderDetail
	WHERE ProductID = @ProductID
	)
GO

SELECT * FROM dbo.fn_GetMinMaxOrderPricesForProduct(0)
UNION
SELECT * FROM dbo.fn_GetMinMaxOrderPricesForProduct(809)
UNION
SELECT * FROM dbo.fn_GetMinMaxOrderPricesForProduct(711)
GO

--1.5 ��������� ���� �������� ������
--����� ���������� ����� ��������������, ��� ��� �������� ����������� ������� ����� ���������
--����������. ��� ������ �������� ������� fn_GetAllDescriptionsForProduct, ������� ���������� ���
--�������� ��� ������. ������� ��������� �� ���� ������������� ������ @ProductID � ����������
--��� ��������� ��� ������� ������ �������� � ���� �������� �� ���������� ����������: ProductID,
--Name, MinUnitPrice, MaxUnitPrice, ListPrice, ProductModel, Culture, Description. ����� Name �
--������������ ������, MinUnitPrice, MaxUnitPrice � ��������� ��� ������ �� �������
--fn_GetMinMaxOrderPricesForProduct, ListPrice � ��������� ����, ProductModel � ���� Name ��
--������� ProductModel, Culture � ���� �������� �� ������� ProductModelProductDescription,
--Description � �������� �� ������� ProductDescription. ���������: ����������� �������������
--vProductAndDescription ��� ���������� ���������� ���������� � ������� � ��������� ���
--����������. �������� ������������ ������� ��� ������� � ���������������� 0 � 711.

CREATE FUNCTION dbo.fn_GetAllDescriptionsForProduct (@ProductID int)
RETURNS TABLE AS
RETURN (
	SELECT Pr.ProductID, Pr.Name, MinMax.MinUnitPrice, MinMax.MaxUnitPrice, ListPrice, ProductModel, Culture, Description
	FROM SalesLT.vProductAndDescription as PrDesc
	JOIN SalesLT.Product as Pr
	ON Pr.ProductID = PrDesc.ProductID
	JOIN dbo.fn_GetMinMaxOrderPricesForProduct(@ProductID) as MinMax
	ON Pr.ProductID = @ProductID
	)
GO

SELECT * FROM dbo.fn_GetAllDescriptionsForProduct(0)
UNION
SELECT * FROM dbo.fn_GetAllDescriptionsForProduct(809)
UNION
SELECT * FROM dbo.fn_GetAllDescriptionsForProduct(711)
GO

--2.1 �������������� ������������� vAllAddresses
--�������� ��������� �Include Actual Execution Plan� � �Include Live Query Statistics� � ��������� ������
--SELECT * FROM [dbo] . [ vAllAddresses]
--��������������� ���� ���������� ������� � ���������, ��� ���������� ������� � �������������
--������ �������� ����. ����������, ��� ������������� ������� � ������ WITH SCHEMABINDING,
--�������� ���������� ���������� ������ UIX_vAllAddresses �� ������������� vAllAddresses, �������
--� ���� ��� ��������. ����� �������� ������� ��� ��� ��������� ������ (��������, � ������ �WITH
--(NOEXPAND)�, �.�. SELECT * FROM [dbo] . [vAllAddresses] WITH (NOEXPAND)) � ���������, ��� ����
--���������� ���������� ��������� ���� ������.




SELECT * FROM SalesLT.vAllAddresses

CREATE UNIQUE CLUSTERED INDEX UIX_vAllAddresses ON SalesLT.vAllAddresses
(
	[CustomerID] ASC,
	[AddressType] ASC,
	[AddressID] ASC,
	[AddressLine1] ASC,
	[AddressLine2] ASC,
	[City] ASC,
	[StateProvince] ASC,
	[CountryRegion] ASC,
	[PostalCode] ASC
) ON [PRIMARY]

SELECT * FROM SalesLT.vAllAddresses WITH (NOEXPAND)