USE Tarbet
GO

IF OBJECT_ID('fnDistance') IS NOT NULL
    DROP FUNCTION fnDistance
GO
CREATE FUNCTION fnDistance
    (@FirstAddressID int, @SecondAddressID int)
    RETURNS float
BEGIN
    DECLARE @Zip1 char(5) = (
        SELECT Zip 
        FROM Address.Addresses 
        WHERE Address.Addresses.AddressID = @FirstAddressID);
    DECLARE @Zip2 char(5) = (
        SELECT Zip 
        FROM Address.Addresses 
        WHERE Address.Addresses.AddressID = @SecondAddressID);
    DECLARE @LAT1 float = (
        SELECT Latitude 
        FROM Address.ZipList 
        WHERE Address.ZipList.Zip = @Zip1);
    DECLARE @LONG1 float = (
        SELECT Longitude 
        FROM Address.ZipList 
        WHERE Address.ZipList.Zip = @Zip1);
    DECLARE @LAT2 float = (
        SELECT Latitude 
        FROM Address.ZipList 
        WHERE Address.ZipList.Zip = @Zip2);
    DECLARE @LONG2 float = (
        SELECT Longitude 
        FROM Address.ZipList 
        WHERE Address.ZipList.Zip = @Zip2);
    RETURN 111.045 * DEGREES(ACOS(COS(RADIANS(@LAT1))
                 * COS(RADIANS(@LAT2))
                 * COS(RADIANS(@LONG1) - RADIANS(@LONG2))
                 + SIN(RADIANS(@LAT1))
                 * SIN(RADIANS(@LAT2))));
END;
GO

IF OBJECT_ID('fnWarehouseRankByDistance') IS NOT NULL
    DROP FUNCTION fnWarehouseRankByDistance
GO
CREATE FUNCTION fnWarehouseRankByDistance
    (@AddressID int)
    RETURNS TABLE
RETURN (
    SELECT ROW_NUMBER() OVER(ORDER BY dbo.fnDistance(@AddressID, AddressID)) AS Rank, WarehouseID 
    FROM Warehouse.Warehouses);
GO

IF OBJECT_ID('fnFindWarehouseByAddress') IS NOT NULL
    DROP FUNCTION fnFindWarehouseByAddress
GO
CREATE FUNCTION fnFindWarehouseByAddress
    (@AddressID int)
    RETURNS int
BEGIN
    RETURN (
        SELECT WarehouseID 
        FROM Warehouse.Warehouses 
        WHERE Warehouse.Warehouses.AddressID = @AddressID);
END;
GO

IF OBJECT_ID('fnCheckAvailability') IS NOT NULL
    DROP FUNCTION fnCheckAvailability
GO
CREATE FUNCTION fnCheckAvailability
    (@OrderID int)
    RETURNS TABLE
RETURN (
    SELECT ProductID
    FROM Order_.OnlineOrderToItem 
    WHERE OrderID = @OrderID AND ProductID NOT IN (SELECT ProductID FROM OnlineAvailableProducts));
GO

IF OBJECT_ID('fnCurrentCustomerID') IS NOT NULL
    DROP FUNCTION fnCurrentCustomerID
GO
CREATE FUNCTION fnCurrentCustomerID
    ()
    RETURNS int
BEGIN
    RETURN (
        SELECT CustomerID
        FROM Customer.Customers
        WHERE UserName = CURRENT_USER);
END
GO

IF OBJECT_ID('fnCurrentStoreID') IS NOT NULL
    DROP FUNCTION fnCurrentStoreID
GO
CREATE FUNCTION fnCurrentStoreID
    ()
    RETURNS int
BEGIN
    RETURN (
        SELECT StoreID
        FROM Store.Stores
        WHERE UserName = CURRENT_USER);
END
GO

IF OBJECT_ID('fnCurrentWarehouseID') IS NOT NULL
    DROP FUNCTION fnCurrentWarehouseID
GO
CREATE FUNCTION fnCurrentWarehouseID
    ()
    RETURNS int
BEGIN
    RETURN (
        SELECT WarehouseID
        FROM Warehouse.Warehouses
        WHERE UserName = CURRENT_USER);
END
GO

IF OBJECT_ID('fnCurrentSupplierID') IS NOT NULL
    DROP FUNCTION fnCurrentSupplierID
GO
CREATE FUNCTION fnCurrentSupplierID
    ()
    RETURNS int
BEGIN
    RETURN (
        SELECT SupplierID
        FROM Supplier.Suppliers
        WHERE UserName = CURRENT_USER);
END
GO