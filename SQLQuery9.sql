--������ 1: ���������� �������
--1. �������� �����
--�������� AdventureWorks������ ��������� ����� �����. �������� ��� � ������� SalesLT.Product, 
--��������� �������� �� ��������� ��� NULL ��� ����������� �������� 
--(����������� ��������� � ���� ���������� ������� ��������):

insert into SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate) values ('LED Lights', 'LT-L123', 2.56, 12.99, 37, GETDATE())
select ProductID from SalesLT.Product where ProductNumber= 'LT-L123'
select * from SalesLT.Product where ProductNumber= 'LT-L123'

delete from SalesLT.Product where Name = 'LED Lights'

--2. �������� ����� �������� ��������� � ����� ��������
--�������� AdventureWorks��������� � ���� ������� ��������� �������BellsandHorns�.
--������������� ������������������������ ����� ��������� =4 (Accessories). 
--��� ����� ��������� �������� � ���� ��������� ��� ����� ������:

--insert into SalesLT.ProductCategory (Name, ParentProductCategoryID) values ('Bells and Horns', 4)

--declare @id int = SCOPE_IDENTITY()
--insert into SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate) 
--values ('Bicycle Bell', 'BB-RING', 2.47, 4.99, @id, GETDATE()),
--('Bicycle Horn', 'BB-PARP', 1.29, 3.75, @id, GETDATE())

--select p.Name, p.ProductNumber, p.StandardCost, p.ListPrice, p.ProductCategoryID, p.SellStartDate, c.ProductCategoryID, c.ParentProductCategoryID 
--from SalesLT.Product as p
--join SalesLT.ProductCategory as c
--on c.ProductCategoryID = p.ProductCategoryID
--where (ParentProductCategoryID = ident_current('SalesLT.ProductCategory'))

--������ 2: ���������� ���������� �� �������
--1. ���������� ��� �� ������
--�������� �� �������� � �������� AdventureWorks������ ������� ��10%�������� ������� ���� ������������������ �BellsandHorns�. 
--�������� ������ � ������� SalesLT.Product��� ���� �������, 
--����� ��������� �� ���� (������� ListPrice) �� 10% (���������� �������������������� ��������)

update SalesLT.Product
set ListPrice = 1.1*(ListPrice)
where ProductCategoryID = (select ProductCategoryID from SalesLT.ProductCategory where Name = 'Bells and Horns')

--2. ����������� ������ �������
--����� ����� �LEDLights�, ������� �� �������� ������ ������, ������ �������� ��� ���������� �������� ��������. 
--�������� ������� SalesLT.Product, ����� ���������� �������� ���������� ���� DiscontinuedDate��� 
--���� �������� ��������� �Lights� (���������� ����� ProductCategoryID= 37), 
--����� ������ �LEDLights�, ������� �� ������������� (���������� �����ProductNumber�LT-L123�)

update SalesLT.Product
set DiscontinuedDate = getdate()
where ((ProductCategoryID = 37) and (ProductNumber != 'LT-L123'))

--������ 3: �������� �������
--1. ������� ��������� ������� � ������ � ���
--������� ������ ��������� �BellsandHorns� � �� �������. �� ������ ���������, 
--��� �� �������� ������ �� ������ � ���������� �������, 
--����� �������� ��������� ������������������� ����� (���������� �� ��������� ��������������).
delete from SalesLT.Product where ProductCategoryID = (select ProductCategoryID from SalesLT.ProductCategory where Name = 'Bells and Horns')
delete from SalesLT.ProductCategory where Name = 'Bells and Horns'

