create table person_discounts
( 	id bigint primary key ,
	person_id bigint not null ,
	pizzeria_id bigint  not null ,
	discount numeric ,
	constraint fk_person_discounts_person_id foreign key (person_id) references person(id) ,
 	constraint fk_pizzeria_discounts_pizzeria_id foreign key (pizzeria_id) references pizzeria(id)
);


INSERT INTO person_discounts (id, person_id, pizzeria_id, discount)
SELECT
-- Уникальный индификатор
    ROW_NUMBER() OVER() as id, 
    person_id,
    pizzeria_id,
    case when buy_pizzas = 1 then 10.5
         when buy_pizzas  = 2 then 22
         else 30
    end discount
FROM (
    SELECT po.person_id, m.pizzeria_id, count(po.person_id) AS buy_pizzas 
    FROM person_order po
    JOIN menu m
        ON po.menu_id = m.id
-- aggregated state 
    GROUP BY person_id, pizzeria_id
) AS order_sum;


SELECT p.name, m.pizza_name, m.price, 
ROUND((m.price - (pd.discount/100)*m.price)) AS discount_price, 
pi.name AS pizzeria_name 
FROM person p  
	JOIN person_order po ON po.person_id = p.id 
	JOIN menu m ON po.menu_id = m.id
	JOIN pizzeria pi ON pi.id = m.pizzeria_id
	JOIN person_discounts pd ON p.id = pd.person_id
ORDER BY p.name, m.pizza_name;
	

CREATE INDEX idx_person_discounts_unique ON person_discounts(person_id, pizzeria_id);
SET enable_seqscan = off;
EXPLAIN ANALYZE 
SELECT person_id, pizzeria_id
FROM person_discounts;


alter table person_discounts ADD CONSTRAINT ch_nn_person_id check (person_id IS NOT NULL);
alter table person_discounts ADD CONSTRAINT ch_nn_pizzeria_id check (pizzeria_id IS NOT NULL);
alter table person_discounts ADD CONSTRAINT ch_nn_discount check (discount IS NOT NULL);
alter table person_discounts ALTER COLUMN discount SET default 0;
alter table person_discounts ADD CONSTRAINT ch_range_discount check (discount between 0 and 100);


COMMENT ON TABLE person_discounts IS 'This table is for look discount for person';
COMMENT ON COLUMN person_discounts.id IS 'Порядковый номер';
COMMENT ON COLUMN person_discounts.person_id IS 'Порядковый номер person';
COMMENT ON COLUMN person_discounts.pizzeria_id IS 'Порядковый номер pizzeria';
COMMENT ON COLUMN person_discounts.discount IS 'Sale for person';


-- CREATE SEQUENCE создаёт генератор последовательности
CREATE SEQUENCE seq_person_discounts START 1;
-- nextval последовательность увеличивается на заданное количество (необходимо когда добавляем строки в таблицу)
ALTER TABLE person_discounts ALTER COLUMN id SET default nextval('seq_person_discounts');
-- setval установка текущего значения последовательности (необходимо когда удаляем строки из таблицы)
SELECT setval('seq_person_discounts', (select count(*) + 1 from person_discounts));
-- select *
-- from pg_sequences
-- where sequencename = 'seq_person_discounts'
