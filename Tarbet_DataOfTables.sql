USE Tarbet
GO

DELETE Store.StoreProductList;
DELETE Warehouse.WarehouseProductList;
DELETE Supplier.ProductDetail;
DELETE Product.Products;
DELETE Warehouse.Warehouses;
DELETE Store.Stores;
DELETE Supplier.Suppliers;
DELETE Customer.Customers;
DELETE Address.Addresses;
GO

SET IDENTITY_INSERT Address.Addresses ON 
INSERT INTO Address.Addresses (AddressID, Street, City, State, Zip) VALUES
    (1, '302 Marshall St', 'Syracuse', 'NY', '13210'),
    (2, '120 L St', 'Boston', 'MA', '02127'),
    (3, '1501 NW 56th St', 'Seattle', 'WA', '98107'),
    (4, '4375 Payne Ave', 'San Jose', 'CA', '95117'),
    (5, '8770 Dell Center Dr', 'Liverpool', 'NY', '13090'),
    (6, '5399 W Genesee St', 'Camillus', 'NY', '13031'),
    (7, '6438 Basile Rowe', 'Syracuse', 'NY', '13057'),
    (8, '12620 SE 41st Pl', 'Bellevue', 'WA', '98006'),
    (9, '3816 Smith Ave', 'Everett', 'WA', '98201'),
    (10, '1425 N Rabe Ave UNIT 102', 'Fresno', 'CA', '93727'),
    (11, '320 4th Ave N', 'Franklin', 'TN', '37064'),
    (12, '2474 State Rte 21', 'Canandaigua', 'NY', '14424'),
    (13, '1 Coca Cola Pl SE', 'Atlanta', 'GA', '30313'),
    (14, '2401 Utah Ave S', 'Seattle', 'WA', '98134'),
    (15, 'One Apple Park Way', 'Cupertino', 'CA', '95014'),
    (16, '1 Dell Way', 'Round Rock', 'TX', '78681');
SET IDENTITY_INSERT Address.Addresses OFF
GO

SET IDENTITY_INSERT Customer.Customers ON 
INSERT INTO Customer.Customers (CustomerID, FirstName, LastName, UserName) VALUES
    (1, 'James', 'Taylor', 'JamesTaylor'),
    (2, 'Robert', 'Evans', 'RobertEvans'),
    (3, 'John', 'Smith', 'JohnSmith'),
    (4, 'William', 'Davies', 'WilliamDavies');
SET IDENTITY_INSERT Customer.Customers OFF
GO

SET IDENTITY_INSERT Store.Stores ON 
INSERT INTO Store.Stores (StoreID, UserName, AddressID) VALUES
    (1, 'Store1', 5),
    (2, 'Store2', 6),
    (3, 'Store3', 7),
    (4, 'Store4', 8);
SET IDENTITY_INSERT Store.Stores OFF
GO

SET IDENTITY_INSERT Warehouse.Warehouses ON 
INSERT INTO Warehouse.Warehouses (WarehouseID, UserName, AddressID) VALUES
    (1, 'Warehouse1', 9),
    (2, 'Warehouse2', 10),
    (3, 'Warehouse3', 11),
    (4, 'Warehouse4', 12);
SET IDENTITY_INSERT Warehouse.Warehouses OFF
GO

SET IDENTITY_INSERT Supplier.Suppliers ON 
INSERT INTO Supplier.Suppliers (SupplierID, SupplierName, UserName, AddressID) VALUES
    (1, 'Coco-Cola Company', 'Coco-Cola', 13),
    (2, 'Starbucks Coffee Company', 'Starbucks', 14),
    (3, 'Apple Inc.', 'Apple', 15),
    (4, 'Dell Inc.', 'Dell', 16);
SET IDENTITY_INSERT Supplier.Suppliers OFF
GO

SET IDENTITY_INSERT Product.Products ON 
INSERT INTO Product.Products (ProductID, ProductName, UnitPrice) VALUES
    (1, 'Coco-Cola Coke 18 pack', 34.99),
    (2, 'Starbucks Frappuccino Coffee Drink', 2.99),
    (3, 'Apple iPhone 13 (256GB, Starlight)', 929.00),
    (4, 'Dell Inspiron 24 5400', 979.99);
SET IDENTITY_INSERT Product.Products OFF
GO

INSERT INTO Supplier.ProductDetail (ProductID, SupplierID, AvailableNumber) VALUES
    (1, 1, 10000),
    (2, 2, 50000),
    (3, 3, 3000),
    (4, 4, 1000);
GO

INSERT INTO Store.StoreProductList (ProductID, StoreID, Price, Quantity) VALUES
    (1, 1, 34.99, 100),
    (1, 2, 2.99, 200),
    (1, 3, 929.00, 10),
    (1, 4, 979.99, 5);
GO

INSERT INTO Warehouse.WarehouseProductList (WarehouseID, ProductID, InStock) VALUES
    (1, 1, 1000),
    (1, 2, 2000),
    (1, 3, 200),
    (2, 1, 1000),
    (2, 2, 2000),
    (2, 3, 300),
    (3, 1, 500),
    (3, 2, 1000),
    (4, 1, 500),
    (4, 2, 1000);
GO