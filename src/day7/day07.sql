Select p.id as person_id, count(pv.person_id) as count_of_visits
From person p
	Join person_visits pv ON pv.person_id = p.id
GROUP BY p.id 
ORDER BY count_of_visits DESC, p.id ASC; 


Select p.name as person_id, count(pv.person_id) as count_of_visits
From person p
	Join person_visits pv ON pv.person_id = p.id
GROUP BY p.name 
ORDER BY count_of_visits DESC, p.name ASC
LIMIT 4; 


(SELECT piz.name, count(po.person_id) as count, 'order' as action_type
FROM pizzeria piz
	JOIN menu m ON m.pizzeria_id = piz.id
	JOIN person_order po ON m.id = po.menu_id
GROUP BY piz.name
LIMIT 3)
UNION 
(SELECT piz.name, count(pv.person_id) as count, 'visit' as action_type
FROM pizzeria piz
	JOIN person_visits pv ON pv.pizzeria_id = piz.id
GROUP BY piz.name 
LIMIT 3)
ORDER BY action_type ASC, count DESC;


WITH orders AS (
	SELECT piz.name, count(po.person_id) as count
	FROM pizzeria piz
		JOIN menu m ON m.pizzeria_id = piz.id
		JOIN person_order po ON m.id = po.menu_id
	GROUP BY piz.name
), 
	visits AS (
	SELECT piz.name, count(pv.person_id) as count
	FROM pizzeria piz
		JOIN person_visits pv ON pv.pizzeria_id = piz.id
	GROUP BY piz.name
), 
	summa AS (
	SELECT o.name, (o.count + v.count) AS total_count
	FROM orders o
		JOIN visits v
    ON v.name = o.name
)
SELECT piz.name,
CASE
    WHEN total_count IS NULL THEN 0
    ELSE total_count
END total_count
FROM pizzeria piz
	FULL JOIN summa ON piz.name = summa.name
ORDER BY total_count DESC, name;


SELECT p.name, count (pv.person_id) as count_of_visits
FROM person p
	JOIN person_visits pv ON pv.person_id = p.id
GROUP BY p.name
HAVING count(*) > 3; -- фильтрация групп


SELECT DISTINCT p.name
FROM person p
	JOIN person_order po ON po.person_id = p.id
ORDER BY p.name;


SELECT piz.name, count(order_date) as count_of_orders, 
ROUND(avg(m.price),2) AS average_price, max(m.price) AS max_price,
min(m.price) as min_price
FROM pizzeria piz
	JOIN menu m ON piz.id = m.pizzeria_id
	JOIN person_order po ON po.menu_id = m.id
GROUP BY piz.name
ORDER BY piz.name;


SELECT ROUND(avg(rating),4) AS global_rating
FROM pizzeria;


SELECT p.address, piz.name, count(po.menu_id) AS count_of_orders
FROM person p
	JOIN person_order po ON p.id = po.person_id
	JOIN menu m ON po.menu_id = m.id
	JOIN pizzeria piz ON m.pizzeria_id = piz.id
GROUP BY p.address, piz.name
ORDER BY p.address, piz.name;


SELECT address, ROUND(max(age)-(min(age) / max(age::numeric)),2) AS formula,
ROUND(avg(age),2) as average,
    CASE
        when ROUND((max(age) - min(age) / max(age::numeric)),2) > round(avg(age),2)
		then 'true' else 'false'
    END comparison
FROM person
GROUP BY address
ORDER BY 1;