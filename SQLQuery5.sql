--1.1 Получите наименование и приблизительный вес каждого товара
select ProductID, Upper(Name) as ProductName, FLOOR([Weight]) as ApproxWeight from SalesLT.Product
--1.2 Получите год и месяц, когда товары были впервые проданы
select ProductID, 
Upper(Name) as ProductName, 
Round([Weight], 0) as ApproxWeight, 
Year(SellStartDate) as SellStartYear, 
Datename(mm, SellStartDate) as SellStartMonth 
from SalesLT.Product
where Isnumeric(Size) = 1
--1.3 Получите типы товаров из номеров товаров
select ProductID, 
Upper(Name) as ProductName, 
Round([Weight], 0) as ApproxWeight, 
Year(SellStartDate) as SellStartYear, 
Datename(mm, SellStartDate) as SellStartMonth,
Left(ProductNumber, 2) as ProductType 
from SalesLT.Product
--1.4 Получите только товары, имеющие числовой размер
select ProductID,
Upper(Name) as ProductName, 
Round([Weight], 0) as ApproxWeight, 
Year(SellStartDate) as SellStartYear, 
Datename(mm, SellStartDate) as SellStartMonth,
Left(ProductNumber, 2) as ProductType 
from SalesLT.Product
where Isnumeric(Size) = 1

--2.1 Получите компании, отранжированные по суммам продаж
select cu.CompanyName, S.TotalDue as Revenue, 
RANK() OVER
(ORDER BY S.TotalDue Desc) as [Rank] 
from SalesLT.Customer as Cu
join SalesLT.SalesOrderHeader as S
on cu.CustomerID = S.CustomerID

--3.1 Получите общий объем продаж по товару
select Pr.Name, Sum(S.LineTotal) as TotalRevenue from SalesLT.Product as Pr
join SalesLT.SalesOrderDetail as S
on Pr.ProductID = S.ProductID 
group by Name
order by TotalRevenue desc
--3.2 Отфильтруйте список продаж товаров, включив в него только те товары, стоимость которых превышает $1000
select P.Name, Sum(Sy.LineTotal) as TotalRevenue from SalesLT.Product as P
join SalesLT.SalesOrderDetail as Sy
on P.ProductID = Sy.ProductID 
where Sy.LineTotal > 1000
group by Name
order by TotalRevenue desc
--3.3 Отфильтруйте группы продаж товаров так, чтобы включить только те из них, общий объем продаж которых более $20000
select P.Name, Sum(SyO.LineTotal) as TotalRevenue from SalesLT.Product as P
join SalesLT.SalesOrderDetail as SyO
on P.ProductID = SyO.ProductID 
where P.ListPrice > 1000
group by Name
having Sum(SyO.LineTotal) >20000
order by TotalRevenue desc