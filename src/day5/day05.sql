CREATE INDEX idx_menu_pizzeria_id ON menu (pizzeria_id);
CREATE INDEX idx_person_order_person_id ON person_order (person_id);
CREATE INDEX idx_person_order_menu_id ON person_order (menu_id);
CREATE INDEX idx_person_visits_person_id ON person_visits (person_id);
CREATE INDEX idx_person_visits_pizzeria_id ON person_visits (pizzeria_id);


SET enable_seqscan = off;
EXPLAIN ANALYZE
SELECT pizza_name, p.name as pizzeria_name
FROM menu 
	JOIN pizzeria p ON p.id = menu.pizzeria_id;
--use INDEX
--"Planning Time: 0.079 ms"
--"Execution Time: 0.047 ms"
--NOT use INDEX
-- SET enable_seqscan = on;
-- EXPLAIN ANALYZE
-- SELECT pizza_name, p.name
-- FROM menu 
-- 	JOIN pizzeria p ON p.id = menu.pizzeria_id;
--"Planning Time: 0.091 ms"
--"Execution Time: 0.037 ms"


CREATE INDEX IF NOT EXISTS idx_person_name ON person(UPPER(name));
EXPLAIN ANALYZE
SELECT name
FROM person
WHERE UPPER(name) = 'DENIS';


CREATE INDEX IF NOT EXISTS idx_person_order_multi ON person_order (person_id, menu_id, order_date);
EXPLAIN ANALYZE 
SELECT person_id, menu_id, order_date
FROM person_order
WHERE person_id = 8 AND menu_id = 19;


CREATE INDEX IF NOT EXISTS idx_person_order_multi ON person_order (person_id, menu_id, order_date);
EXPLAIN ANALYZE 
SELECT person_id, menu_id, order_date
FROM person_order
WHERE person_id = 8 AND menu_id = 19;


CREATE INDEX IF NOT EXISTS idx_person_order_order_date ON person_order(person_id, menu_id, order_date)
WHERE order_date = '2022-01-01';
EXPLAIN ANALYZE 
SELECT person_id, menu_id, order_date
FROM person_order
WHERE order_date = '2022-01-01';



CREATE INDEX idx_1 ON pizzeria(rating);
SET enable_seqscan = off;
EXPLAIN ANALYZE
SELECT
    m.pizza_name AS pizza_name,
    max(rating) OVER (PARTITION BY rating
			ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING
			AND UNBOUNDED FOLLOWING) AS k
FROM  menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1,2;
-- BEFORE
-- SET enable_seqscan = off;
-- "Sort  (cost=64.80..64.85 rows=19 width=96) (actual time=0.135..0.137 rows=19 loops=1)"
-- "  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))"
-- "  Sort Method: quicksort  Memory: 26kB"
-- "  ->  WindowAgg  (cost=64.01..64.39 rows=19 width=96) (actual time=0.088..0.106 rows=19 loops=1)"
-- "        ->  Sort  (cost=64.01..64.06 rows=19 width=64) (actual time=0.077..0.079 rows=19 loops=1)"
-- "              Sort Key: pz.rating"
-- "              Sort Method: quicksort  Memory: 26kB"
-- "              ->  Nested Loop  (cost=0.29..63.61 rows=19 width=64) (actual time=0.026..0.061 rows=19 loops=1)"
-- "                    ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..12.42 rows=19 width=40) (actual time=0.012..0.020 rows=19 loops=1)"
-- "                          Heap Fetches: 19"
-- "                    ->  Index Scan using pizzeria_pkey on pizzeria pz  (cost=0.15..2.69 rows=1 width=40) (actual time=0.001..0.001 rows=1 loops=19)"
-- "                          Index Cond: (id = m.pizzeria_id)"
-- "Planning Time: 0.146 ms"
-- "Execution Time: 0.170 ms"
-- ///////////////////////////////////////////////////////////////////////////////////////////////////////////
-- "Sort  (cost=64.80..64.85 rows=19 width=96) (actual time=0.150..0.152 rows=19 loops=1)"
-- "  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))"
-- "  Sort Method: quicksort  Memory: 26kB"
-- "  ->  WindowAgg  (cost=64.01..64.39 rows=19 width=96) (actual time=0.094..0.116 rows=19 loops=1)"
-- "        ->  Sort  (cost=64.01..64.06 rows=19 width=64) (actual time=0.086..0.088 rows=19 loops=1)"
-- "              Sort Key: pz.rating"
-- "              Sort Method: quicksort  Memory: 26kB"
-- "              ->  Nested Loop  (cost=0.29..63.61 rows=19 width=64) (actual time=0.039..0.072 rows=19 loops=1)"
-- "                    ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..12.42 rows=19 width=40) (actual time=0.029..0.036 rows=19 loops=1)"
-- "                          Heap Fetches: 19"
-- "                    ->  Index Scan using pizzeria_pkey on pizzeria pz  (cost=0.15..2.69 rows=1 width=40) (actual time=0.001..0.001 rows=1 loops=19)"
-- "                          Index Cond: (id = m.pizzeria_id)"
-- "Planning Time: 0.211 ms"
-- "Execution Time: 0.193 ms"

-- AFTER

-- "Sort  (cost=25.95..26.00 rows=19 width=96) (actual time=0.111..0.112 rows=19 loops=1)"
-- "  Sort Key: m.pizza_name, (max(pz.rating) OVER (?))"
-- "  Sort Method: quicksort  Memory: 26kB"
-- "  ->  WindowAgg  (cost=0.27..25.54 rows=19 width=96) (actual time=0.079..0.097 rows=19 loops=1)"
-- "        ->  Nested Loop  (cost=0.27..25.21 rows=19 width=64) (actual time=0.068..0.080 rows=19 loops=1)"
-- "              ->  Index Scan using idx_1 on pizzeria pz  (cost=0.13..12.22 rows=6 width=40) (actual time=0.029..0.030 rows=6 loops=1)"
-- "              ->  Index Only Scan using idx_menu_unique on menu m  (cost=0.14..2.15 rows=1 width=40) (actual time=0.007..0.007 rows=3 loops=6)"
-- "                    Index Cond: (pizzeria_id = pz.id)"
-- "                    Heap Fetches: 19"
-- "Planning Time: 0.119 ms"
-- "Execution Time: 0.134 ms"
