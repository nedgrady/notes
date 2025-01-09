# Goals
Add the following tools to your toolbelt:
1. SQL statements
	1. DDL Statements
		1. CREATE TABLE
		2. DROP TABLE
		3. ALTER TABLE
	2. DML Statements
		1. INSERT
		2. SELECT
			1. ORDER BY
			2. TOP/LIMIT
		3. DELETE
		4. UPDATE
		5. WHERE (for SELECT, DELETE, UPDATE)
	3. Built-in functions
		1. Get the current date
		2. Arithmetic
2. Table design
	1. Columns
		1. Types
		2. NULLs
	2. Constraints
		1. Primary Key
		2. Foreign Key
		3. Unique
	3. Modelling the real world
		1. One to many
		2. Many to Many
		3. Drawing the above out
3. Database Setup
	1. Locally
	2. In the cloud
		1. SQL running on a VM
		2. SQL as a Service
4. Stretch: Comfortable exploring an existing enterprise db

 # Not in scope, but important
 * Transactions
 * Stored Procedures
 * Aggregating data
	 * MIN, MAX, AVG, COUNT with GROUP BY
	 * HAVING
	 * DISTINCT

# Scenario
We're in the early stage of developing a new product called 'partygoers'. We'll be getting some requirements one-by-one, and want to ensure that our SQL database technology of choice is up to the task (hint: it will be :D)

# Setup

First, a VERY quick pre-amble on databases:

Two key players:
* The engine (a.k.a. the server)
	* Usually hosted on dedicated hardware when running in production
	* In test environments, you'll see some running on shared hardware, some on their own hardware
	* When used for local development, any of
		* Shared server for all devs (EUGH - n.b. there are horror stories of devs devving against PROD!)
		* Server running locally on dev's machines (Isolated - Nice!)
* Clients (a.k.a. connections)
	* Sends SQL (query) (DDL, DML) to the server
	* May receive data, or just a success/failure response
	* Apps connect to a DB, submits SQL via code e.g.
		* ![[Pasted image 20241216220332.png]]
	* Humans connect to the DB, usually by using a client then hand-crafting queries
		* ![[Screenshot 2024-12-16 at 22.51.35.png]]

Today we are going to focus on hand-crafting SQL, just to avoid the complexities (that aren't THAT complex) of connecting to a server via code.

* Normally would have to somehow
	* Download the postgres program onto PC https://www.postgresql.org/download/
	* Figure out how to start it... https://www.postgresql.org/docs/current/server-start.html
* But for ease of setup we will use Docker

1. Install docker https://docs.docker.com/desktop/setup/install/windows-install/

2. pull the postgres image (container with the postgres engine installed so we don't have to manually install it)
```
docker pull postgres
```

If this is successful, you can run `docker images ls` and see a line for 'postgres'
3. Run the image to start postgres
```bash
docker run -e POSTGRES_PASSWORD=password -d -p 5432:5432 postgres
```
If this is successful, you can run `docker ps` and see a line for postgres...
... then connect from your tool of choice (e.g. PGAdmin)

Host name/address: localhost
Port: 5432
Username: postgres
Password: password

Remember we're creating a new product, so creating a new database is probably a good idea.
![[Pasted image 20241217004402.png]]


# Requirements

Each requirement will be in the form of an english statement, we will aim to write the SQL to solve the problem. There may be many ways to solve each requirement (perhaps multiple options for the SQL or table design). E.g (for a fictitious payments processor):

1. I have a list of payments from a third party that I want to store to use later e.g:
amount: 1.23, payment_initiated_at: '2024-12-17 00:55:52', payment_confirmed_at: '2024-12-17 00:55:53'
amount: 2.34, payment_initiated_at: '2024-12-17 00:55:52', payment_confirmed_at: NULL
Answer:
```sql
insert into payments
(
	amount,
	payment_initited_at,
	payment_confirmed_at
)
SELECT	1.23, '2024-12-17 00:55:52'::timestamp, '2024-12-17 00:55:53'::timestamp
UNION
SELECT	2.34, '2024-12-17 00:55:52'::timestamp, NULL

-- OR

insert into payments
(
	amount,
	payment_initited_at,
	payment_confirmed_at
)
VALUES
(1.23, '2024-12-17 00:55:52'::timestamp, '2024-12-17 00:55:53'::timestamp),
(2.34, '2024-12-17 00:55:52'::timestamp, NULL)
```
2. I want to see a list of all the payments that have been completed in the last 24 hrs

```sql
select	*
from	payments
where	payment_confirmed_at > now() - INTERVAL '1 DAY'
```


# Requirements (Real)

1. We're out on the street gauging interest for the app, we're going to collect some information about people and need a way to store it for later
	1. Name (We need this)
	2. Have they ever been to a party before (some people prefer not to answer)
2. We're hosting members only party. The bouncers want to print a list of members in the system so they can check people turning up are members.
3. We've decided we'll host two types of parties, one with alcohol one without so we need to track people's ages too
4. A person called 'Kevin de Boner' turned up, the bouncers noticed there's two people with that name on the printout so weren't sure what to do.
5. We've contacted people signed up in step 1 (before we tracked age) to ask their age, can you help us store this data?
6. There's now about 100 people on the printout. Its taking the bouncers a long time to find a name. Can you help speed this process up?
7. Those changes were great, but its still taking a bit too long. To speed this process up we'll add two queues at parties - a 'newbies' queue and a 'been before' queue. We also want to tick 'newbies' off and update them in our system to reflect they've attended a party.
8. We're going to host an over 18s party now, can you help us create a list of people who are able to enter?

BREAK

9. We're taking a picture of people's ID when they enter the party. Can you store them in the DB?
10. We've started to ask what people's favourite drink is upon entry, e.g. 'Diet Coca Cola', 'Pepsi Max' or 'Red Wine'. People can only have 1 favourite drink. We'd like to capture what people's favourite drinks are. (at least 2 ways to do this)
11. Upon entry, we'd like the bouncers to shout out a person's favourite drink to the bar staff. Can you help us get this info to the bouncers?
12. Due to a very disgusting viral video, its now taboo to say 'red wine' out loud. People now say 'Rouge Juice'. How can we prevent the bouncers from shouting out 'Rouge Juice' to the bar staff? (at least 2 ways to do this)
13. Sometimes we've ran out of people's favourite drinks, is it possible for them to have 2 favourite drinks?
14. We've had some people ask to exercise their 'right to be forgotten' under GDPR. Can you help us add this functionality?

BREAK

Hopefully now we have completed
* A schema script
* At least one data migration script



16. We're ready to host our database for real in a production environment, but we don't have the resources to have a DBA
	1. https://aws.amazon.com/rds/free/
	2. Remember to add ip to whitelist![[Pasted image 20241219095530.png]]
		
17. When would we choose a managed instance over provisioning SQL on a VM, and vice-versa?



# Homework

1. Translate the answers we gave using pgsql into another db technology's version of SQL
2. Compare the two SQL scripts, note how some things are very similar - what does this tell us about the tools/skills we've sharpened today?
3. Run the other database locally (docker, or bare metal setup)
4. Quickly setup a free tier on RDS for the above db, create the objects scripted out in part 2.