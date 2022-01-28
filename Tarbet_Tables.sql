USE master
GO

IF DB_ID('Tarbet') IS NOT NULL
    DROP DATABASE Tarbet
GO

/****** Object:  Database Target2    ******/
CREATE DATABASE Tarbet
GO

USE Tarbet
GO

/****** Object:  SCHEMA Customer     ******/
CREATE SCHEMA Customer;
GO

/****** Object:  SCHEMA Address     ******/
CREATE SCHEMA Address;
GO

/****** Object:  SCHEMA Product     ******/
CREATE SCHEMA Product;
GO

/****** Object:  SCHEMA Order_     ******/
CREATE SCHEMA Order_;
GO

/****** Object:  SCHEMA Shipping     ******/
CREATE SCHEMA Shipping;
GO

/****** Object:  SCHEMA Store     ******/
CREATE SCHEMA Store;
GO

/****** Object:  SCHEMA Warehouse     ******/
CREATE SCHEMA Warehouse;
GO

/****** Object:  SCHEMA Supplier     ******/
CREATE SCHEMA Supplier;
GO

/****** Object:  Table ZipList     ******/
CREATE TABLE Address.ZipList(
    Zip char(5) NOT NULL,
    Latitude float NOT NULL,
    Longitude float NOT NULL,
    PRIMARY KEY (Zip),
    CONSTRAINT CHK_Zip CHECK (LEN(Zip) = 5),
    CONSTRAINT CHK_LatLng CHECK ((Latitude BETWEEN -90 AND 90) AND (Longitude BETWEEN -180 AND 180))
)
GO

/****** Object:  Table Addresses     ******/
CREATE TABLE Address.Addresses(
    AddressID int IDENTITY(1, 1) NOT NULL,
    Street varchar(100) NOT NULL,
    City varchar(20) NOT NULL,
    State varchar(20) NOT NULL,
    Zip char(5) NOT NULL,
    PRIMARY KEY (AddressID),
    FOREIGN KEY (Zip) REFERENCES Address.ZipList(Zip)
)
GO

/****** Object:  Table Customers     ******/
CREATE TABLE Customer.Customers(
    CustomerID int IDENTITY(1, 1) NOT NULL, 
    FirstName varchar(50) NOT NULL, 
    LastName varchar(50) NOT NULL, 
    UserName varchar(50) NOT NULL UNIQUE, 
    Email varchar(100), 
    HomePhone varchar(20), 
    CellPhone varchar(20), 
    BusinessPhone varchar(20),
    PRIMARY KEY (CustomerID)
)
GO

/****** Object:  Table ShippingAddressList     ******/
CREATE TABLE Customer.ShippingAddressList(
    CustomerID int NOT NULL,
    AddressID int NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer.Customers(CustomerID),
    FOREIGN KEY (AddressID) REFERENCES Address.Addresses(AddressID)
)
GO

/****** Object:  Table BillingAddressList     ******/
CREATE TABLE Customer.BillingAddressList(
    CustomerID int NOT NULL,
    AddressID int NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer.Customers(CustomerID),
    FOREIGN KEY (AddressID) REFERENCES Address.Addresses(AddressID)
)
GO

/****** Object:  Table CreditCards     ******/
CREATE TABLE Customer.CreditCards(
    CardID int IDENTITY(1, 1) NOT NULL,
    CardNum varchar(20) NOT NULL,
    OwnerName varchar(100),
    ExpireDate date,
    PRIMARY KEY (CardID)
)
GO

/****** Object:  Table CardList     ******/
CREATE TABLE Customer.CardList(
    CustomerID int NOT NULL,
    CardID int NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customer.Customers(CustomerID),
    FOREIGN KEY (CardID) REFERENCES Customer.CreditCards(CardID)
)
GO

/****** Object:  Table Products     ******/
CREATE TABLE Product.Products(
    ProductID int IDENTITY(1, 1) NOT NULL,
    ProductName varchar(50) NOT NULL,
    Description varchar(1000),
    UnitPrice money NOT NULL,
    AvgScore float,
    PRIMARY KEY (ProductID)
)
GO

/****** Object:  Table Reviews     ******/
CREATE TABLE Product.Reviews(
    ReviewID int IDENTITY(1, 1) NOT NULL,
    ProductID int NOT NULL,
    CustomerID int NOT NULL,
    Text varchar(1000),
    Score float NOT NULL,
    ReviewDate datetime NOT NULL,
    PRIMARY KEY (ReviewID),
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES Customer.Customers(CustomerID),
    CONSTRAINT CHK_Score CHECK (Score BETWEEN 0.0 AND 5.0)
)
GO

/****** Object:  Table WishList     ******/
CREATE TABLE Customer.WishList(
    CustomerID int NOT NULL,
    ProductID int NOT NULL,
    Quantity int NOT NULL DEFAULT 1,
    FOREIGN KEY (CustomerID) REFERENCES Customer.Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    CONSTRAINT CHK_WishQuantity CHECK (Quantity >= 0)
)
GO


