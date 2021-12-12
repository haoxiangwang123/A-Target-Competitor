USE Tarbet
GO

CREATE ROLE Visitor;
GRANT SELECT ON Product.Products TO Visitor;
GRANT SELECT ON Product.Reviews TO Visitor;
GRANT SELECT ON Store.Stores TO Visitor;
GRANT SELECT ON Warehouse.Warehouses TO Visitor;
GRANT SELECT ON Supplier.Suppliers TO Visitor;
GRANT SELECT ON OnlineAvailableProducts TO Visitor;
GRANT SELECT ON ProductSales TO Visitor;
GRANT SELECT ON ProductSalesVolume TO Visitor;
GRANT SELECT ON ProductStars TO Visitor;
GO

CREATE ROLE Customer;
ALTER ROLE Visitor ADD MEMBER Customer;
-- GRANT EXEC ON spCustomerCreateAccount TO Customer;
-- GRANT EXEC ON spCustomerShowBillingAddress TO Customer;
GRANT EXEC ON spCustomerAddBillingAddress TO Customer;
-- GRANT EXEC ON spCustomerDropBillingAddress TO Customer;
-- GRANT EXEC ON spCustomerShowShippingAddress TO Customer;
GRANT EXEC ON spCustomerAddShippingAddress TO Customer;
-- GRANT EXEC ON spCustomerDropShippingAddress TO Customer;
-- GRANT EXEC ON spCustomerShowCardList TO Customer;
-- GRANT EXEC ON spCustomerAddCreditCard TO Customer;
-- GRANT EXEC ON spCustomerDropCreditCard TO Customer;
GRANT EXEC ON spCustomerCreateOnlineOrder TO Customer;
-- GRANT EXEC ON spCustomerShowOnlineOrderList TO Customer;
-- GRANT EXEC ON spCustomerShowOnlineOrderList TO Customer;
GRANT EXEC ON spCustomerAddOnlineItem TO Customer;
GRANT EXEC ON spCustomerDropOnlineItem TO Customer;
GRANT EXEC ON spCustomerPlaceOnlineOrder TO Customer;
GRANT EXEC ON spCustomerPayOnlineOrder TO Customer;
GRANT EXEC ON spCustomerWriteReview TO Customer;
GRANT EXEC ON spCustomerCreateInStoreOrder TO Customer;
-- GRANT EXEC ON spCustomerShowInStoreOrderList TO Customer;
GRANT EXEC ON spCustomerAddInStoreItem TO Customer;
GRANT EXEC ON spCustomerDropInStoreItem TO Customer;
-- GRANT EXEC ON spCustomerPayInStoreOrder TO Customer;
-- GRANT EXEC ON spCustomerReturnProduct TO Customer;
GRANT EXEC ON spCustomerReturnShipping TO Customer;
GO

CREATE ROLE Store;
ALTER ROLE Visitor ADD MEMBER Store;
GRANT EXEC ON spStoreCreateOrder TO Store;
GRANT EXEC ON spStoreAddItemInOrder TO Store;
GRANT EXEC ON spStoreDropItemInOrder TO Store;
GRANT EXEC ON spStorePlaceOrder TO Store;
-- GRANT EXEC ON spStoreShowOrderList TO Store;
-- GRANT EXEC ON spStoreShowProductList TO Store;
GO

CREATE ROLE Warehouse;
ALTER ROLE Visitor ADD MEMBER Warehouse;
GRANT EXEC ON spWarehouseCreateOrder TO Warehouse;
-- GRANT EXEC ON spWarehouseAddItemInOrder TO Warehouse;
-- GRANT EXEC ON spWarehouseDropItemInOrder TO Warehouse;
-- GRANT EXEC ON spWarehousePlaceOrder TO Warehouse;
-- GRANT EXEC ON spWarehouseShowOrderList TO Warehouse;
-- GRANT EXEC ON spWarehouseShowProductList TO Warehouse;
GO

CREATE ROLE Supplier;
ALTER ROLE Visitor ADD MEMBER Supplier;
-- GRANT EXEC ON spSupplierCreateProduct TO Supplier;
GRANT EXEC ON spSupplierRestockProduct TO Supplier;
-- GRANT EXEC ON spSupplierShowProductList TO Supplier;
GO

CREATE ROLE TarbetAdministrator;
ALTER ROLE db_datareader ADD MEMBER TarbetAdministrator;
ALTER ROLE db_datawriter ADD MEMBER TarbetAdministrator;
GRANT EXEC ON spScheduleShipping TO TarbetAdministrator;
GRANT EXEC ON spShippingDelivered TO TarbetAdministrator;
GRANT EXEC ON spShippingReturned TO TarbetAdministrator;
GRANT EXEC ON spStoreOrderCompleted TO TarbetAdministrator;
-- GRANT EXEC ON spWarehouseOrderCompleted TO TarbetAdministrator;
-- GRANT EXEC ON spAlterProductPrice TO TarbetAdministrator;
GO
