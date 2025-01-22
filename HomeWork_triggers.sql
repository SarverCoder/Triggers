
--Trigger Tasks for Online Learning Platform Tables

-- task 1

select * from enrollments;

 create or replace function check_score_student()
 returns trigger 
 language plpgsql
 as $$

 begin 
	if new.score < 0 or new.score > 100 then
		raise exception 'Student baholash mezoniga togri kelmaydi';
	end if;
	return new;
 end;

 $$

create trigger exception_enroll
before insert
on enrollments
for each row 
execute function check_score_student()

insert into enrollments(student_id, course_id, enrollment_date, completion_status, score)
values ( 1, 50, current_timestamp, 'In Progress', -1);

-- task 2

create table enrollment_logs (
	log_id int primary key generated always as identity,
	Action_type varchar(50),
	student_id int,
	course_id int,
	old_core numeric(10,2),
	new_score numeric(10,2)
	
);

select * from enrollment_logs;

create or replace function enrollment_action()
returns trigger 
language plpgsql
as $$

begin 
	if TG_OP = 'INSERT' then
		insert into enrollment_logs (Action_type, student_id,course_id, old_core, new_score)
		values (TG_OP::TEXT, new.student_id, new.course_id, null, new.score);

	elsif TG_OP = 'UPDATE' then
		insert into enrollment_logs (Action_type, student_id,course_id, old_core, new_score)
		values (TG_OP, new.student_id, new.course_id, old.score, new.score);

	elsif TG_OP = 'DELETE' then
		insert into enrollment_logs (Action_type, student_id,course_id, old_core, new_score)
		values (TG_OP, old.student_id, old.course_id, old.score, null);

	
	end if;
	return null;
 
end;

$$

--insert
create trigger insert_enrollments
after insert
on enrollments
for each row
execute function enrollment_action()

--update 
create trigger update_enrollments
after update
on enrollments
for each row
execute function enrollment_action()

--delete
create trigger delete_enrollments
after delete
on enrollments
for each row
execute function enrollment_action()

select * from enrollments;

insert into enrollments(student_id, course_id, enrollment_date, completion_status, score)
values ( 6, 22, current_timestamp, 'In Progress', 45.88);

update enrollments 
set score = 60.0
where enrollment_id = 60;

delete from enrollments 
where enrollment_id = 60;

select * from enrollment_logs;

-- task 3

create or replace function update_completion_status()
returns trigger 
language plpgsql
as $$

begin 
	if new.score < 70 then
		new.completion_status := 'In Progress';

	else 
		new.completion_status := 'Completed';
	end if;

	return new;

end;

$$

create trigger check_completion
before update 
on enrollments
for each row
execute function update_completion_status()

select * from enrollments
order by enrollment_id

update enrollments 
set score = 80.45
where student_id = 35 and course_id = 16;

--task 4

create or replace function enrollment_course_limit()
returns trigger 
language plpgsql
as $$

	declare student_count int;

begin
	select count(student_id) into student_count
	from enrollments
	where course_id = new.course_id
	group by course_id;

	if student_count > 100 then
		raise exception 'Bu kurs joy tolgan';
		return null;
	else 
		raise notice 'Successfuly';
	 return new;
	
	end if;

end;

$$

select course_id, count(student_id) as number_of_students
from enrollments
where course_id = 8
group by course_id

create trigger inserting_courses
before insert
on enrollments
for each row 
execute function enrollment_course_limit()

insert into enrollments(student_id, course_id, enrollment_date, completion_status, score)
values ( 6, 8, current_timestamp, 'In Progress', 45.88);

--task 5

create table notifications(
	id int primary key generated always as identity,
	student_id int,
	message text,
	time_stamp timestamp default current_timestamp
);

create or replace function high_score()
returns trigger 
language plpgsql
as $$

begin
	if new.score > 90 then
		insert into notifications(student_id, message)
		values (new.student_id, 'Congratulations!');
	end if;
	return new;

end

$$

create trigger trig_high_score
after insert
on enrollments
for each row 
execute function high_score();

select * from notifications;

select * from enrollments;

insert into enrollments(student_id, course_id, enrollment_date, completion_status, score)
values ( 7, 10, current_timestamp, 'Completed', 92.70);


--task 6

create table price_change_log(
	log_id int primary key generated always as identity,
	course_id int,
	old_price numeric(10,2),
	new_price numeric(10,2),
	change_date timestamp default current_timestamp
);

create or replace function write_log_func()
returns trigger 
language plpgsql
as $$

begin

	insert into price_change_log (course_id, old_price,new_price)
	values (old.course_id, old.price, new.price);

	return null;
end;


$$


create trigger change_price
after update 
on courses
for each row 
execute function write_log_func()


update courses
set price = 180.0
where course_id = 1;

select * from price_change_log;

select * from courses;

-- task 7

create or replace function set_enrollment_date()
returns trigger 
language plpgsql
as $$

begin 

	if new.enrollment_date is null then
		new.enrollment_date := current_timestamp;
	end if;

	return new;

end;
$$

create trigger time_set
before insert
on enrollments
for each row
execute function set_enrollment_date()

insert into enrollments(student_id, course_id, enrollment_date, completion_status, score)
values ( 4,12, null, 'Completed', 92.70);

select * from enrollments;


--task 8


create table archived_students(
	archive_id int primary key generated always as identity,
	student_id int,
	first_name varchar(255),	
	last_name varchar(255),
	email varchar(100),
	date_of_birth date,
	registration_date timestamp,
	daleted_date timestamp default current_timestamp
);

create or replace function archiv_write_func()
returns trigger 
language plpgsql
as $$

begin

	insert into archived_students(student_id, first_name, last_name, email,date_of_birth,registration_date)
	values (old.student_id,old.first_name,old.last_name,old.email, old.date_of_birth, old.registration_date);
	
	return null;
end;
$$



create trigger archive_students
before delete 
on students
for each row 
execute function archiv_write_func()

select * from archived_students;

select * from students;

delete from students
where student_id = 50;


