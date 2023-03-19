-- Data Analysis using MySQL --

-- The dataset is is E-commerce Business Transaction of a store, below is the metadata --

-- TransactionNo (categorical): a six-digit unique number that defines each transaction. The letter “C” in the code indicates a cancellation.
-- Date (numeric): the date when each transaction was generated.
-- ProductNo (categorical): a five or six-digit unique character used to identify a specific product.
-- Product (categorical): product/item name.
-- Price (numeric): the price of each product per unit in pound sterling (£).
-- Quantity (numeric): the quantity of each product per transaction. Negative values related to cancelled transactions.
-- CustomerNo (categorical): a five-digit unique number that defines each customer.
-- Country (categorical): name of the country where the customer resides.

-- Let as check the datatype of each column
DESCRIBE transactions_sales2;

-- It seems that it is not in appropriate data type. Let's fix it
ALTER TABLE transactions_sales2
MODIFY COLUMN Date DATE;

UPDATE transactions_sales2 
SET Date = STR_TO_DATE(Date, '%m/%d/%Y');

DESCRIBE transactions_sales2;

-- Let us do some exploratory data analysis

-- 1. lets check the top 10 most highest transactions base on total sale
SELECT TransactionNo,
	ProductNo,
    ProductName,
    ROUND((Price * Quantity), 2) AS total_sale
FROM transactions_sales2
WHERE TransactionNo NOT LIKE '%C_%'
ORDER BY total_sale DESC
LIMIT 10;

-- 2. Check the total product that are canceled  in each country
SELECT Country,
	SUM(Quantity) AS Total_cancels
FROM transactions_sales2
WHERE TransactionNo LIKE '%C_%'
GROUP BY Country
ORDER BY Total_cancels;

-- 3. Top 10 most sold product and its total sale
SELECT ProductName,
	COUNT(ProductName) AS Total_Sold,
    ROUND(SUM((Price * Quantity)), 2) AS Total_sale
FROM transactions_sales2
GROUP BY ProductName
ORDER BY Total_sale DESC
LIMIT 10;

-- Now I noticed that if I filter some country, it will return nothing like below
SELECT * 
FROM transactions_sales2
WHERE Country = 'United Kingdom';

-- But if we use this
SELECT *
FROM transactions_sales2
WHERE Country LIKE '%United Kingdom%';

-- It will return transactions in united kingdom,
-- so the problem is there are some white spaces on it
-- or it has non-printable characters or non-ASCII
SELECT Country,
	LENGTH(Country) AS Length_check
FROM transactions_sales2
GROUP BY Country
ORDER BY Length_check;

-- Let's delete all the white spaces and update the table
UPDATE transactions_sales2 
SET Country = TRIM(REPLACE(REPLACE(REPLACE(Country, '\r', ' '), '\n', ' '), '\t', ' '));

SELECT *
FROM transactions_sales2
WHERE Country = 'USA' OR Country = 'Japan'
LIMIT 10;

-- Seems the problem has been solve lets continue
-- 4. Let's check the top 10 countries that has most sales
SELECT Country,
	COUNT(*) AS total_sold,
    ROUND(SUM(Price * Quantity), 2) AS total_sale
FROM transactions_sales2
WHERE TransactionNo NOT LIKE '%C_%'
GROUP BY Country
ORDER BY total_sale DESC
LIMIT 10;

-- 5. Average and total sale per year
SELECT YEAR(Date) AS year,
	COUNT(YEAR(Date)) AS transactions_per_year,
    ROUND(SUM(Price * Quantity), 2) AS total_sale_per_year,
    ROUND(AVG(Price * QUantity), 2) AS average_sale_per_year
FROM transactions_sales2
WHERE TransactionNo NOT LIKE '%C_%'
GROUP BY year;

-- 6. sales retention per month
SELECT 'Febuary-January' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 1 THEN CustomerNo END) AS Previous_Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 2 THEN CustomerNo END) AS Current_Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 2 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 1) THEN CustomerNo END) AS Repeated_customers,
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 2 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 1) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 1 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'March-February' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 2 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 3 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 3 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 2) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 3 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 2) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 2 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'April-March' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 3 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 4 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 4 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 3) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 4 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 3) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 3 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'May-April' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 4 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 5 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 5 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 4) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 5 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 4) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 4 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'June-May' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 5 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 6 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 6 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 5) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 6 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 5) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 5 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'July-June' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 6 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 7 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 7 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 6) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 7 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 6) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 6 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'August-July' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 7 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 8 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 8 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 7) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 8 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 7) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 7 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'September-August' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 8 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 9 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 9 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 8) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 9 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 8) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 8 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'October-September' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 9 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 10 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 10 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 9) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 10 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 9) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 9 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'November-October' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 10 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 11 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 11 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 10) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 11 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 10) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 10 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2
UNION
SELECT 'December-November' AS Month,
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 11 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 12 THEN CustomerNo END),
       COUNT(DISTINCT CASE WHEN MONTH(Date) = 12 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 11) THEN CustomerNo END),
       ROUND(COUNT(DISTINCT CASE WHEN MONTH(Date) = 12 AND TransactionNo NOT LIKE '%C_%' AND CustomerNo IN 
              (SELECT DISTINCT CustomerNo FROM transactions_sales2 WHERE MONTH(Date) = 11) THEN CustomerNo END) /
             COUNT(DISTINCT CASE WHEN MONTH(Date) = 11 THEN CustomerNo END) * 100, 2) AS RetentionRate
FROM transactions_sales2;

-- 7. How many transactions were cancelled, and what was the total value of cancelled transactions?
SELECT COUNT(TransactionNo) AS num_of_cancel,
	ROUND(SUM(Price * Quantity), 2) AS total_value
FROM transactions_sales2
WHERE TransactionNo LIKE '%C_%';


-- 8. the rate of cancelation in each country
SELECT Country,
	COUNT(CASE WHEN LEFT(TransactionNo, 1) = 'C' THEN 1 END) / COUNT(*) * 100 AS Cancel_percentage
FROM transactions_sales2
GROUP BY Country;

-- Conclusions 

-- We can tell that the sales are really good for the certain products
-- and the average sales in 2019 is really good compare to 2018
-- also there are many products that are cancel
-- lastly some customers are not buying again based on the sales retention.


-- recommendation

-- To boost sales and lower cancellations, it is advised to concentrate on enhancing 
-- customer happiness and addressing any problems with product quality or customer 
-- service in certain nations. Also, determining popular products and studying sales trends 
-- can assist in stocking and growing the company.














