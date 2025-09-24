-- Library Management System Database
CREATE DATABASE library_management_system;
USE library_management_system;

-- Members table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    national_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    address TEXT,
    membership_date DATE NOT NULL,
    membership_status ENUM('Active', 'Suspended', 'Expired') DEFAULT 'Active',
    max_books_allowed INT DEFAULT 5
);

-- Authors table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE,
    nationality VARCHAR(50)
);

-- Publishers table
CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name VARCHAR(100) UNIQUE NOT NULL,
    address TEXT,
    contact_email VARCHAR(100),
    contact_phone VARCHAR(15)
);

-- Categories table
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_category_id INT NULL,
    FOREIGN KEY (parent_category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

-- Books table
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    title VARCHAR(200) NOT NULL,
    edition VARCHAR(10),
    publication_year YEAR,
    publisher_id INT NOT NULL,
    category_id INT NOT NULL,
    page_count INT,
    language VARCHAR(30) DEFAULT 'English',
    FOREIGN KEY (publisher_id) REFERENCES publishers(publisher_id) ON DELETE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE RESTRICT
);

-- Book-Authors junction table (Many-to-Many relationship)
CREATE TABLE book_authors (
    book_id INT NOT NULL,
    author_id INT NOT NULL,
    author_order INT DEFAULT 1,
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);

-- Book copies table
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    copy_number INT NOT NULL,
    acquisition_date DATE NOT NULL,
    status ENUM('Available', 'Checked Out', 'Reserved', 'Under Repair', 'Lost') DEFAULT 'Available',
    location VARCHAR(50),
    UNIQUE KEY unique_book_copy (book_id, copy_number),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Loans table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    copy_id INT NOT NULL,
    loan_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    late_fee DECIMAL(8,2) DEFAULT 0.00,
    loan_status ENUM('Active', 'Returned', 'Overdue') DEFAULT 'Active',
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT
);

-- Reservations table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    book_id INT NOT NULL,
    reservation_date DATE NOT NULL,
    reservation_status ENUM('Active', 'Fulfilled', 'Cancelled') DEFAULT 'Active',
    expiry_date DATE NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Fines table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT PRIMARY KEY,
    member_id INT NOT NULL,
    loan_id INT NULL,
    fine_amount DECIMAL(8,2) NOT NULL,
    fine_reason ENUM('Late Return', 'Book Damage', 'Lost Book', 'Other') NOT NULL,
    fine_date DATE NOT NULL,
    paid_date DATE NULL,
    fine_status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE SET NULL
);

-- Staff table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    hire_date DATE NOT NULL
);

-- Example JOIN queries demonstrating relationships:

-- 1. INNER JOIN: Get all books with their publisher and category information
SELECT 
    b.title,
    b.isbn,
    p.publisher_name,
    c.category_name,
    b.publication_year
FROM books b
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
INNER JOIN categories c ON b.category_id = c.category_id;

-- 2. LEFT JOIN: Get all members and their current loans (including members with no loans)
SELECT 
    m.first_name,
    m.last_name,
    m.email,
    l.loan_date,
    l.due_date,
    l.loan_status
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id AND l.loan_status = 'Active';

-- 3. RIGHT JOIN: Find all loans with member info (including loans with invalid member references)
SELECT 
    l.loan_id,
    l.loan_date,
    l.due_date,
    m.first_name,
    m.last_name,
    m.email
FROM members m
RIGHT JOIN loans l ON m.member_id = l.member_id;

-- 4. Multiple INNER JOINS: Get book details with authors and copies information
SELECT 
    b.title,
    a.first_name AS author_first_name,
    a.last_name AS author_last_name,
    bc.copy_id,
    bc.status AS copy_status,
    p.publisher_name
FROM books b
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
INNER JOIN book_copies bc ON b.book_id = bc.book_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id;

-- 5. LEFT JOIN with WHERE: Find members with no current loans
SELECT 
    m.member_id,
    m.first_name,
    m.last_name,
    m.email
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id AND l.loan_status = 'Active'
WHERE l.loan_id IS NULL;

-- 6. RIGHT JOIN with WHERE: Find loans without valid book copies
SELECT 
    l.loan_id,
    l.loan_date,
    l.due_date,
    bc.copy_id
