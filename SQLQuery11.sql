--Задача 1: Журналирование ошибок
--1. Выбросите ошибку для несуществующих заказов
--В настоящее время для удаления данных по заказу используется следующий код:
--DECLARE @SalesOrderID int = <ID_заказа_для_удаления>
--DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;
--DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;
--Этот код всегда выполняется успешно, даже если указанный заказ не существует. Измените код так,
--чтобы проверить существование заказа с указанным идентификатором, прежде чем пытаться его
--удалить. Если заказ не существует, то Ваш код должен выбросить ошибку: «Заказ #<SalesOrderID> не
--существует». В противном случае он должен удалить данные по заказу.
--SELECT SalesOrderID FROM SalesLT.SalesOrderDetail 

BEGIN TRANSACTION

DECLARE @SalesOrderID int = 7178
IF (EXISTS(SELECT SalesOrderID FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID))
BEGIN
	DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;
	DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;
END
ELSE
BEGIN
	declare @ToString varchar(24) = 'Заказ ' + CAST(@SalesOrderID AS varchar) + ' не существует'
	RAISERROR (@ToString, 16, 0);
END;

ROLLBACK TRAN

--2. Обработка ошибок
--Сейчас Ваш код выбрасывает ошибку, если указанный заказ не существует. Теперь Вы должны дописать
--свой код, чтобы поймать эту (или любую другую) ошибку и вывести сообщение об ошибке в
--пользовательский интерфейс с помощью команды PRINT.
BEGIN TRANSACTION

DECLARE @SalesOrderID int = 7178
BEGIN TRY
IF (EXISTS(SELECT SalesOrderID FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID))
BEGIN
	DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;
	DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;
END
ELSE
BEGIN
	declare @ToString varchar(24) = 'Заказ ' + CAST(@SalesOrderID AS varchar) + ' не существует'
	RAISERROR (@ToString, 16, 0);
END;
END try
BEGIN CATCH
PRINT ERROR_MESSAGE();
THROW 50001, 'Произошла ошибка', 0;
END CATCH;

rollback tran

--Задача 2: Обеспечение согласованности данных
--1. Внедрение транзакций
--Усовершенствуйте Ваш код, созданный в предыдущем задании, чтобы два оператора DELETE
--рассматривались как единая транзакция. В обработчике ошибок измените код так, чтобы, если
--транзакция находится в процессе выполнения, она бы отменялась, и ошибка пробрасывалась в

BEGIN TRANSACTION

DECLARE @SalesOrderID int = 71782
BEGIN TRY
if (exists(select SalesOrderID from SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID))
begin
begin tran

	DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;
	THROW 50001, 'Произошла ошибка', 0;
	DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;

commit tran
end
else
begin
	declare @ToString varchar(24) = 'Заказ ' + CAST(@SalesOrderID AS varchar) + ' не существует'
	RAISERROR (@ToString, 16, 0);
end;
end try

begin catch
if @@TRANCOUNT > 0
begin
	ROLLBACK TRAN
END
	PRINT ERROR_MESSAGE();
	THROW 50001, 'Произошла ошибка', 0
end catch;

rollback tran
