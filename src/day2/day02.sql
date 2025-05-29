SELECT pi.name, pi.rating 
FROM person_visits pv FULL JOIN pizzeria pi ON pi.id = pv.pizzeria_id
WHERE pv.id IS null;


SELECT missing_date::date
FROM generate_series(
  '2022-01-01'::date, 
  '2022-01-10',
  '1 day'
  ) AS missing_date
  FULL JOIN (SELECT visit_date, person_id FROM person_visits WHERE person_visits.person_id = 1 OR person_visits.person_id = 2) pv ON pv.visit_date = missing_date
WHERE  pv.visit_date IS null
ORDER BY missing_date ASC;


SELECT coalesce(p.name, '-') as person_name, all_date::date as visit_date, coalesce(pi.name, '-') as pizzeria_name
FROM generate_series(
  '2022-01-01'::date, 
  '2022-01-03',
  '1 day'
  ) AS all_date
  FULL JOIN (SELECT * FROM person_visits WHERE visit_date between '2022-01-01' and '2022-01-03') pv ON pv.visit_date = all_date
  FULL JOIN (SELECT * FROM pizzeria) pi ON pv.pizzeria_id = pi.id
  FULL JOIN (SELECT * FROM person) p ON pv.person_id = p.id
ORDER BY person_name, visit_date, pizzeria_name;
--
-- Простой вариант
-- SELECT coalesce(p.name, '-') as person_name, pv.visit_date, coalesce(piz.name, '-') as pizzeria_name
-- FROM pizzeria piz
-- 	FULL JOIN (SELECT * FROM person_visits WHERE visit_date between '2022-01-01' and '2022-01-03') pv ON  piz.id = pv.pizzeria_id
-- 	FULL JOIN person p ON pv.person_id = p.id
-- ORDER BY person_name, pv.visit_date, pizzeria_name;


WITH MISSDATE(missing_date) AS 
(
SELECT missing_date::date
FROM generate_series(
  '2022-01-01'::date, 
  '2022-01-10',
  '1 day'
  ) AS missing_date
  FULL JOIN (SELECT visit_date, person_id FROM person_visits WHERE person_visits.person_id = 1 OR person_visits.person_id = 2) pv ON pv.visit_date = missing_date
WHERE  pv.visit_date IS null
)
SELECT missing_date
FROM MISSDATE
ORDER BY missing_date ASC;


SELECT m.pizza_name, p.name as pizzeria_name, m.price
FROM menu m
FULL JOIN (SELECT * FROM pizzeria) p ON p.id = m.pizzeria_id 
WHERE m.pizza_name = 'mushroom pizza' OR m.pizza_name = 'pepperoni pizza'
ORDER BY m.pizza_name, p.name;


SELECT name
FROM person
WHERE gender = 'female' AND age >= 25
ORDER BY name;


SELECT m.pizza_name, p.name
FROM pizzeria p
 JOIN (SELECT * FROM menu) m ON p.id = m.pizzeria_id
 JOIN (SELECT * FROM person_order) po ON po.menu_id = m.id
 JOIN (SELECT * FROM person WHERE name = 'Denis' OR name = 'Anna') per ON po.person_id = per.id
ORDER BY m.pizza_name, p.name;


SELECT p.name
FROM pizzeria p
  JOIN (SELECT * FROM menu WHERE price < 800) m ON p.id = m.pizzeria_id
  JOIN (SELECT * FROM person_visits WHERE visit_date = '2022-01-08') pv ON pv.pizzeria_id = p.id
  JOIN (SELECT * FROM person WHERE name = 'Dmitriy') per ON pv.person_id = per.id;


SELECT per.name
FROM person as per
  JOIN (SELECT * FROM person_order) po ON po.person_id = per.id
  JOIN (SELECT * FROM menu) m ON po.menu_id = m.id
WHERE per.gender = 'male' AND (per.address = 'Moscow' OR per.address = 'Samara') AND (
(m.pizza_name = 'pepperoni pizza' OR m.pizza_name = 'mushroom pizza') OR 
(m.pizza_name = 'pepperoni pizza' AND m.pizza_name = 'mushroom pizza')
)
ORDER BY per.name DESC;


WITH girls AS (SELECT per.name, m.pizza_name
FROM person as per
  JOIN (SELECT * FROM person_order) po ON po.person_id = per.id
  JOIN (SELECT * FROM menu) m ON po.menu_id = m.id
WHERE per.gender = 'female')

SELECT name
FROM girls
WHERE pizza_name = 'pepperoni pizza'
INTERSECT
SELECT name
FROM girls
WHERE pizza_name = 'cheese pizza'
ORDER BY name;


SELECT pn2.name as person_name1, pn1.name as person_name2, pn1.address as common_address 
FROM person pn1, person pn2
WHERE pn1.address = pn2.address AND pn1.id < pn2.id
ORDER BY person_name1, person_name2, common_address;