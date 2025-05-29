SELECT id as object_id, pizza_name as object_name FROM menu
	UNION
SELECT id as object_id, name as object_name FROM person
ORDER BY 
	object_id ASC,
	object_name ASC;


SELECT object_name
FROM (SELECT name AS object_name FROM person ORDER BY object_name) AS cash1
UNION ALL
SELECT object_name
FROM (SELECT pizza_name AS object_name FROM menu ORDER BY object_name) AS cash2;


SELECT pizza_name as Pizza_name FROM menu
	INTERSECT 
	SELECT pizza_name as Pizza_name FROM menu
ORDER BY 
	Pizza_name DESC;


SELECT visit_date AS action_date, person_id AS person_id FROM person_visits
INTERSECT
SELECT order_date AS action_date, person_id AS person_id FROM person_order
ORDER BY action_date ASC, person_id DESC;


SELECT  person_id AS person_id FROM person_order WHERE order_date = '2022-01-07'
EXCEPT ALL
SELECT person_id AS person_id FROM person_visits WHERE visit_date = '2022-01-07';


SELECT 
	p.id as "person.id",
	p.name as "person.name",
	p.age, 
	p.gender,
	p.address,
	z.id as "pizzeria.id",
	z.name as "pizzeria.name",
	z.rating
FROM
	person p 
CROSS JOIN
	pizzeria z
ORDER BY p.id ASC, z.id ASC;


SELECT order_date, CONCAT (p.name, ' (age:', p.age, ')') AS person_information
FROM person_order po
JOIN person p ON p.id = po.person_id
ORDER BY order_date ASC, name ASC;


SELECT order_date, CONCAT (p.name, ' (age:', p.age, ')') AS person_information
FROM person_order po
JOIN person p ON p.id = po.person_id
ORDER BY order_date ASC, name ASC;


SELECT po.order_date, CONCAT(p.name, ' (age:', p.age, ')') AS person_information
FROM person_order AS po (number_id, id, menu_id, order_date)
NATURAL JOIN person p
ORDER BY order_date ASC, person_information ASC;


SELECT name
FROM pizzeria
WHERE name NOT IN (SELECT name
FROM pizzeria pi JOIN person_visits pv ON pi.id = pv.pizzeria_id);
SELECT name
FROM pizzeria pi
WHERE NOT EXISTS (SELECT 1
FROM person_visits pv
WHERE pi.id = pv.pizzeria_id);


SELECT p.name as person_name, m.pizza_name, pi.name as pizzeria_name
FROM person p
	JOIN person_order po ON p.id = po.person_id
	JOIN menu m ON po.menu_id = m.id
	JOIN pizzeria pi ON m.pizzeria_id = pi.id
ORDER BY p.name, m.pizza_name, pi.name ASC;