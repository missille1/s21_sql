create table person_audit
( created timestamp with time zone not null default current_timestamp ,
  type_event char(1) default 'I' not null ,	
  row_id bigint  not null ,
  name varchar not null ,
  age integer not null default 10 ,
  gender varchar default 'female' not null ,
  address varchar,
  constraint ch_type_event check ( type_event in ('I','U','D'))
  );

-- Database Trigger Function
CREATE OR REPLACE FUNCTION fnc_trg_person_insert_audit() RETURNS trigger AS $fnc_trg_person_insert_audit$
-- fnc_trg_person_insert_audit$ ограничитель
-- RETURNS trigger что возвращаем
BEGIN
    IF (TG_OP = 'INSERT') THEN
	--TG_OP спецальная переменная содержит тип операции
        INSERT INTO person_audit SELECT now(), 'I', NEW.*;
		--now возращает дату и время текущее
		--I insert
		--new значение новой строки вставляем все *.
RETURN NEW;
--Необходимо для тригеров бефор, оставляем просто
END IF;
RETURN NULL; -- игнорим так как у нас AFTER
END;
$fnc_trg_person_insert_audit$ LANGUAGE plpgsql;

-- Database Trigger
CREATE TRIGGER trg_person_insert_audit AFTER INSERT ON person
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_insert_audit();
--EACH ROW каждая строка
--EXECUTE FUNCTION когда тригер страбатывает - выполняется функция fnc_trg_person_insert_audit();

INSERT INTO person(id, name, age, gender, address) VALUES (10,'Damir', 22, 'male', 'Irkutsk');


--test
--SELECT * FROM public.person_audit


'-------------------------------------------------------------------------------------------------------'

CREATE OR REPLACE FUNCTION fnc_trg_person_update_audit() RETURNS trigger AS $fnc_trg_person_update_audit$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO person_audit SELECT current_timestamp, 'U', NEW.*;
RETURN NEW;
END IF;
RETURN NULL; -- ignor
END;
$fnc_trg_person_update_audit$ LANGUAGE plpgsql;

-- Database Trigger for UPDATE
CREATE TRIGGER trg_person_update_audit AFTER UPDATE ON person
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_update_audit();

UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;



--test
--SELECT * FROM public.person_audit

'-------------------------------------------------------------------------------------------------------'

CREATE OR REPLACE FUNCTION fnc_trg_person_delete_audit() RETURNS trigger AS $fnc_trg_person_delete_audit$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO person_audit SELECT current_timestamp, 'D', OLD.*;
RETURN NEW;
END IF;
RETURN NULL;
END;
$fnc_trg_person_delete_audit$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_delete_audit AFTER DELETE ON person
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_delete_audit();

DELETE FROM person WHERE id = 10;

-- Check
-- select * from person_audit
-- order by created;

'-------------------------------------------------------------------------------------------------------'
-- FOR DELL 
DROP TRIGGER IF EXISTS trg_person_delete_audit ON public.person;
DROP TRIGGER IF EXISTS trg_person_insert_audit ON public.person;
DROP TRIGGER IF EXISTS trg_person_update_audit ON public.person;

DROP function fnc_trg_person_insert_audit();
DROP function fnc_trg_person_delete_audit();
DROP function fnc_trg_person_update_audit();

truncate person_audit; -- чистильщик

--------------------------------------------------------------------

CREATE OR REPLACE FUNCTION fnc_trg_person_audit() RETURNS trigger AS $fnc_trg_person_audit$
BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO person_audit SELECT current_timestamp, 'D', OLD.*;
RETURN OLD; --как будто это не влияет но я не пон
ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO person_audit SELECT current_timestamp, 'U', NEW.*;
RETURN NEW;
ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO person_audit SELECT current_timestamp, 'I', NEW.*;
RETURN NEW;
END IF;
RETURN NULL;
END;
$fnc_trg_person_audit$ LANGUAGE plpgsql;


CREATE TRIGGER trg_person_audit AFTER INSERT OR UPDATE OR DELETE ON person
    FOR EACH ROW EXECUTE FUNCTION fnc_trg_person_audit();


---------------------------------------------

INSERT INTO person(id, name, age, gender, address)  VALUES (10,'Damir', 22, 'male', 'Irkutsk');
UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;
DELETE FROM person WHERE id = 10;


'-------------------------------------------------------------------------------------------------------'
CREATE OR REPLACE FUNCTION fnc_persons_female()
RETURNS TABLE (
        id bigint,
        name varchar,
        age integer,
        gender varchar,
        address varchar
) AS $$
        (SELECT * FROM person
         WHERE person.gender = 'female');
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION fnc_persons_male()
RETURNS TABLE (
        id bigint,
        name varchar,
        age integer,
        gender varchar,
        address varchar
) AS $$
        (SELECT * FROM person
         WHERE person.gender = 'male');
$$ LANGUAGE sql;

-- check
SELECT *
FROM fnc_persons_male();

SELECT *
FROM fnc_persons_female();

'-------------------------------------------------------------------------------------------------------'
--- чистим чистим 
DROP FUNCTION IF EXISTS public.fnc_persons_female();
DROP FUNCTION IF EXISTS public.fnc_persons_male();

CREATE OR REPLACE FUNCTION fnc_persons(IN pgender varchar default 'female')
RETURNS TABLE (
        id bigint,
        name varchar,
        age integer,
        gender varchar,
        address varchar
) AS $$
(SELECT * FROM person WHERE person.gender = pgender);
$$ LANGUAGE sql;



-- МУЖ.ЖЕН

-- select *
-- from fnc_persons(pgender := 'male');
-- select *
-- from fnc_persons();
'-------------------------------------------------------------------------------------------------------'

CREATE OR REPLACE FUNCTION fnc_person_visits_and_eats_on_date(pperson varchar default 'Dmitriy',
pprice numeric default 500, pdate date default '2022-01-08')
RETURNS TABLE ( name varchar ) --устаналиваем что вернуть только название пиццерии
AS
$$
  SELECT piz.name AS name
  FROM pizzeria piz
          JOIN menu m ON m.pizzeria_id = piz.id
          JOIN person_visits pv ON pv.pizzeria_id = piz.id
          JOIN person p ON p.id = pv.person_id
  WHERE p.name = pperson AND price < pprice
   AND pv.visit_date = pdate;
$$ LANGUAGE SQL;

--select *
-- from fnc_person_visits_and_eats_on_date(pprice := 800);

-- select *
-- from fnc_person_visits_and_eats_on_date(pperson := 'Anna',pprice := 1300,pdate := '2022-01-01');


'-------------------------------------------------------------------------------------------------------'

CREATE FUNCTION func_minimum(VARIADIC arr numeric[])
--Функции SQL с переменным числом аргументов VARIADIC
RETURNS numeric
AS 
$$
SELECT min(i) FROM unnest(arr) g(i);
-- unnest(arr) массив в строки
$$ LANGUAGE SQL;

SELECT func_minimum(VARIADIC arr => ARRAY[10.0, -1.0, 5.0, 4.4]);

'-------------------------------------------------------------------------------------------------------'

CREATE OR REPLACE FUNCTION fnc_fibonacci(pstop integer default 10)
    RETURNS TABLE (a bigint)
AS
$$
WITH RECURSIVE f(a,b) AS (
	SELECT 0 AS a, 1 as b
	UNION ALL
	SELECT b, a+b
	FROM f
	WHERE b<pstop
)
SELECT a FROM f;
$$ LANGUAGE SQL;

select * from fnc_fibonacci(100);
select * from fnc_fibonacci();

'-------------------------------------------------------------------------------------------------------'