--Задача 1: Получение итогов продаж по регионам
---1. Получите итоги для страны/региона и штата/провинции
-- В существующем отчете используется следующий запрос, 
--чтобы вернуть общий доход от продаж, сгруппированный по стране/региону и штату/провинции
SELECT a.CountryRegion, a.StateProvince, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
INNER JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY 
Grouping sets (a.CountryRegion, (a.CountryRegion, a.StateProvince), ())
ORDER BY a.CountryRegion, a.StateProvince;

---2. Укажите уровни группировки в результатах
--Измените свой предыдущий запрос, чтобы включить столбец с именем «Level», который указывает, 
--на каком уровне в иерархии отображается показатель дохода в строке:итоговом,страна/регион и штат/провинция.
SELECT a.CountryRegion, a.StateProvince,GROUPING_ID(a.CountryRegion, a.StateProvince)as Lavel, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
INNER JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY 
Grouping sets (a.CountryRegion, a.StateProvince, ())
ORDER BY a.CountryRegion, a.StateProvince;

--3. Добавьте уровень группировки для городов
--Расширьте свой предыдущий запрос, чтобы включить столбец «City» (после столбца StateProvince) и группировку
--для отдельных городов. Измените правила для столбца «Level» так, чтобы строка, показывающая промежуточный
--итог для города Лондон, содержала значение «London Subtotal». Добавьте столбец City в выражение сортировки
--результатов.
SELECT a.CountryRegion, a.StateProvince,City, 
choose (GROUPING_ID(a.CountryRegion, a.StateProvince),city +'subtotal',a.StateProvince + 'subtotal', a.CountryRegion + 'subtotal', 'Total')as Level, SUM(soh.TotalDue) AS Revenue
FROM SalesLT.Address AS a
INNER JOIN SalesLT.CustomerAddress AS ca ON a.AddressID = ca.AddressID
INNER JOIN SalesLT.Customer AS c ON ca.CustomerID = c.CustomerID
INNER JOIN SalesLT.SalesOrderHeader as soh ON c.CustomerID = soh.CustomerID
GROUP BY 
Grouping sets (a.CountryRegion, a.StateProvince, City, ())
ORDER BY a.CountryRegion, a.StateProvince, City;

--Задача 2: Получение доходов от продаж по категориям 
--1. Получите доход от продаж для каждой родительской категории
--Получите список названийкомпаний-клиентов (столбец CompanyName), их общийдоход (сумма значенийLineTotalв таблице SalesLT.SalesOrderDetail)
--для каждой родительской категории в разделахAccessories, Bikes, ClothingиComponents(в соответствующихстолбцах Accessories, Bikes, Clothingи Components).
--Отсортируйте результаты запроса по названию компании.
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