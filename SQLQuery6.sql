use AdventureWorksLT2017
--1.1 Получите товары, у которых прейскурантная цена выше средней цены за товар
--Получите идентификатор товара, наименование и прейскурантную цену для каждого товара, чья
--прейскурантная цена выше средней цены за единицу товара для всех проданных товаров.

select ProductID, Name, ListPrice from SalesLT.Product
where ListPrice > 
(select AVG(UnitPrice) from SalesLT.SalesOrderDetail)

--1.2 Получите товары с прейскурантной ценой в 100 долларов или более, которые были проданы менее чем за 100 долларов
--Получить идентификатор товара, наименование и прейскурантную цену для каждого товара, чья
--прейскурантная цена составляет $100 или более, а товар продан менее чем за $100.

select ProductID, Name, ListPrice from SalesLT.Product
where (ListPrice >= 100) and ProductID IN (select ProductID from SalesLT.SalesOrderDetail
where UnitPrice < 100)

--1.3 Получите себестоимость, прейскурантную цену и среднюю цену продажи для каждого товар
--Получите идентификатор товара, наименование, себестоимость (столбец StandardCost) и прейскурантную
--цену для каждого товара из таблицы Products вместе со средней ценой продажи единицы данного товара
--в столбце AvgSellingPrice.

select pr.ProductID, pr.Name, pr.StandardCost, pr.ListPrice, 
(select AVG(UnitPrice) from SalesLT.SalesOrderDetail 
where pr.ProductID=ProductID) as AvgSellingPrice
from SalesLT.Product as pr

--1.4 Получите товары у которых средняя цена продажи ниже себестоимости
--Отфильтруйте предыдущий запрос так, чтобы включить только товары, где себестоимость выше средней
--цены продажи товара.

select pr.ProductID, pr.Name, pr.StandardCost, pr.ListPrice, 
(select AVG(UnitPrice) from SalesLT.SalesOrderDetail 
where pr.ProductID=ProductID) as AvgSellingPrice
from SalesLT.Product as pr
where (pr.StandardCost > (select AVG(UnitPrice) from SalesLT.SalesOrderDetail))

--2.1 Получите информацию о клиентах для всех заказов
--Получите идентификатор заказа, идентификатор клиента, имя, фамилию и общую сумму (TotalDue) для
--всех заказов из таблицы SalesLT.SalesOrderHeader и функции dbo.ufnGetCustomerInformation.
--Необходимо отсортировать результаты по SalesOrderID
select soh.SalesOrderID, p.CustomerID, p.FirstName, p.LastName, soh.TotalDue from SalesLT.SalesOrderHeader as soh
CROSS APPLY dbo.ufnGetCustomerInformation(soh.CustomerID) as P
--2.2 Получите информацию об адресе клиента
--Получите идентификатор клиента, имя, фамилию, адресную строку 1 и город для всех клиентов из таблиц
--SalesLT.Address и SalesLT.CustomerAddress и функции dbo.ufnGetCustomerInformation. Необходимо
--отсортировать результаты по CustomerID.
select ca.CustomerID, p.FirstName, p.LastName, ad.AddressLine1, ad.City
from  SalesLT.CustomerAddress as ca
join SalesLT.Address as ad
on ca.AddressID = ad.AddressID
CROSS APPLY dbo.ufnGetCustomerInformation(ca.CustomerID) as P
order by p.CustomerID
