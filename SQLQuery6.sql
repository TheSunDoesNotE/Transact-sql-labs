use AdventureWorksLT2017
--1.1 �������� ������, � ������� �������������� ���� ���� ������� ���� �� �����
--�������� ������������� ������, ������������ � �������������� ���� ��� ������� ������, ���
--�������������� ���� ���� ������� ���� �� ������� ������ ��� ���� ��������� �������.

select ProductID, Name, ListPrice from SalesLT.Product
where ListPrice > 
(select AVG(UnitPrice) from SalesLT.SalesOrderDetail)

--1.2 �������� ������ � �������������� ����� � 100 �������� ��� �����, ������� ���� ������� ����� ��� �� 100 ��������
--�������� ������������� ������, ������������ � �������������� ���� ��� ������� ������, ���
--�������������� ���� ���������� $100 ��� �����, � ����� ������ ����� ��� �� $100.

select ProductID, Name, ListPrice from SalesLT.Product
where (ListPrice >= 100) and ProductID IN (select ProductID from SalesLT.SalesOrderDetail
where UnitPrice < 100)

--1.3 �������� �������������, �������������� ���� � ������� ���� ������� ��� ������� �����
--�������� ������������� ������, ������������, ������������� (������� StandardCost) � ��������������
--���� ��� ������� ������ �� ������� Products ������ �� ������� ����� ������� ������� ������� ������
--� ������� AvgSellingPrice.

select pr.ProductID, pr.Name, pr.StandardCost, pr.ListPrice, 
(select AVG(UnitPrice) from SalesLT.SalesOrderDetail 
where pr.ProductID=ProductID) as AvgSellingPrice
from SalesLT.Product as pr

--1.4 �������� ������ � ������� ������� ���� ������� ���� �������������
--������������ ���������� ������ ���, ����� �������� ������ ������, ��� ������������� ���� �������
--���� ������� ������.

select pr.ProductID, pr.Name, pr.StandardCost, pr.ListPrice, 
(select AVG(UnitPrice) from SalesLT.SalesOrderDetail 
where pr.ProductID=ProductID) as AvgSellingPrice
from SalesLT.Product as pr
where (pr.StandardCost > (select AVG(UnitPrice) from SalesLT.SalesOrderDetail))

--2.1 �������� ���������� � �������� ��� ���� �������
--�������� ������������� ������, ������������� �������, ���, ������� � ����� ����� (TotalDue) ���
--���� ������� �� ������� SalesLT.SalesOrderHeader � ������� dbo.ufnGetCustomerInformation.
--���������� ������������� ���������� �� SalesOrderID
select soh.SalesOrderID, p.CustomerID, p.FirstName, p.LastName, soh.TotalDue from SalesLT.SalesOrderHeader as soh
CROSS APPLY dbo.ufnGetCustomerInformation(soh.CustomerID) as P
--2.2 �������� ���������� �� ������ �������
--�������� ������������� �������, ���, �������, �������� ������ 1 � ����� ��� ���� �������� �� ������
--SalesLT.Address � SalesLT.CustomerAddress � ������� dbo.ufnGetCustomerInformation. ����������
--������������� ���������� �� CustomerID.
select ca.CustomerID, p.FirstName, p.LastName, ad.AddressLine1, ad.City
from  SalesLT.CustomerAddress as ca
join SalesLT.Address as ad
on ca.AddressID = ad.AddressID
CROSS APPLY dbo.ufnGetCustomerInformation(ca.CustomerID) as P
order by p.CustomerID
