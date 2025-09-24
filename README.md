Library Management System Database
Library Management System Database
Overview
Complete MySQL database for library operations with 11 normalized tables managing members, books, loans, reservations, and fines.

Core Features
Member management with status tracking

Book inventory with copy-level tracking

Loan system with due dates and late fees

Reservation system for high-demand books

Fine management for overdue/lost items

Staff management for library personnel

Key Relationships
One-to-Many: Publishers→Books, Categories→Books, Members→Loans

Many-to-Many: Books↔Authors (via book_authors junction table)

Self-Referencing: Category hierarchy

JOIN Examples Included
INNER JOIN: Active books with publishers/categories

LEFT JOIN: Members with their loans (including no loans)

RIGHT JOIN: Data integrity checks (loans without copies, authors without books)

Multiple JOINs: Complex reports across 4+ tables

**Quick Start**
sql
mysql -u root -p < library_management_system.sql
Sample Queries
Available books report

Overdue loans tracking

Member activity summaries

Publisher inventory reports

**Tables**
11 tables with proper constraints ensuring data integrity and relational consistency.
Complete MySQL database for library operations with 11 normalized tables managing members, books, loans, reservations, and fines.

Core Features
Member management with status tracking

Book inventory with copy-level tracking

Loan system with due dates and late fees

Reservation system for high-demand books

Fine management for overdue/lost items

Staff management for library personnel

**Key Relationships**
One-to-Many: Publishers→Books, Categories→Books, Members→Loans

Many-to-Many: Books↔Authors (via book_authors junction table)

Self-Referencing: Category hierarchy

JOIN Examples Included
INNER JOIN: Active books with publishers/categories

LEFT JOIN: Members with their loans (including no loans)

RIGHT JOIN: Data integrity checks (loans without copies, authors without books)

Multiple JOINs: Complex reports across 4+ tables

Quick Start
sql
mysql -u root -p < library_management_system.sql
Sample Queries
Available books report

Overdue loans tracking

Member activity summaries

Publisher inventory reports

Tables
11 tables with proper constraints ensuring data integrity and relational consistency.
