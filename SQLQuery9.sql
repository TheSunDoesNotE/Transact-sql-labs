--Задача 1: Добавление товаров
--1. Добавьте товар
--Компания AdventureWorksначала продавать новый товар. Добавьте его в таблицу SalesLT.Product, 
--используя значения по умолчанию или NULL для неуказанных столбцов 
--(используйте синтаксис с явно указанными именами столбцов):

insert into SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate) values ('LED Lights', 'LT-L123', 2.56, 12.99, 37, GETDATE())
select ProductID from SalesLT.Product where ProductNumber= 'LT-L123'
select * from SalesLT.Product where ProductNumber= 'LT-L123'

delete from SalesLT.Product where Name = 'LED Lights'

--2. Добавьте новую товарную категорию с двумя товарами
--Компания AdventureWorksдобавляет в свой каталог категорию товаров«BellsandHorns».
--Идентификатор родительскойкатегориидля новой категории =4 (Accessories). 
--Эта новая категория включает в себя следующие два новых товара:

--insert into SalesLT.ProductCategory (Name, ParentProductCategoryID) values ('Bells and Horns', 4)

--declare @id int = SCOPE_IDENTITY()
--insert into SalesLT.Product (Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate) 
--values ('Bicycle Bell', 'BB-RING', 2.47, 4.99, @id, GETDATE()),
--('Bicycle Horn', 'BB-PARP', 1.29, 3.75, @id, GETDATE())

--select p.Name, p.ProductNumber, p.StandardCost, p.ListPrice, p.ProductCategoryID, p.SellStartDate, c.ProductCategoryID, c.ParentProductCategoryID 
--from SalesLT.Product as p
--join SalesLT.ProductCategory as c
--on c.ProductCategoryID = p.ProductCategoryID
--where (ParentProductCategoryID = ident_current('SalesLT.ProductCategory'))

--Задача 2: Обновление информации по товарам
--1. Обновление цен на товары
--Менеджер по продажам в компании AdventureWorksпринял решение на10%повысить ценыдля всех товаровизкатегории «BellsandHorns». 
--Обновите строки в таблице SalesLT.Productдля этих товаров, 
--чтобы увеличить их цену (столбец ListPrice) на 10% (ссылайтесь накатегориютоваровпо названию)

update SalesLT.Product
set ListPrice = 1.1*(ListPrice)
where ProductCategoryID = (select ProductCategoryID from SalesLT.ProductCategory where Name = 'Bells and Horns')

--2. Прекращение продаж товаров
--Новый товар «LEDLights», который вы добавили первой задаче, должен заменить все предыдущие световые продукты. 
--Обновите таблицу SalesLT.Product, чтобы установить значение «сегодня»в поле DiscontinuedDateдля 
--всех товаровв категории «Lights» (ссылайтесь через ProductCategoryID= 37), 
--кроме товара «LEDLights», который вы добавилиранее (ссылайтесь черезProductNumber«LT-L123»)

update SalesLT.Product
set DiscontinuedDate = getdate()
where ((ProductCategoryID = 37) and (ProductNumber != 'LT-L123'))

--Задача 3: Удаление товаров
--1. Удалить категорию товаров и товары в ней
--Удалите записи категории «BellsandHorns» и ее товаров. Вы должны убедиться, 
--что вы удаляете записи из таблиц в правильном порядке, 
--чтобы избежать нарушения ограниченийвнешнего ключа (ссылайтесь на категорию товаровпоимени).
delete from SalesLT.Product where ProductCategoryID = (select ProductCategoryID from SalesLT.ProductCategory where Name = 'Bells and Horns')
delete from SalesLT.ProductCategory where Name = 'Bells and Horns'

