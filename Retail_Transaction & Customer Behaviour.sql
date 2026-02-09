-- 1. Product Hierarchy Table 
CREATE TABLE prod_cat_info (
    prod_cat_code INT,
    prod_cat VARCHAR(50),
    prod_sub_cat_code INT,
    prod_subcat VARCHAR(50),
    PRIMARY KEY (prod_cat_code, prod_sub_cat_code) 
);

SELECT * FROM prod_cat_info;
copy prod_cat_info FROM 'C:\Users\QC#\OneDrive\Documents\prod_cat_info.csv' 
Delimiter ','
CSV HEADER;
()
-- 2. Customers Table
CREATE TABLE customers (
    customer_Id INT PRIMARY KEY,
    DOB DATE,
    Gender CHAR(1),
    city_code INT
);
select * from customers;
copy customers FROM 'C:\Users\QC#\OneDrive\Documents\Customers.csv'
Delimiter ','
CSV HEADER;

CREATE TABLE transactions (
    transaction_id BIGINT,
    cust_id INT,
    tran_date DATE,
    prod_subcat_code INT, 
    prod_cat_code INT,
    Qty INT,
    Rate INT,
    Tax DECIMAL(10,3),
    total_amt DECIMAL(10,3),
    Store_type VARCHAR(20),
    -- Relationships setup
    CONSTRAINT fk_customer FOREIGN KEY (cust_id) REFERENCES customers(customer_Id),
    CONSTRAINT fk_product FOREIGN KEY (prod_cat_code, prod_subcat_code) 
               REFERENCES prod_cat_info(prod_cat_code, prod_sub_cat_code)
);
SELECT * FROM transactions;
copy transactions FROM 'C:\Users\QC#\OneDrive\Documents\transactions.csv'
Delimiter ','
CSV HEADER;

-------------------------------------------------Questions--------------------------------------------

--1.What is the total no of records in customers table?.
SELECT COUNT(*) AS total_customer_record FROM customers;
--2.How many unique Stores_type Exist in Transactions table?.
SELECT COUNT(DISTINCT Store_type) AS Unique_store_type FROM transactions;
--3.Find The Earliest And latest Transaction date in the data sets to unterstand  time period?.
SELECT max( tran_date) AS latest_date,
       MIN( tran_date) AS Earliest_date
FROM transactions;	   
--4.Count how many trasactions are return?.
SELECT count(*) AS total_return
FROM transactions
WHERE  total_amt<0 ;
--5.which product category has generated the highest total revenue?.
SELECT p.prod_cat,SUM(t.total_amt) As total_revenue
                 FROM prod_cat_info AS p
				 JOIN transactions AS t
     ON p.prod_cat_code=t.prod_cat_code
     GROUP by p.prod_cat
     ORDER BY total_revenue DESC LIMIT 1;
--6.Calculte the total amount spent by male and female customer?.
SELECT c.gender,sum(t.total_amt) AS total_Revenue
               FROM customers AS c
			   JOIN transactions AS t
	  ON c.customer_id=t.cust_id
	  WHERE c.gender IS NOT NULL
	  GROUP BY c.gender;
--7.List Top 5 prod_subcat names based on the total quantity sold?.
SELECT p.prod_subcat,sum(t.Qty) AS Total_quantity 
       FROM prod_cat_info AS p
	   JOIN transactions  AS t
 ON p.  prod_cat_code=t.prod_cat_code
 GROUP BY p.prod_subcat
 ORDER by Total_quantity DESC LIMIT 5;
 --8.Find the total tax collected from each city_code?.
 SELECT c.city_code,sum(t.Tax) AS total_tax
               FROM customers AS c
			   JOIN transactions As t
       ON c.customer_id=t.cust_id
	   GROUP BY c.city_code;
--9.Calculate the total Revanue for Each month .Which month saw the biggest spike in sales?.
SELECT TO_ChAR(tran_date, 'Month')AS month_name,Sum(t.total_amt) As total_revenue
                            FROM customers As c
							JOIN transactions AS t
							ON c.customer_id=t.cust_id
							GROUP BY month_name
							ORDER BY total_revenue DESC limit 1;

--10.identify customer who have made more than 10 transactions .List their customer_id and total spend?.
SELECT cust_id,count(transaction_id) As total_tran,
          SUM(total_amt) AS Total_spend
		  From transactions
		  GROUP by cust_id
		  HAVING count(transaction_id) >10 
		  ORDER BY total_tran DESC;
		  
--11.For Each product category,calculte the Return Rate percentage?.
SELECT p.prod_cat,COUNT(case when t.QTY<0 then 1 end ) AS return_count,
count(*) as total_count,
ROUND(CAST(COUNT(CASE WHEN t.QTY<0 THEN 1 END) AS NUMERIC)/Count(*) * 100, 2)AS return_rate_per
FROM prod_cat_info AS p
join transactions AS t
ON p.prod_cat_code=t.prod_cat_code
GROUP BY p.prod_cat;

--12.Create age buckets based on DOB and find which group spend the most?.
SELECT 
 CASE WHEN AGE(c.DOB)<'25 years' THEN 'under 25'
 WHEN AGE(c.DOB) BETWEEN '25 year ' ANd '40 year' THEN '25-40'
 ELSE '40+' END as AGE_GROUP,
             SUM(t.total_amt) as total_spend
 FROM customers as c
 JOIN transactions AS t
 ON c.customer_id=t.cust_id
 GROUP BY AGE_GROUP
 order by total_spend DESC;
--13.Find the number of days between the FIRST and LAST purchase for every customer?.
SELECT cust_id,max(tran_date) as first_purchase, 
               min(tran_date) as last_purchase,
			   max(tran_date)-min(tran_date) AS days_btw
			   FROM transactions 
			   GROUP by cust_id;
			   
--14.What is the AVG NO of items per Transactions for each Store?.
SELECT store_type,AVG(QTY) AS Average_item_per_tran
FROM transactions 
group by store_type;
--15.Use a window function to show a report with:
--TRAN_DATE,DAILY_REVENUE,cumultive_running_total of revenue?.
SELECT tran_date,SUM(total_amt) as daily_revenue,
SUM(SUM(total_amt)) over(order by tran_date) AS running_total
               FROM transactions
               group by tran_date 
	           Order by tran_date;
			   
				  

	   
