USE Tarbet
GO

IF OBJECT_ID('spCustomerAddShippingAddress') IS NOT NULL
    DROP PROC spCustomerAddShippingAddress
GO
CREATE PROC spCustomerAddShippingAddress 
    @AddressID int OUTPUT,
    @CustomerID int,
    @Street varchar(100),
    @City varchar(20),
    @State varchar(20),
    @Zip char(5)
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
INSERT INTO Address.Addresses (Street, City, State, Zip)
VALUES (@Street, @City, @State, @Zip);
SET @AddressID = @@IDENTITY;
INSERT INTO Customer.ShippingAddressList (CustomerID, AddressID)
VALUES (@CustomerID, @AddressID);
GO

IF OBJECT_ID('spCustomerAddBillingAddress') IS NOT NULL
    DROP PROC spCustomerAddBillingAddress
GO
CREATE PROC spCustomerAddBillingAddress
    @AddressID int OUTPUT,
    @CustomerID int,
    @Street varchar(100),
    @City varchar(20),
    @State varchar(20),
    @Zip char(5)
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
INSERT INTO Address.Addresses (Street, City, State, Zip)
VALUES (@Street, @City, @State, @Zip);
SET @AddressID = @@IDENTITY;
INSERT INTO Customer.BillingAddressList (CustomerID, AddressID)
VALUES (@CustomerID, @AddressID);
GO

IF OBJECT_ID('spCustomerCreateOnlineOrder') IS NOT NULL
    DROP PROC spCustomerCreateOnlineOrder
GO
CREATE PROC spCustomerCreateOnlineOrder 
    @OrderID int OUTPUT,
    @CustomerID int,
    @AddressID int
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
INSERT INTO Order_.OnlineOrders (CustomerID, AddressID)
VALUES (@CustomerID, @AddressID);
SET @OrderID = @@IDENTITY;
GO

IF OBJECT_ID('spCustomerAddOnlineItem') IS NOT NULL
    DROP PROC spCustomerAddOnlineItem
