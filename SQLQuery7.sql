--Задача 1: Получение данных о товаре
--1. Получите описания модели товара
--Получите идентификатор товара, название товара (столбец ProductName), название модели товара (столбец
--ProductModel) и описание модели товара (столбец Summary) для каждого товара из таблицы SalesLT.Product и
--отображения SalesLT.vProductModelCatalogDescription, упорядочив результаты по идентификатору товара.
select p.ProductID, p.Name as ProductName, scr.Name as ProductModel, scr.Summary from SalesLT.Product as p
join SalesLT.vProductModelCatalogDescription as scr
on p.ProductModelID = scr.ProductModelID
order by p.ProductID
--2. Создайте таблицу с уникальными цветами
--Создайте табличную переменную и заполните ее списком уникальных цветов из таблицы SalesLT.Product. Затем
--используйте табличную переменную, чтобы отфильтровать запрос, который возвращает идентификатор товара,
--название товара (столбец ProductName) и цвет (столбец Color) из таблицы SalesLT.Product, упорядочивая по
--цветам так, чтобы возвращались только те товары, цвета которых перечислены в табличной переменной.
declare @Colors as table (Color varchar(20))
insert into @Colors
select distinct Color from SalesLT.Product
--select Color from @Colors
select ProductID, Name, Color from SalesLT.Product
where Color in (select Color from @Colors)
order by Color
--3. Создайте таблицу с уникальными размерами
--Создайте временную таблицу и заполните ее списком уникальных размеров из таблицы SalesLT.Product. Затем
--используйте временную таблицу, чтобы отфильтровать запрос, который возвращает идентификатор товара,
--название товара (столбец ProductName) и размер (столбец Size) из таблицы SalesLT.Product, упорядочивая по
--размерам по убыванию так, чтобы возвращались только те товары, размеры которых перечислены во временной
--таблице.
create table #Sizes
(Sizes varchar(5))
insert into #Sizes
select distinct Size from SalesLT.Product
select ProductID, Name, Size from SalesLT.Product
where size in (select Size from #Sizes)
order by Size desc
DROP TABLE #Sizes;

--4. Получите родительские категории товаров
--БД AdventureWorksLT содержит табличную функцию dbo.ufnGetAllCategories, которая возвращает таблицу
--товарных категорий (например «Road Bikes») и их родительских категорий (например «Bikes»). Напишите запрос,
--которых использует эту функцию, чтобы вернуть список всех товаров (столбцы ProductID, ProductName) включая их
--родительские категории (столбец ParentCategory) и категории (столбец Category), упорядоченные по
--соответствующему полному пути категорий (т.е. названию категории, включая название родительской категории)
--и названию товара.
select pr.ProductID, pr.Name as ProductName, f.ParentProductCategoryName as ParentCategory, f.ProductCategoryName as Category from SalesLT.Product as pr
join dbo.ufnGetAllCategories() as f
on pr.ProductCategoryID=f.ProductCategoryID
order by ParentCategory, Category, ProductName

--Задача 2: Получение информации по доходам от продаж клиентам
--1. Получите доходы от продаж по клиентам и контактные данные (используйте производные таблицы)
--Получите список клиентов в формате “Название_Компании (Имя_Контакта Фамилия_Контакта)” в столбце
--CompanyContact (например, значение может быть “Action Bicycle Specialists (Terry Eminhizer)”), значение
--полученной выручки (сумма значений TotalDue) для этого клиента (столбец Revenue). Используйте производную
--таблицу, чтобы получить сведения по каждому заказу и затем постройте запрос к полученной производной
--таблице, чтобы сгруппировать данные. Результаты должны быть упорядочены по значениям в CompanyContact.
select CompanyContact, sum(TotalDue) as Revenue from
(select (CompanyName + ' ('+ FirstName + ' ' + LastName + ')') as CompanyContact, TotalDue from SalesLT.Customer as cu
join SalesLT.SalesOrderHeader as so
on cu.CustomerID = so.CustomerID) as cn
group by CompanyContact
order by CompanyContact

--2. Получите доходы от продаж по клиентам и контактные данные (используйте CTE – обобщенные табличные выражения)
--Перепишите предыдущий запрос с помощью CTE (обобщенного табличного выражения) вместо производных
--таблиц.
with Client (CompanyContact, TotalDue)
as
(
select (CompanyName + ' ('+ FirstName + ' ' + LastName + ')') as CompanyContact, so.TotalDue from SalesLT.Customer as cu
join SalesLT.SalesOrderHeader as so
on cu.CustomerID = so.CustomerID
)
select CompanyContact, sum(TotalDue) as Revenue from Client
group by CompanyContact
order by CompanyContact