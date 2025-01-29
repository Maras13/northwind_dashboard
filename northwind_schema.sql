DROP TABLE IF EXISTS public.databasechangeloglock;
DROP TABLE IF EXISTS public.databasechangelog;

-- Create tables with improved structure, data integrity, and consistency

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
    photoPath TEXT,  -- Path to the employee's photo (if applicable)
    UNIQUE (employeeID)  -- Ensure employeeID is unique across the table
);
COMMENT ON TABLE employees IS 'Table containing employee information';
COMMENT ON COLUMN employees.employeeID IS 'Unique identifier for each employee';

-- Indexing for employeeID (commonly queried for joins)
CREATE INDEX idx_employeeID ON employees(employeeID);

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

-- Indexing for categoryID (commonly queried for product lookups)
CREATE INDEX idx_categoryID ON categories(categoryID);

-- Territories table: Stores information about sales territories
CREATE TABLE territories (
    territoryID INTEGER PRIMARY KEY,  -- Unique ID for each territory
    territoryDescription VARCHAR(255) NOT NULL,  -- Description of the territory
    regionID INTEGER NOT NULL,  -- Region to which the territory belongs (foreign key)
    FOREIGN KEY (regionID) REFERENCES regions(regionID)  -- Enforcing foreign key relationship
);
COMMENT ON TABLE territories IS 'Table containing information about sales territories';
COMMENT ON COLUMN territories.regionID IS 'ID of the region to which the territory belongs';

-- Indexing for regionID in territories (for fast lookup)
CREATE INDEX idx_regionID ON territories(regionID);

-- Employee-Territories table: Junction table to associate employees with territories
CREATE TABLE employee_territories (
    employeeID INTEGER NOT NULL,  -- Employee ID (foreign key)
    territoryID INTEGER NOT NULL,  -- Territory ID (foreign key)
    FOREIGN KEY (employeeID) REFERENCES employees(employeeID),  -- Enforcing foreign key relationship
    FOREIGN KEY (territoryID) REFERENCES territories(territoryID),  -- Enforcing foreign key relationship
    PRIMARY KEY (employeeID, territoryID)  -- Composite primary key to ensure unique associations
);
COMMENT ON TABLE employee_territories IS 'Junction table to associate employees with territories';

-- Indexing for employeeID and territoryID in employee_territories (for faster joins)
CREATE INDEX idx_employeeID_territoryID ON employee_territories(employeeID, territoryID);

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

-- Indexing for customerID (commonly queried in orders)
CREATE INDEX idx_customerID ON customers(customerID);

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

-- Indexing for supplierID (commonly queried in products)
CREATE INDEX idx_supplierID ON suppliers(supplierID);

-- Shippers table: Stores information about shippers
CREATE TABLE shippers (
    shipperID INTEGER PRIMARY KEY,  -- Unique ID for each shipper
    companyName VARCHAR(255) NOT NULL,  -- Shipper's company name
    phone VARCHAR(50)  -- Shipper's phone number
);
COMMENT ON TABLE shippers IS 'Table containing information about shipping companies';

-- Indexing for shipperID (commonly queried in orders)
CREATE INDEX idx_shipperID ON shippers(shipperID);

-- Products table: Stores product information
CREATE TABLE products (
    productID INTEGER PRIMARY KEY,  -- Unique ID for each product
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

-- Indexing for productID, supplierID, and categoryID (for faster lookups)
CREATE INDEX idx_productID ON products(productID);
CREATE INDEX idx_supplierID_products ON products(supplierID);
CREATE INDEX idx_categoryID_products ON products(categoryID);

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

-- Indexing for orderID, employeeID, and customerID (frequent query fields)
CREATE INDEX idx_orderID ON orders(orderID);
CREATE INDEX idx_employeeID_orders ON orders(employeeID);
CREATE INDEX idx_customerID_orders ON orders(customerID);

-- Order Details table: Stores details about each product in an order
CREATE TABLE order_details (
    orderID INTEGER NOT NULL,  -- Order ID (foreign key)
    productID INTEGER NOT NULL,  -- Product ID (foreign key)
    unitPrice FLOAT NOT NULL,  -- Price per unit of the product
    quantity INTEGER NOT NULL,  -- Quantity of the product ordered
    discount FLOAT NOT NULL,  -- Discount applied to the product
    PRIMARY KEY (order
