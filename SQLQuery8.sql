--������ 1: ��������� ������ ������ �� ��������
---1. �������� ����� ��� ������/������� � �����/���������
-- � ������������ ������ ������������ ��������� ������, 
--����� ������� ����� ����� �� ������, ��������������� �� ������/������� � �����/���������
SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
INNER JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY 
Grouping sets (a.CountryRegion, (a.CountryRegion, a.StateProvince), ())
ORDER BY a.CountryRegion, a.StateProvince;

---2. ������� ������ ����������� � �����������
--�������� ���� ���������� ������, ����� �������� ������� � ������ �Level�, ������� ���������, 
--�� ����� ������ � �������� ������������ ���������� ������ � ������:��������,������/������ � ����/���������.
SELECT a.CountryRegion, a.StateProvince,GROUPING_ID(a.CountryRegion, a.StateProvince)as Lavel, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
INNER JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY 
Grouping sets (a.CountryRegion, a.StateProvince, ())
ORDER BY a.CountryRegion, a.StateProvince;

--3. �������� ������� ����������� ��� �������
--��������� ���� ���������� ������, ����� �������� ������� �City� (����� ������� StateProvince) � �����������
--��� ��������� �������. �������� ������� ��� ������� �Level� ���, ����� ������, ������������ �������������
--���� ��� ������ ������, ��������� �������� �London Subtotal�. �������� ������� City � ��������� ����������
--�����������.
SELECT a.CountryRegion, a.StateProvince,City, 
choose (GROUPING_ID(a.CountryRegion, a.StateProvince),city +'subtotal',a.StateProvince + 'subtotal', a.CountryRegion + 'subtotal', 'Total')as Level, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
INNER JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY 
Grouping sets (a.CountryRegion, a.StateProvince, City, ())
ORDER BY a.CountryRegion, a.StateProvince, City;

--������ 2: ��������� ������� �� ������ �� ���������� 
--1. �������� ����� �� ������ ��� ������ ������������ ���������
--�������� ������ ����������������-�������� (������� CompanyName), �� ���������� (����� ��������LineTotal� ������� SalesLT.SalesOrderDetail)
--��� ������ ������������ ��������� � ��������Accessories, Bikes, Clothing�Components(� ����������������������� Accessories, Bikes, Clothing� Components).
--������������ ���������� ������� �� �������� ��������.
SELECT CompanyName, Bikes, Accessories, Clothing
FROM
(SELECT c.CompanyName as CompanyName, so.LineTotal as SuM, v.ParentProductCategoryName as Category from SalesLT.Customer as c
join SalesLT.SalesOrderHeader as s
on c.CustomerID = s.CustomerID
join SalesLT.SalesOrderDetail as so
on s.SalesOrderID = so.SalesOrderID
join SalesLT.Product as p
on so.ProductID = p.ProductID
join SalesLT.vGetAllCategories as v
on p.ProductCategoryID = v.ProductCategoryID)
 
AS sales
PIVOT (SUM(SuM) FOR Category IN([Bikes], [Accessories], [Clothing])) AS pvt