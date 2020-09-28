-- Create a query that lists each movie, its film category and the number of times it has ben rented out.

WITH
t1 AS ( /* RENTED TIMES PER TITLE, ID */
    SELECT i.film_id film_id, COUNT(*) AS rental_counter
    FROM inventory i
    JOIN rental r
    ON r.inventory_id = i.inventory_id
    GROUP BY 1
    ORDER BY 2 DESC),

t2 AS ( /* FILM_ID - TITLE - CATEGORY */
    SELECT f_c.film_id film_id, f.title title, c.name cat_name
    FROM film_category f_c
    JOIN category c
    ON c.category_id = f_c.category_id
    JOIN film f
    ON f.film_id = f_c.film_id
    ORDER BY 1, 2)

SELECT  t2.title, t2.cat_name category, t1.rental_counter
FROM t2
JOIN --t1 there are some films that where never rented, counter returns null if Left join
ON t2.film_id = t1.film_id
WHERE t2.cat_name = 'Animation' OR t2.cat_name = 'Children' OR t2.cat_name = 'Classics'
      OR t2.cat_name = 'Comedy' OR t2.cat_name = 'Family' OR t2.cat_name = 'Music'
ORDER BY 3 DESC
