


--Get the names and the quantities units in stock for each product.

SELECT product_name, units_in_stock 
FROM products;


--Get a list of customers who are located in 'Germany'.


SELECT * FROM customers
WHERE country = 'Germany';


--Average days to ship

SELECT 
    AVG(CAST(shipped_date - order_date AS INTEGER)) AS AvgDaysToShip
FROM orders
WHERE shipped_date IS NOT NULL;



--Get a list of current products (Product ID and name).


SELECT product_id, product_name 
FROM products;

--Get a list of the most and least expensive products (name and unit price).

SELECT product_name, unit_price
FROM products
WHERE unit_price = (SELECT MIN(unit_price) FROM products)
   OR unit_price = (SELECT MAX(unit_price) FROM products);



--Get products that cost less than $20.

SELECT product_name, unit_price
FROM products
WHERE unit_price < 20;


--Get products that cost between $15 and $25.

SELECT product_name, unit_price
FROM products
WHERE unit_price BETWEEN 15 AND 20;

--Find the products with prices above the average price.


SELECT product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products);



--Find the ten most expensive products.



SELECT product_name, unit_price
FROM products
ORDER BY unit_price DESC
LIMIT 10;


--Get a list of discontinued products (Product ID and name).
SELECT product_name,
       unit_price
FROM   products
WHERE  discontinued = TRUE;


--Count current and discontinued products.

SELECT 
    COUNT(CASE WHEN discontinued = FALSE THEN 1 END) AS current_products,
    COUNT(CASE WHEN discontinued = TRUE THEN 1 END) AS discontinued_products
FROM products;




--Find products with less units in stock than the quantity on order.

SELECT product_name, units_in_stock, units_on_order
FROM products
WHERE units_in_stock < units_on_order;



--Find the customer who had the highest order amount

SELECT contact_name, SUM(od.unit_price * od.quantity) as total_amount_order
FROM customers c
JOIN orders o on c.customer_id = o.customer_id
JOIN order_details od on o.order_id = od.order_id
GROUP BY c.customer_id
ORDER BY total_amount_order DESC
LIMIT 1;




--Get orders for a given employee and the according customer

SELECT o.order_id, o.order_date, c.contact_name AS customer_name
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.employee_id = 5;



--Find the hiring age of each employee

SELECT 
    first_name,
    last_name,
    birth_date,
    hire_date,
    EXTRACT(YEAR FROM age(hire_date, birth_date)) AS hiring_age
FROM employees
ORDER BY hiring_age;


-- Get number of customers in each city
SELECT city, COUNT(*) AS num_customers
FROM customers
GROUP BY city;


--Find the total number of orders placed by each customer.
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id;


---Get the average price of products for each category.

SELECT category_id, AVG(unit_price) AS avg_price
FROM products
GROUP BY category_id;

--Get a list of employees and their assigned territories.

SELECT e.first_name, e.last_name, t.territory_description
FROM employees e
JOIN employee_territories et ON e.employee_id = et.employee_id
JOIN territories t ON et.territory_id = t.territory_id;


--Get the orders that contain products in the 'Beverages' category.

SELECT o.order_id
FROM orders o
WHERE o.order_id IN (
    SELECT od.order_id
    FROM order_details od
    JOIN products p ON od.product_id = p.product_id
    WHERE p.category_id = (SELECT category_id FROM categories WHERE category_name = 'Beverages')
);


--Get the total number of orders placed in the year 1997.
SELECT COUNT(*)
FROM orders
WHERE EXTRACT(YEAR FROM order_date) = 1997;

--Find all employees who were hired in the month of March.
SELECT first_name, last_name, hire_date
FROM employees
WHERE EXTRACT(MONTH FROM hire_date) = 3;

--Find products ordered the most.

SELECT p.product_name, SUM(od.quantity) AS total_quantity
FROM order_details od
INNER JOIN products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 1;


