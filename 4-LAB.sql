--1.1 Получите платежные адреса
SELECT cu.CompanyName, ad.AddressLine1 , ad.City AS [Address], 'Billing' AS AddressType  
FROM SalesLT.Address AS ad 
JOIN SalesLT.CustomerAddress AS ca
ON ad.AddressID = ca.AddressID
JOIN SalesLT.Customer AS cu
ON ca.CustomerID = cu.CustomerID
WHERE ca.AddressType = 'Main Office';

--1.2 Получите адрес доставки
SELECT cu.CompanyName, ad.AddressLine1 , ad.City AS [Address], 'Shipping' AS AddressType 
FROM SalesLT.Address AS ad 
JOIN SalesLT.CustomerAddress AS ca
ON ad.AddressID = ca.AddressID
JOIN SalesLT.Customer AS cu
ON ca.CustomerID = cu.CustomerID
WHERE ca.AddressType = 'Shipping';

--1.3 Объедините платежный адрес и адрес доставки
SELECT cu.CompanyName, ad.AddressLine1 , ad.City AS [Address], 'Billing' AS AddressType  
FROM SalesLT.Address AS ad 
JOIN SalesLT.CustomerAddress AS ca
ON ad.AddressID = ca.AddressID
JOIN SalesLT.Customer AS cu
ON ca.CustomerID = cu.CustomerID
WHERE ca.AddressType = 'Main Office'
UNION ALL
SELECT cu.CompanyName, ad.AddressLine1 , ad.City AS [Address], 'Shipping' AS AddressType 
FROM SalesLT.Address AS ad 
JOIN SalesLT.CustomerAddress AS ca
ON ad.AddressID = ca.AddressID
JOIN SalesLT.Customer AS cu
ON ca.CustomerID = cu.CustomerID
WHERE ca.AddressType = 'Shipping'
ORDER by cu.CompanyName, AddressType;

--2.1 Получите клиентов, имеющих только адрес главного офиса
SELECT cu.CompanyName FROM SalesLT.CustomerAddress AS ca
JOIN SalesLT.Customer AS cu
ON ca.CustomerID = cu.CustomerID
WHERE ca.AddressType = 'Main Office'
EXCEPT
SELECT cu.CompanyName 
FROM  SalesLT.CustomerAddress AS ca
JOIN SalesLT.Customer AS cu
ON ca.CustomerID = cu.CustomerID
WHERE ca.AddressType = 'Shipping';

--2.2 Получите клиентов, имеющих оба типа адреса
SELECT cu.CompanyName 
FROM SalesLT.CustomerAddress AS ca
JOIN SalesLT.Customer AS cu
ON ca.CustomerID = cu.CustomerID
WHERE ca.AddressType = 'Main Office'
INTERSECT
SELECT cu.CompanyName 
FROM  SalesLT.CustomerAddress AS ca
JOIN SalesLT.Customer AS cu
ON ca.CustomerID = cu.CustomerID
WHERE ca.AddressType = 'Shipping';