/****** Object:  Table Suppliers     ******/
CREATE TABLE Supplier.Suppliers(
    SupplierID int IDENTITY(1, 1) NOT NULL,
    SupplierName varchar(50) NOT NULL,
    UserName varchar(50) NOT NULL UNIQUE, 
    AddressID int NOT NULL UNIQUE,
    Phone varchar(20),
    Fax varchar(20),
    Email varchar(100),
    Webpage varchar(100),
    PRIMARY KEY (SupplierID),
    FOREIGN KEY (AddressID) REFERENCES Address.Addresses(AddressID)
)
GO

/****** Object:  Table ProductDetail     ******/
CREATE TABLE Supplier.ProductDetail(
    ProductID int NOT NULL,
    SupplierID int NOT NULL,
    AvailableNumber int NOT NULL DEFAULT 0,
    PRIMARY KEY (ProductID),
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    FOREIGN KEY (SupplierID) REFERENCES Supplier.Suppliers(SupplierID),
    CONSTRAINT CHK_SupplierAvailable CHECK (AvailableNumber >= 0)
)
GO

/****** Object:  Table Warehouses     ******/
CREATE TABLE Warehouse.Warehouses(
    WarehouseID int IDENTITY(1, 1) NOT NULL,
    UserName varchar(50) NOT NULL UNIQUE, 
    AddressID int NOT NULL UNIQUE,
    Phone varchar(20),
    Fax varchar(20),
    Email varchar(100),
    PRIMARY KEY (WarehouseID),
    FOREIGN KEY (AddressID) REFERENCES Address.Addresses(AddressID)
)
GO

