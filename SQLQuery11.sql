--������ 1: �������������� ������
--1. ��������� ������ ��� �������������� �������
--� ��������� ����� ��� �������� ������ �� ������ ������������ ��������� ���:
--DECLARE @SalesOrderID int = <ID_������_���_��������>
--DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;
--DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;
--���� ��� ������ ����������� �������, ���� ���� ��������� ����� �� ����������. �������� ��� ���,
--����� ��������� ������������� ������ � ��������� ���������������, ������ ��� �������� ���
--�������. ���� ����� �� ����������, �� ��� ��� ������ ��������� ������: ������ #<SalesOrderID> ��
--����������. � ��������� ������ �� ������ ������� ������ �� ������.
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
	declare @ToString varchar(24) = '����� ' + CAST(@SalesOrderID AS varchar) + ' �� ����������'
	RAISERROR (@ToString, 16, 0);
END;

ROLLBACK TRAN

--2. ��������� ������
--������ ��� ��� ����������� ������, ���� ��������� ����� �� ����������. ������ �� ������ ��������
--���� ���, ����� ������� ��� (��� ����� ������) ������ � ������� ��������� �� ������ �
--���������������� ��������� � ������� ������� PRINT.
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
	declare @ToString varchar(24) = '����� ' + CAST(@SalesOrderID AS varchar) + ' �� ����������'
	RAISERROR (@ToString, 16, 0);
END;
END try
BEGIN CATCH
PRINT ERROR_MESSAGE();
THROW 50001, '��������� ������', 0;
END CATCH;

rollback tran

--������ 2: ����������� ��������������� ������
--1. ��������� ����������
--���������������� ��� ���, ��������� � ���������� �������, ����� ��� ��������� DELETE
--��������������� ��� ������ ����������. � ����������� ������ �������� ��� ���, �����, ����
--���������� ��������� � �������� ����������, ��� �� ����������, � ������ �������������� �

BEGIN TRANSACTION

DECLARE @SalesOrderID int = 71782
BEGIN TRY
if (exists(select SalesOrderID from SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID))
begin
begin tran

	DELETE FROM SalesLT.SalesOrderDetail WHERE SalesOrderID = @SalesOrderID;
	THROW 50001, '��������� ������', 0;
	DELETE FROM SalesLT.SalesOrderHeader WHERE SalesOrderID = @SalesOrderID;

commit tran
end
else
begin
	declare @ToString varchar(24) = '����� ' + CAST(@SalesOrderID AS varchar) + ' �� ����������'
	RAISERROR (@ToString, 16, 0);
end;
end try

begin catch
if @@TRANCOUNT > 0
begin
	ROLLBACK TRAN
END
	PRINT ERROR_MESSAGE();
	THROW 50001, '��������� ������', 0
end catch;

rollback tran
