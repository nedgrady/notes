
-- 1
CREATE TABLE IF NOT EXISTS people
(
	name text NOT NULL,
	has_attended_party boolean
);

-- Some seed data
INSERT INTO people
(
	name,
	has_attended_party
)
SELECT
	'Ned Grady',
	true
UNION ALL
SELECT
	'Azz',
	true
UNION ALL
SELECT
	'Kevin de Boner',
	false
UNION ALL
SELECT
	'Debbie Downer',
	NULL
	
	

-- 2
SELECT
	name
FROM
	people;

-- 3
ALTER TABLE people
ADD COLUMN date_of_birth timestamp;


-- 4
INSERT INTO people
(
	name	
)
SELECT
	'Kevin de Boner';

ALTER TABLE people
ADD COLUMN id BIGSERIAL PRIMARY KEY;

SELECT
	id,
	name
FROM
	people;

-- 5
UPDATE
	people
SET
	date_of_birth = '2000-01-03'
WHERE
	id = 1;

-- 6
SELECT
	name
FROM
	people
ORDER BY
	name

-- 7
DO
$$
BEGIN
    FOR i IN 1..200 LOOP
        INSERT INTO people (name, has_attended_party, date_of_birth)
        VALUES (
            -- Concatenate "User" with selected system-generated data or objects
            (SELECT 'User_' || substr(md5(random()::text || clock_timestamp()::text), 1, 8)),
            -- Random boolean value for has_attended_party
            (CASE WHEN random() > 0.5 THEN TRUE ELSE FALSE END),
            -- Random timestamp with a 10% chance of being NULL
            (CASE WHEN random() > 0.1 THEN 
                timestamp '1990-01-01' + (random() * (365 * 40)) * '1 day'::interval
            ELSE 
                NULL
            END)
        );
    END LOOP;
END
$$;

SELECT
	has_attended_party,
	name
FROM
	people
ORDER BY
	has_attended_party,
	name;

	
-- 8 
SELECT
	has_attended_party,
	name,
	age(date_of_birth)
FROM
	people
WHERE
	EXTRACT(year FROM age(date_of_birth)) >= 18
ORDER BY
	has_attended_party,
	name;

-- 9
-- No!

-- 10
-- Option 1
ALTER TABLE people
ADD COLUMN favourite_drink text;

-- Option 2
CREATE TABLE IF NOT EXISTS drinks
(
	id bigserial PRIMARY KEY,
	name text NOT NULL
);

ALTER TABLE people
ADD COLUMN favourite_drink_id bigint REFERENCES drinks(id);

INSERT INTO drinks
(
	name
)
SELECT 'Red Wine'
UNION ALL
SELECT 'Coca Cola'
UNION ALL
SELECT 'Pepsi Max'

UPDATE people
SET favourite_drink_id = (id % 3) + 1
WHERE id < 50

UPDATE people
SET	favourite_drink = (SELECT name from drinks where drinks.id = (people.id % 3) + 1)
WHERE people.id < 50


-- 11
-- Denormalized Option
SELECT
	has_attended_party,
	name,
	id,
	age(date_of_birth),
	favourite_drink
FROM
	people
WHERE
	EXTRACT(year FROM age(date_of_birth)) >= 18
ORDER BY
	has_attended_party,
	name;

-- Normalized Option, 1 to Many
SELECT
	people.has_attended_party,
	people.name,
	people.id,
	age(people.date_of_birth),
	drinks.name
FROM
	people
	LEFT JOIN drinks on people.favourite_drink_id = drinks.id
WHERE
	EXTRACT(year FROM age(people.date_of_birth)) >= 18
ORDER BY
	people.has_attended_party,
	people.name;


-- 12
-- n.b. Got to think about case sensitivity
-- 'Fudge the query' option
SELECT
	people.has_attended_party,
	people.name,
	people.id,
	age(people.date_of_birth),
	REPLACE(drinks.name, 'Red Wine', 'Rouge Juice')
FROM
	people
	LEFT JOIN drinks on people.favourite_drink_id = drinks.id
WHERE
	EXTRACT(year FROM age(people.date_of_birth)) >= 18
ORDER BY
	people.has_attended_party,
	people.name;


-- 'Fudge the data' option
UPDATE	drinks
SET		name = REPLACE(name, 'Red Wine', 'Rouge Juice')


-- 13
-- Nasty Hack (SQL not listed)
-- Add favourite_drink_2 or favourite_drink_2_id to people table

-- Convert people-drinks to Many - Many relationship

CREATE TABLE person_drink_preferences
(
	person_id bigint NOT NULL REFERENCES people(id),
	drink_id bigint NOT NULL REFERENCES drinks(id),
	    PRIMARY KEY (person_id, drink_id)
);


INSERT INTO person_drink_preferences
(
	person_id,
	drink_id
)
SELECT
	people.id,
	drinks.id
FROM
	people

INNER JOIN drinks ON drinks.id = people.favourite_drink_id;

INSERT INTO person_drink_preferences
(
	person_id,
	drink_id
)
SELECT 6, 3


ALTER TABLE people 
DROP COLUMN favourite_drink_id;

SELECT
	people.has_attended_party,
	people.name,
	people.id,
	age(people.date_of_birth),
	REPLACE(drinks.name, 'Red Wine', 'Rouge Juice')
FROM
	people
	LEFT JOIN person_drink_preferences dp
		ON dp.person_id = people.id
	LEFT JOIN drinks
		ON dp.drink_id = drinks.id
WHERE
	EXTRACT(year FROM age(people.date_of_birth)) >= 18
	-- AND people.id = 6
ORDER BY
	people.has_attended_party,
	people.name;

-- 14
DELETE FROM person_drink_preferences
WHERE	person_id = 1;

DELETE FROM people
WHERE id = 1;



