USE Tarbet
GO

CREATE USER JamesTaylor FOR LOGIN JamesTaylor;
ALTER ROLE Customer ADD MEMBER JamesTaylor;
GO

CREATE USER Store1 FOR LOGIN Store1;
ALTER ROLE Store ADD MEMBER Store1;
GO

CREATE USER Warehouse1 FOR LOGIN Warehouse1;
ALTER ROLE Warehouse ADD MEMBER Warehouse1;
GO

CREATE USER Starbucks FOR LOGIN Starbucks;
ALTER ROLE Supplier ADD MEMBER Starbucks;
GO

CREATE USER Administrator1 FOR LOGIN Administrator1;
ALTER ROLE TarbetAdministrator ADD MEMBER Administrator1;
GO