FROM book_copies bc
RIGHT JOIN loans l ON bc.copy_id = l.copy_id
WHERE bc.copy_id IS NULL;

-- 7. INNER JOIN with aggregation: Get book popularity based on loan count
SELECT 
    b.title,
    COUNT(l.loan_id) as total_loans,
    p.publisher_name
FROM books b
INNER JOIN book_copies bc ON b.book_id = bc.book_id
INNER JOIN loans l ON bc.copy_id = l.copy_id
INNER JOIN publishers p ON b.publisher_id = p.publisher_id
GROUP BY b.book_id, b.title, p.publisher_name
ORDER BY total_loans DESC;

-- 8. LEFT JOIN for fines with member and loan details
SELECT 
    m.first_name,
    m.last_name,
    m.email,
    f.fine_amount,
    f.fine_reason,
    f.fine_status,
    l.loan_date,
    l.due_date,
    b.title
FROM fines f
INNER JOIN members m ON f.member_id = m.member_id
LEFT JOIN loans l ON f.loan_id = l.loan_id
LEFT JOIN book_copies bc ON l.copy_id = bc.copy_id
LEFT JOIN books b ON bc.book_id = b.book_id
WHERE f.fine_status = 'Pending';

-- 9. RIGHT JOIN to find authors with no books
SELECT 
    a.first_name,
    a.last_name,
    ba.book_id
FROM book_authors ba
RIGHT JOIN authors a ON ba.author_id = a.author_id
WHERE ba.book_id IS NULL;

-- 10. Self-join for category hierarchy
SELECT 
    child.category_name AS child_category,
    parent.category_name AS parent_category
FROM categories child
LEFT JOIN categories parent ON child.parent_category_id = parent.category_id;

-- 11. INNER JOIN for active reservations with member and book info
SELECT 
    r.reservation_date,
    m.first_name,
    m.last_name,
    b.title,
    a.first_name AS author_first_name,
    a.last_name AS author_last_name
FROM reservations r
INNER JOIN members m ON r.member_id = m.member_id
INNER JOIN books b ON r.book_id = b.book_id
INNER JOIN book_authors ba ON b.book_id = ba.book_id
INNER JOIN authors a ON ba.author_id = a.author_id
WHERE r.reservation_status = 'Active';

-- 12. Multiple LEFT JOINS: Comprehensive member activity report
SELECT 
    m.member_id,
    m.first_name,
    m.last_name,
    COUNT(DISTINCT l.loan_id) as total_loans,
    COUNT(DISTINCT r.reservation_id) as active_reservations,
    COUNT(DISTINCT f.fine_id) as pending_fines,
    SUM(CASE WHEN f.fine_status = 'Pending' THEN f.fine_amount ELSE 0 END) as total_pending_fines
FROM members m
LEFT JOIN loans l ON m.member_id = l.member_id
LEFT JOIN reservations r ON m.member_id = r.member_id AND r.reservation_status = 'Active'
LEFT JOIN fines f ON m.member_id = f.member_id AND f.fine_status = 'Pending'
GROUP BY m.member_id, m.first_name, m.last_name;

-- 13. RIGHT JOIN to find publishers with no books
SELECT 
    p.publisher_name,
    b.title
FROM books b
RIGHT JOIN publishers p ON b.publisher_id = p.publisher_id
WHERE b.book_id IS NULL;

-- 14. INNER JOIN with date filtering: Overdue books report
SELECT 
    m.first_name,
    m.last_name,
    m.email,
    b.title,
    l.loan_date,
    l.due_date,
    DATEDIFF(CURDATE(), l.due_date) as days_overdue
FROM loans l
INNER JOIN members m ON l.member_id = m.member_id
INNER JOIN book_copies bc ON l.copy_id = bc.copy_id
INNER JOIN books b ON bc.book_id = b.book_id
WHERE l.loan_status = 'Active' 
AND l.due_date < CURDATE();

-- 15. RIGHT JOIN to find book copies never loaned
SELECT 
    bc.copy_id,
    b.title,
    bc.acquisition_date
FROM loans l
RIGHT JOIN book_copies bc ON l.copy_id = bc.copy_id
INNER JOIN books b ON bc.book_id = b.book_id
WHERE l.loan_id IS NULL;