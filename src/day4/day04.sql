CREATE VIEW v_persons_male AS SELECT id, name, age, gender, address FROM person
WHERE gender = 'male';

CREATE VIEW v_persons_female AS SELECT id, name, age, gender, address FROM person
WHERE gender = 'female';


SELECT name FROM v_persons_female
UNION
SELECT name FROM v_persons_male
ORDER BY name;


CREATE VIEW v_generated_dates AS SELECT generated_date::date
FROM generate_series(
  '2022-01-01'::date,
  '2022-01-31',
  '1 day'
) AS generated_date;


SELECT generated_date as missing_date
FROM v_generated_dates
EXCEPT
SELECT visit_date as missing_date
FROM person_visits
WHERE visit_date <= '2022-01-31'
ORDER by missing_date;


CREATE VIEW v_symmetric_union AS
(
	(SELECT person_id
	FROM person_visits
	WHERE visit_date = '2022-01-02'
	
	EXCEPT
	
	SELECT person_id
	FROM person_visits
	WHERE visit_date = '2022-01-06')
	
	UNION
	
	(SELECT person_id
	FROM person_visits
	WHERE visit_date = '2022-01-06'
	
	EXCEPT
	
	SELECT person_id
	FROM person_visits
	WHERE visit_date = '2022-01-02'
)
ORDER by person_id);
-- CREATE VIEW v_symmetric_union AS ((SELECT person_id
-- FROM person_visits
-- WHERE visit_date <= '2022-01-02'
-- EXCEPT
-- SELECT person_id
-- FROM person_visits
-- WHERE visit_date <= '2022-01-06')
-- UNION
-- (SELECT person_id
-- FROM person_visits
-- WHERE visit_date <= '2022-01-06'
-- EXCEPT
-- SELECT person_id
-- FROM person_visits
-- WHERE visit_date <= '2022-01-02')
-- ORDER by person_id);


CREATE VIEW v_price_with_discount AS (
SELECT p.name, m.pizza_name, m.price, di.discount_price::integer
FROM person p
	JOIN person_order po ON po.person_id = p.id
	JOIN menu m ON m.id = po.menu_id 
	JOIN (SELECT id, price - price*0.1 as discount_price FROM menu) AS di ON di.id = po.menu_id 
ORDER by p.name, m.pizza_name);


CREATE MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS (
SELECT p.name
FROM pizzeria p
  JOIN (SELECT * FROM menu WHERE price < 800) m ON p.id = m.pizzeria_id
  JOIN (SELECT * FROM person_visits WHERE visit_date = '2022-01-08') pv ON pv.pizzeria_id = p.id
  JOIN (SELECT * FROM person WHERE name = 'Dmitriy') per ON pv.person_id = per.id);



INSERT INTO person_visits (id, person_id, pizzeria_id, visit_date)
VALUES ( ( SELECT MAX( id )+1 FROM person_visits ),
( SELECT id FROM person WHERE name = 'Dmitriy' ),
( SELECT p.id FROM pizzeria p 
				JOIN (SELECT * FROM menu WHERE price < 800 LIMIT 1) m ON p.id = m.pizzeria_id
				JOIN mv_dmitriy_visits_and_eats dvae ON dvae.name != p.name ),
'2022-01-08');
REFRESH MATERIALIZED VIEW mv_dmitriy_visits_and_eats;


DROP MATERIALIZED VIEW IF EXISTS mv_dmitriy_visits_and_eats;
DROP VIEW IF EXISTS v_generated_dates;
DROP VIEW IF EXISTS v_persons_female;
DROP VIEW IF EXISTS v_persons_male;
DROP VIEW IF EXISTS v_price_with_discount;
DROP VIEW IF EXISTS v_symmetric_union;