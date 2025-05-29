-- Session #1

-- Update of rating for "Pizza Hut" to 5 points in a transaction mode.
-- Check that you can see a changes in session #1.

BEGIN;
UPDATE pizzeria
SET rating = 5 WHERE name = 'Pizza Hut';

SELECT * FROM pizzeria WHERE name = 'Pizza Hut';


-- Session #2

SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

-- Session #1

-- Publish your changes for all parallel sessions.

COMMIT;

-- Session #2

-- Check that you can see a changes in session #2.

SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

'----------------------------------------------------------------------------'

-- SESSEION #1

BEGIN;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

UPDATE pizzeria
SET rating = 4 WHERE name = 'Pizza Hut';
COMMIT;

SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

-- SESSEION #2

BEGIN;
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';

COMMIT;

SELECT * FROM pizzeria WHERE name = 'Pizza Hut';


'----------------------------------------------------------------------------'

-- Session #1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Session #2
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
-- Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
-- Session #1
UPDATE pizzeria SET rating = 4 WHERE name = 'Pizza Hut';
-- Session #2
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
-- Session #1
COMMIT;
-- Session #2
COMMIT;
-- Session #1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
-- Session #2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

'----------------------------------------------------------------------------'

-- Session 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SHOW TRANSACTION ISOLATION LEVEL;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

-- Session 2
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
SHOW TRANSACTION ISOLATION LEVEL;
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
COMMIT;

-- Session 1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
COMMIT;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

-- Session 2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

'----------------------------------------------------------------------------'

-- Session 1
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Session 2
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
-- Session 1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
-- Session 2
UPDATE pizzeria SET rating = 3.0 WHERE name = 'Pizza Hut';
COMMIT;
-- Session 1
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
COMMIT;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
-- Session 2
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';


'----------------------------------------------------------------------------'

-- Session 1
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Session 2
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- Session 1
SELECT sum(rating) FROM pizzeria;
-- Session 2
insert into pizzeria values (10,'Kazan Pizza', 5);
COMMIT;
-- Session 1
SELECT sum(rating) FROM pizzeria;
COMMIT;
SELECT sum(rating) FROM pizzeria;
-- Session 2
SELECT sum(rating) FROM pizzeria;

'----------------------------------------------------------------------------'

-- Session 1
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Session 2
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- Session 1
SELECT sum(rating) FROM pizzeria;
-- Session 2
insert into pizzeria values (11,'Kazan Pizza 2', 4);
COMMIT;
-- Session 1
SELECT sum(rating) FROM pizzeria;
COMMIT;
SELECT sum(rating) FROM pizzeria;
-- Session 2
SELECT sum(rating) FROM pizzeria;


'----------------------------------------------------------------------------'


-- Session 1
BEGIN;
-- Session 2
BEGIN;
-- Session 1
UPDATE pizzeria SET rating = 3.1 WHERE id = 1;
-- Session 2
UPDATE pizzeria SET rating = 3.1 WHERE id = 2;
-- Session 1
UPDATE pizzeria SET rating = 3.2 WHERE id = 2;
-- Session 2
UPDATE pizzeria SET rating = 3.2 WHERE id = 1;
-- Session 1
COMMIT;
-- Session 2
COMMIT;


-- Session 1
SELECT * from pizzeria;

-- Session 2
SELECT * from pizzeria;
