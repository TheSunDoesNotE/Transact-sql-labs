--1.1 �������� ������������ � ��������������� ��� ������� ������
select ProductID, Upper(Name) as ProductName, FLOOR([Weight]) as ApproxWeight from SalesLT.Product
--1.2 �������� ��� � �����, ����� ������ ���� ������� �������
select ProductID, 
Upper(Name) as ProductName, 
Round([Weight], 0) as ApproxWeight, 
Year(SellStartDate) as SellStartYear, 
Datename(mm, SellStartDate) as SellStartMonth 
from SalesLT.Product
where Isnumeric(Size) = 1
--1.3 �������� ���� ������� �� ������� �������
select ProductID, 
Upper(Name) as ProductName, 
Round([Weight], 0) as ApproxWeight, 
Year(SellStartDate) as SellStartYear, 
Datename(mm, SellStartDate) as SellStartMonth,
Left(ProductNumber, 2) as ProductType 
from SalesLT.Product
--1.4 �������� ������ ������, ������� �������� ������
select ProductID,
Upper(Name) as ProductName, 
Round([Weight], 0) as ApproxWeight, 
Year(SellStartDate) as SellStartYear, 
Datename(mm, SellStartDate) as SellStartMonth,
Left(ProductNumber, 2) as ProductType 
from SalesLT.Product
where Isnumeric(Size) = 1

--2.1 �������� ��������, ��������������� �� ������ ������
select cu.CompanyName, S.TotalDue as Revenue, 
RANK() OVER
(ORDER BY S.TotalDue Desc) as [Rank] 
from SalesLT.Customer as Cu
join SalesLT.SalesOrderHeader as S
on cu.CustomerID = S.CustomerID

--3.1 �������� ����� ����� ������ �� ������
select Pr.Name, Sum(S.LineTotal) as TotalRevenue from SalesLT.Product as Pr
join SalesLT.SalesOrderDetail as S
on Pr.ProductID = S.ProductID 
group by Name
order by TotalRevenue desc
--3.2 ������������ ������ ������ �������, ������� � ���� ������ �� ������, ��������� ������� ��������� $1000
select P.Name, Sum(Sy.LineTotal) as TotalRevenue from SalesLT.Product as P
join SalesLT.SalesOrderDetail as Sy
on P.ProductID = Sy.ProductID 
where Sy.LineTotal > 1000
group by Name
order by TotalRevenue desc
--3.3 ������������ ������ ������ ������� ���, ����� �������� ������ �� �� ���, ����� ����� ������ ������� ����� $20000
select P.Name, Sum(SyO.LineTotal) as TotalRevenue from SalesLT.Product as P
join SalesLT.SalesOrderDetail as SyO
on P.ProductID = SyO.ProductID 
where P.ListPrice > 1000
group by Name
having Sum(SyO.LineTotal) >20000
order by TotalRevenue desc