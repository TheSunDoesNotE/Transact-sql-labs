--1.1 Получение итоговой суммы продаж по клиенту
--Отдел продаж планирует ввести для клиентов ряд новых акций, которые зависят от потраченной
--клиентом суммы. Поэтому Вас просят написать функцию с именем fn_GetOrdersTotalDueForCustomer,
--принимающую один входной параметр @CustomerID (идентификатор клиента) и возвращающую
--общую сумму, потраченную клиентом на оплату всех заказов (т.е. сумму TotalDue). Приведите
--примеры использования написанной функции для клиентов с идентификаторами 1 и 30113.

CREATE OR ALTER FUNCTION dbo.fn_GetOrdersTotalDueForCustomer (@CustomerID int)
RETURNS float AS
BEGIN
	DECLARE @Result float
	SELECT @Result = SUM(TotalDue) FROM SalesLT.SalesOrderHeader WHERE CustomerID = @CustomerID
	RETURN @Result
END
GO

PRINT dbo.fn_GetOrdersTotalDueForCustomer(1)
PRINT dbo.fn_GetOrdersTotalDueForCustomer(30113)
GO

--1.2 Получение всех типов адресов клиентов
--Отдел продаж проводит ревизию адресов клиентов и Вам поручили создать представление
--vAllAddresses для отображения всех типов адресов всех клиентов. Представление должно содержать
--следующие атрибуты: CustomerID, AddressType, AddressID, AddressLine1, AddressLine2, City,
--StateProvince, CountryRegion, PostalCode. Протестируйте созданное представление.

CREATE VIEW SalesLT.vAllAddresses
WITH SCHEMABINDING
AS
	SELECT C.CustomerID, AddressType, Ad.AddressID, AddressLine1, AddressLine2, City, StateProvince, CountryRegion, PostalCode
	FROM SalesLT.Customer as C
	JOIN SalesLT.CustomerAddress as CA on CA.CustomerID = C.CustomerID
	JOIN SalesLT.Address as Ad on Ad.AddressID = CA.AddressID
GO

SELECT * FROM SalesLT.vAllAddresses
GO

--1.3 Получение всех адресов клиента
--Вам необходимо для оформления карточки клиента реализовать функцию
--fn_GetAddressesForCustomer, возвращающую все адреса для конкретного клиента (входной параметр
--@CustomerID – идентификатор клиента) из ранее созданного представления vAllAddresses.
--Возвращаемый набор данных должен содержать все доступные атрибуты из представления.
--Протестируйте созданную функцию – напишите запрос, возвращающий адреса клиентов в виде
--одного набора данных для клиентов с идентификаторами 0, 29502 и 29503.

CREATE OR ALTER FUNCTION dbo.fn_GetAddressesForCustomer (@CustomerID int)
RETURNS TABLE AS
RETURN (
	SELECT * FROM SalesLT.vAllAddresses WHERE CustomerID = @CustomerID
	)
GO

SELECT * FROM dbo.fn_GetAddressesForCustomer(29545)
UNION
SELECT * FROM dbo.fn_GetAddressesForCustomer(29502)
UNION
SELECT * FROM dbo.fn_GetAddressesForCustomer(29503)
GO

--1.4 Определение максимальной и минимальной суммы продажи товара
--Для получения статистики по продажам товаров компании Вас просят создать функцию
--fn_GetMinMaxOrderPricesForProduct, принимающую на вход идентификатор товара @ProductID и
--возвращающую строку с двумя столбцами: MinUnitPrice и MaxUnitPrice, содержащий соответственно
--минимальную и максимальную цену (из столбца UnitPrice) за которую был продан данный товар.
--Провести тестирование функции для товаров с идентификаторами 0 и 711.

