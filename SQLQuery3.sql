--1.1 Получите заказы клиентов
--В качестве первого шага по созданию отчета по счетам напишите запрос, который возвращает
--название компании (CompanyName) из таблицы SalesLT.Customer, а также идентификатор заказа
--(SalesOrderID) и итоговую стоимость (TotalDue) из таблицы SalesLT.SalesOrderHeader.
SELECT cn.CompanyName, so.SalesOrderID, so.TotalDue 
FROM SalesLT.Customer AS cn 
Join SalesLT.SalesOrderHeader AS so 
ON cn.CustomerID=so.CustomerID
--1.2Получите заказы клиентов с адресами
--Расширьте свой предыдущий запрос по заказам клиентов, чтобы включить в него адрес главного
--офиса для каждого клиента, включая полный адрес (столбцы AddressLine1 и AddressLine2), город
--(City), штат или провинцию (StateProvince), почтовый индекс (PostalCode) и страну/регион
--(CountryRegion).
SELECT c.CompanyName, oh.SalesOrderID, oh.TotalDue, a.AddressLine1, a.AddressLine2, a.City, a.StateProvince, a.PostalCode, a.CountryRegion
FROM SalesLT.Customer AS c 
JOIN SalesLT.SalesOrderHeader AS oh
ON oh.CustomerID=c.CustomerID
JOIN SalesLT.CustomerAddress AS ca
ON c.CustomerID=ca.CustomerID AND AddressType = 'Main Office' 
JOIN SalesLT.[Address] AS a
ON ca.AddressID=a.AddressID
--2.1 Получить список всех клиентов и их заказов
--Менеджер по продажам просит составить список всех компаний-клиентов (CompanyName) с их
--именами и контактами (имя и фамилия – FirstName и LastName), который бы показывал
--идентификатор заказа (SalesOrderID) и общую сумму (TotalDue) за каждый заказ, который
--разместили клиенты. Клиенты, которые не разместили заказы, должны быть включены в нижней
--части списка со значениями NULL для идентификатора заказа и общей суммы.
SELECT c.CompanyName, c.FirstName, c.LastName, o.SalesOrderID, o.TotalDue FROM SalesLT.Customer as c
LEFT JOIN SalesLT.SalesOrderHeader AS o
ON c.CustomerID = o.CustomerID
ORDER BY o.CustomerID DESC

--2.2 Получить список клиентов без адреса
--Сотрудник отдела продаж заметил, что Adventure Works не имеет информации по адресам для
--всех клиентов. Вы должны написать запрос, который возвращает список идентификаторов
--клиентов, названий компаний, имен контактов (имя и фамилия) и номера телефонов для
--клиентов, не имеющих адреса.
SELECT c.CustomerID, c.CompanyName, c.FirstName, c.LastName, c.Phone FROM SalesLT.Customer AS c
JOIN SalesLT.CustomerAddress AS ca
ON c.CustomerID = ca.CustomerID
JOIN SalesLT.[Address] AS ad
ON ca.AddressID = ad.AddressID AND ad.AddressLine2 IS NULL
 
--2.3 Получить список клиентов и товаров
--Создайте запрос, который возвращает столбец идентификаторов клиентов (CustomerID) для
--клиентов, которые никогда не размещали заказы, и столбец идентификаторов товаров (ProductID)
--для товаров, которые никогда не были заказаны. Каждая строка с идентификатором клиента
--должна иметь идентификатор продукта NULL (поскольку клиент никогда не заказывал продукт), и
--каждая строка с идентификатором товара должна иметь идентификатор клиента NULL (поскольку
--товар никогда не заказывался клиентом).
SELECT c.CustomerID, pr.ProductID FROM SalesLT.Customer AS c
FULL JOIN SalesLT.SalesOrderHeader AS o
ON c.CustomerID = o.CustomerID 
FULL JOIN SalesLT.SalesOrderDetail AS so
ON o.SalesOrderID = so.SalesOrderID 
FULL JOIN SalesLT.Product AS pr 
ON so.ProductID = pr.ProductID 
WHERE c.CustomerID IS NULL OR pr.ProductID IS NULL

