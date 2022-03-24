--������ 1: ����� �������� � �������
--1. �������� ��� ��� ��������� ���� ��������� �������� � ������� �������
--��������� ������ ������ ��� ���������� ������ � ��������� �������� �������, ��� ����������
--�������� ������ ���� �������� �������� �� ��������� ����� (char, nchar, varchar, nvarchar, text,
--ntext) �� ������� �������. ��������� �� ������ �������� ���, ��������� ��� ������ ������ �
--����� ��������, �� ���������� ������� �� ������������� �������� ������� � �������� �����
--�� �� ��������� ����������). � ���������� �� ������ ������� ������� �� ���������
--ColumnName (�������� �������) � Type (��� ������ �������), ���������� ������ ���������
--�������. �������� ������ ��� ������� SalesLT.Product.

DECLARE @Name AS NVARCHAR(20) = 'Product'
DECLARE @Schema AS NVARCHAR(20) = 'SalesLT'

--print @Name

SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
WHERE (DATA_TYPE = 'nvarchar' or DATA_TYPE ='char' or DATA_TYPE ='nchar' or DATA_TYPE ='varchar' or DATA_TYPE ='nvarchar' or DATA_TYPE ='text'
or DATA_TYPE = 'ntext')
 and TABLE_NAME = @Name
  AND table_schema = @Schema

  GO

--2. �������� ���, ��� ������ �������� � ��������� �������� �������
--�� ����������� ������� ��� ����� �������� ��� ��������� ������� �������, � ������� ����
--������������ �����. ������ �� ������� �������� SQL-������ ��� �������� ������ SQL-�������,
--������� ��������� �� �� ������ �� �������, ������� �������� ������� �������� � �����
--��������� �������. ���� �� ������ ������ �� ����������� �������, �������� SQL-������ ���
--������ ������������� �������� (��������� � �������� ��� ������ ���������� �������� �����
--����������) � ��������� ������� (������) ������������ ������� (�������������� ������ ������
--���������� ��� ������� �� �������). �� ������� ������������ �� ������� � ��� ����� ���
--���������� ������� ����� ��������������� SQL-������� �� ����� � ������� ��������� PRINT

DECLARE @Name AS NVARCHAR(20) = 'Product'
DECLARE @Schema AS NVARCHAR(20) = 'SalesLT'
DECLARE @column AS NVARCHAR(2000)
DECLARE @Ask AS NVARCHAR(2000)
DECLARE @stringToFind AS NVARCHAR(2000) = 'Bike'

DECLARE c1 CURSOR LOCAL FAST_FORWARD
FOR
	SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
	WHERE (DATA_TYPE = 'nvarchar' or DATA_TYPE ='char' or DATA_TYPE ='nchar' or DATA_TYPE ='varchar' or DATA_TYPE ='nvarchar' or DATA_TYPE ='text'
	or DATA_TYPE = 'ntext')
	and TABLE_NAME = @Name
	AND table_schema = @Schema
OPEN c1
WHILE (1=1)
BEGIN

FETCH c1 into @column
IF @@fetch_status <> 0 BREAK
SET @Ask = 'select ['+ @column + '] from ['+@Schema+'].['+ @Name+ '] where ['+@column+'] like '+ '''%' + @stringToFind + '%'''
EXEC (@Ask)
END

CLOSE c1
DEALLOCATE c1

go
--������ 2: ����� �������� �� ���� ��
--1. �������� �������� ���������
--�� ������� �������� ���������, ���������� � ������ ������, � ���� �������� ��������� �
--������ SalesLT.uspFindStringInTable. �� ���� ��������� ������ ��������� ��� ��������� ���������:
-- @schema sysname � ��� �����
--� @table sysname � ��� �������
--� @stringToFind nvarchar(2000) � ���������, ������� ���������� ����� � �������
--� �������� ���������� �������� ��������� ������ ���������� ����� ������, ��������� �� ����
--�������� ������� � �����, � ������� ���� ������� �������� ���������. ������������� ��������
--��������� ������ ���������� � �������� ���� �������� (RETURN) ���������� ����� �
--�������������� �������. ������������� �������� ��������� � ������� �� ������� 1 .2.

CREATE OR ALTER PROCEDURE SalesLT.uspFindStringInTable 
@schema sysname, @table sysname, @stringToFind NVARCHAR(2000)
AS
DECLARE @count int = 0
DECLARE @column AS NVARCHAR(2000)
DECLARE @Ask AS NVARCHAR(2000)=''

declare c1 cursor LOCAL FAST_FORWARD
for
	select COLUMN_NAME from INFORMATION_SCHEMA.COLUMNS
	where (DATA_TYPE = 'nvarchar' or DATA_TYPE ='char' or DATA_TYPE ='nchar' or DATA_TYPE ='varchar' or DATA_TYPE ='nvarchar' or DATA_TYPE ='text'
	or DATA_TYPE = 'ntext')
	and TABLE_NAME = @table
	and table_schema = @Schema
open c1
while (1=1)
begin

fetch c1 into @column
if @@fetch_status <> 0 break
if @Ask<>''
set @Ask = @Ask +' or '

set @Ask = @Ask + '['+@column+'] like '+ '''%' + @stringToFind + '%'''



end
close c1
deallocate c1
set @Ask = 'select * from ['+@Schema+'].['+ @table+ '] where ' + @Ask
print @ask
exec (@Ask)


return @@rowcount
go
declare @a int
exec @a = SalesLT.uspFindStringInTable 'SalesLT', 'Product', 'Bike'
print @a

select * from SalesLT.Product where [Name] like '%Bike%' or  [ProductNumber] like '%Bike%'


--2. �������� ������ �� ������ �������� � ��
--������ �������� ��������� ��� ������ ��������� � ������� �� ������ �� ���� �������������
--���������� �������� �������� �� �� ������ ���� ������ �� ���� ������ � ������ ��������� ����� ��
--���� ��������. ���������� ������ �� ���� �� ���� ���������� ������ ������������ � ���������
--����: ��� ������ �� ������, � ������� �� ����� ���������, � ������ ������ ��������� ���� ��
--������� (������������ PRINT):
--� � ������� <�����>.<���_�������> �� ������� ����� ����������
--� � ������� <�����>.<���_�������> ������� �����: < ����������>



set noCount on

DECLARE @schema nvarchar(2000)
DECLARE @tablename nvarchar(2000)
DECLARE @Ask as nvarchar(2000)

DECLARE @search nvarchar(2000) = 'Bike'

DECLARE @rowscount int
DECLARE c2 CURSOR LOCAL FAST_FORWARD
FOR
	SELECT DISTINCT TABLE_SCHEMA, TABLE_NAME from INFORMATION_SCHEMA.COLUMNS

OPEN c2
while (1=1)
begin

FETCH c2 into @schema, @tablename

IF @@fetch_status <> 0 BREAK

BEGIN TRY

EXEC @rowscount = SalesLT.uspFindStringInTable @schema, @tablename, @search

END TRY
BEGIN CATCH

PRINT '������ �������';
PRINT ERROR_MESSAGE();

END CATCH;

IF @rowscount <> 0
	PRINT '� ������� '+@schema+'.'+@tablename+' ������� �����: '+Cast(@rowscount as nvarchar(2000))
IF @rowscount = 0
	PRINT '� ������� '+@schema+'.'+@tablename+' �� ������� ����� ����������'

END

CLOSE c2
DEALLOCATE c2

