USE master
GO

CREATE LOGIN JamesTaylor WITH PASSWORD = 'TarbetCustomer#1',
    DEFAULT_DATABASE = Tarbet;
GO

CREATE LOGIN Store1 WITH PASSWORD = 'TarbetStore#1',
    DEFAULT_DATABASE = Tarbet;
GO

CREATE LOGIN Warehouse1 WITH PASSWORD = 'TarbetWarehouse#1',
    DEFAULT_DATABASE = Tarbet;
GO

CREATE LOGIN Starbucks WITH PASSWORD = 'TarbetSupplier#1',
    DEFAULT_DATABASE = Tarbet;
GO

CREATE LOGIN Administrator1 WITH PASSWORD = 'TarbetAdministrator#1',
    DEFAULT_DATABASE = Tarbet;
GO