/****** Object:  Table WarehouseProductList     ******/
CREATE TABLE Warehouse.WarehouseProductList(
    WarehouseID int NOT NULL,
    ProductID int NOT NULL,
    InStock int NOT NULL DEFAULT 0,
    OnWay int NOT NULL DEFAULT 0,
    InReturn int NOT NULL DEFAULT 0,
    PRIMARY KEY (WarehouseID, ProductID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouse.Warehouses(WarehouseID),
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    CONSTRAINT CHK_WarehouseAvailable CHECK (InStock >= 0 AND OnWay >=0 AND InReturn >=0)
)
GO

/****** Object:  Table Stores     ******/
CREATE TABLE Store.Stores(
    StoreID int IDENTITY(1, 1) NOT NULL,
    UserName varchar(50) NOT NULL UNIQUE, 
    AddressID int NOT NULL UNIQUE,
    Phone varchar(20),
    Fax varchar(20),
    Email varchar(100),
    PRIMARY KEY (StoreID),
    FOREIGN KEY (AddressID) REFERENCES Address.Addresses(AddressID)
)
GO

/****** Object:  Table StoreProductList     ******/
CREATE TABLE Store.StoreProductList(
    StoreID int NOT NULL,
    ProductID int NOT NULL,
    Price money NOT NULL,
    Quantity int NOT NULL,
    PRIMARY KEY (StoreID, ProductID),
    FOREIGN KEY (StoreID) REFERENCES Store.Stores(StoreID),
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    CONSTRAINT CHK_StoreQuantity CHECK (Quantity >= 0)
)
GO

/****** Object:  Table InStoreOrders     ******/
CREATE TABLE Order_.InStoreOrders(
    OrderID int IDENTITY(1, 1) NOT NULL,
    CustomerID int NOT NULL,
    OrderDate datetime NOT NULL,
    StoreID int NOT NULL,
    TotalPrice money NOT NULL DEFAULT 0,
    PRIMARY KEY (OrderID),
    FOREIGN KEY (CustomerID) REFERENCES Customer.Customers(CustomerID),
    FOREIGN KEY (StoreID) REFERENCES Store.Stores(StoreID)
)
GO

/****** Object:  Table InStoreOrderToItem     ******/
CREATE TABLE Order_.InStoreOrderToItem(
    OrderID int NOT NULL,
    ProductID int NOT NULL,
    Quantity int NOT NULL, 
    UnitPrice money NOT NULL, 
    FOREIGN KEY (OrderID) REFERENCES Order_.InStoreOrders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    CONSTRAINT CHK_InStoreOrderQuantity CHECK (Quantity >= 0)
)
GO

/****** Object:  Table InStorePayment     ******/
CREATE TABLE Order_.InStorePayment(
    PaymentID int IDENTITY(1, 1) NOT NULL,
    OrderID int NOT NULL,
    PaymentTotal money NOT NULL,
    CardNumber varchar(20) NOT NULL,
    PayDate datetime NOT NULL,
    PRIMARY KEY (PaymentID),
    FOREIGN KEY (OrderID) REFERENCES Order_.InStoreOrders(OrderID),
)
GO

/****** Object:  Table OnlineOrders     ******/
CREATE TABLE Order_.OnlineOrders(
    OrderID int IDENTITY(1, 1) NOT NULL,
    CustomerID int NOT NULL,
    Locked bit NOT NULL DEFAULT 0,
    OrderDate datetime,
    TotalPrice money NOT NULL DEFAULT 0,
    PayDueDate datetime,
    AddressID int,
    PRIMARY KEY (OrderID),
    FOREIGN KEY (CustomerID) REFERENCES Customer.Customers(CustomerID),
    FOREIGN KEY (AddressID) REFERENCES Address.Addresses(AddressID),
    CONSTRAINT CHK_PayDueDate CHECK (PayDueDate > OrderDate)
)
GO

/****** Object:  Table OnlineOrderToItem     ******/
CREATE TABLE Order_.OnlineOrderToItem(
    OrderID int NOT NULL,
    ProductID int NOT NULL,
    Quantity int NOT NULL, 
    UnitPrice money NOT NULL, 
    FOREIGN KEY (OrderID) REFERENCES Order_.OnlineOrders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    CONSTRAINT CHK_OnlineOrderQuantity CHECK (Quantity >= 0)
)
GO

/****** Object:  Table OnlinePayment     ******/
CREATE TABLE Order_.OnlinePayment(
    PaymentID int IDENTITY(1, 1) NOT NULL,
    OrderID int NOT NULL,
    PaymentTotal money NOT NULL,
    CardNumber varchar(20) NOT NULL,
    PayDate datetime NOT NULL,
    PRIMARY KEY (PaymentID),
    FOREIGN KEY (OrderID) REFERENCES Order_.OnlineOrders(OrderID),
)
GO

/****** Object:  Table Shippings     ******/
CREATE TABLE Shipping.Shippings(
    ShippingID int IDENTITY(1, 1) NOT NULL,
    OrderID int NOT NULL,
    ShippingService varchar(20) NOT NULL, 
    Status varchar(10) NOT NULL, 
    StartAddressID int NOT NULL,
    ArriveAddressID int NOT NULL, 
    ShippingFare money NOT NULL DEFAULT 0, 
    StartDate datetime, 
    ExpectedShippingDate datetime, 
    ActualShippingDate datetime,
    PRIMARY KEY (ShippingID),
    FOREIGN KEY (OrderID) REFERENCES Order_.OnlineOrders(OrderID),
    FOREIGN KEY (StartAddressID) REFERENCES Address.Addresses(AddressID),
    FOREIGN KEY (ArriveAddressID) REFERENCES Address.Addresses(AddressID),
    CONSTRAINT CHK_ShippingService CHECK (ShippingService IN ('USPS', 'FedEx', 'UPS')),
    CONSTRAINT CHK_Status CHECK (Status IN ('Ready', 'Shipped', 'Delivered', 'Returned')),
)
GO

/****** Object:  Table ShippingToItem     ******/
CREATE TABLE Shipping.ShippingToItem(
    ShippingID int NOT NULL,
    ProductID int NOT NULL,
    Quantity int NOT NULL, 
    FOREIGN KEY (ShippingID) REFERENCES Shipping.Shippings(ShippingID),
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    CONSTRAINT CHK_ShippingQuantity CHECK (Quantity >= 0)
)
GO

/****** Object:  Table StoreOrders     ******/
CREATE TABLE Order_.StoreOrders(
    OrderID int IDENTITY(1, 1) NOT NULL,
    StoreID int NOT NULL,
    OrderDate datetime,
    TotalPrice money NOT NULL DEFAULT 0,
    PRIMARY KEY (OrderID),
    FOREIGN KEY (StoreID) REFERENCES Store.Stores(StoreID)
)
GO

/****** Object:  Table StoreOrderToItem     ******/
CREATE TABLE Order_.StoreOrderToItem(
    OrderID int NOT NULL,
    ProductID int NOT NULL,
    Quantity int NOT NULL, 
    UnitPrice money NOT NULL, 
    FOREIGN KEY (OrderID) REFERENCES Order_.StoreOrders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    CONSTRAINT CHK_StoreOrderQuantity CHECK (Quantity >= 0)
)
GO

/****** Object:  Table WarehouseOrders     ******/
CREATE TABLE Order_.WarehouseOrders(
    OrderID int IDENTITY(1, 1) NOT NULL,
    WarehouseID int NOT NULL,
    OrderDate datetime,
    TotalPrice money NOT NULL DEFAULT 0,
    PRIMARY KEY (OrderID),
    FOREIGN KEY (WarehouseID) REFERENCES Warehouse.Warehouses(WarehouseID)
)
GO

/****** Object:  Table WarehouseOrderToItem     ******/
CREATE TABLE Order_.WarehouseOrderToItem(
    OrderID int NOT NULL,
    ProductID int NOT NULL,
    Quantity int NOT NULL, 
    UnitPrice money NOT NULL, 
    FOREIGN KEY (OrderID) REFERENCES Order_.WarehouseOrders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Product.Products(ProductID),
    CONSTRAINT CHK_WarehouseOrderQuantity CHECK (Quantity >= 0)
)
GO
