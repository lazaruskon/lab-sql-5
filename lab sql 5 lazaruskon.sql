-- Lab 5 SQL 

use sakila;

  -- Drop column picture from staff.
select * from staff; -- checking this table
alter table staff
drop column picture;
select * from staff; -- sanity check

  -- A new person is hired to help Jon. Her name is TAMMY SANDERS, and she is a customer. Update the database accordingly.
select * from staff; -- checking this table
select * from customer; -- checking this table
select * from customer where first_name = "tammy" and last_name = "sanders"; -- to identify where tammy sanders is

insert into staff (staff_id, first_name, last_name, address_id, email, store_id, username, last_update)
select customer_id, first_name, last_name, address_id, email, store_id, first_name, last_update 
from customer
where customer.first_name = "tammy" and customer.last_name = "sanders";
-- I was getting an error about the column username which doesn't exist in the customer table. At first I tried to add a null but that was not allowed by the table's settings (staff). So I just used the first_name column after examining the username column.

select * from staff; -- sanity check

  -- Add rental for movie "Academy Dinosaur" by Charlotte Hunter from Mike Hillyer at Store 1. You can use current date for the rental_date column in the rental table. Hint: Check the columns in the table rental and see what information you would need to add there. You can query those pieces of information. For eg., you would notice that you need customer_id information as well. To get that you can use the following query:
  -- select customer_id from sakila.customer
  -- where first_name = 'CHARLOTTE' and last_name = 'HUNTER';
  -- Use similar method to get inventory_id, film_id, and staff_id.

select * from film;
select * from staff;
select * from rental;
select * from inventory;

-- finding the elements needed based on the rental table columns.
select * from rental order by rental_id desc limit 1; -- to see the existing last rental_id. We then add 1 to this. -- rental_id = 16050
select current_timestamp(); -- rental_date = 2022-08-27 17:38:02
select inventory_id from sakila.inventory where inventory_id = 1; -- inventory_id = 6
select customer_id from sakila.customer where first_name = 'CHARLOTTE' and last_name = 'HUNTER'; -- customer_id = 130
-- return_date = NULL
select staff_id from sakila.staff where first_name = 'Mike' and last_name = 'Hillyer'; -- staff_id = 1
select current_timestamp(); -- last_update = 2022-08-27 17:38:02

insert into rental
values	(16050,
		"2022-08-27 17:38:02",
		(select inventory_id from sakila.inventory where film_id = (select film_id from sakila.film where title = "Academy Dinosaur") and inventory_id = 6),
        (select customer_id from sakila.customer where first_name = "CHARLOTTE" and last_name = "HUNTER"),
        NULL,
        1,
        "2022-08-27 17:38:02"); -- Giving credit where credit is due: Sergi helped me with the clustered arguments.

select * from rental order by rental_id desc limit 1; -- sanity check

--  Delete non-active users, but first, create a backup table deleted_users to store customer_id, email, and the date for the users that would be deleted. Follow these steps:
    -- Check if there are any non-active users
	-- Create a table backup table as suggested
    -- Insert the non active users in the table backup table
    -- Delete the non active users from the table customer

select * from customer;
select * from customer where active = 0; -- to get the non-active users
select count(*) from customer where active = 0; -- to see exactly how many non-active users we have

create table deleted_users(
customer_id int unique not null,
email char(50) default null, 
create_date datetime
); -- creating an empty table to store the non-active users
select * from deleted_users; -- sanity check table

insert into deleted_users (customer_id, email, create_date)
select customer_id, email, create_date
from sakila.customer
where active = 0;
select * from deleted_users; -- double sanity check table

delete from customer where active = 0; -- After deactivating safe mode, this is giving the following error: Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`sakila`.`payment`, CONSTRAINT `fk_payment_customer` FOREIGN KEY (`customer_id`) REFERENCES `customer` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE)
set FOREIGN_KEY_CHECKS=0; -- disabling the foreign key check
delete from customer where active = 0;
set FOREIGN_KEY_CHECKS=1; -- reactivating the foreign key check
-- probably there's a more elegant way to do this, so any suggestions are welcome! :) 

select count(*) from customer where active = 0; -- triple sanity check