CREATE FUNCTION dbo.fn_GetMinMaxOrderPricesForProduct (@ProductID int)
RETURNS TABLE AS
RETURN (
	SELECT MIN(UnitPrice) as MinUnitPrice, MAX(UnitPrice) as MaxUnitPrice
	FROM SalesLT.SalesOrderDetail
	WHERE ProductID = @ProductID
	)
GO

SELECT * FROM dbo.fn_GetMinMaxOrderPricesForProduct(0)
UNION
SELECT * FROM dbo.fn_GetMinMaxOrderPricesForProduct(809)
UNION
SELECT * FROM dbo.fn_GetMinMaxOrderPricesForProduct(711)
GO

--1.5 Получение всех описаний товара
--Отдел маркетинга хочет удостовериться, что все описания продаваемых товаров четко описывают
--информацию. Вас просят написать функцию fn_GetAllDescriptionsForProduct, которая возвращает все
--описания для товара. Функция принимает на вход идентификатор товара @ProductID и возвращает
--все найденные для данного товара описания в виде кортежей со следующими атрибутами: ProductID,
--Name, MinUnitPrice, MaxUnitPrice, ListPrice, ProductModel, Culture, Description. Здесь Name –
--наименование товара, MinUnitPrice, MaxUnitPrice – результат для товара из функции
--fn_GetMinMaxOrderPricesForProduct, ListPrice – розничная цена, ProductModel – поле Name из
--таблицы ProductModel, Culture – язык описания из таблицы ProductModelProductDescription,
--Description – описание из таблицы ProductDescription. Подсказка: используйте представление
--vProductAndDescription для сокращения количества соединений в запросе и улучшении его
--читаемости. Провести тестирование функции для товаров с идентификаторами 0 и 711.

CREATE FUNCTION dbo.fn_GetAllDescriptionsForProduct (@ProductID int)
RETURNS TABLE AS
RETURN (
	SELECT Pr.ProductID, Pr.Name, MinMax.MinUnitPrice, MinMax.MaxUnitPrice, ListPrice, ProductModel, Culture, Description
	FROM SalesLT.vProductAndDescription as PrDesc
	JOIN SalesLT.Product as Pr
	ON Pr.ProductID = PrDesc.ProductID
	JOIN dbo.fn_GetMinMaxOrderPricesForProduct(@ProductID) as MinMax
	ON Pr.ProductID = @ProductID
	)
GO

SELECT * FROM dbo.fn_GetAllDescriptionsForProduct(0)
UNION
SELECT * FROM dbo.fn_GetAllDescriptionsForProduct(809)
UNION
SELECT * FROM dbo.fn_GetAllDescriptionsForProduct(711)
GO

--2.1 Материализация представления vAllAddresses
--Включите параметры “Include Actual Execution Plan” и “Include Live Query Statistics” и выполните запрос
--SELECT * FROM [dbo] . [ vAllAddresses]
--Проанализируйте план выполнения запроса и убедитесь, что добавление индекса в представление
--должно улучшить план. Убедившись, что представление создано с опцией WITH SCHEMABINDING,
--добавьте уникальный кластерный индекс UIX_vAllAddresses на представление vAllAddresses, включив
--в него все атрибуты. После создания индекса еще раз выполните запрос (возможно, с опцией “WITH
--(NOEXPAND)”, т.е. SELECT * FROM [dbo] . [vAllAddresses] WITH (NOEXPAND)) и убедитесь, что план
--выполнения использует созданный Вами индекс.




SELECT * FROM SalesLT.vAllAddresses

CREATE UNIQUE CLUSTERED INDEX UIX_vAllAddresses ON SalesLT.vAllAddresses
(
	[CustomerID] ASC,
	[AddressType] ASC,
	[AddressID] ASC,
	[AddressLine1] ASC,
	[AddressLine2] ASC,
	[City] ASC,
	[StateProvince] ASC,
	[CountryRegion] ASC,
	[PostalCode] ASC
) ON [PRIMARY]

SELECT * FROM SalesLT.vAllAddresses WITH (NOEXPAND)