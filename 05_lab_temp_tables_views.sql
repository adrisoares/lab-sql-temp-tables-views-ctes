/* Creating a Customer Summary Report : in this exercise, you will create a customer summary report that summarizes key information 
about customers in the Sakila database, including their rental history and payment details. 
The report will be generated using a combination of views, CTEs, and temporary tables.

Step 1: Create a View
First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, 
email address, and total number of rentals (rental_count).*/

CREATE VIEW customer_data AS
		SELECT customer.customer_id, CONCAT(first_name, " ", last_name) AS full_name, COUNT(*) AS rental_count, email 
		FROM sakila.rental
		INNER JOIN sakila.customer
		ON sakila.rental.customer_id = sakila.customer.customer_id
		GROUP BY customer.customer_id;

/* Step 2: Create a Temporary Table
Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use 
the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.*/

CREATE TEMPORARY TABLE customer_data AS (
							SELECT customer.customer_id, CONCAT(first_name, " ", last_name) AS full_name, COUNT(*) AS rental_count, email 
							FROM sakila.rental
							INNER JOIN sakila.customer
							ON sakila.rental.customer_id = sakila.customer.customer_id
							GROUP BY customer.customer_id);
                                          
CREATE TEMPORARY TABLE total_paid AS (
									  SELECT SUM(amount) AS total_paid, customer_id
									  FROM sakila.payment
									  GROUP BY customer_id);
SELECT * 
FROM customer_data
INNER JOIN total_paid
ON customer_data.customer_id = total_paid.customer_id;


/* Step 3: Create a CTE and the Customer Summary Report
Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
The CTE should include the customer's name, email address, rental count, and total amount paid.*/


WITH customer_summary AS (
					SELECT customer_data.customer_id, customer_data.full_name, customer_data.email, 
					customer_data.rental_count, total_paid.total_paid
					FROM customer_data
					JOIN total_paid 
					ON customer_data.customer_id = total_paid.customer_id) 
SELECT * 
FROM customer_summary;

/*Next, using the CTE, create the query to generate the final customer summary report, which should include: 
customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column 
from total_paid and rental_count.*/

WITH customer_summary AS (
					SELECT customer_data.customer_id, customer_data.full_name, customer_data.email, 
					customer_data.rental_count, total_paid.total_paid
					FROM customer_data
					JOIN total_paid 
					ON customer_data.customer_id = total_paid.customer_id)
                    
SELECT full_name AS customer_name, email, rental_count, total_paid, ROUND(total_paid / rental_count, 2) AS average_payment_per_rental
FROM customer_summary;