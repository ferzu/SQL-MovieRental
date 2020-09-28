
/* 1. We want to find out how the two stores compare in their count of rental orders during rvery month for all the years we have data for.
Write a query that returns the store ID for the store, the year and month and the number ofrental orders each store has fulfilled for that month.
Your table should include a column for each of the following: year, month, store ID and count of rental orders fulfilled during tha month.*/

-- numerical results differ a bit from the solutions' table


SELECT s.store_id,
       DATE_PART ('year', r.rental_date) AS year,
       DATE_PART ('month', r.rental_date) AS month,
	   COUNT (*) AS counter
FROM rental r
JOIN payment p
ON r.rental_id = p.rental_id
JOIN staff s
ON p.staff_id = s.staff_id
JOIN store st
ON s.store_id = st.store_id
GROUP BY 1, 2, 3
ORDER BY 4 DESC




/* 2. We would like to know who were our top 10 paying customers, how many payments thay made on a monthly basis during 2007, and what was the monthly_amountof the monthly payments. Write a query to capture the customer name, month and year of payment, and total payment amount for each month by these top 10 paying customers.*/
--who are top 10 paying customers
--number payments per month in 2007 + amont payments
--customer name, month and year of payment, total payment amount for each month


SELECT
      DISTINCT c.first_name||' '||c.last_name AS customer_name,
	   c.customer_id id,
      DATE_TRUNC('month', p.payment_date) AS month,
      SUM(p.amount) OVER (PARTITION BY c.customer_id ORDER BY DATE_PART('month', p.payment_date)) AS monthly_amount,
      COUNT (*) OVER (PARTITION BY c.customer_id ORDER BY DATE_PART('month', p.payment_date)) AS count_monthly_payments
FROM customer c
JOIN rental r
ON r.customer_id = c.customer_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY 1, 2, 3, p.amount, c.customer_id, p.payment_date
ORDER BY 4 DESC

-- checking number payments for Ana Bradley
WITH t1 AS (
SELECT  customer_id,
		DATE_TRUNC ('month', payment_date) AS month,
		SUM(amount) AS total_spent,
		COUNT (*) AS pay_count
FROM payment
WHERE customer_id = 181
GROUP BY 1, payment_date)

SELECT SUM (t1.total_spent)
FROM t1


-- ALTERNATIVE SOLUTION

WITH t1 AS (
        SELECT  customer_id,
        		DATE_TRUNC ('month', payment_date) AS month,
        		SUM(amount) AS total_spent,
        		ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY payment_date) AS pay_count
        FROM payment
        GROUP BY 1, payment_date),

	    t2 AS (
        SELECT t1.customer_id customer_id,
        	   SUM (t1.total_spent) AS total,
        	   MAX (t1.pay_count) AS counter
        FROM t1
        GROUP BY 1)

SELECT
		c.first_name||' '||c.last_name AS customer_name,
		t2.*
FROM t2
JOIN customer c
ON c.customer_id = t2.customer_id
ORDER BY 3 DESC;
