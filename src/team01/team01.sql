SELECT name, lastname, type, sum(money) as volume, currency_name,
last_rate_to_usd, (sum(money) * last_rate_to_usd) as total_volume_in_usd
FROM (
      	SELECT DISTINCT
			  COALESCE(u.name, 'not defined') as name, 
			  COALESCE(u.lastname, 'not defined') as lastname, b.type, b.money,
			  COALESCE(c.name, 'not defined') as currency_name,
			-- оконная функция которая находим согласно дате последний курс валют 
			  COALESCE(first_value(c.rate_to_usd) over(partition by c.id order by c.updated desc), 1) as last_rate_to_usd
         FROM balance b
	-- Нужен именно фул потому что теряем Петра при запросе
         	FULL JOIN public.user u ON b.user_id = u.id
         	FULL JOIN currency c ON b.currency_id = c.id
     ) SORT
GROUP BY name, lastname, type, currency_name, last_rate_to_usd
ORDER BY name desc, lastname, type

-- select u.name, u.lastname, b.type, sum(b.money), 
-- c.name, c.rate_to_usd, sum(b.money)*c.rate_to_usd
-- from (
-- 	SELECT 
-- 	)
-- 	public.user u	
-- 	FULL JOIN balance b ON b.user_id = u.id
-- 	FULL JOIN currency c ON c.id = b.currency_id
-- GROUP BY u.name, u.lastname, b.type, c.name, c.rate_to_usd
-- ORDER BY u.name desc, u.lastname ASC, b.type ASC


'---------------------------------------------------------------------------------'

--insert into currency values (100, 'EUR', 0.85, '2022-01-01 13:29');
--insert into currency values (100, 'EUR', 0.79, '2022-01-08 13:29');
SELECT name,
	lastname,
	currency_name,
	CAST(money * rate_to_usd as float) AS currency_in_usd
FROM (
		SELECT COALESCE("user".name, 'not defined') AS name,
			COALESCE("user".lastname, 'not defined') AS lastname,
			currency.name AS currency_name,
			money,
			COALESCE (
				(
					SELECT rate_to_usd AS t1
					FROM currency
					WHERE id = b.currency_id
						AND updated < b.updated
					ORDER BY updated DESC
					LIMIT 1
				), (
					SELECT rate_to_usd AS t2
					FROM currency
					WHERE id = b.currency_id
						AND updated > b.updated
					ORDER BY updated ASC
					LIMIT 1
				)
			) AS rate_to_usd
		FROM balance b
			INNER JOIN (
				SELECT id,
					name
				FROM currency
				GROUP BY id,
					name
			) AS currency ON currency.id = b.currency_id
			LEFT JOIN "user" ON "user".id = b.user_id
	) as a
ORDER BY name DESC,
	lastname,
	currency_name;
