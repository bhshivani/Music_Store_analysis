ALTER TABLE assets
ALTER COLUMN asset_no TYPE int 
USING asset_no::int;

CREATE TABLE employee(
employee_id VARCHAR(50) PRIMARY KEY,
last_name CHAR(50),
first_name CHAR(50),
title VARCHAR(50),
reports_to VARCHAR(30),
levels VARCHAR(10),
birthdate TIMESTAMP,
hire_date TIMESTAMP,
address VARCHAR(120),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(30),
postal_code VARCHAR(30),
phone VARCHAR(30),
fax VARCHAR(30),
email VARCHAR(30));

CREATE TABLE customer(
customer_id VARCHAR(30) PRIMARY KEY,
first_name CHAR(30),
last_name CHAR(30),
company VARCHAR(30),
address VARCHAR(30),
city VARCHAR(30),
state VARCHAR(30),
country VARCHAR(30),
postal_code INT8,
phone INT,
fax INT,
email VARCHAR(30),
support_rep_id VARCHAR(30));

CREATE TABLE invoice(
invoice_id VARCHAR(30) PRIMARY KEY,
customer_id VARCHAR(30),
invoice_date TIMESTAMP,
billing_address VARCHAR(120),
billing_city VARCHAR(30),
billing_state VARCHAR(30),
billing_country VARCHAR(30),
billing_postal VARCHAR(30),
total FLOAT8);

CREATE TABLE invoice_line(
invoice_line_id VARCHAR(50) PRIMARY KEY,
invoice_id VARCHAR(30),
track_id VARCHAR(30),
unit_price VARCHAR(30),
quantity VARCHAR(30));

CREATE TABLE track(
track_id VARCHAR(50) PRIMARY KEY,
name VARCHAR(30),
album_id VARCHAR(30),
media_type_id VARCHAR(30),
genre_id VARCHAR(30),
composer VARCHAR(30),
milliseconds TIMESTAMP,
bytes INT8,
unit_price INT16);

CREATE TABLE playlist(
playlist_id VARCHAR(50) PRIMARY KEY,
name  VARCHAR(30));

CREATE TABLE playlist_track(
playlist_id VARCHAR(50) PRIMARY KEY,
track_id VARCHAR(50) PRIMARY KEY);

CREATE TABLE artist(
artist_id VARCHAR(50) PRIMARY KEY,
name  VARCHAR(30)); 

CREATE TABLE album(
album_id VARCHAR(50) PRIMARY KEY,
title  VARCHAR(30),
artist_id  VARCHAR(30));

CREATE TABLE media_type(
media_type_id VARCHAR(50) PRIMARY KEY,
name VARCHAR(30));

CREATE TABLE genre(
genre_id VARCHAR(50) PRIMARY KEY,
name VARCHAR(30));

select * from music_database.dbo.employee$
---find out the most senior employee based on job profile----

select top 1 * from music_database.dbo.employee$
order by levels desc 

--to find which country have the most invoices?-----

select * from  music_database.dbo.invoice$
select COUNT(*) as c,billing_country from music_database.dbo.invoice$
group by billing_country
order by c desc


------what are top 3 valuesbof total invoice?-----
select * from music_database.dbo.invoice$

select top 3 total from music_database.dbo.invoice$
order by total desc

---which country has the best customer?we would to throw a promotional music festival in the city 
---we made the most money ,write the highest sum ofinvoice total return both the city name & sum of all invoice
---of all invoice tables?-------

select * from music_database.dbo.invoice$
select sum(total) as invoice_total,
billing_city from music_database.dbo.invoice$
group by billing_city
order by invoice_total desc

---who is the best customer? the customer who has spent money will be declared the best customer.write a query that
---returns the person who has spent the most money----------------


select * from music_database.dbo.customer$
--we have to connect customer$ table with invoice$ table by using JOINS--
select customer$.customer_id, customer$.first_name,customer$.last_name,
sum(invoice$.total) as total  from  music_database.dbo.customer$
join
 music_database.dbo.invoice$ on customer$.customer_id =invoice$.customer_id
group by customer$.customer_id,customer$.first_name,customer$.last_name
order by total desc

--write a querry to return the email,first_name,last_name and Genre of all Rock Music listeners.
---return your ordered alphabetically byemail starting with A.

select * from music_database.dbo.customer$
--we have to join customer$_table with Genre table---

select distinct customer$.email, customer$.first_name, customer$.last_name
from music_database.dbo.customer$
join music_database.dbo.invoice$ on customer$.customer_id = invoice$.customer_id
join music_database.dbo.invoice_line$ on invoice$.invoice_id = invoice_line$.invoice_id
where invoice_line$.track_id IN (
   select track$.track_id
   from music_database.dbo.track$
  join music_database.dbo.genre$ on track$.genre_id = genre$.genre_id
   where genre$.name LIKE 'Rock'
)
order by email;

