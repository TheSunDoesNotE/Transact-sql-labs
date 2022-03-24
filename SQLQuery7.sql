--������ 1: ��������� ������ � ������
--1. �������� �������� ������ ������
--�������� ������������� ������, �������� ������ (������� ProductName), �������� ������ ������ (�������
--ProductModel) � �������� ������ ������ (������� Summary) ��� ������� ������ �� ������� SalesLT.Product �
--����������� SalesLT.vProductModelCatalogDescription, ���������� ���������� �� �������������� ������.
select p.ProductID, p.Name as ProductName, scr.Name as ProductModel, scr.Summary from SalesLT.Product as p
join SalesLT.vProductModelCatalogDescription as scr
on p.ProductModelID = scr.ProductModelID
order by p.ProductID
--2. �������� ������� � ����������� �������
--�������� ��������� ���������� � ��������� �� ������� ���������� ������ �� ������� SalesLT.Product. �����
--����������� ��������� ����������, ����� ������������� ������, ������� ���������� ������������� ������,
--�������� ������ (������� ProductName) � ���� (������� Color) �� ������� SalesLT.Product, ������������ ��
--������ ���, ����� ������������ ������ �� ������, ����� ������� ����������� � ��������� ����������.
declare @Colors as table (Color varchar(20))
insert into @Colors
select distinct Color from SalesLT.Product
--select Color from @Colors
select ProductID, Name, Color from SalesLT.Product
where Color in (select Color from @Colors)
order by Color
--3. �������� ������� � ����������� ���������
--�������� ��������� ������� � ��������� �� ������� ���������� �������� �� ������� SalesLT.Product. �����
--����������� ��������� �������, ����� ������������� ������, ������� ���������� ������������� ������,
--�������� ������ (������� ProductName) � ������ (������� Size) �� ������� SalesLT.Product, ������������ ��
--�������� �� �������� ���, ����� ������������ ������ �� ������, ������� ������� ����������� �� ���������
--�������.
create table #Sizes
(Sizes varchar(5))
insert into #Sizes
select distinct Size from SalesLT.Product
select ProductID, Name, Size from SalesLT.Product
where size in (select Size from #Sizes)
order by Size desc
DROP TABLE #Sizes;

--4. �������� ������������ ��������� �������
--�� AdventureWorksLT �������� ��������� ������� dbo.ufnGetAllCategories, ������� ���������� �������
--�������� ��������� (�������� �Road Bikes�) � �� ������������ ��������� (�������� �Bikes�). �������� ������,
--������� ���������� ��� �������, ����� ������� ������ ���� ������� (������� ProductID, ProductName) ������� ��
--������������ ��������� (������� ParentCategory) � ��������� (������� Category), ������������� ��
--���������������� ������� ���� ��������� (�.�. �������� ���������, ������� �������� ������������ ���������)
--� �������� ������.
select pr.ProductID, pr.Name as ProductName, f.ParentProductCategoryName as ParentCategory, f.ProductCategoryName as Category from SalesLT.Product as pr
join dbo.ufnGetAllCategories() as f
on pr.ProductCategoryID=f.ProductCategoryID
order by ParentCategory, Category, ProductName

--������ 2: ��������� ���������� �� ������� �� ������ ��������
--1. �������� ������ �� ������ �� �������� � ���������� ������ (����������� ����������� �������)
--�������� ������ �������� � ������� ���������_�������� (���_�������� �������_��������)� � �������
--CompanyContact (��������, �������� ����� ���� �Action Bicycle Specialists (Terry Eminhizer)�), ��������
--���������� ������� (����� �������� TotalDue) ��� ����� ������� (������� Revenue). ����������� �����������
--�������, ����� �������� �������� �� ������� ������ � ����� ��������� ������ � ���������� �����������
--�������, ����� ������������� ������. ���������� ������ ���� ����������� �� ��������� � CompanyContact.
select CompanyContact, sum(TotalDue) as Revenue from
(select (CompanyName + ' ('+ FirstName + ' ' + LastName + ')') as CompanyContact, TotalDue from SalesLT.Customer as cu
join SalesLT.SalesOrderHeader as so
on cu.CustomerID = so.CustomerID) as cn
group by CompanyContact
order by CompanyContact

--2. �������� ������ �� ������ �� �������� � ���������� ������ (����������� CTE � ���������� ��������� ���������)
--���������� ���������� ������ � ������� CTE (����������� ���������� ���������) ������ �����������
--������.
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