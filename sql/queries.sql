/******************************************************************
 Q1 — Top 10 clientes por gasto con ranking
 Propósito: obtener los 10 clientes que más han pagado en total,
 mostrando su posición usando una window function (RANK).
******************************************************************/

SELECT
    RANK() OVER (ORDER BY SUM(p.amount) DESC) AS rank,
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_paid
FROM payment p
JOIN customer c ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_paid DESC
LIMIT 10;

 /*****************************************************************
 Q2 — Top 3 películas por tienda (por número de rentas)
 Propósito: para cada tienda, obtener las 3 películas más rentadas
 usando ROW_NUMBER() particionado por store_id.
******************************************************************/

WITH film_rentals AS (
    SELECT
        i.store_id,
        f.film_id,
        f.title,
        COUNT(r.rental_id) AS rentals_count
    FROM rental r
    JOIN inventory i ON i.inventory_id = r.inventory_id
    JOIN film f     ON f.film_id = i.film_id
    GROUP BY i.store_id, f.film_id, f.title
),
ranked AS (
    SELECT
        store_id,
        film_id,
        title,
        rentals_count,
        ROW_NUMBER() OVER (
            PARTITION BY store_id
            ORDER BY rentals_count DESC
        ) AS rn
    FROM film_rentals
)
SELECT
    store_id,
    film_id,
    title,
    rentals_count,
    rn
FROM ranked
WHERE rn <= 3
ORDER BY store_id, rn;

 /*****************************************************************
 Q3 — Inventario disponible por tienda (CTE)
 Propósito: calcular cuántos items (inventory_id) están disponibles
 por tienda, es decir, que no tienen una renta activa
 (return_date IS NULL).
******************************************************************/

WITH active_rentals AS (
    SELECT
        r.inventory_id
    FROM rental r
    WHERE r.return_date IS NULL
),
available_inventory AS (
    SELECT
        i.store_id,
        i.inventory_id
    FROM inventory i
    LEFT JOIN active_rentals ar
        ON ar.inventory_id = i.inventory_id
    WHERE ar.inventory_id IS NULL
)
SELECT
    store_id,
    COUNT(*) AS available_inventory_count
FROM available_inventory
GROUP BY store_id
ORDER BY store_id;

 /*****************************************************************
 Q4 — Análisis de retrasos: rentas tardías agregadas por categoría (CTE)
 Propósito: por categoría de película, contar cuántas rentas fueron
 tardías y el promedio de días de retraso.
 (Tarde = return_date > due_date = rental_date + rental_duration)
******************************************************************/

WITH rental_delays AS (
    SELECT
        r.rental_id,
        r.customer_id,
        r.inventory_id,
        r.rental_date,
        r.return_date,
        f.film_id,
        f.title,
        f.rental_duration,
        r.rental_date + (f.rental_duration || ' days')::interval AS due_date
    FROM rental r
    JOIN inventory i ON i.inventory_id = r.inventory_id
    JOIN film f     ON f.film_id = i.film_id
    WHERE r.return_date IS NOT NULL
),
late_rentals AS (
    SELECT
        rd.*,
        GREATEST(
            EXTRACT(DAY FROM (rd.return_date - rd.due_date)),
            0
        ) AS days_late
    FROM rental_delays rd
    WHERE rd.return_date > rd.due_date
)
SELECT
    c.category_id,
    c.name AS category_name,
    COUNT(lr.rental_id) AS late_rentals,
    AVG(lr.days_late)   AS avg_days_late
FROM late_rentals lr
JOIN film_category fc ON fc.film_id = lr.film_id
JOIN category c       ON c.category_id = fc.category_id
GROUP BY c.category_id, c.name
ORDER BY late_rentals DESC, c.category_id;