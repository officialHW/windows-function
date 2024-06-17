-- working with window functions
--- 1. Rank staff by the total number of rentals processed
SELECT staff_id,
	count(rental_id) as total_processed,
	rank() over(order by count(rental_id)desc) as ranking
from rental
group by staff_id

-----------------------------------------------------------------------------
-- 2. Which staff member processed the highest number of rentals, and what is their rank?
SELECT r.staff_id, s.first_name, s.last_name,
	count(r.rental_id) as total_processed,
	rank() over(order by count(r.rental_id)desc) as ranking
from rental r
left join staff s
	on r.staff_id = s.staff_id
group by r.staff_id, s.first_name, s.last_name

-----------------------------------------------------------------------------
--3. Compare the average rental duration for each staff member.
select staff_id,
	avg(extract(epoch from (return_date - rental_date))/ 86400),
	dense_rank () over(order by avg(extract(epoch from (return_date - rental_date))/ 86400)) as ranking
from rental
group by staff_id

----------------------------------------------------------------------------------------------------
--4. Identify the staff member who had the highest revenue generated from rentals. how much was it?
SELECT staff_id, 
	sum(amount) as total_revenue,
	rank() over(order by sum(amount)desc) as ranking
from payment
group by staff_id;

----------------------------------------------------------------------------------------------------
--5. Rank customers by their total amount spent on rentals?
select p.customer_id, concat(c.first_name, ' ' ,c.last_name),
	sum(amount) total_spent,
	dense_rank() over( order by sum(amount) desc),
	rank() over( order by sum(amount) desc)
from payment p
left join customer c
	on p.customer_id = c.customer_id
group by p.customer_id, c.first_name, c.last_name;


----------------------------------------------------------------------------------------------------
--6. Calculate the average payment amount for each customer.
select customer_id, (avg(amount), 2) avg_payment
from payment
group by customer_id
order by avg_payment


----------------------------------------------------------------------------------------------------
--8. Categorize customers into frequent, occasional, and rare renters based on their total number of rentals.
select customer_id, count(rental_id) cnt,
		case
			when count(rental_id) > 30 then 'Top Customer'
			when count(rental_id) > 20 then 'Frequent Customer'
			when count(rental_id) > 10 then 'Occasional Customer'
			else 'Rare Customer'
		end customer_category
from rental
group by customer_id
order by cnt desc

-----------------------------------------------------------------------------------------
--9. Use a case statement to categorize rentals as "Overdue" if the return date is past the due date, otherwise categorize them as "On Time".


-----------------------------------------------------------------------------------------
--10. Find the previous and next payment dates for each payment made by a customer.
--Tip: Use the LAG and LEAD window functions to find the previous and next payment dates for each payment made by a customer.

select customer_id,
		payment_date,
		amount,
		lag(amount) over(partition by customer_id order by payment_date) as previous_amount,
		lead(amount) over(partition by customer_id order by payment_date) as next_amount
from payment
