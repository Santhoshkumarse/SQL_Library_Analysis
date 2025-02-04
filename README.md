# Library Management System using SQL Project

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![Screenshot (516)](https://github.com/user-attachments/assets/7e46fb36-d88d-48f4-8216-1556556e310e)


- **Database Creation**: Created a database named `Library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE Library_db;
Use Library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Changing the Datatype of all columns to required datatype**
```sql
 --books
  ALTER TABLE books 
MODIFY COLUMN publisher varchar(50);

-- branch
ALTER TABLE branch
MODIFY COLUMN contact_no varchar(13);
select * from employees; -- emp_id

-- employees
ALTER TABLE employees
MODIFY COLUMN emp_name varchar(20);

-- isuued_status
ALTER TABLE issued_status
MODIFY COLUMN issued_id varchar(15);

-- members
ALTER TABLE members
MODIFY COLUMN member_id varchar(15);

-- return_status
ALTER TABLE return_status
MODIFY COLUMN return_id varchar(15);
```

**Represent the Primary Key and Foreign Key**
```sql
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
REFRENCES issued_status(issued_book_isbn);

-- branch and employees
ALTER TABLE employees
ADD CONSTRAINT fk_branch_id FOREIGN KEY (branch_id)
REFRENCES branch(branch_id);

-- employees and issued_status
ALTER TABLE issued_status
ADD CONSTRAINT fk_emp_id fOREIGN KEY (issued_emp_id)
REFRENCES employees(emp_id);

-- issued_status and member
CREATE INDEX idx_member_id 
ON members (member_id);
ALTER TABLE issued_status
ADD CONSTRAINT fk_mem_id foreign key (issued_member_id)
REFRENCES members(member_id);

-- issued_status and return_status
select * from return_status; -- return_id
select * from issued_status; -- issued_id
CREATE INDEX idx_issued_id 
ON issued_status (issued_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_id foreign key (issued_id)
REFRENCES issued_status(issued_id);
```

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '237 Main st'
WHERE member_id = 'C102';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS102';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE total_issued_count as
SELECT b.isbn,
    COUNT(issued_book_isbn) 
FROM books as b
JOIN issued_status as i ON i.issued_book_isbn = b.isbn
GROUP BY 1;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Horror';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT b.category,sum(b.rental_price),count(*) as count_books FROM issued_status as i
JOIN
books as b
ON b.isbn = i.issued_book_isbn
GROUP BY category;

```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members 
WHERE reg_date >= CURDATE() - INTERVAL 180 DAY;
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
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
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rst
ON rst.issued_id = ist.issued_id
WHERE rst.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT
    ist.issued_member_id,
    m.member_name,
    b.book_title,
    ist.issued_date,
    rst.return_date,
    (30 -datediff(rst.return_date,ist.issued_date)) as over_due_days 
FROM return_status as rst
JOIN 
issued_status as ist 
	ON ist.issued_id = rst.issued_id
JOIN 
members as m 
	ON m.member_id = ist.issued_member_id
LEFT JOIN 
books as b 
	ON b.isbn = ist.issued_book_isbn
WHERE datediff(rst.return_date,ist.issued_date)>30
OREDR BY 1 ;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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

--Testing Function and add records
CALL add_return_records('RS138', 'IS135', 'Good');

-- Check the book's current status
SELECT * FROM books WHERE isbn = '978-0-307-58837-1';

-- Check the issued status
SELECT * FROM issued_status WHERE issued_book_isbn = '978-0-307-58837-1';

-- Check the return status
SELECT * FROM return_status WHERE issued_id = 'IS135';

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE  branch_reports as
SELECT 
	br.branch_id,
    br.manager_id,
    count(ist.issued_id) as no_of_issued,
    count(rst.return_id) as no_of_returned,
    sum(b.rental_price) as total_renvenue 
FROM books as b
JOIN 
issued_status as ist 
	ON ist.issued_book_isbn = b.isbn
LEFT JOIN 
return_status as rst 
	ON rst.issued_id = ist.issued_id
JOIN 
employees as e 
	ON e.emp_id = ist.issued_emp_id
JOIN 
branch as br 
	ON br.branch_id = e.branch_id
GROUP BY 1,2;
SELECT * FROM branch_reports;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

CREATE TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (SELECT 
                        DISTINCT issued_member_id   
                    FROM issued_status
                    WHERE 
                        issued_date >= CURRENT_DATE - INTERVAL '2 month'
                    )
;

SELECT * FROM active_members;

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    
```sql
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
 ```


**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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

```



**Task 20: Create Table As Select (CTAS)**
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines

```sql
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
```



## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/Santhoshkumarse/SQL_Library_Analysis
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `Library_db.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `Library_analysis.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Santhosh Kumar S E

This project showcases SQL skills essential for database management and analysis. For more content on SQL and data analysis, connect with me through the following channels:
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/santhosh-kumar-s-e-59a4a3240/)

Thank you for your interest in this project!
