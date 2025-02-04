Create database Library_db;
use Library_db;
select * from books; -- book_title
select * from branch; -- branch_id
select * from employees; -- emp_id
select * from issued_status; -- issued_id
select * from members; -- member_id
select * from return_status; -- return_id
-- Changing datatypes
-- book table
ALTER TABLE books 
MODIFY COLUMN publisher varchar(50);

-- branch
ALTER TABLE branch
MODIFY COLUMN contact_no varchar(13);
select * from employees; -- emp_id

-- deleting the null columns in return_book_name

-- employees
ALTER TABLE employees
MODIFY COLUMN emp_name varchar(20);


select * from issued_status; -- issued_id
-- isuued_status
ALTER TABLE issued_status
MODIFY COLUMN issued_id varchar(15);

-- members
ALTER TABLE members
MODIFY COLUMN member_id varchar(15);

-- return_status
ALTER TABLE return_status
MODIFY COLUMN return_id varchar(15);


-- Applying the Primary Key
ALTER TABLE branch
ADD CONSTRAINT pk_branch_id PRIMARY KEY (branch_id);

-- Appying Foreign Key
CREATE INDEX idx_issued_book_isbn 
ON issued_status (issued_book_isbn);

SELECT isbn
FROM books
WHERE isbn NOT IN (SELECT issued_book_isbn FROM issued_status);
DELETE FROM books
WHERE isbn NOT IN (SELECT issued_book_isbn FROM issued_status);


-- books and issued_date
ALTER TABLE books
ADD CONSTRAINT fk_isbn FOREIGN KEY (isbn)
References issued_status(issued_book_isbn);

-- branch and employees
ALTER TABLE employees
ADD CONSTRAINT fk_branch_id FOREIGN KEY (branch_id)
References branch(branch_id);

-- employees and issued_status
ALTER TABLE issued_status
ADD CONSTRAINT fk_emp_id fOREIGN KEY (issued_emp_id)
References employees(emp_id);

-- issued_status and member
CREATE INDEX idx_member_id 
ON members (member_id);
ALTER TABLE issued_status
add constraint fk_mem_id foreign key (issued_member_id)
references members(member_id);

-- issued_status and return_status
select * from return_status; -- return_id
select * from issued_status; -- issued_id
CREATE INDEX idx_issued_id 
ON issued_status (issued_id);

ALTER TABLE return_status
add constraint fk_issued_id foreign key (issued_id)
references issued_status(issued_id);

