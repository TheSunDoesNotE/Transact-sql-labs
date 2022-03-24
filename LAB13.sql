--1.1 Напишите код проверки выполнения правила ограничения цен.
-- Напишите код проверки выполнения правила ограничения цен.
--Поскольку перед вводом ограничения в БД необходимо убедиться, что текущие данные
--удовлетворяют введенному правилу Вам необходимо написать код, который бы возвращал список
--товаров (все столбцы из таблицы Product), которые нарушают указанное правило. Если такие товары
--обнаружатся – необходимо вывести надпись ‘Правило 20-кратной разницы в цене нарушено у
--<количество> товаров’, в противном случае вывести 'Правило 20-кратной разницы в цене
--соблюдено'.
SELECT * FROM SalesLT.Product as Pr
WHERE (ListPrice > (SELECT MIN(ListPrice) * 20 FROM SalesLT.Product WHERE ProductCategoryID = Pr.ProductCategoryID))
OR (ListPrice < (SELECT MAX(ListPrice) / 20 FROM SalesLT.Product WHERE ProductCategoryID = Pr.ProductCategoryID))
DECLARE @Rows int = @@ROWCOUNT

IF (@Rows <> 0) PRINT N'Правило 20-кратной разницы в цене нарушено у ' + CAST(@Rows as nvarchar(20)) + N' товаров'
ELSE PRINT N'Правило 20-кратной разницы в цене соблюдено'
GO

--1.2 Создайте триггер для обеспечения правила 20-кратной разницы в отпускной цене
--Вам поручили написать триггер с именем SalesLT.TriggerProductListPriceRules, который должен
--поддерживать в БД правило 20-кратной разницы в отпускной цене товаров из одной рубрики.
--Основное назначение триггера – отменять изменения данных, которые нарушают правило 20-кратной
--разницы в цене, оповещая при этом пользователя выбрасыванием ошибки с номером 50001 и
--сообщением ‘Вносимые изменения нарушают правило 20-кратной разницы в цене товаров из одной
--рубрики (слишком дешево)’ или ‘Вносимые изменения нарушают правило 20-кратной разницы в цене
--товаров из одной рубрики (слишком дорого)’.
--CREATE 
Create or Alter TRIGGER SalesLT.TriggerProductListPriceRules ON SalesLT.Product
AFTER INSERT, UPDATE AS
BEGIN
IF EXISTS(SELECT * FROM inserted as Ins
WHERE (Ins.ListPrice > (SELECT MIN(ListPrice) * 20 FROM SalesLT.Product WHERE ProductCategoryID = Ins.ProductCategoryID)))
BEGIN
ROLLBACK;
THROW 50001, N'Вносимые изменения нарушают правило 20-кратной разницы в цене товаров из одной рубрики (слишком дорого)', 1;
END
ELSE IF EXISTS(SELECT * FROM inserted as Ins
WHERE (Ins.ListPrice < (SELECT MAX(ListPrice) / 20 FROM SalesLT.Product WHERE ProductCategoryID = Ins.ProductCategoryID)))
BEGIN
ROLLBACK;
THROW 50001, N'Вносимые изменения нарушают правило 20-кратной разницы в цене товаров из одной рубрики (слишком дешево)', 1;
END
END
GO

--1.3 Протестируйте созданный триггер

DECLARE
@Minimum float = (SELECT MIN(ListPrice) FROM SalesLT.Product WHERE ProductCategoryID = 5),
@Maximum float = (SELECT MAX(ListPrice) FROM SalesLT.Product WHERE ProductCategoryID = 5)

PRINT N'Минимальная цена: ' + CAST(@Minimum as nvarchar(20)) + N', максимальная цена: ' + CAST(@Maximum as nvarchar(20))

BEGIN TRY
INSERT INTO SalesLT.Product(Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
VALUES ('Golden Bike', 'GB-15000', 1, 15000, 5, GETDATE())
END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

BEGIN TRY
	INSERT INTO SalesLT.Product(Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
	VALUES ('Toy Bike', 'TB-50', 1, 50, 5, GETDATE())
END TRY

BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

SELECT Name, ProductNumber, ListPrice FROM SalesLT.Product WHERE ProductCategoryID = 5
ORDER BY ListPrice ASC
GO

--2.1 Создание триггеров
--Вам необходимо создать два AFTER-триггера TriggerProduct и TriggerProductCategory: по одному для
--каждой из таблиц Product и ProductCategory для поддержания ссылочной целостности между этими
--таблицами по полю ProductCategoryID. Соответственно, триггеры должны выбрасывать ошибку 50002
--с описанием ‘Ошибка: попытка нарушения ссылочной целостности между таблицами Product и
--ProductCategory, транзакция отменена’ (в TriggerProduct состояние 0, в TriggerProductCategory –
--состояние 1).
CREATE OR ALTER TRIGGER Trigger_Product ON SalesLT.Product
AFTER INSERT, UPDATE, DELETE AS
BEGIN
	IF (SELECT ProductCategoryID FROM inserted) NOT IN (SELECT ProductCategoryID FROM SalesLT.ProductCategory)
	BEGIN
		ROLLBACK;
		THROW 50002, N'Ошибка: попытка нарушения ссылочной целостности между таблицами Product и ProductCategory, транзакция отменена', 0;
	END
END
GO

CREATE OR ALTER TRIGGER Trigger_ProductCategory ON SalesLT.ProductCategory
AFTER INSERT, UPDATE, DELETE AS
BEGIN
	IF ((SELECT ProductCategoryID FROM deleted) IN (SELECT ProductCategoryID FROM SalesLT.Product))
	BEGIN
		ROLLBACK;
		THROW 50002, N'Ошибка: попытка нарушения ссылочной целостности между таблицами Product и ProductCategory, транзакция отменена', 1;
	END
END
GO

--2.2 Тестирование триггеров
--Для тестирования триггеров Вы временно отключаете проверку ограничения на основе внешнего
--ключа (после обновления диаграммы связь между таблицами становится пунктирной):
--ALTER TABLE SalesLT.Product NOCHECK CONSTRAINT FK_Product_ProductCategory_ProductCategoryID;
--Необходимо попытаться добавить запись о любом новом товаре с ProductCategoryID=-1 в таблицу
--Product и убедиться, что Вы получите сообщение об ошибке из триггера. Затем Вам нужно попытаться
--удалить запись о категории с ProductCategoryID=5 из таблицы ProductCategory и убедиться, что Вы
--также получите сообщение об ошибке из триггера.
ALTER TABLE SalesLT.Product NOCHECK CONSTRAINT FK_Product_ProductCategory_ProductCategoryID;

BEGIN TRY
	INSERT INTO SalesLT.Product(Name, ProductNumber, StandardCost, ListPrice, ProductCategoryID, SellStartDate)
	VALUES ('Unknown', 'Unknown', 1, 1, -1, GETDATE())
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

BEGIN TRY
	DELETE FROM SalesLT.ProductCategory WHERE ProductCategoryID = 7
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE();
END CATCH

--2.3 Восстановление внешнего ключа и отключение триггеров


-- включение проверки внешнего ключа
ALTER TABLE SalesLT.Product CHECK CONSTRAINT FK_Product_ProductCategory_ProductCategoryID;

-- отключение триггеров
DISABLE TRIGGER SalesLT.Trigger_Product ON SalesLT.Product;
DISABLE TRIGGER SalesLT.Trigger_ProductCategory ON SalesLT.ProductCategory;