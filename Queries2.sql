2.

/*We need to know how the length of rental duration of family-friendly movies compared to the duration that all movies comparedrental duration all movies are rented for. Provide a table with the movie titles and divide them into 4 levels (1rst quarter, 2nd quarter, 3rd quarter, final quarter) based on the quartiles (25%, 50%, 75%) of the rental duration for movies accross all categories. Indicate the category that this family-friendly movies fall into.*/


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
          OR t2.cat_name = 'Comedy' OR t2.cat_name = 'Family' OR t2.cat_name = 'Music')


-- Option 1: TITLE, CATEGORY, TYPE, rental_duration, quartile

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


-- Option 2: COMPARISON TABLE: number of family films per rental_duration compared to other categories per rental_duration

SELECT DISTINCT quartile, Type_film, COUNT (*) AS counter_films
FROM (
SELECT quartile, Type_film
FROM(
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
ON c.category_id = fc.category_id) sub
WHERE Type_film = 'Family') sub2
GROUP BY 1, 2

UNION ALL

SELECT DISTINCT quartile, Type_film, COUNT (*) AS counter_films
FROM (
SELECT quartile, Type_film
FROM(
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
ON c.category_id = fc.category_id) sub
WHERE Type_film = 'Other') sub2
GROUP BY 1, 2
