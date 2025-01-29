-- Drop existing tables with CASCADE to remove dependent objects
DROP TABLE IF EXISTS public.order_details CASCADE;
DROP TABLE IF EXISTS public.orders CASCADE;
DROP TABLE IF EXISTS public.shippers CASCADE;
DROP TABLE IF EXISTS public.customers CASCADE;
DROP TABLE IF EXISTS public.employees CASCADE;
DROP TABLE IF EXISTS public.territories CASCADE;
DROP TABLE IF EXISTS public.regions CASCADE;
DROP TABLE IF EXISTS public.categories CASCADE;
DROP TABLE IF EXISTS public.suppliers CASCADE;
DROP TABLE IF EXISTS public.databasechangeloglock CASCADE;
DROP TABLE IF EXISTS public.databasechangelog CASCADE;



-- Employees table: Stores information about each employee
CREATE TABLE employees (
    employeeID INT PRIMARY KEY,  -- Unique ID for each employee
    lastName VARCHAR(255) NOT NULL,  -- Employee's last name
    firstName VARCHAR(255) NOT NULL,  -- Employee's first name
    title VARCHAR(255),  -- Employee's job title
    titleOfCourtesy VARCHAR(255),  -- Title of courtesy (e.g., Mr., Ms., Dr.)
    birthDate DATE,  -- Employee's birth date
    hireDate DATE,  -- Date when the employee was hired
    address VARCHAR(255),  -- Employee's address
    city VARCHAR(255),  -- Employee's city
    region VARCHAR(255),  -- Employee's region
    postalCode VARCHAR(255),  -- Employee's postal code
    country VARCHAR(255),  -- Employee's country
    homePhone VARCHAR(50),  -- Employee's home phone number
    extension VARCHAR(50),  -- Employee's extension number
    photo TEXT,  -- Employee's photo (stored as text, could be URL or binary)
    notes TEXT,  -- Additional notes about the employee
    reportsTo INT,  -- ID of the employee's manager (references another employee)
    photoPath TEXT  -- Path to the employee's photo (if applicable)
);
COMMENT ON TABLE employees IS 'Table containing employee information';
COMMENT ON COLUMN employees.employeeID IS 'Unique identifier for each employee';




-- Regions table: Stores information about regions
CREATE TABLE regions (
    regionID INT PRIMARY KEY,  -- Unique ID for each region
    regionDescription VARCHAR(255) NOT NULL  -- Description of the region
);
COMMENT ON TABLE regions IS 'Table containing region information';
COMMENT ON COLUMN regions.regionID IS 'Unique identifier for each region';

-- Categories table: Stores information about product categories
CREATE TABLE categories (
    categoryID INTEGER PRIMARY KEY,  -- Unique ID for each category
    categoryName VARCHAR(255) NOT NULL,  -- Name of the category
    description VARCHAR(255),  -- Description of the category
    picture TEXT  -- Image representing the category
);
COMMENT ON TABLE categories IS 'Table containing product category information';


-- Territories table: Stores information about sales territories
CREATE TABLE territories (
    territoryID INTEGER PRIMARY KEY,  -- Unique ID for each territory
    territoryDescription VARCHAR(255) NOT NULL,  -- Description of the territory
    regionID INTEGER NOT NULL,  -- Region to which the territory belongs (foreign key)
    FOREIGN KEY (regionID) REFERENCES regions(regionID)  -- Enforcing foreign key relationship
);
COMMENT ON TABLE territories IS 'Table containing information about sales territories';
COMMENT ON COLUMN territories.regionID IS 'ID of the region to which the territory belongs';



-- Employee-Territories table: Junction table to associate employees with territories
CREATE TABLE employee_territories (
    employeeID INTEGER NOT NULL,  -- Employee ID (foreign key)
    territoryID INTEGER NOT NULL,  -- Territory ID (foreign key)
);


COMMENT ON TABLE employee_territories IS 'Junction table to associate employees with territories';



-- Customers table: Stores customer information
CREATE TABLE customers (
    customerID VARCHAR(5) PRIMARY KEY,  -- Unique ID for each customer
    companyName VARCHAR(255) NOT NULL,  -- Customer's company name
    contactName VARCHAR(255),  -- Contact person for the customer
    contactTitle VARCHAR(255),  -- Contact person's title
    address VARCHAR(255),  -- Customer's address
    city VARCHAR(255),  -- Customer's city
    region VARCHAR(255),  -- Customer's region
    postalCode VARCHAR(255),  -- Customer's postal code
    country VARCHAR(255),  -- Customer's country
    phone VARCHAR(50),  -- Customer's phone number
    fax VARCHAR(50)  -- Customer's fax number
);
COMMENT ON TABLE customers IS 'Table containing customer information';



-- Suppliers table: Stores supplier information
CREATE TABLE suppliers (
    supplierID INTEGER PRIMARY KEY,  -- Unique ID for each supplier
    companyName VARCHAR(255) NOT NULL,  -- Supplier's company name
    contactName VARCHAR(255),  -- Contact person at the supplier
    contactTitle VARCHAR(255),  -- Contact person's title
    address VARCHAR(255),  -- Supplier's address
    city VARCHAR(255),  -- Supplier's city
    region VARCHAR(255),  -- Supplier's region
    postalCode VARCHAR(255),  -- Supplier's postal code
    country VARCHAR(255),  -- Supplier's country
    phone VARCHAR(50),  -- Supplier's phone number
    fax VARCHAR(50),  -- Supplier's fax number
    homePage VARCHAR(255)  -- Supplier's homepage URL
);
COMMENT ON TABLE suppliers IS 'Table containing supplier information';