----let's invite the artists who have written the most Rock Music in our data set.
--write a query that returns the Artist name and total track count of the top 10 rock bands-----

--through album table ,we join artist$ table and Genre$ table with track$ table ---

select * from music_database.dbo.artist$

SELECT TOP 10 artist$.name AS ArtistName,
COUNT(track$.track_id) AS TotalTrackCount
FROM music_database.dbo.track$ AS track$
JOIN music_database.dbo.album$ AS album$ ON track$.album_id = album$.album_id
JOIN music_database.dbo.artist$ AS artist$ ON album$.artist_id = artist$.artist_id
JOIN music_database.dbo.genre$ AS genre$ ON track$.genre_id = genre$.genre_id
WHERE genre$.name = 'Rock'
GROUP BY artist$.name
ORDER BY TotalTrackCount DESC;


---Return all the track names that have a song length longer than the average song length.return the name and each track.
--order by the song length with the long---

--firstly we define average length after we use filter by where clause---

select name ,milliseconds from music_database.dbo.track$
where milliseconds>(select avg (milliseconds)as avg_track_length from  music_database.dbo.track$)
order by milliseconds desc


---find how much amount spent by each customer on artists? write a query  to return customer name ,artist name and total spent.

WITH best_selling_artist AS (
    SELECT TOP 1
        artist$.artist_id AS artist_id,
        artist$.name AS artist_name,
        SUM(invoice_line$.unit_price * invoice_line$.quantity) AS total_sales
    FROM music_database.dbo.invoice_line$ AS invoice_line$
    JOIN music_database.dbo.track$ ON track$.track_id = invoice_line$.track_id
    JOIN music_database.dbo.album$ ON album$.album_id = track$.album_id
    JOIN music_database.dbo.artist$ ON artist$.artist_id = album$.artist_id
    GROUP BY artist$.artist_id, artist$.name
    ORDER BY total_sales DESC
)
SELECT
    artist_id,
    artist_name,
    total_sales
FROM best_selling_artist;

SELECT 
	c.customer_id, 
	c.first_name, 
	c.last_name, 
	bsa.name, 
	SUM(il.unit_price * il.quantity) AS amount_spent
FROM music_database.dbo.invoice$ i
JOIN music_database.dbo.customer$ c ON c.customer_id = i.customer_id
JOIN music_database.dbo.invoice_line$ il ON il.invoice_id = i.invoice_id
JOIN music_database.dbo.track$  t ON t.track_id = il.track_id
JOIN music_database.dbo.album$ alb ON alb.album_id = t.album_id
JOIN music_database.dbo.artist$ bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.name
ORDER BY amount_spent DESC;


-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
--with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
--the maximum number of purchases is shared return all Genres.



WITH popular_genre AS 
(
    SELECT
        COUNT(invoice_line$.quantity) AS purchases,
        customer$.country,
        genre$.name AS genre_name,
        genre$.genre_id, 
        ROW_NUMBER() OVER(PARTITION BY customer$.country ORDER BY COUNT(invoice_line$.quantity) DESC) AS RowNo 
    FROM music_database.dbo.invoice_line$ AS invoice_line$
    JOIN music_database.dbo.invoice$ AS invoice$ ON invoice$.invoice_id = invoice_line$.invoice_id
    JOIN music_database.dbo.customer$ AS customer$ ON customer$.customer_id = invoice$.customer_id
    JOIN music_database.dbo.track$ AS track$ ON track$.track_id = invoice_line$.track_id
    JOIN music_database.dbo.genre$ AS genre$ ON genre$.genre_id = track$.genre_id
    GROUP BY customer$.country, genre$.name, genre$.genre_id
)
SELECT customer$.country, genre_name, genre_id purchases
FROM music_database.dbo.genre$ invoice_genre WITH popular_genre AS 
(
    SELECT
        COUNT(invoice_line$.quantity) AS purchases,
        customer$.country,
        genre$.name AS genre_name,
        genre$.genre_id, 
        ROW_NUMBER() OVER(PARTITION BY customer$.country ORDER BY COUNT(invoice_line$.quantity) DESC) AS RowNo 
    FROM music_database.dbo.invoice_line$ AS invoice_line$
    JOIN music_database.dbo.invoice$ AS invoice$ ON invoice$.invoice_id = invoice_line$.invoice_id
    JOIN music_database.dbo.customer$ AS customer$ ON customer$.customer_id = invoice$.customer_id
    JOIN music_database.dbo.track$ AS track$ ON track$.track_id = invoice_line$.track_id
    JOIN music_database.dbo.genre$ AS genre$ ON genre$.genre_id = track$.genre_id
    GROUP BY customer$.country, genre$.name, genre$.genre_id
)
SELECT customer$.country, genre_name, genre_id purchases
FROM music_database.dbo.genre$  popular_genre
WHERE RowNo = 1;





