This project design a shopping database for a Target competitor, which has in store and online sales. An initial list of suggested information to be included in this database is listed below. Several business considerations shall also be considered such as each online order has a single shipping address and can contain multiple products from one or more warehouses. Multiple warehouses may have the same product and the originating warehouse for a shipment is chosen based on the shipping time and cost, which can be determined by the zip codes of the originating warehouse and the shipping address. Suppliers may also have multiple products in various warehouses. Stores can also place orders to deliver products from warehouses to stores for in store purchases. Product quantity in stores and warehouses need also to be updated based on transactions.  

**Customers:**
- Customer ID, name, username, email, phone numbers (home, cell, business), address book (several shipping/billing addresses), credit card information
- Online orders, in-store purchases, returns
- Wishlist
- Reviews (date, product, score, text)  

**Products:**
- Product ID, product name, description, price, customer ratings (text, score, date)  

**Suppliers:**
- Supplier ID, name, address, phone, fax, email, webpage
- Products information (product, number of products available, unit price)  

**Warehouses:**
- Warehouse ID, address, phone, fax, email
- Stored products (product, number in stock, number on the way, number in return)  

**Stores:**
- Store ID, address, phone, fax, email, webpage
- Products (product, price, quantity)  

**Online Orders/Returns:**
- Order ID, status (ready, shipped, delivered, returned), order date, order items (product, quantity, unit price, total price)
- Shipping service (USPS, FedEx, UPS), shipping address
- Shipping fare (depending on the address between the warehouse and the shipping address)
- Expected shipping date, actual shipping date, any shipping information
