USE Tarbet
GO

CREATE INDEX IX_ShippingAddressList ON Customer.ShippingAddressList (CustomerID);
GO

CREATE INDEX IX_BillingAddressList ON Customer.BillingAddressList (CustomerID);
GO

CREATE INDEX IX_Reviews ON Product.Reviews (ProductID);
GO

CREATE INDEX IX_WishList ON Customer.WishList (CustomerID);
GO

CREATE INDEX IX_ProductDetail ON Supplier.ProductDetail (SupplierID);
GO

CREATE INDEX IX_InStorePayment ON Order_.InStorePayment (OrderID);
GO

CREATE INDEX IX_OnlinePayment ON Order_.OnlinePayment (OrderID);
GO

CREATE INDEX IX_Shippings ON Shipping.Shippings (OrderID);
GO

CREATE UNIQUE INDEX IX_ShippingToItem ON Shipping.ShippingToItem (ShippingID, ProductID);
GO

CREATE INDEX IX_InStoreOrders ON Order_.InStoreOrders (CustomerID);
GO

CREATE UNIQUE INDEX IX_InStoreOrderToItem ON Order_.InStoreOrderToItem (OrderID, ProductID);
GO

CREATE INDEX IX_OnlineOrders ON Order_.OnlineOrders (CustomerID);
GO

CREATE UNIQUE INDEX IX_OnlineOrderToItem ON Order_.OnlineOrderToItem (OrderID, ProductID);
GO

CREATE INDEX IX_StoreOrders ON Order_.StoreOrders (StoreID);
GO

CREATE UNIQUE INDEX IX_StoreOrderToItem ON Order_.StoreOrderToItem (OrderID, ProductID);
GO

CREATE INDEX IX_WarehouseOrders ON Order_.WarehouseOrders (WarehouseID);
GO

CREATE UNIQUE INDEX IX_WarehouseOrderToItem ON Order_.WarehouseOrderToItem (OrderID, ProductID);
GO