select * from books;
-- Project Task
/* Task 1. Create a New Book Record -- "978-1-60129-456-2','To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')" */
Insert into books(isbn,book_title,category,rental_price,status,author,publisher) values ('978-1-60129-456-2','To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
Update members
set member_address = '237 Main st'
where member_id = 'C102';

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS102' 
-- from the issued_status table
delete from issued_status
where issued_id = 'IS102';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from issued_status
where issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

select issued_emp_id,count(*) from issued_status
group by issued_emp_id
having count(*)>1;

-- CTAS(Create Table as Select)
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
select 
	b.isbn,
    count(issued_book_isbn) 
from books as b
join issued_status as i on i.issued_book_isbn = b.isbn
group by 1;

-- Task 7. Retrieve All Books in a Specific Category:

select * from books
where category = 'Horror';

-- Task 8: Find Total Rental Income by Category:

select b.category,sum(b.rental_price),count(*) as count_books from issued_status as i
JOIN
books as b
ON b.isbn = i.issued_book_isbn
group by category;

-- List Members Who Registered in the Last 180 Days:
SELECT * FROM members 
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;

-- List Employees with Their Branch Manager's Name and their branch details:
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
ON e2.emp_id = b.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
Create table expensive as select * from books
where rental_price > 7;

-- Task 12: Retrieve the List of Books Not Yet Returned
select ist.issued_book_name,ist.issued_book_isbn,ist.issued_id,rst.return_book_name,rst.return_book_isbn from issued_status as ist
left join return_status as rst on ist.issued_id = rst.issued_id
where rst.return_book_isbn is null ;

-- Advanced SQL Operations
-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have 
-- overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

select * from issued_status;

select 
	ist.issued_member_id,
	m.member_name,
    b.book_title,
    ist.issued_date,
    rst.return_date,
    (30 -datediff(rst.return_date,ist.issued_date)) as over_due_days 
from return_status as rst
join 
issued_status as ist 
	on ist.issued_id = rst.issued_id
join 
members as m 
	on m.member_id = ist.issued_member_id
left join 
books as b 
	on b.isbn = ist.issued_book_isbn
where datediff(rst.return_date,ist.issued_date)>30
order by 1 ;

-- Task 14: Update Book Status on Return
-- Write a query to update the status of books in the books table to "Yes" 
-- when they are returned (based on entries in the return_status table).
DELIMITER $$

CREATE PROCEDURE add_return_records(
    IN p_return_id VARCHAR(10),
    IN p_issued_id VARCHAR(10),
    IN p_book_quality VARCHAR(10)
)
BEGIN
    DECLARE v_isbn VARCHAR(50);
    DECLARE v_book_name VARCHAR(80);

    -- Insert into return_status based on user input
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    -- Retrieve issued book details
    SELECT issued_book_isbn, issued_book_name
    INTO v_isbn, v_book_name
    FROM issued_status
    WHERE issued_id = p_issued_id;

    -- Update book status to 'Yes'
    UPDATE books
    SET status = 'Yes'
    WHERE isbn = v_isbn;

    -- Display a message
    SELECT CONCAT('Thank you for returning the book: ', v_book_name) AS message;
END$$

DELIMITER ;
CALL add_return_records('RS138', 'IS135', 'Good');

-- Check the book's current status
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';

-- Check the issued status
SELECT * FROM issued_status WHERE issued_book_isbn = '978-0-307-58837-1';

-- Check the return status
SELECT * FROM return_status WHERE issued_id = 'IS135';



-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, 
-- showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
Create table  branch_reports as
select 
	br.branch_id,
    br.manager_id,
    count(ist.issued_id) as no_of_issued,
    count(rst.return_id) as no_of_returned,
    sum(b.rental_price) as total_renvenue 
from books as b
join 
issued_status as ist 
	on ist.issued_book_isbn = b.isbn
left join 
return_status as rst 
	on rst.issued_id = ist.issued_id
join 
employees as e 
	on e.emp_id = ist.issued_emp_id
join 
branch as br 
	on br.branch_id = e.branch_id
Group by 1,2;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
-- containing members who have issued at least one book in the last 2 months.


CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
    FROM issued_status
    WHERE issued_date >= DATE_SUB(CURRENT_DATE, INTERVAL 2 MONTH)
);


SELECT * FROM active_members;



-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.

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
GROUP BY 1, 2;

-- Task 18: Identify Members Issuing High-Risk Books
-- Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. 
-- Display the member name, book title, and the number of times they've issued damaged books.

SELECT 
    m.member_name,
    b.book_title,
    COUNT(*) AS times_issued_damaged
FROM 
    issued_status AS i
JOIN 
    members AS m ON i.issued_member_id = m.member_id
JOIN 
    books AS b ON i.issued_book_isbn = b.isbn
WHERE 
    b.status = 'damaged'
GROUP BY 
    m.member_name, b.book_title
HAVING 
    COUNT(*) > 2;



--  Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and 
-- the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), the procedure 
-- should return an error message indicating that the book is currently not available.

DELIMITER $$

CREATE PROCEDURE issue_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(30),
    IN p_issued_emp_id VARCHAR(10)
)
BEGIN
    DECLARE v_status VARCHAR(10);

    -- Check if the book is available ('yes')
    SELECT status INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        -- Insert into issued_status
        INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

        -- Update book status to 'no'
        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        -- Display success message
        SELECT CONCAT('Book records added successfully for book ISBN: ', p_issued_book_isbn) AS message;
    ELSE
        -- Display unavailable message
        SELECT CONCAT('Sorry to inform you, the book you have requested is unavailable. Book ISBN: ', p_issued_book_isbn) AS message;
    END IF;
END$$

DELIMITER ;

CALL issue_book('IS155', 'C108', '978-0-553-29698-2', 'E104');
-- Check the book's current status
SELECT * FROM books WHERE isbn = '978-0-553-29698-2';

-- Check the issued status
SELECT * FROM issued_status WHERE issued_book_isbn = '978-0-553-29698-2';




-- Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and 
-- calculate fines.
CREATE TABLE overdue_books_summary AS
SELECT
    m.member_id,
    COUNT(i.issued_book_isbn) AS overdue_books_count,
    SUM(0.50 * DATEDIFF(CURRENT_DATE, i.issued_date)) AS total_fines
FROM
    issued_status i
JOIN
    members m ON i.issued_member_id = m.member_id
LEFT JOIN
    return_status r ON i.issued_id = r.issued_id
WHERE
    r.issued_id IS NULL
    AND DATEDIFF(CURRENT_DATE, i.issued_date) > 30
GROUP BY
    m.member_id;
    
select * from overdue_books_summary;


