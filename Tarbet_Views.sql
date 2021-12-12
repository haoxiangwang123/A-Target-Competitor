USE Tarbet
GO

/****** Object:  View OnlineAvailableProducts     ******/
IF OBJECT_ID('OnlineAvailableProducts') IS NOT NULL
    DROP VIEW OnlineAvailableProducts
GO

CREATE VIEW OnlineAvailableProducts AS
    SELECT DISTINCT ProductID
    FROM Warehouse.WarehouseProductList
    WHERE InStock > 0;
GO

/****** Object:  View ProductSalesVolume     ******/
IF OBJECT_ID('ProductSalesVolume') IS NOT NULL
    DROP VIEW ProductSalesVolume
GO

CREATE VIEW ProductSalesVolume AS
    SELECT ISNULL (OnlineProductSaleVolume.ProductID, InStoreProductSaleVolume.ProductID) AS ProductID, 
        ISNULL (OnlineSaleVolume, 0) + ISNULL (InStoreSaleVolume, 0) AS SalesVolume
    FROM (SELECT ProductID, SUM(UnitPrice * Quantity) AS OnlineSaleVolume
            FROM Order_.OnlineOrderToItem
            GROUP BY ProductID) AS OnlineProductSaleVolume
        FULL OUTER JOIN (
            SELECT ProductID, SUM(UnitPrice * Quantity) AS InStoreSaleVolume
            FROM Order_.InStoreOrderToItem
            GROUP BY ProductID) AS InStoreProductSaleVolume
        ON OnlineProductSaleVolume.ProductID = InStoreProductSaleVolume.ProductID;
GO

/****** Object:  View OnlineProductStars     ******/
IF OBJECT_ID('ProductStars') IS NOT NULL
    DROP VIEW ProductStars
GO

CREATE VIEW ProductStars AS
    SELECT ProductID, '5-stars Product' AS Grade
    FROM Product.Products
    WHERE AvgScore >= 4.7
UNION
    SELECT ProductID, '4-stars Product' AS Grade
    FROM Product.Products
    WHERE AvgScore < 4.7 AND AvgScore >= 4.4
UNION
    SELECT ProductID, '3-stars Product' AS Grade
    FROM Product.Products
    WHERE AvgScore < 4.4 AND AvgScore >= 4.0
GO

/****** Object:  View ProductSales     ******/
IF OBJECT_ID('ProductSales') IS NOT NULL
    DROP VIEW ProductSales
GO

CREATE VIEW ProductSales AS
    SELECT ISNULL (OnlineProductSalesQuantity.ProductID, InStoreProductSalesQuantity.ProductID) AS ProductID, 
        ISNULL (OnlineSalesQuantity, 0) + ISNULL (InStoreSalesQuantity, 0) AS Sales
    FROM (SELECT ProductID, SUM(Quantity) AS OnlineSalesQuantity
            FROM Order_.OnlineOrderToItem
            GROUP BY ProductID) AS OnlineProductSalesQuantity
        FULL OUTER JOIN (
            SELECT ProductID, SUM(Quantity) AS InStoreSalesQuantity
            FROM Order_.InStoreOrderToItem
            GROUP BY ProductID) AS InStoreProductSalesQuantity
        ON OnlineProductSalesQuantity.ProductID = InStoreProductSalesQuantity.ProductID;
GO