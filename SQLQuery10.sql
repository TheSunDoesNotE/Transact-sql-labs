--Задача 1: Создание скриптов для добавления заказов
--1. Напишите код для добавления заголовка заказа
--Ваш скрипт для добавления заголовка заказа должен позволять пользователям указывать значения для даты заказа(столбец OrderDate), 
--срока платежа(столбец DueDate)и идентификатора клиента(столбец CustomerID). Идентификатор SalesOrderIDдолжен быть сгенерирован автоматически 
--необходимо использовать следующее значениедля последовательности SalesLT.SalesOrderNumber и присваиваться переменной.
--Затем скрипт должен добавитьзапись в таблицу SalesLT.SalesOrderHeaderс использованием этих значений и жестко запрограммированногозначения «CARGOTRANSPORT5»
--для способадоставки и со значениями по умолчанию или NULL для всех остальных столбцов.
--После того, как скрипт добавил запись, он должен отобразить использованное значениеSalesOrderIDс помощью команды PRINT.
begin transaction

declare @OrderDate datetime = Getdate()
declare @DueDate datetime = DATEADD(d, 7, Getdate())
declare @CustomerID int = 1

declare @ID int = next value for SalesLT.SalesOrderNumber
print @ID

insert into SalesLT.SalesOrderHeader (SalesOrderID, CustomerID, OrderDate, DueDate, ShipMethod) 
values (@ID, @CustomerID, @OrderDate, @DueDate, 'CARGO TRANSPORT 5')

select * from SalesLT.SalesOrderHeader where SalesOrderID=@ID

--rollback transaction 

--2. Напишите код, добавляющий товар к заказу
--Скрипт для добавления товара в заказ должен позволять указывать идентификатор заказа,
--идентификатор товара, проданное количество товара и цену за единицу товара. Затем скрипт
--должен проверить, существует ли указанный идентификатор заказа в таблице
--SalesLT.SalesOrderHeader. Если существует, то скрипт должен добавить данные по товару в таблицу
--SalesLT.SalesOrderDetail (используя значения по умолчанию или NULL для неуказанных столбцов).
--Если идентификатор заказа не существует в таблице SalesLT.SalesOrderHeader, то скрипт должен
--выводить сообщение «Заказ не существует».
--begin transaction

declare @SalesOrderID int = @ID
declare @ProductID int = 760
declare @OrderQty smallint = 1
declare @UnitPrice money = 782.99

if exists (select SalesOrderID from SalesLT.SalesOrderHeader where SalesOrderID=@SalesOrderID)
begin
	insert into SalesLT.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice) values (@SalesOrderID, @ProductID, @OrderQty, @UnitPrice)
end
else
begin
	print 'Заказ не существует'
end
select * from SalesLT.SalesOrderDetail where SalesOrderID=@SalesOrderID

rollback transaction

--Задача 2: Обновление цен на велосипеды (категория «Bikes»)
--1. Напишите цикл WHILE, чтобы обновить цены на велосипеды
--Вам необходимо написать скрипт на
--Transact-SQL, который постепенно увеличивает цену (в столбце ListPrice) для всех велосипедов на
--10%, пока средняя цена велосипеда не будет по крайней мере такой же, как средняя по рынку, или
--пока самый дорогой велосипед не будет стоить выше приемлемой максимальной цены, указанной
--в потребительском исследовании.

begin transaction

declare @MaxPrice money = 5000
declare @AvgPrice money = 2000

while 
(@AvgPrice > (select AVG(ListPrice) from SalesLT.Product
where ProductCategoryID in (select ProductCategoryID
from SalesLT.vGetAllCategories where ParentProductCategoryName = 'Bikes')))
and
(@MaxPrice > (select MAX(ListPrice) from SalesLT.Product where ProductCategoryID in (select ProductCategoryID
from SalesLT.vGetAllCategories where ParentProductCategoryName = 'Bikes')))

begin

update SalesLT.Product set ListPrice = 1.1*ListPrice where ProductCategoryID in (select ProductCategoryID
from SalesLT.vGetAllCategories where ParentProductCategoryName = 'Bikes')

end

declare @a money = (select MAX(ListPrice) from SalesLT.Product where ProductCategoryID in (select ProductCategoryID
from SalesLT.vGetAllCategories where ParentProductCategoryName = 'Bikes'))
declare @b money = (select AVG(ListPrice) from SalesLT.Product as p 
where 
(select ParentProductCategoryName 
from SalesLT.vGetAllCategories as v where v.ProductCategoryID = p.ProductCategoryID) = 'Bikes')


print @a
print @b


rollback transaction
