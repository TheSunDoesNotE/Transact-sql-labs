--1.1 �������� ��� �������� ���������� ������� ����������� ���.
-- �������� ��� �������� ���������� ������� ����������� ���.
--��������� ����� ������ ����������� � �� ���������� ���������, ��� ������� ������
--������������� ���������� ������� ��� ���������� �������� ���, ������� �� ��������� ������
--������� (��� ������� �� ������� Product), ������� �������� ��������� �������. ���� ����� ������
--����������� � ���������� ������� ������� �������� 20-������� ������� � ���� �������� �
--<����������> �������, � ��������� ������ ������� '������� 20-������� ������� � ����
--���������'.
SELECT * FROM SalesLT.Product as Pr
WHERE (ListPrice > (SELECT MIN(ListPrice) * 20 FROM SalesLT.Product WHERE ProductCategoryID = Pr.ProductCategoryID))
OR (ListPrice < (SELECT MAX(ListPrice) / 20 FROM SalesLT.Product WHERE ProductCategoryID = Pr.ProductCategoryID))
DECLARE @Rows int = @@ROWCOUNT

IF (@Rows <> 0) PRINT N'������� 20-������� ������� � ���� �������� � ' + CAST(@Rows as nvarchar(20)) + N' �������'
ELSE PRINT N'������� 20-������� ������� � ���� ���������'
GO

--1.2 �������� ������� ��� ����������� ������� 20-������� ������� � ��������� ����
--��� �������� �������� ������� � ������ SalesLT.TriggerProductListPriceRules, ������� ������
--������������ � �� ������� 20-������� ������� � ��������� ���� ������� �� ����� �������.
--�������� ���������� �������� � �������� ��������� ������, ������� �������� ������� 20-�������
--������� � ����, �������� ��� ���� ������������ ������������� ������ � ������� 50001 �
--���������� ��������� ��������� �������� ������� 20-������� ������� � ���� ������� �� �����
--������� (������� ������)� ��� ��������� ��������� �������� ������� 20-������� ������� � ����
--������� �� ����� ������� (������� ������)�.
--CREATE 
Create or Alter TRIGGER SalesLT.TriggerProductListPriceRules ON SalesLT.Product
AFTER INSERT, UPDATE AS
BEGIN
IF EXISTS(SELECT * FROM inserted as Ins
WHERE (Ins.ListPrice > (SELECT MIN(ListPrice) * 20 FROM SalesLT.Product WHERE ProductCategoryID = Ins.ProductCategoryID)))
BEGIN
ROLLBACK;
THROW 50001, N'�������� ��������� �������� ������� 20-������� ������� � ���� ������� �� ����� ������� (������� ������)', 1;
END
ELSE IF EXISTS(SELECT * FROM inserted as Ins
WHERE (Ins.ListPrice < (SELECT MAX(ListPrice) / 20 FROM SalesLT.Product WHERE ProductCategoryID = Ins.ProductCategoryID)))
BEGIN
ROLLBACK;
THROW 50001, N'�������� ��������� �������� ������� 20-������� ������� � ���� ������� �� ����� ������� (������� ������)', 1;
END
END
GO

--1.3 ������������� ��������� �������

DECLARE
@Minimum float = (SELECT MIN(ListPrice) FROM SalesLT.Product WHERE ProductCategoryID = 5),
@Maximum float = (SELECT MAX(ListPrice) FROM SalesLT.Product WHERE ProductCategoryID = 5)

PRINT N'����������� ����: ' + CAST(@Minimum as nvarchar(20)) + N', ������������ ����: ' + CAST(@Maximum as nvarchar(20))

BEGIN TRY
INSERT INTO SalesLT.Product(Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES ('Golden Bike', 'GB-15000', 1, 15000, 5, GETDATE())
END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

BEGIN TRY
	INSERT INTO SalesLT.Product(Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
	VALUES ('Toy Bike', 'TB-50', 1, 50, 5, GETDATE())
END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

SELECT Name, ProductNumber, ListPrice FROM SalesLT.Product WHERE ProductCategoryID = 5
ORDER BY ListPrice ASC
GO

--2.1 �������� ���������
--��� ���������� ������� ��� AFTER-�������� TriggerProduct � TriggerProductCategory: �� ������ ���
--������ �� ������ Product � ProductCategory ��� ����������� ��������� ����������� ����� �����
--��������� �� ���� ProductCategoryID. ��������������, �������� ������ ����������� ������ 50002
--� ��������� �������: ������� ��������� ��������� ����������� ����� ��������� Product �
--ProductCategory, ���������� ��������� (� TriggerProduct ��������� 0, � TriggerProductCategory �
--��������� 1).
CREATE OR ALTER TRIGGER Trigger_Product ON SalesLT.Product
AFTER INSERT, UPDATE, DELETE AS
BEGIN
	IF (SELECT ProductCategoryID FROM inserted) NOT IN (SELECT ProductCategoryID FROM SalesLT.ProductCategory)
	BEGIN
		ROLLBACK;
		THROW 50002, N'������: ������� ��������� ��������� ����������� ����� ��������� Product � ProductCategory, ���������� ��������', 0;
	END
END
GO

CREATE OR ALTER TRIGGER Trigger_ProductCategory ON SalesLT.ProductCategory
AFTER INSERT, UPDATE, DELETE AS
BEGIN
	IF ((SELECT ProductCategoryID FROM deleted) IN (SELECT ProductCategoryID FROM SalesLT.Product))
	BEGIN
		ROLLBACK;
		THROW 50002, N'������: ������� ��������� ��������� ����������� ����� ��������� Product � ProductCategory, ���������� ��������', 1;
	END
END
GO

--2.2 ������������ ���������
--��� ������������ ��������� �� �������� ���������� �������� ����������� �� ������ ��������
--����� (����� ���������� ��������� ����� ����� ��������� ���������� ����������):
--ALTER TABLE SalesLT.Product NOCHECK CONSTRAINT FK_Product_ProductCategory_ProductCategoryID;
--���������� ���������� �������� ������ � ����� ����� ������ � ProductCategoryID=-1 � �������
--Product � ���������, ��� �� �������� ��������� �� ������ �� ��������. ����� ��� ����� ����������
--������� ������ � ��������� � ProductCategoryID=5 �� ������� ProductCategory � ���������, ��� ��
--����� �������� ��������� �� ������ �� ��������.
ALTER TABLE SalesLT.Product NOCHECK CONSTRAINT FK_Product_ProductCategory_ProductCategoryID;

BEGIN TRY
	INSERT INTO SalesLT.Product(Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
	VALUES ('Unknown', 'Unknown', 1, 1, -1, GETDATE())
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

BEGIN TRY
	DELETE FROM SalesLT.ProductCategory WHERE ProductCategoryID = 7
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

--2.3 �������������� �������� ����� � ���������� ���������


-- ��������� �������� �������� �����
ALTER TABLE SalesLT.Product CHECK CONSTRAINT FK_Product_ProductCategory_ProductCategoryID;

-- ���������� ���������
DISABLE TRIGGER SalesLT.Trigger_Product ON SalesLT.Product;
DISABLE TRIGGER SalesLT.Trigger_ProductCategory ON SalesLT.ProductCategory;