SELECT m.pizza_name, m.price, pi.name as pizzeria_name, pv.visit_date
FROM menu m 
	JOIN (SELECT id, name FROM pizzeria) pi ON m.pizzeria_id = pi.id
	JOIN (SELECT visit_date, person_id, pizzeria_id FROM person_visits) pv ON pv.pizzeria_id = pi.id
	JOIN (SELECT name, id FROM person) p ON pv.person_id = p.id
WHERE p.name = 'Kate' AND m.price BETWEEN 800 AND 1000
ORDER BY 1, 2, 3;

'------------------------------------------------------------------------------------------------'

SELECT id as menu_id 
FROM menu
EXCEPT 
SELECT menu_id
FROM person_order
ORDER BY menu_id;

'------------------------------------------------------------------------------------------------'

SELECT m.pizza_name, m.price, p.name as pizzeria_name
FROM menu m
JOIN (SELECT name, id FROM pizzeria) p ON p.id = m.pizzeria_id
EXCEPT 
SELECT m.pizza_name, m.price, p.name as pizzeria_name
FROM menu m
	JOIN (SELECT menu_id, person_id FROM person_order) po ON po.menu_id = m.id
	JOIN (SELECT name, id FROM pizzeria) p ON p.id = m.pizzeria_id
ORDER BY pizza_name, price;

'------------------------------------------------------------------------------------------------'

WITH male_visits AS (
	SELECT pi.name, COUNT (pv.person_id) AS visit_count
	FROM pizzeria pi
		JOIN person_visits pv ON pv.pizzeria_id = pi.id
		JOIN person p ON p.id = pv.person_id
	WHERE p.gender = 'male'
	GROUP BY pi.name), 

female_visits AS (
	SELECT pi.name, COUNT (pv.person_id) AS visit_count
	FROM pizzeria pi
		JOIN person_visits pv ON pv.pizzeria_id = pi.id
		JOIN person p ON p.id = pv.person_id
	WHERE p.gender = 'female'
	GROUP BY pi.name)

SELECT mv.name AS pizzeria_name
FROM male_visits mv
WHERE visit_count > (SELECT visit_count FROM female_visits fv WHERE mv.name = fv.name)

UNION ALL 

SELECT fv.name AS pizzeria_name
FROM female_visits fv
WHERE visit_count > (SELECT visit_count FROM male_visits mv WHERE fv.name= mv.name)

ORDER BY pizzeria_name;

'------------------------------------------------------------------------------------------------'

WITH male_order AS (
	SELECT pi.name
	FROM pizzeria pi
		JOIN menu m ON m.pizzeria_id = pi.id
		JOIN person_order po ON po.menu_id = m.id
		JOIN person p ON p.id = po.person_id	
	WHERE p.gender = 'male'
	GROUP BY pi.name), 

female_order AS (
	SELECT pi.name
	FROM pizzeria pi
		JOIN menu m ON m.pizzeria_id = pi.id
		JOIN person_order po ON po.menu_id = m.id
		JOIN person p ON p.id = po.person_id	
	WHERE p.gender = 'female'
	GROUP BY pi.name),

male_order_only AS (
	SELECT * FROM male_order
	EXCEPT 
	SELECT * FROM female_order
	), 

female_order_only AS (
	SELECT * FROM female_order
	EXCEPT 
	SELECT * FROM male_order
	) 

SELECT name AS pizzeria_name
FROM male_order_only

UNION

SELECT name AS pizzeria_name
FROM female_order_only

ORDER BY pizzeria_name;

'------------------------------------------------------------------------------------------------'

WITH Avisit AS (
	SELECT pi.name
	FROM pizzeria pi
		JOIN menu m ON m.pizzeria_id = pi.id
		JOIN person_order po ON po.menu_id = m.id
		JOIN person p ON p.id = po.person_id	
	WHERE p.name = 'Andrey'
	GROUP BY pi.name), 

