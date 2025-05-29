SELECT name, age
FROM person
WHERE address LIKE 'Kazan';


SELECT name, age 
FROM person
WHERE gender = 'female' AND address = 'Kazan'
ORDER BY name ASC;


SELECT name, rating 
FROM pizzeria
WHERE rating >= 3.5 AND rating <= 5
ORDER BY rating DESC;
SELECT name, rating
FROM pizzeria
WHERE rating BETWEEN 3.5 AND 5
ORDER BY rating DESC;


SELECT DISTINCT person_id
FROM person_visits
WHERE (visit_date BETWEEN '2022-01-06' AND '2022-01-09') OR (pizzeria_id = 2)
ORDER BY person_id DESC;


SELECT CONCAT(
    name,
    ' (age:',
    age,
    ',gender:',
    '''', -- двойные кавычки экранируют одиночные кавычки
    gender,
    '''', 
    ',address:',
    '''', 
    address,
    '''', 
    ')'
) AS person_information
FROM person
ORDER BY id ASC;


SELECT
    (SELECT name FROM person WHERE person.id = person_order.person_id) AS NAME
FROM person_order
WHERE ((order_date = '2022.01.07') AND ((menu_id = 13) OR (menu_id = 14) OR (menu_id = 18)));


SELECT
    (SELECT name FROM person WHERE person.id = person_order.person_id) AS NAME,
	CASE WHEN (SELECT name FROM person WHERE person.id = person_order.person_id) = 'Denis'
	THEN 'true'
	ELSE 'false'
	END AS check_name
FROM person_order
WHERE ((order_date = '2022.01.07') AND ((menu_id = 13) OR (menu_id = 14) OR (menu_id = 18)));


SELECT id, name, 
	CASE
	WHEN age >= 10 AND age <= 20 THEN 'interval #1'
	WHEN age > 20 AND age < 24 THEN 'interval #2'
	ELSE 'interval #3'
	END AS interval_info
FROM person
ORDER BY interval_info ASC;


SELECT *
FROM person_order
WHERE id % 2 = 0 
ORDER BY id ASC;


SELECT 
	(SELECT name FROM person WHERE person.id = pv.person_id) AS person_name ,  -- что берем
      (SELECT name FROM pizzeria WHERE pizzeria.id = pv.pizzeria_id) AS pizzeria_name  -- что берем
FROM 
	(SELECT * FROM person_visits WHERE visit_date BETWEEN '2022.01.07' AND '2022.01.09') AS pv -- основное где
ORDER BY 
	person_name ASC,
	pizzeria_name DESC;