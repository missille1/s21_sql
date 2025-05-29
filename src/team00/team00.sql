create table nodes 
( point1 varchar not null,
  point2 varchar not null,
  cost integer not null 
  );

insert into nodes values ( 'a', 'b', '10');
insert into nodes values ( 'a', 'd', '20');
insert into nodes values ( 'a', 'c', '15');
insert into nodes values ( 'b', 'd', '25');
insert into nodes values ( 'b', 'c', '35');
insert into nodes values ( 'b', 'a', '10');
insert into nodes values ( 'c', 'b', '35');
insert into nodes values ( 'c', 'd', '30');
insert into nodes values ( 'c', 'a', '15');
insert into nodes values ( 'd', 'a', '20');
insert into nodes values ( 'd', 'c', '30');
insert into nodes values ( 'd', 'b', '25');


WITH RECURSIVE way AS (
-- Просто строим маршрут от точки А до любой следующей точки
  SELECT point1 AS path, point1, point2, cost
  FROM nodes n
  WHERE point1 = 'a'
  
  UNION
  
-- Выполняем рекурсивно добавлением следующих точек маршрута
  SELECT CONCAT(w.path, ',', n.point1) AS path,
    n.point1, n.point2,
    w.cost + n.cost
  FROM way w
    JOIN nodes n ON w.point2 = n.point1
  WHERE path NOT LIKE CONCAT('%', n.point1, '%') -- Проверяем, что мы не прошли точку например %b% дважды. % - означает сколько угодно символов до.
),

-- Фильтруем чтобы были пройденный все точки в количестве 5 штук.
filter_way AS (
  SELECT cost AS total_cost, CONCAT('{', path, ',', point2, '}') AS tour
  FROM way
  WHERE LENGTH(path) = 7 AND point2 = 'a'
)
-- Финальный запрос
SELECT *
FROM filter_way
-- Ищем только самые дешевый путь
WHERE total_cost = ( SELECT MIN(total_cost)
  					FROM filter_way)
ORDER BY total_cost, tour;


'--------------------------------------------------------------------------------------------------'



WITH RECURSIVE way AS (
-- Просто строим маршрут от точки А до любой следующей точки
  SELECT point1 AS path, point1, point2, cost
  FROM nodes n
  WHERE point1 = 'a'
  
  UNION
  
-- Выполняем рекурсивно добавлением следующих точек маршрута
  SELECT CONCAT(w.path, ',', n.point1) AS path,
    n.point1, n.point2,
    w.cost + n.cost
  FROM way w
    JOIN nodes n ON w.point2 = n.point1
  WHERE path NOT LIKE CONCAT('%', n.point1, '%') -- Проверяем, что мы не прошли точку например %b% дважды. % - означает сколько угодно символов до.
),

-- Фильтруем чтобы были пройденный все точки в количестве 5 штук.
filter_way AS (
  SELECT cost AS total_cost, CONCAT('{', path, ',', point2, '}') AS tour
  FROM way
  WHERE LENGTH(path) = 7 AND point2 = 'a'
)
-- Финальный запрос
SELECT *
FROM filter_way
-- Ищем только самые дешевый путь
-- WHERE total_cost = ( SELECT MIN(total_cost)
--   					FROM filter_way)

-- UNION ALL 

-- SELECT *
-- FROM filter_way
-- -- Ищем только самые дорогой путь
-- WHERE total_cost = ( SELECT MAX(total_cost)
--   					FROM filter_way)

ORDER BY total_cost, tour;