--Create a report showing the total sales for each region
-- (based on employee territories

SELECT 
    e.region,
    SUM(od.quantity * p.unit_price) AS total_sales
FROM 
    employees e
JOIN 
    employee_territories et ON e.employee_id = et.employee_id
JOIN 
    territories t ON et.territory_id = t.territory_id
JOIN 
    orders o ON o.employee_id = e.employee_id
JOIN 
    order_details od ON o.order_id = od.order_id
JOIN 
    products p ON od.product_id = p.product_id
GROUP BY 
    e.region
ORDER BY 
    total_sales DESC;



--Find customers who ordered products in more than one category

SELECT 
    c.contact_name AS customer_name
FROM 
    customers c
JOIN 
    orders o ON c.customer_id = o.customer_id
JOIN 
    order_details od ON o.order_id = od.order_id
JOIN 
    products p ON od.product_id = p.product_id
JOIN 
    categories cat ON p.category_id = cat.category_id
GROUP BY 
    c.customer_id
HAVING 
    COUNT(DISTINCT p.category_id) > 1;


-- Generate a summary report for each product category showing the total quantity sold, total sales, 
--and number of orders

SELECT 
    cat.category_name,
    SUM(od.quantity) AS total_quantity_sold,
    SUM(od.quantity * p.unit_price) AS total_sales,
    COUNT(DISTINCT o.order_id) AS number_of_orders
FROM 
    categories cat
JOIN 
    products p ON cat.category_id = p.category_id
JOIN 
    order_details od ON p.product_id = od.product_id
JOIN 
    orders o ON od.order_id = o.order_id
GROUP BY 
    cat.category_name
ORDER BY 
    total_sales DESC;

--Rank employees based on their total sales.

SELECT e.first_name, e.last_name, SUM(od.quantity * p.unit_price) AS total_sales,
       RANK() OVER (ORDER BY SUM(od.quantity * p.unit_price) DESC) AS sales_rank
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY e.employee_id;


-- Calculate running total sales per order.

SELECT o.order_id, o.order_date, 
       SUM(od.quantity * p.unit_price) AS order_sales,
       SUM(SUM(od.quantity * p.unit_price)) OVER (ORDER BY o.order_date) AS running_total_sales
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date;



--Find the difference in sales between each order and the previous order
SELECT o.order_id, o.order_date, 
       SUM(od.quantity * p.unit_price) AS order_sales,
       LAG(SUM(od.quantity * p.unit_price)) OVER (ORDER BY o.order_date) AS previous_order_sales,
       SUM(od.quantity * p.unit_price) - 
       LAG(SUM(od.quantity * p.unit_price)) OVER (ORDER BY o.order_date) AS sales_difference
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
GROUP BY o.order_id, o.order_date
ORDER BY o.order_date;


--Find the total sales per product and then get the top 5 selling products

WITH ProductSales AS (
    SELECT p.product_name, SUM(od.quantity * p.unit_price) AS total_sales
    FROM products p
    JOIN order_details od ON p.product_id = od.product_id
    GROUP BY p.product_name
)
SELECT product_name, total_sales
FROM ProductSales
ORDER BY total_sales DESC
LIMIT 5;


--Find customers who have made orders worth more than $500
SELECT c.customer_id, c.contact_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    WHERE o.customer_id = c.customer_id
    GROUP BY o.order_id
    HAVING SUM(od.quantity * p.unit_price) > 500
);

--Create a function to calculate the total sales for a given employee

CREATE OR REPLACE FUNCTION increase_employee_salary(emp_id INT, percent_increase DECIMAL) 
RETURNS VOID AS $$
BEGIN
    UPDATE employees
    SET salary = salary * (1 + percent_increase / 100)
    WHERE employee_id = emp_id;
END;
$$ LANGUAGE plpgsql;



SELECT total_sales_by_employee(5);




--Create a function to calculate a customer’s lifetime value
CREATE OR REPLACE FUNCTION lifetime_value_by_customer(cust_id TEXT)
RETURNS DECIMAL AS $$
DECLARE
    total_value DECIMAL;
BEGIN
    SELECT SUM(od.quantity * p.unit_price) INTO total_value
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    JOIN products p ON od.product_id = p.product_id
    WHERE o.customer_id = cust_id; 
    
    RETURN total_value;
END;
$$ LANGUAGE plpgsql;


SELECT lifetime_value_by_customer('FISSA');


-- Orders per category and year
SELECT 
    c.category_name,
    EXTRACT(YEAR FROM o.order_date) AS order_year,
    COUNT(DISTINCT od.order_id) AS OrderCount
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name, order_year
ORDER BY order_year, order_count DESC;


-- Top 5 earners(revenue per employee)
SEECT e.first_name, e.last_name, e.title, 
DATE_PART('year',AGE(e.hire_date, e.birth_date)) AS hiring_age,
c.company_name,
SUM(od.unit_price*od.quantity) as revenue_per_employee,
o.order_id 
FROM orders o 
JOIN employees e ON o.employee_id=e.employee_id 
JOIN order_details od ON od.order_id=o.order_id 
JOIN customers c on o.customer_id=c.customer_id
group by emp.first_name, emp.last_name, e.title, hiring_age, c.company_name,o.orderid
ORDER BY revenue_per_employee DESC
Limit 5;

--- revenue per country

select c.category_name,
o.ship_country,
SUM(od.unit_price*od.quantity) as revenue
from categories c
join  products p on p.category_id = c.category_id
join order_details od on od.product_id=p.product_id
join orders o on o.order_id=od.order_id
group by c.category_name,o.ship_country;