GO
CREATE PROC spCustomerAddOnlineItem
    @OrderID int,
    @ProductID int,
    @Quantity int
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
IF NOT EXISTS (SELECT * FROM Order_.OnlineOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID!', 1;
-- IF (SELECT CustomerID FROM Order_.OnlineOrders WHERE OrderID = @OrderID) <> @CustomerID
--     THROW 50008, 'Insufficient permissions!', 1;
IF NOT EXISTS (SELECT * FROM Product.Products WHERE ProductID = @ProductID)
    THROW 50007, 'Invalid ProductID!', 1;
IF (SELECT Locked FROM Order_.OnlineOrders WHERE OrderID = @OrderID) = 1
    THROW 50002, 'Invalid operation! This order is locked.', 1;
IF EXISTS (SELECT * FROM Order_.OnlineOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID)
    UPDATE Order_.OnlineOrderToItem
    SET Quantity = Quantity + @Quantity
    WHERE OrderID = @OrderID AND ProductID = @ProductID;
ELSE
BEGIN
    DECLARE @UnitPrice money = (SELECT UnitPrice FROM Product.Products WHERE ProductID = @ProductID);
    INSERT INTO Order_.OnlineOrderToItem (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice);
END;
GO

IF OBJECT_ID('spCustomerDropOnlineItem') IS NOT NULL
    DROP PROC spCustomerDropOnlineItem
GO
CREATE PROC spCustomerDropOnlineItem
    @OrderID int,
    @ProductID int,
    @Quantity int
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
IF NOT EXISTS (SELECT * FROM Order_.OnlineOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID', 1;
-- IF (SELECT CustomerID FROM Order_.OnlineOrders WHERE OrderID = @OrderID) <> @CustomerID
--     THROW 50008, 'Insufficient permissions!', 1;
IF NOT EXISTS (SELECT * FROM Product.Products WHERE ProductID = @ProductID)
    THROW 50007, 'Invalid ProductID!', 1;
IF (SELECT Locked FROM Order_.OnlineOrders WHERE OrderID = @OrderID) = 1
    THROW 50002, 'Invalid operation! This order is locked.', 1;
IF EXISTS (SELECT * FROM Order_.OnlineOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID)
BEGIN
    IF (SELECT Quantity FROM Order_.OnlineOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID) < @Quantity
        UPDATE Order_.OnlineOrderToItem
        SET Quantity = 0
        WHERE OrderID = @OrderID AND ProductID = @ProductID;
    ELSE
        UPDATE Order_.OnlineOrderToItem
        SET Quantity = Quantity - @Quantity
        WHERE OrderID = @OrderID AND ProductID = @ProductID;
END

IF OBJECT_ID('spCustomerPlaceOnlineOrder') IS NOT NULL
    DROP PROC spCustomerPlaceOnlineOrder;
GO
CREATE PROC spCustomerPlaceOnlineOrder
    @OrderID int
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
IF NOT EXISTS (SELECT * FROM Order_.OnlineOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID!', 1;
-- IF (SELECT CustomerID FROM Order_.OnlineOrders WHERE OrderID = @OrderID) <> @CustomerID
--     THROW 50008, 'Insufficient permissions!', 1;
IF (SELECT Locked FROM Order_.OnlineOrders WHERE OrderID = @OrderID) = 1
    THROW 50002, 'Invalid operation! This order is locked.', 1;
UPDATE Order_.OnlineOrders
SET Locked = 1
WHERE OrderID = @OrderID;
UPDATE Order_.OnlineOrders
SET OrderDate = GETDATE()
WHERE OrderID = @OrderID;
UPDATE Order_.OnlineOrders
SET PayDueDate = DATEADD(day, 1, GETDATE())
WHERE OrderID = @OrderID;
GO

IF OBJECT_ID('spScheduleShipping') IS NOT NULL
    DROP PROC spScheduleShipping
GO
CREATE PROC spScheduleShipping
    @OrderID int
AS
DECLARE @UnavailableProductID int;
DECLARE @ErrorMessage varchar(100);
DECLARE @ShippingAddressID int;
DECLARE @WarehouseCount int;
DECLARE @CurrentWarehouseID int;
DECLARE @CurrentProductID int;
DECLARE @CurrentWarehouseHave int;
DECLARE @CurrentProductNeed int;
DECLARE @HasShipping bit;
DECLARE @CurrentShippingID int;
DECLARE @UnscheduledProducts TABLE
    (ID int,
    ProductID int,
    Quantity int);
DECLARE @WarehouseRank TABLE
    (Rank int,
    WarehouseID int);
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
IF NOT EXISTS (SELECT * FROM Order_.OnlineOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID!', 1;
INSERT @UnscheduledProducts
SELECT ROW_NUMBER() OVER(ORDER BY ProductID) AS ID, ProductID, Quantity
FROM Order_.OnlineOrderToItem
WHERE OrderID = @OrderID;
SET @ShippingAddressID = (SELECT AddressID FROM Order_.OnlineOrders WHERE OrderID = @OrderID);
INSERT @WarehouseRank
SELECT *
FROM dbo.fnWarehouseRankByDistance(@ShippingAddressID);
SET @WarehouseCount = (SELECT COUNT(*) FROM @WarehouseRank);
BEGIN TRAN
    DECLARE @i int = 1;
    -- Schedule warehouses for items from near to far
    WHILE @i <= @WarehouseCount AND (SELECT SUM(Quantity) FROM @UnscheduledProducts) > 0
    BEGIN
        SET @HasShipping = 0;
        SET @CurrentWarehouseID = (SELECT WarehouseID FROM @WarehouseRank WHERE Rank = @i);
        DECLARE @j int = 1;
        WHILE @j <= (SELECT COUNT(*) FROM @UnscheduledProducts)
        BEGIN
            SET @CurrentProductID = (SELECT ProductID FROM @UnscheduledProducts WHERE ID = @j);
            SET @CurrentWarehouseHave = (
                SELECT InStock 
                FROM Warehouse.WarehouseProductList 
                WHERE WarehouseID = @CurrentWarehouseID AND ProductID = @CurrentProductID);
            SET @CurrentProductNeed = (
                SELECT Quantity 
                FROM @UnscheduledProducts
                WHERE ProductID = @CurrentProductID);
            IF @CurrentProductNeed > 0 AND @CurrentWarehouseHave > 0
            BEGIN
                IF @HasShipping = 0
                BEGIN
                    DECLARE @StartAddressID int = (SELECT AddressID FROM Warehouse.Warehouses WHERE WarehouseID = @CurrentWarehouseID);
                    DECLARE @ArriveAddressID int = (SELECT AddressID FROM Order_.OnlineOrders WHERE OrderID = @OrderID);
                    INSERT INTO Shipping.Shippings (OrderID, Status, StartAddressID, ArriveAddressID, StartDate, ShippingService, ShippingFare)
                    VALUES (@OrderID, 'Ready', @StartAddressID, @ArriveAddressID, GETDATE(), 'USPS', dbo.fnDistance(@StartAddressID, @ArriveAddressID) / 1000 + 5);
                    SET @HasShipping = 1;
                    SET @CurrentShippingID = @@IDENTITY;
                END
                IF @CurrentProductNeed > @CurrentWarehouseHave
                    SET @CurrentProductNeed = @CurrentWarehouseHave;
                UPDATE Warehouse.WarehouseProductList
                SET InStock = InStock - @CurrentProductNeed
                WHERE WarehouseID = @CurrentWarehouseID AND ProductID = @CurrentProductID;
                UPDATE Warehouse.WarehouseProductList
                SET OnWay = OnWay + @CurrentProductNeed
                WHERE WarehouseID = @CurrentWarehouseID AND ProductID = @CurrentProductID;
                UPDATE @UnscheduledProducts
                SET Quantity = Quantity - @CurrentProductNeed
                WHERE ID = @CurrentProductID;
                INSERT INTO Shipping.ShippingToItem (ShippingID, ProductID, Quantity)
                VALUES (@CurrentShippingID, @CurrentProductID, @CurrentProductNeed);
            END
            SET @j = @j + 1;
        END
        SET @i = @i + 1;
    END
    IF (SELECT SUM(Quantity) FROM @UnscheduledProducts) > 0
        GOTO PROBLEM;
COMMIT TRAN
PROBLEM:
    IF (SELECT SUM(Quantity) FROM @UnscheduledProducts) > 0
    BEGIN
        ROLLBACK TRAN;
        UPDATE Order_.OnlineOrders
        SET Locked = 0
        WHERE OrderID = @OrderID;
        SET @UnavailableProductID = (SELECT TOP 1 ProductID FROM @UnscheduledProducts WHERE Quantity > 0);
        SET @ErrorMessage = 'Product ' + CONVERT(varchar(10), @UnavailableProductID)  + ' is unavailable!';
        THROW 50004, @ErrorMessage, 1;
    END
GO

IF OBJECT_ID('spCustomerPayOnlineOrder') IS NOT NULL
    DROP PROC spCustomerPayOnlineOrder
GO
CREATE PROC spCustomerPayOnlineOrder
    @OrderID int,
    @PaymentTotal money,
    @CardNumber varchar(20)
AS
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
IF NOT EXISTS (SELECT * FROM Order_.OnlineOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID!', 1;
-- IF (SELECT CustomerID FROM Order_.OnlineOrders WHERE OrderID = @OrderID) <> @CustomerID
--     THROW 50008, 'Insufficient permissions!', 1;
IF (SELECT Locked FROM Order_.OnlineOrders WHERE OrderID = @OrderID) = 0
    THROW 50005, 'Invalid operation! Please place order before pay it.', 1;
BEGIN TRAN
    INSERT INTO Order_.OnlinePayment (OrderID, PaymentTotal, CardNumber, PayDate)
    VALUES (@OrderID, @PaymentTotal, @CardNumber, GETDATE());
    IF (SELECT SUM(PaymentTotal) FROM Order_.OnlinePayment WHERE OrderID = @OrderID) >= 
        (SELECT TotalPrice FROM Order_.OnlineOrders WHERE OrderID = @OrderID)
    BEGIN
        UPDATE Shipping.Shippings
        SET Status = 'Shipped'
        WHERE OrderID = @OrderID;
    END
    IF (SELECT PayDueDate FROM Order_.OnlineOrders WHERE OrderID = @OrderID) < GETDATE()
        GOTO PROBLEM1;
COMMIT TRAN
PROBLEM1:
    IF (SELECT PayDueDate FROM Order_.OnlineOrders WHERE OrderID = @OrderID) < GETDATE()
    BEGIN
        THROW 50003, 'Order expired!', 1;
        ROLLBACK TRAN;
    END
GO

IF OBJECT_ID('spShippingDelivered') IS NOT NULL
    DROP PROC spShippingDelivered
GO
CREATE PROC spShippingDelivered
    @ShippingID int
AS
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
IF NOT EXISTS (SELECT * FROM Shipping.Shippings WHERE ShippingID = @ShippingID)
    THROW 50006, 'Invalid ShippingID!', 1;
BEGIN TRAN
    UPDATE Shipping.Shippings
    SET Status = 'Delivered'
    WHERE ShippingID = @ShippingID;
    UPDATE Warehouse.WarehouseProductList
    SET OnWay = OnWay - (
        SELECT Quantity 
        FROM Shipping.ShippingToItem 
        WHERE ShippingID = @ShippingID AND ProductID = Warehouse.WarehouseProductList.ProductID)
    WHERE WarehouseID = (
        SELECT WarehouseID
        FROM Warehouse.Warehouses 
        WHERE AddressID = (
            SELECT StartAddressID 
            FROM Shipping.Shippings 
            WHERE ShippingID = @ShippingID)) 
        AND ProductID IN (
            SELECT ProductID 
            From Shipping.ShippingToItem 
            WHERE ShippingID = @ShippingID);
COMMIT TRAN
GO

IF OBJECT_ID('spCustomerReturnShipping') IS NOT NULL
    DROP PROC spCustomerReturnShipping
GO
CREATE PROC spCustomerReturnShipping
    @ShippingID int
AS
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
IF NOT EXISTS (SELECT * FROM Shipping.Shippings WHERE ShippingID = @ShippingID)
    THROW 50006, 'Invalid ShippingID!', 1;
-- IF (SELECT CustomerID FROM Order_.OnlineOrders WHERE OrderID = (SELECT OrderID FROM Shipping.Shippings WHERE ShippingID = @ShippingID)) <> @CustomerID
--     THROW 50008, 'Insufficient permissions!', 1;
BEGIN TRAN
    UPDATE Warehouse.WarehouseProductList
    SET InReturn = InReturn + 
        (SELECT Quantity 
        FROM Shipping.ShippingToItem 
        WHERE ShippingID = @ShippingID AND ProductID = Warehouse.WarehouseProductList.ProductID)
    WHERE WarehouseID = (
        SELECT WarehouseID 
        FROM Warehouse.Warehouses 
        WHERE AddressID = (
            SELECT StartAddressID 
            FROM Shipping.Shippings 
            WHERE ShippingID = @ShippingID)) 
        AND ProductID IN (
            SELECT ProductID 
            FROM Shipping.ShippingToItem 
            WHERE ShippingID = @ShippingID);
COMMIT TRAN
GO

IF OBJECT_ID('spShippingReturned') IS NOT NULL
    DROP PROC spShippingReturned
GO
CREATE PROC spShippingReturned
    @ShippingID int,
    @Intact bit
AS
DECLARE @WarehouseID int = (SELECT WarehouseID FROM Warehouse.Warehouses WHERE AddressID = (
    SELECT StartAddressID 
    FROM Shipping.Shippings 
    WHERE ShippingID = @ShippingID));
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
IF NOT EXISTS (SELECT * FROM Shipping.Shippings WHERE ShippingID = @ShippingID)
    THROW 50006, 'Invalid ShippingID!', 1;
BEGIN TRAN
    UPDATE Shipping.Shippings
    SET Status = 'Returned'
    WHERE ShippingID = @ShippingID;
    UPDATE Warehouse.WarehouseProductList
    SET InReturn = InReturn - (
        SELECT Quantity 
        FROM Shipping.ShippingToItem 
        WHERE ShippingID = @ShippingID AND ProductID = Warehouse.WarehouseProductList.ProductID)
    WHERE WarehouseID = @WarehouseID AND ProductID IN (
        SELECT ProductID 
        FROM Shipping.ShippingToItem 
        WHERE ShippingID = @ShippingID);
    IF @Intact = 1
    BEGIN
        UPDATE Warehouse.WarehouseProductList
        SET InStock = InStock + (
            SELECT Quantity 
            FROM Shipping.ShippingToItem 
            WHERE ShippingID = @ShippingID AND ProductID = Warehouse.WarehouseProductList.ProductID)
        WHERE WarehouseID = @WarehouseID AND ProductID IN (
            SELECT ProductID 
            FROM Shipping.ShippingToItem 
            WHERE ShippingID = @ShippingID);
        DECLARE @OrderID int = (SELECT OrderID FROM Shipping.Shippings WHERE ShippingID = @ShippingID);
        DECLARE @TotalPrice money = (
                SELECT SUM(Quantity * UnitPrice)
                FROM Shipping.ShippingToItem JOIN Product.Products
                    ON Shipping.ShippingToItem.ProductID = Product.Products.ProductID
                WHERE ShippingID = @ShippingID);
        INSERT INTO Order_.OnlinePayment (OrderID, PaymentTotal, CardNumber, PayDate)
        VALUES (@OrderID, -@TotalPrice, (SELECT TOP 1 CardNumber FROM Order_.OnlinePayment WHERE OrderID = @OrderID), GETDATE());
    END
COMMIT TRAN
GO

IF OBJECT_ID('spCustomerWriteReview') IS NOT NULL
    DROP PROC spCustomerWriteReview
GO
CREATE PROC spCustomerWriteReview
    @CustomerID int,
    @ProductID int,
    @Text varchar(1000),
    @Score float
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
IF NOT EXISTS (SELECT * FROM Product.Products WHERE ProductID = @ProductID)
    THROW 50007, 'Invalid ProductID!', 1;
INSERT INTO Product.Reviews (ProductID, CustomerID, Text, Score, ReviewDate)
VALUES (@ProductID, @CustomerID, @Text, @Score, GETDATE());
GO

IF OBJECT_ID('spCustomerCreateInStoreOrder') IS NOT NULL
    DROP PROC spCustomerCreateInStoreOrder
GO
CREATE PROC spCustomerCreateInStoreOrder 
    @OrderID int OUTPUT,
    @CustomerID int,
    @StoreID int,
    @OrderDate datetime
AS
INSERT INTO Order_.InStoreOrders (CustomerID, StoreID, OrderDate)
VALUES (@CustomerID, @StoreID, @OrderDate);
SET @OrderID = @@IDENTITY;
GO

IF OBJECT_ID('spCustomerAddInStoreItem') IS NOT NULL
    DROP PROC spCustomerAddInStoreItem
GO
CREATE PROC spCustomerAddInStoreItem
    @OrderID int,
    @ProductID int,
    @Quantity int
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
IF NOT EXISTS (SELECT * FROM Order_.InStoreOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID!', 1;
-- IF (SELECT CustomerID FROM Order_.OnlineOrders WHERE OrderID = @OrderID) <> @CustomerID
--     THROW 50008, 'Insufficient permissions!', 1;
IF NOT EXISTS (SELECT * FROM Product.Products WHERE ProductID = @ProductID)
    THROW 50007, 'Invalid ProductID!', 1;
IF EXISTS (SELECT * FROM Order_.InStoreOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID)
    UPDATE Order_.InStoreOrderToItem
    SET Quantity = Quantity + @Quantity
    WHERE OrderID = @OrderID AND ProductID = @ProductID;
ELSE
BEGIN
    DECLARE @UnitPrice money = (SELECT Price FROM Store.StoreProductList WHERE StoreID = (SELECT StoreID FROM Order_.InStoreOrders WHERE OrderID = @OrderID) AND ProductID = @ProductID);
    INSERT INTO Order_.InStoreOrderToItem (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice);
END;
GO

IF OBJECT_ID('spCustomerDropInStoreItem') IS NOT NULL
    DROP PROC spCustomerDropInStoreItem
GO
CREATE PROC spCustomerDropInStoreItem
    @OrderID int,
    @ProductID int,
    @Quantity int
AS
-- DECLARE @CustomerID int = dbo.fnCurrentCustomerID();
IF NOT EXISTS (SELECT * FROM Order_.InStoreOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID', 1;
-- IF (SELECT CustomerID FROM Order_.OnlineOrders WHERE OrderID = @OrderID) <> @CustomerID
--     THROW 50008, 'Insufficient permissions!', 1;
IF NOT EXISTS (SELECT * FROM Product.Products WHERE ProductID = @ProductID)
    THROW 50007, 'Invalid ProductID!', 1;
IF EXISTS (SELECT * FROM Order_.InStoreOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID)
    IF (SELECT Quantity FROM Order_.InStoreOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID) < @Quantity
        UPDATE Order_.InStoreOrderToItem
        SET Quantity = 0
        WHERE OrderID = @OrderID AND ProductID = @ProductID;
    ELSE
        UPDATE Order_.InStoreOrderToItem
        SET Quantity = Quantity - @Quantity
        WHERE OrderID = @OrderID AND ProductID = @ProductID;
GO

IF OBJECT_ID('spStoreCreateOrder') IS NOT NULL
    DROP PROC spStoreCreateOrder
GO
CREATE PROC spStoreCreateOrder 
    @OrderID int OUTPUT,
    @StoreID int
AS
-- DECLARE @StoreID int = dbo.fnCurrentStoreID();
INSERT INTO Order_.StoreOrders (StoreID)
VALUES (@StoreID);
SET @OrderID = @@IDENTITY;
GO

IF OBJECT_ID('spStoreAddItemInOrder') IS NOT NULL
    DROP PROC spStoreAddItemInOrder
GO
CREATE PROC spStoreAddItemInOrder
    @OrderID int,
    @ProductID int,
    @Quantity int
AS
-- DECLARE @StoreID int = dbo.fnCurrentStoreID();
IF NOT EXISTS (SELECT * FROM Order_.StoreOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID!', 1;
-- IF (SELECT StoreID FROM Order_.StoreOrders WHERE OrderID = @OrderID) <> @StoreID
--     THROW 50008, 'Insufficient permissions!', 1;
IF NOT EXISTS (SELECT * FROM Product.Products WHERE ProductID = @ProductID)
    THROW 50007, 'Invalid ProductID!', 1;
IF EXISTS (SELECT * FROM Order_.StoreOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID)
    UPDATE Order_.StoreOrderToItem
    SET Quantity = Quantity + @Quantity
    WHERE OrderID = @OrderID AND ProductID = @ProductID;
ELSE
BEGIN
    DECLARE @UnitPrice money = (SELECT UnitPrice FROM Product.Products WHERE ProductID = @ProductID);
    INSERT INTO Order_.StoreOrderToItem (OrderID, ProductID, Quantity, UnitPrice)
    VALUES (@OrderID, @ProductID, @Quantity, @UnitPrice);
END;
GO

IF OBJECT_ID('spStoreDropItemInOrder') IS NOT NULL
    DROP PROC spStoreDropItemInOrder
GO
CREATE PROC spStoreDropItemInOrder
    @OrderID int,
    @ProductID int,
    @Quantity int
AS
-- DECLARE @StoreID int = dbo.fnCurrentStoreID();
IF NOT EXISTS (SELECT * FROM Order_.StoreOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID', 1;
-- IF (SELECT StoreID FROM Order_.StoreOrders WHERE OrderID = @OrderID) <> @StoreID
--     THROW 50008, 'Insufficient permissions!', 1;
IF NOT EXISTS (SELECT * FROM Product.Products WHERE ProductID = @ProductID)
    THROW 50007, 'Invalid ProductID!', 1;
IF EXISTS (SELECT * FROM Order_.StoreOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID)
BEGIN
    IF (SELECT Quantity FROM Order_.StoreOrderToItem WHERE OrderID = @OrderID AND ProductID = @ProductID) < @Quantity
        UPDATE Order_.StoreOrderToItem
        SET Quantity = 0
        WHERE OrderID = @OrderID AND ProductID = @ProductID;
    ELSE
        UPDATE Order_.StoreOrderToItem
        SET Quantity = Quantity - @Quantity
        WHERE OrderID = @OrderID AND ProductID = @ProductID;
END
GO

IF OBJECT_ID('spStorePlaceOrder') IS NOT NULL
    DROP PROC spStorePlaceOrder
GO
CREATE PROC spStorePlaceOrder
    @OrderID int
AS
-- DECLARE @StoreID int = dbo.fnCurrentStoreID();
IF NOT EXISTS (SELECT * FROM Order_.StoreOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID', 1;
-- IF (SELECT StoreID FROM Order_.StoreOrders WHERE OrderID = @OrderID) <> @StoreID
--     THROW 50008, 'Insufficient permissions!', 1;
SELECT ProductID
INTO #UnavailableProduct
FROM Order_.StoreOrderToItem 
WHERE OrderID = @OrderID AND ProductID NOT IN (SELECT ProductID FROM OnlineAvailableProducts);
IF (SELECT COUNT(*) FROM #UnavailableProduct) > 0
BEGIN
    DECLARE @UnavailableProductID int = (SELECT TOP 1 ProductID FROM #UnavailableProduct);
    DECLARE @ErrorMessage varchar(100) = 'Product ' + CONVERT(varchar(10), @UnavailableProductID)  + ' is unavailable!';
    THROW 50004, @ErrorMessage, 1;
END
UPDATE Order_.OnlineOrders
SET OrderDate = GETDATE()
WHERE OrderID = @OrderID;
GO

IF OBJECT_ID('spStoreOrderCompleted') IS NOT NULL
    DROP PROC spStoreOrderCompleted
GO
CREATE PROC spStoreOrderCompleted
    @OrderID int
AS
DECLARE @StoreID int;
DECLARE @UnavailableProductID int;
DECLARE @ErrorMessage varchar(100);
DECLARE @ShippingAddressID int;
DECLARE @WarehouseCount int;
DECLARE @CurrentWarehouseID int;
DECLARE @CurrentProductID int;
DECLARE @CurrentWarehouseHave int;
DECLARE @CurrentProductNeed int;
DECLARE @UnscheduledProducts TABLE
    (ID int,
    ProductID int,
    Quantity int);
DECLARE @WarehouseRank TABLE
    (Rank int,
    WarehouseID int);
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
IF NOT EXISTS (SELECT * FROM Order_.StoreOrders WHERE OrderID = @OrderID)
    THROW 50001, 'Invalid OrderID!', 1;
INSERT @UnscheduledProducts
SELECT ROW_NUMBER() OVER(ORDER BY ProductID) AS ID, ProductID, Quantity
FROM Order_.StoreOrderToItem
WHERE OrderID = @OrderID;
SET @StoreID = (SELECT StoreID FROM Order_.StoreOrders WHERE OrderID = @OrderID);
SET @ShippingAddressID = (SELECT AddressID FROM Store.Stores WHERE StoreID = @StoreID);
INSERT @WarehouseRank
SELECT *
FROM dbo.fnWarehouseRankByDistance(@ShippingAddressID);
SET @WarehouseCount = (SELECT COUNT(*) FROM @WarehouseRank);
BEGIN TRAN
    DECLARE @i int = 1;
    -- Schedule warehouses for items from near to far
    WHILE @i <= @WarehouseCount AND (SELECT SUM(Quantity) FROM @UnscheduledProducts) > 0
    BEGIN
        SET @CurrentWarehouseID = (SELECT WarehouseID FROM @WarehouseRank WHERE Rank = @i);
        DECLARE @j int = 1;
        WHILE @j <= (SELECT COUNT(*) FROM @UnscheduledProducts)
        BEGIN
            SET @CurrentProductID = (SELECT ProductID FROM @UnscheduledProducts WHERE ID = @j);
            SET @CurrentWarehouseHave = (
                SELECT InStock 
                FROM Warehouse.WarehouseProductList 
                WHERE WarehouseID = @CurrentWarehouseID AND ProductID = @CurrentProductID);
            SET @CurrentProductNeed = (
                SELECT Quantity 
                FROM @UnscheduledProducts
                WHERE ProductID = @CurrentProductID);
            IF @CurrentProductNeed > 0 AND @CurrentWarehouseHave > 0
            BEGIN
                IF @CurrentProductNeed > @CurrentWarehouseHave
                    SET @CurrentProductNeed = @CurrentWarehouseHave
                UPDATE Warehouse.WarehouseProductList
                SET InStock = InStock - @CurrentProductNeed
                WHERE WarehouseID = @CurrentWarehouseID AND ProductID = @CurrentProductID;
                UPDATE Store.StoreProductList
                SET Quantity = Quantity + @CurrentProductNeed
                WHERE StoreID = @StoreID AND ProductID = @CurrentProductID;
                UPDATE @UnscheduledProducts
                SET Quantity = Quantity - @CurrentProductNeed
                WHERE ProductID = @CurrentProductID;
            END
            SET @j = @j + 1;
        END
        SET @i = @i + 1;
    END
    IF (SELECT SUM(Quantity) FROM @UnscheduledProducts) > 0
        GOTO PROBLEM11;
COMMIT TRAN
PROBLEM11:
    IF (SELECT SUM(Quantity) FROM @UnscheduledProducts) > 0
    BEGIN
        ROLLBACK TRAN;
        SET @UnavailableProductID = (SELECT TOP 1 ProductID FROM @UnscheduledProducts WHERE Quantity > 0);
        SET @ErrorMessage = 'Product ' + CONVERT(varchar(10), @UnavailableProductID)  + ' is unavailable!';
        THROW 50004, @ErrorMessage, 1;
    END
GO

IF OBJECT_ID('spWarehouseCreateOrder') IS NOT NULL
    DROP PROC spWarehouseCreateOrder
GO
CREATE PROC spWarehouseCreateOrder 
    @OrderID int OUTPUT,
    @WarehouseID int
AS
-- DECLARE @WarehouseID int = dbo.fnCurrentWarehouseID();
INSERT INTO Order_.WarehouseOrders (WarehouseID)
VALUES (@WarehouseID);
SET @OrderID = @@IDENTITY;
GO

IF OBJECT_ID('spSupplierRestockProduct') IS NOT NULL
    DROP PROC spSupplierRestockProduct
GO
CREATE PROC spSupplierRestockProduct
    @SupplierID int,
    @ProductID int,
    @Quantity int
AS
-- DECLARE @SupplierID int = dbo.fnCurrentSupplierID();
IF NOT EXISTS (SELECT * FROM Supplier.ProductDetail WHERE ProductID = @ProductID)
    THROW 50007, 'Invalid ProductID', 1;
-- IF @SupplierID NOT IN (SELECT SupplierID FROM Supplier.ProductDetail WHERE ProductID = @ProductID)
--     THROW 50008, 'Insufficient permissions!', 1;
UPDATE Supplier.ProductDetail
SET AvailableNumber = AvailableNumber + @Quantity
WHERE SupplierID = @SupplierID AND ProductID = @ProductID;
GO