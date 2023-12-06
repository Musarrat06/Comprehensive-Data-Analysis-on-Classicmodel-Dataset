Use classicmodels;
SELECT * FROM classicmodels.customers;
SELECT * FROM classicmodels.orders;
SELECT * FROM classicmodels.orderdetails;
SELECT * FROM classicmodels.employees;

SELECT * FROM classicmodels.products;
SELECT * FROM classicmodels.offices;

/* 1. Select all different status in which the product in. */
select distinct(status)
from orders;

/* 2. List all the employee's job titles.  */
select distinct(jobTitle)
from employees;

/* 3. List all the products along with their product scale. */
select productCode, productName, productLine, productScale 
from products
group by productScale, productCode, productName, productLine;

/* 4. List all the territories where we have offices. */
select distinct(territory)
from offices;

/* 5. select customers who do not have a credit limit (with zero credit limit). */
select * from customers 
where creditLimit = 0;

/* 6. List all offices not in the USA. */
select * from offices 
where country != 'USA';

/* 7. List all orders that shipped after the required date */
select *
from orders
where shippedDate > requiredDate;

/* 8. List all customers who have the word 'Mini' in their name. */
select * from customers 
where customerName like '%Mini%';

/* 9. List all products supplied by 'Highway 66 Mini Classics'. */
select * from products 
where productVendor = 'Highway 66 Mini Classics';

/* 10. List all product not supplied by 'Highway 66 Mini Classics'. */
select * from products 
where productVendor != 'Highway 66 Mini Classics';

/* 11. List all employees that don't have a manager. */
select * from employees 
where reportsTo is null;

/* 12. Display every order along with the details of that order for order numbers 10270, 10272, 10279. */
select orderNumber, productCode, quantityOrdered, 
priceEach, orderLineNumber
from orders natural join  orderdetails
where orderNumber in('10270','10272','10279');

-- or

SELECT ordernumber, productcode, quantityordered, priceeach, orderlinenumber
FROM Orders NATURAL JOIN OrderDetails
WHERE ordernumber = 10270 OR ordernumber = 10272 OR ordernumber = 10279; 

/* 13. Find the ProductLine which have the buy price higher than the average buyprice. */
select productLine, buyPrice
from products 
where buyPrice > (
				   select avg(buyPrice) from products);

/* 14. Total Payment received for product lines. */
select productlines.ProductLine, sum(Payments.Amount) as Total_Pyament_Received
from payments inner join orders
on orders.customerNumber = payments.customerNumber
inner join orderdetails
on orderdetails.orderNumber = orders.orderNumber
inner join products 
on products.productCode = orderdetails.productCode
inner join productlines
on productlines.productLine = products.productLine
group by productLine;

/* 15. How many employees are there in the company. */
select count(*) as Employees_Count 
from employees;

/* 16. which orders have a value greater than $50,000. */
select orderNumber, sum(quantityOrdered*priceEach) as Sales
from orderdetails
group by orderNumber
having sum(quantityOrdered*priceEach) > 50000.00
order by orderNumber;

/* 17. How many distinct products does classicmodels sell */
select count(distinct productLine) as Products 
from productlines;

/* 18. List the products and the profit that we have made on them.  */
with Profits_On_Products as (
select products.productName, products.productLine, 
((orderdetails.quantityOrdered*orderdetails.priceEach)-(products.buyPrice*orderdetails.quantityOrdered)) as Profit
from orderdetails join products
on products.productCode = orderdetails.productCode
) select productLine, sum(profit) as Profit_On_Each_Product from Profits_On_Products
group by productLine;

-- OR -- 
-- by creating view:
create view Profits_On_Products as
(
select products.productName, products.productLine, 
((orderdetails.quantityOrdered*orderdetails.priceEach)-(products.buyPrice*orderdetails.quantityOrdered)) as Profit
from orderdetails join products
on products.productCode = orderdetails.productCode
);
select productLine, sum(profit) as Profit_On_Each_Product 
from Profits_On_Products
group by productLine;

/* 19. Select customers that live in the same state as one of our offices */
select customerName, contactFirstName, contactLastName
from customers join offices
where customers.state = offices.state;

/* 20. List the total number of products per product line where number of products > 3 */
select productLine, count(productName) as Total_Count
from products
group by productLine
having count(productName) > 3;

/* 21. Find the products containing the name 'Ford'. */
SELECT productName As 'Products'
FROM Products
WHERE productName LIKE '%Ford%';

/* 22. Find the total of all payments made by each customer. */
select customers.customerName, sum(payments.amount) as Payment_Amount
from payments natural join customers
group by customers.customerNumber;

/* 23.	List products that didn't sell */
SELECT productName from products
where not exists ( SELECT * FROM orderdetails
                   WHERE products.productCode = orderdetails.productCode );
-- OR
select productname, ordernumber
from Products left outer join OrderDetails
using(productcode)
where ordernumber is null;

/* 24. list out the account representative for each customer */
select customerName,concat(e.firstName,' ',e.lastName) As 'Account Repersentative'
from customers
inner join employees e on customers.salesRepEmployeeNumber = e.employeeNumber;

/* 25. List the payment greater than $100,000. Sort the report so the customer who made the highest payment appears 
 first. */
select customers.customerName, sum(payments.amount ) as 'Amount Paid'
from payments join customers
using(customerNumber)
where payments.amount > 100000
group by customers.customerName
order by customers.customerName desc;

/* 26. Find out the number of customer transaction in each year.*/
SELECT YEAR(orderDate) years,
       COUNT(DISTINCT customerNumber) 'number of customer'
FROM orders
WHERE status = 'Shipped'
GROUP BY 1;

/* 27. find the customers who placed atleast one order with a total value greater than $60,000. */
select customerNumber, customerName from customers
where exists(
			 select orderNumber, sum(quantityOrdered*priceEach) as TotalAmount
			 from orderdetails join orders 
			 using(orderNumber)
			 where customerNumber = customers.customerNumber
			 group by orderNumber
			 having TotalAmount > 60000);

/* 28. Find the maximum, minimum, average number of items in sales orders. */
select max(items) as Maximum_no_of_orders, 
min(items) as Minimum_no_of_orders, 
floor(avg(items)) as Average_no_of_orders
from 
	(select orderNumber, count(orderNumber) as items
	 from orderdetails group by orderNumber) as lineitems;

/* 29. List of productlines and vendors that supply the products in that productline. */
SELECT productline, productvendor
FROM ProductLines NATURAL JOIN Products
ORDER BY productline, productvendor;

/* 30. Find the number of new customers for each year. */
SELECT YEAR(first_order) years,
       COUNT(customerNumber) 'Number of new customers'
FROM(
       SELECT customerNumber,
              MIN(orderDate) first_order
       FROM orders
       WHERE status = 'Shipped'
       GROUP BY 1) first
GROUP BY 1;

/* 31. Find all customer with their contact firstname, contact lastname and credit limit.
 where credit limit is greater than 50000.*/
select contactFirstName, contactLastName, creditLimit
from customers
where creditLimit > 50000;
