USE Tarbet
GO

IF OBJECT_ID('Addresses_INSERT_UPDATE') IS NOT NULL
    DROP TRIGGER Addresses_INSERT_UPDATE
GO
CREATE TRIGGER Addresses_INSERT_UPDATE
    ON Address.Addresses
    AFTER INSERT, UPDATE
AS
UPDATE Address.Addresses
SET Street = UPPER(Street)
WHERE AddressID IN (SELECT AddressID FROM Inserted);
UPDATE Address.Addresses
SET City = UPPER(City)
WHERE AddressID IN (SELECT AddressID FROM Inserted);
UPDATE Address.Addresses
SET State = UPPER(State)
WHERE AddressID IN (SELECT AddressID FROM Inserted);
GO

IF OBJECT_ID('OnlineOrderToItem_INSERT_UPDATE') IS NOT NULL
    DROP TRIGGER OnlineOrderToItem_INSERT_UPDATE
GO
CREATE TRIGGER OnlineOrderToItem_INSERT_UPDATE
    ON Order_.OnlineOrderToItem
    AFTER INSERT, UPDATE
AS
UPDATE Order_.OnlineOrders
SET TotalPrice = (
    SELECT SUM(UnitPrice * Quantity)
    FROM Order_.OnlineOrderToItem
    WHERE Order_.OnlineOrderToItem.OrderID = Order_.OnlineOrders.OrderID
)
WHERE OrderID IN (SELECT OrderID FROM Inserted);
GO

IF OBJECT_ID('OnlineOrderToItem_DELETE') IS NOT NULL
    DROP TRIGGER OnlineOrderToItem_DELETE
GO
CREATE TRIGGER OnlineOrderToItem_DELETE
    ON Order_.OnlineOrderToItem
    AFTER DELETE
AS
UPDATE Order_.OnlineOrders
SET TotalPrice = (
    SELECT SUM(UnitPrice * Quantity)
    FROM Order_.OnlineOrderToItem
    WHERE Order_.OnlineOrderToItem.OrderID = Order_.OnlineOrders.OrderID
)
WHERE OrderID IN (SELECT OrderID FROM Deleted);
GO

IF OBJECT_ID('Reviews_INSERT') IS NOT NULL
    DROP TRIGGER Reviews_INSERT
GO
CREATE TRIGGER Reviews_INSERT
    ON Product.Reviews
    AFTER INSERT
AS
UPDATE Product.Productss
SET AvgScore = (
    SELECT AVG(Score)
    FROM Product.Reviews
    WHERE Product.Reviews.ProductID = Product.Products.ProductID
)
WHERE ProductID IN (SELECT ProductID FROM Inserted);
GO

IF OBJECT_ID('OnlineOrders_DELETE') IS NOT NULL
    DROP TRIGGER OnlineOrders_DELETE
GO
CREATE TRIGGER OnlineOrders_DELETE
    ON Order_.OnlineOrders
    INSTEAD OF DELETE
AS
DELETE Order_.OnlineOrders
WHERE OrderID IN (SELECT OrderID FROM Deleted WHERE Locked = 0);
IF (SELECT COUNT(*) FROM deleted WHERE Locked = 1) > 0
    THROW 50002, 'Invalid operation! This order is locked.', 1;
GO