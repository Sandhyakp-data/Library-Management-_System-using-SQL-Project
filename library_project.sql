SELECT * FROM librabry.books;
##Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
insert into books (isbn,book_title,category,rental_price,status,author,publisher)
values ('978-1-60129-456-2','To Kill a Mockingbird','Classic',6.00,'yes','Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM librabry.books
where isbn="978-1-60129-456-2";

##Task 2: Update an Existing Member's Address**
SELECT * FROM members;
Update members 
set member_address= '123 KRISH st'
WHERE member_id = 'C103'
LIMIT 1;

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103'
LIMIT 1;

##Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
select* from issued_status
where issued_id= 'IS120';
select row_count();

delete from issued_status
where issued_id = 'IS123'
limit 1;
select row_count() as deleted_count;

##Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'
select* from issued_status
where issued_emp_id ='E101';

##Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.
select issued_emp_id,count(*) from issued_status
group by 1
having count(*)>1; 
## having used here because its give only duplicate  if u hont use having here then with and without duplicates both u will get.

##3. CTAS (Create Table As Select)
##Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
select * from book_issued_cnt;
select * from books;
select * from issued_status;

### 4. Data Analysis & Findings

##The following SQL queries were used to address specific questions:

##Task 7. **Retrieve All Books in a Specific Category**:
SELECT * FROM books
WHERE category = 'Classic';

##8 Task 8: Find Total Rental Income by Category**:
SELECT 
    category,
    SUM(rental_price),
    COUNT(*)
FROM 
books
group by 1;
select* from books;
select* from issued_status;

SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY 1;
## List Members Who Registered in the Last 180 Days**:
SELECT *
FROM members
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

insert into members (member_id,member_name,member_address,reg_date)
values ('c120','Sandy','143 krish st','2025-1-25'),
       ('c121','poorna','153 arsi st','2025-4-25');
       
SELECT * FROM members
WHERE reg_date >= CURDATE() - interval 180 day;

#List Employees with Their Branch Manager's Name and their branch details**:

##select* from branch;
SELECT 
    e1.emp_id,
    e1.emp_name,
    e1.position,
    e1.salary,
    b.*,
    e2.emp_name as manager
FROM employees as e1
JOIN 
branch as b
ON e1.branch_id = b.branch_id 
JOIN
employees as e2
ON e2.emp_id = b.manager_id

##Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
select * from expensive_books;
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

create table lowest_books as 
select * from books
WHERE rental_price < 7.00;
select * from lowest_books;
##Task 12: **Retrieve the List of Books Not Yet Returned**

SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;

## Advanced SQL Operations

##Task 13: Identify Members with Overdue Books**  
##Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.


SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    -- rs.return_date,
    CURRENT_DATE - ist.issued_date as over_dues_days
FROM issued_status as ist
JOIN 
members as m
    ON m.member_id = ist.issued_member_id
JOIN 
books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN 
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL
    AND
    (CURRENT_DATE - ist.issued_date) > 30
ORDER BY 1

##Task 14: Update Book Status on Return**  
##Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).
##CREATE OR REPLACE PROCEDURE add_return_records(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(10))
##Testing FUNCTION add_return_records

-- issued_id = IS135
-- ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

##Task 15: Branch Performance Report**  
-- Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.


CREATE TABLE branch_reports
AS
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as number_book_issued,
    COUNT(rs.return_id) as number_of_book_return,
    SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
JOIN 
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
JOIN 
books as bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY 1, 2;

SELECT * FROM branch_reports;
##Task 16: CTAS: Create a Table of Active Members**  
##Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.


CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE issued_date >= CURDATE() - INTERVAL 2 MONTH
                    )
				
;				
SELECT * FROM active_members;
CREATE TABLE active_members AS
SELECT DISTINCT m.*
FROM members m
JOIN issued_status bi ON m.member_id = bi.member_id
WHERE bi.issue_date >= CURDATE() - INTERVAL 2 MONTH;

##Task 17: Find Employees with the Most Book Issues Processed**  
##Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT 
    e.emp_name,
    b.*,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1, 2















