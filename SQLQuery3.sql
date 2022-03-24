--1.1 �������� ������ ��������
--� �������� ������� ���� �� �������� ������ �� ������ �������� ������, ������� ����������
--�������� �������� (CompanyName) �� ������� SalesLT.Customer, � ����� ������������� ������
--(SalesOrderID) � �������� ��������� (TotalDue) �� ������� SalesLT.SalesOrderHeader.
SELECT cn.CompanyName, so.SalesOrderID, so.TotalDue 
FROM SalesLT.Customer AS cn 
Join SalesLT.SalesOrderHeader AS so 
ON cn.CustomerID=so.CustomerID
--1.2�������� ������ �������� � ��������
--��������� ���� ���������� ������ �� ������� ��������, ����� �������� � ���� ����� ��������
--����� ��� ������� �������, ������� ������ ����� (������� AddressLine1 � AddressLine2), �����
--(City), ���� ��� ��������� (StateProvince), �������� ������ (PostalCode) � ������/������
--(CountryRegion).
SELECT c.CompanyName, oh.SalesOrderID, oh.TotalDue, a.AddressLine1, a.AddressLine2, a.City, a.StateProvince, a.PostalCode, a.CountryRegion
FROM SalesLT.Customer AS c 
JOIN SalesLT.SalesOrderHeader AS oh
ON oh.CustomerID=c.CustomerID
JOIN SalesLT.CustomerAddress AS ca
ON c.CustomerID=ca.CustomerID AND AddressType = 'Main Office' 
JOIN SalesLT.[Address] AS a
ON ca.AddressID=a.AddressID
--2.1 �������� ������ ���� �������� � �� �������
--�������� �� �������� ������ ��������� ������ ���� ��������-�������� (CompanyName) � ��
--������� � ���������� (��� � ������� � FirstName � LastName), ������� �� ���������
--������������� ������ (SalesOrderID) � ����� ����� (TotalDue) �� ������ �����, �������
--���������� �������. �������, ������� �� ���������� ������, ������ ���� �������� � ������
--����� ������ �� ���������� NULL ��� �������������� ������ � ����� �����.
SELECT c.CompanyName, c.FirstName, c.LastName, o.SalesOrderID, o.TotalDue FROM SalesLT.Customer as c
LEFT JOIN SalesLT.SalesOrderHeader AS o
ON c.CustomerID = o.CustomerID
ORDER BY o.CustomerID DESC

--2.2 �������� ������ �������� ��� ������
--��������� ������ ������ �������, ��� Adventure Works �� ����� ���������� �� ������� ���
--���� ��������. �� ������ �������� ������, ������� ���������� ������ ���������������
--��������, �������� ��������, ���� ��������� (��� � �������) � ������ ��������� ���
--��������, �� ������� ������.
SELECT c.CustomerID, c.CompanyName, c.FirstName, c.LastName, c.Phone FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN SalesLT.[Address] AS ad
ON ca.AddressID = ad.AddressID AND ad.AddressLine2 IS NULL
 
--2.3 �������� ������ �������� � �������
--�������� ������, ������� ���������� ������� ��������������� �������� (CustomerID) ���
--��������, ������� ������� �� ��������� ������, � ������� ��������������� ������� (ProductID)
--��� �������, ������� ������� �� ���� ��������. ������ ������ � ��������������� �������
--������ ����� ������������� �������� NULL (��������� ������ ������� �� ��������� �������), �
--������ ������ � ��������������� ������ ������ ����� ������������� ������� NULL (���������
--����� ������� �� ����������� ��������).
SELECT c.CustomerID, pr.ProductID FROM SalesLT.Customer AS c
FULL JOIN SalesLT.SalesOrderHeader AS o
ON c.CustomerID = o.CustomerID 
FULL JOIN SalesLT.SalesOrderDetail AS so
ON o.SalesOrderID = so.SalesOrderID 
FULL JOIN SalesLT.Product AS pr 
ON so.ProductID = pr.ProductID 
WHERE c.CustomerID IS NULL OR pr.ProductID IS NULL

