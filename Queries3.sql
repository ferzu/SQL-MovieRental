/*Provide a table with the family-friendly film category, each of the quartiles, and the
corresponding count of movies within each combination of film category for each corresponding rental duration category.
The resulting table should have 3 columns: Category, Rental length category, Count.*/


WITH
t1 AS ( /* RENTED TIMES PER TITLE, ID */
    SELECT i.film_id film_id, COUNT(*) AS rental_counter
    FROM inventory i
    JOIN rental r
    ON r.inventory_id = i.inventory_id
    GROUP BY 1
    ORDER BY 2 DESC),

t2 AS ( /* FILM_ID - TITLE - CATEGORY */
    SELECT f_c.film_id film_id, f.title title, c.name cat_name, f.rental_duration rental_duration
    FROM film_category f_c
    JOIN category c
    ON c.category_id = f_c.category_id
    JOIN film f
    ON f.film_id = f_c.film_id
    ORDER BY 1, 2),

t3 AS (
    SELECT  t2.title title, t2.cat_name fam_category, t1.rental_counter, t2.rental_duration rental_duration
    FROM t2
    JOIN t1 --there are some films that where never rented, counter returns null if Left join
    ON t2.film_id = t1.film_id
    WHERE t2.cat_name = 'Animation' OR t2.cat_name = 'Children' OR t2.cat_name = 'Classics'
          OR t2.cat_name = 'Comedy' OR t2.cat_name = 'Family' OR t2.cat_name = 'Music'),

t4 AS (
    SELECT f.title title, c.name category, f.rental_duration rental_duration,
          NTILE (4) OVER (ORDER BY f.rental_duration) AS quartile,
          CASE
          WHEN c.name = 'Animation' OR c.name = 'Children' OR c.name = 'Classics'
               OR c.name = 'Comedy' OR c.name = 'Family' OR c.name = 'Music'
          THEN 'Family'
          ELSE 'Other' END AS Type_film
    FROM film f
    JOIN film_category fc
    ON f.film_id = fc.film_id
    JOIN category c
    ON c.category_id = fc.category_id)


-- it does not give me precisely the same results, but very cloe, it could be that the quartile subdivision is not exact
-- the subdivision also acts differntly if I use the workspace in place of the server

SELECT t4.category category, t4.quartile quartile, COUNT (*) AS counter_films
FROM t4
WHERE t4.Type_film = 'Family'
GROUP BY 1, 2