-- Shippers table: Stores information about shippers
CREATE TABLE shippers (
    shipperID INTEGER PRIMARY KEY,  -- Unique ID for each shipper
    companyName VARCHAR(255) NOT NULL,  -- Shipper's company name
    phone VARCHAR(50)  -- Shipper's phone number
);
COMMENT ON TABLE shippers IS 'Table containing information about shipping companies';


-- Products table: Stores product information
CREATE TABLE products (
    productID INTEGER, 
    productName VARCHAR(255) NOT NULL,  -- Name of the product
    supplierID INTEGER,  -- Supplier of the product (foreign key)
    categoryID INTEGER,  -- Category of the product (foreign key)
    quantityPerUnit VARCHAR(255),  -- Quantity of product per unit
    unitPrice FLOAT,  -- Price of the product per unit
    unitsInStock INTEGER,  -- Available units in stock
    unitsOnOrder INTEGER,  -- Units on order
    reorderLevel INTEGER,  -- Reorder level for inventory
    discontinued BOOLEAN NOT NULL DEFAULT FALSE,  -- Indicates if the product is discontinued
    FOREIGN KEY (supplierID) REFERENCES suppliers(supplierID),  -- Enforcing foreign key relationship
    FOREIGN KEY (categoryID) REFERENCES categories(categoryID)  -- Enforcing foreign key relationship
);
COMMENT ON TABLE products IS 'Table containing product information';



-- Orders table: Stores order information
CREATE TABLE orders (
    orderID INT PRIMARY KEY,  -- Unique ID for each order
    customerID VARCHAR(5) NOT NULL,  -- Customer placing the order (foreign key)
    employeeID INTEGER NOT NULL,  -- Employee handling the order (foreign key)
    orderDate DATE NOT NULL,  -- Date the order was placed
    requiredDate DATE NOT NULL,  -- Date the order is required
    shippedDate DATE,  -- Date the order was shipped (nullable)
    shipVia INTEGER,  -- Shipper used to fulfill the order (foreign key)
    freight FLOAT,  -- Freight charges for the order
    shipName VARCHAR(255),  -- Shipping name
    shipAddress VARCHAR(255),  -- Shipping address
    shipCity VARCHAR(255),  -- Shipping city
    shipRegion VARCHAR(255),  -- Shipping region
    shipPostalCode VARCHAR(255),  -- Shipping postal code
    shipCountry VARCHAR(255),  -- Shipping country
    FOREIGN KEY (employeeID) REFERENCES employees(employeeID),  -- Enforcing foreign key relationship
    FOREIGN KEY (customerID) REFERENCES customers(customerID),  -- Enforcing foreign key relationship
    FOREIGN KEY (shipVia) REFERENCES shippers(shipperID)  -- Enforcing foreign key relationship
);
COMMENT ON TABLE orders IS 'Table containing order information';

-- OrderDetails table: Stores details for each order
CREATE TABLE order_details (
    orderID INT NOT NULL,  -- ID of the order (foreign key)
    productID INTEGER NOT NULL,  -- Product being ordered (foreign key)
    unitPrice FLOAT,  -- Unit price of the product
    quantity INTEGER,  -- Quantity of the product ordered
    discount FLOAT,  -- Discount applied to the order (if any)
    PRIMARY KEY (orderID, productID),  -- Composite primary key to ensure unique order-product pairs
    FOREIGN KEY (orderID) REFERENCES orders(orderID),  -- Enforcing foreign key relationship
    FOREIGN KEY (productID) REFERENCES products(productID)  -- Enforcing foreign key relationship
);
COMMENT ON TABLE order_details IS 'Table containing details about each order';



-- Indexing
CREATE INDEX IF NOT EXISTS idx_employeeID ON employees(employeeID);
CREATE INDEX IF NOT EXISTS idx_regionID ON territories(regionID);
CREATE INDEX IF NOT EXISTS idx_supplierID ON products(supplierID);
CREATE INDEX IF NOT EXISTS idx_categoryID ON products(categoryID);
CREATE INDEX IF NOT EXISTS idx_productID ON products(productID);
CREATE INDEX IF NOT EXISTS idx_shipperID ON shippers(shipperID);
CREATE INDEX IF NOT EXISTS idx_customerID ON customers(customerID);
CREATE INDEX IF NOT EXISTS idx_orderID ON orders(orderID);




-- Copy data into tables

COPY employees FROM '/docker-entrypoint-initdb.d/employees.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';
COPY regions FROM '/docker-entrypoint-initdb.d/regions.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';
COPY categories FROM '/docker-entrypoint-initdb.d/categories.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';
COPY suppliers FROM '/docker-entrypoint-initdb.d/suppliers.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';
COPY shippers FROM '/docker-entrypoint-initdb.d/shippers.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';
COPY customers FROM '/docker-entrypoint-initdb.d/customers.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';
COPY territories FROM '/docker-entrypoint-initdb.d/territories.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';
COPY employee_territories FROM '/docker-entrypoint-initdb.d/employee_territories.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';  -- Skip duplicates

COPY products FROM '/docker-entrypoint-initdb.d/products.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';  
COPY orders FROM '/docker-entrypoint-initdb.d/orders.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';
COPY order_details FROM '/docker-entrypoint-initdb.d/order_details.csv' WITH DELIMITER ',' CSV HEADER NULL AS 'NULL';