Aorder AS (
	SELECT pi.name
	FROM pizzeria pi
		JOIN person_visits pv ON pv.pizzeria_id = pi.id
		JOIN person p ON p.id = pv.person_id
	WHERE p.name = 'Andrey'
	GROUP BY pi.name)

SELECT name AS pizzeria_name
FROM Aorder

EXCEPT

SELECT name AS pizzeria_name
FROM Avisit


ORDER BY pizzeria_name;

'------------------------------------------------------------------------------------------------'

WITH PiName1 AS (
SELECT m.pizza_name, pi.name, m.price
FROM menu m 
	JOIN pizzeria pi ON pi.id = m.pizzeria_id
GROUP BY m.pizza_name, pi.name, m.price),

PiName2 AS (
SELECT m.pizza_name, pi.name, m.price
FROM menu m 
	JOIN pizzeria pi ON pi.id = m.pizzeria_id
GROUP BY m.pizza_name, pi.name, m.price)

SELECT PiName1.pizza_name, PiName1.name AS pizzeria_name_1, PiName2.name AS pizzeria_name_2, PiName1.price
FROM PiName1
	JOIN (SELECT name, pizza_name, price FROM PiName2) PiName2 ON PiName1.pizza_name = PiName2.pizza_name
WHERE PiName1.pizza_name = PiName2.pizza_name AND PiName2.price = PiName1.price AND NOT PiName1.name = PiName2.name AND PiName2.name > PiName1.name
ORDER BY PiName1.pizza_name;

'------------------------------------------------------------------------------------------------'

INSERT INTO menu (id, pizzeria_id, pizza_name, price)
VALUES (19, 2, 'greek pizza', 800);

'------------------------------------------------------------------------------------------------'

INSERT INTO menu (id, pizzeria_id, pizza_name, price)
VALUES ((SELECT MAX( id )+1 FROM menu), ( SELECT id FROM pizzeria WHERE name = 'Dominos' ), 'sicilian pizza', 900);

'------------------------------------------------------------------------------------------------'

INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX( id )+1 FROM person_visits), ( SELECT id FROM person WHERE name = 'Denis' ), ( SELECT id FROM pizzeria WHERE name = 'Dominos' ), '2022-02-24');

INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX( id )+1 FROM person_visits), ( SELECT id FROM person WHERE name = 'Irina' ), ( SELECT id FROM pizzeria WHERE name = 'Dominos' ), '2022-02-24');

'------------------------------------------------------------------------------------------------'

INSERT INTO person_order (id, person_id, menu_id, order_date)
VALUES (( SELECT MAX( id )+1 FROM person_order ), 
( SELECT id FROM person WHERE name = 'Denis' ),  
( SELECT id FROM menu WHERE pizza_name = 'sicilian pizza' ), 
'2022-02-24');

INSERT INTO person_order (id, person_id, menu_id, order_date)
VALUES (( SELECT MAX( id )+1 FROM person_order ), 
( SELECT id FROM person WHERE name = 'Irina' ),  
( SELECT id FROM menu WHERE pizza_name = 'sicilian pizza' ), 
'2022-02-24');

'------------------------------------------------------------------------------------------------'

UPDATE menu
SET price = price * 0.9
WHERE pizza_name = 'greek pizza';

'------------------------------------------------------------------------------------------------'

INSERT INTO person_order(id, person_id, menu_id, order_date)

SELECT
generate_series(
        ( SELECT MAX(id) FROM person_order ) + 1,
		
        ( SELECT MAX(id) FROM person ) + ( SELECT MAX(id) FROM person_order ),
        1
        ),
generate_series(
        ( SELECT MIN(id) FROM person ), ( SELECT MAX(id) FROM person )
        ),
		
( SELECT id FROM menu WHERE pizza_name = 'greek pizza' ),

'2022-02-25';

'------------------------------------------------------------------------------------------------'

DELETE FROM person_order WHERE order_date = '2022-02-25';

DELETE FROM menu WHERE pizza_name = 'greek pizza';