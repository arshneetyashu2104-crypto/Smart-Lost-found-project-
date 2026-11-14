-- =====================================================
-- SMART LOST & FOUND MANAGEMENT SYSTEM
-- Simple DBMS Project (MySQL Only)
-- | Ready for MySQL Workbench & GitHub
-- =====================================================

-- 1. Create Database
DROP DATABASE IF EXISTS smart_lost_found;
CREATE DATABASE smart_lost_found;
USE smart_lost_found;

-- =====================================================
-- 2. CREATE TABLES (6 tables with Primary & Foreign Keys)
-- =====================================================

-- Users table
CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    role ENUM('student', 'faculty', 'staff') DEFAULT 'student'
);

-- Categories table
CREATE TABLE Categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE
);

-- Items table (common details for lost & found)
CREATE TABLE Items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    category_id INT,
    description TEXT,
    status ENUM('lost', 'found', 'claimed', 'returned') DEFAULT 'lost',
    reported_by INT,
    report_date DATE,
    location VARCHAR(100),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id),
    FOREIGN KEY (reported_by) REFERENCES Users(user_id)
);

-- Claims table
CREATE TABLE Claims (
    claim_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT,
    claimant_id INT,
    claim_date DATE,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    proof TEXT,
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (claimant_id) REFERENCES Users(user_id)
);

-- Notifications table
CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    message VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Return_History table
CREATE TABLE Return_History (
    return_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT,
    claim_id INT,
    return_date DATE,
    notes VARCHAR(255),
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (claim_id) REFERENCES Claims(claim_id)
);

-- =====================================================
-- 3. INSERT SAMPLE DATA
-- =====================================================

-- Insert Users
INSERT INTO Users (full_name, email, phone, role) VALUES
('Aarav Sharma', 'aarav@college.edu', '9876543210', 'student'),
('Priya Patel', 'priya@college.edu', '9876543211', 'student'),
('Rohan Mehta', 'rohan@college.edu', '9876543212', 'student'),
('Dr. Anil Kumar', 'anil@college.edu', '9876543213', 'faculty'),
('Sneha Reddy', 'sneha@college.edu', '9876543214', 'student');

-- Insert Categories
INSERT INTO Categories (category_name) VALUES
('Electronics'),
('Documents'),
('Clothing'),
('Accessories'),
('Books');

-- Insert Items (Lost and Found)
INSERT INTO Items (item_name, category_id, description, status, reported_by, report_date, location) VALUES
('iPhone 13 Black', 1, 'Black iPhone with blue case', 'lost', 1, '2025-10-10', 'Library'),
('College ID Card', 2, 'ID card of Aarav Sharma', 'lost', 1, '2025-10-12', 'Cafeteria'),
('Black Jacket', 3, 'Medium size black jacket', 'lost', 2, '2025-10-15', 'Sports Complex'),
('Casio Watch', 4, 'Black G-Shock watch', 'lost', 3, '2025-10-18', 'Auditorium'),
('Data Structures Book', 5, 'CLRS textbook with notes', 'lost', 5, '2025-10-20', 'Lecture Hall'),
('Black iPhone Found', 1, 'iPhone found with blue case', 'found', 4, '2025-10-11', 'Library'),
('Blue ID Card Found', 2, 'College ID of Aarav Sharma', 'found', 2, '2025-10-13', 'Cafeteria'),
('Black Jacket Found', 3, 'North Face style jacket', 'found', 3, '2025-10-16', 'Sports Complex'),
('G-Shock Watch Found', 4, 'Casio watch found near stage', 'found', 1, '2025-10-19', 'Auditorium'),
('Algorithms Book Found', 5, 'CLRS book with handwritten notes', 'found', 4, '2025-10-21', 'Lecture Hall');

-- Insert Claims
INSERT INTO Claims (item_id, claimant_id, claim_date, status, proof) VALUES
(6, 1, '2025-10-12', 'pending', 'I can unlock the phone with Face ID'),
(7, 1, '2025-10-14', 'approved', 'Photo on ID matches me'),
(8, 2, '2025-10-17', 'pending', 'Jacket has a small tear near pocket'),
(9, 3, '2025-10-20', 'rejected', 'Could not describe the scratches'),
(10, 5, '2025-10-22', 'pending', 'My notes are on page 45');

-- Insert Notifications
INSERT INTO Notifications (user_id, message) VALUES
(1, 'Your claim on Black iPhone has been submitted.'),
(1, 'Your claim on ID Card has been approved.'),
(3, 'Your claim on Watch was rejected.'),
(2, 'A found jacket may match your lost item.');

-- Insert Return History (for approved claim)
INSERT INTO Return_History (item_id, claim_id, return_date, notes) VALUES
(7, 2, '2025-10-15', 'ID Card returned after verification');

-- Update status of returned item
UPDATE Items SET status = 'returned' WHERE item_id = 7;

-- =====================================================
-- 4. BASIC CRUD OPERATIONS
-- =====================================================

-- CREATE (already done above with INSERT)

-- READ: Show all lost items
SELECT item_id, item_name, location, report_date 
FROM Items 
WHERE status = 'lost';

-- READ: Show all found items
SELECT item_id, item_name, location, report_date 
FROM Items 
WHERE status = 'found';

-- UPDATE: Change phone number of a user
UPDATE Users 
SET phone = '9998887776' 
WHERE user_id = 1;

-- DELETE: Remove a notification (example)
-- DELETE FROM Notifications WHERE notification_id = 4;

-- =====================================================
-- 5. SIMPLE JOIN QUERIES
-- =====================================================

-- JOIN: Lost items with user name and category
SELECT 
    i.item_name,
    c.category_name,
    u.full_name AS reported_by,
    i.location,
    i.report_date
FROM Items i
JOIN Categories c ON i.category_id = c.category_id
JOIN Users u ON i.reported_by = u.user_id
WHERE i.status = 'lost';

-- JOIN: Claims with item and claimant details
SELECT 
    cl.claim_id,
    i.item_name,
    u.full_name AS claimant,
    cl.status,
    cl.claim_date
FROM Claims cl
JOIN Items i ON cl.item_id = i.item_id
JOIN Users u ON cl.claimant_id = u.user_id;

-- =====================================================
-- 6. GROUP BY and AGGREGATE
-- =====================================================

-- Count items by status
SELECT status, COUNT(*) AS total 
FROM Items 
GROUP BY status;

-- Count items in each category
SELECT 
    c.category_name, 
    COUNT(i.item_id) AS total_items
FROM Categories c
LEFT JOIN Items i ON c.category_id = i.category_id
GROUP BY c.category_name;

-- =====================================================
-- 7. SUBQUERY
-- =====================================================

-- Users who have reported at least one item
SELECT full_name, email 
FROM Users 
WHERE user_id IN (SELECT DISTINCT reported_by FROM Items);

-- Items that have pending claims
SELECT item_name, status 
FROM Items 
WHERE item_id IN (SELECT item_id FROM Claims WHERE status = 'pending');

-- =====================================================
-- 8. VIEWS (2 useful views)
-- =====================================================

-- View 1: Dashboard statistics
CREATE VIEW vw_dashboard AS
SELECT 
    (SELECT COUNT(*) FROM Items WHERE status = 'lost') AS total_lost,
    (SELECT COUNT(*) FROM Items WHERE status = 'found') AS total_found,
    (SELECT COUNT(*) FROM Claims WHERE status = 'pending') AS pending_claims,
    (SELECT COUNT(*) FROM Items WHERE status = 'returned') AS returned_items;

-- View 2: Pending claims details
CREATE VIEW vw_pending_claims AS
SELECT 
    cl.claim_id,
    i.item_name,
    u.full_name AS claimant,
    cl.claim_date,
    cl.proof
FROM Claims cl
JOIN Items i ON cl.item_id = i.item_id
JOIN Users u ON cl.claimant_id = u.user_id
WHERE cl.status = 'pending';

-- Test the views
SELECT * FROM vw_dashboard;
SELECT * FROM vw_pending_claims;

-- =====================================================
-- 9. STORED PROCEDURE (simple claim approval)
-- =====================================================

DELIMITER //

CREATE PROCEDURE approve_claim(IN p_claim_id INT)
BEGIN
    -- Update claim status
    UPDATE Claims 
    SET status = 'approved' 
    WHERE claim_id = p_claim_id AND status = 'pending';
    
    -- Update item status to claimed
    UPDATE Items 
    SET status = 'claimed' 
    WHERE item_id = (SELECT item_id FROM Claims WHERE claim_id = p_claim_id);
    
    -- Add notification
    INSERT INTO Notifications (user_id, message)
    SELECT claimant_id, CONCAT('Your claim #', p_claim_id, ' has been approved.')
    FROM Claims 
    WHERE claim_id = p_claim_id;
END //

DELIMITER ;

-- Example call (uncomment to test):
-- CALL approve_claim(1);

-- =====================================================
-- 10. TRIGGER (auto notification when item is returned)
-- =====================================================

DELIMITER //

CREATE TRIGGER after_item_returned
AFTER UPDATE ON Items
FOR EACH ROW
BEGIN
    IF NEW.status = 'returned' AND OLD.status != 'returned' THEN
        INSERT INTO Notifications (user_id, message)
        VALUES (NEW.reported_by, CONCAT('Your item "', NEW.item_name, '" has been returned to the owner.'));
    END IF;
END //

DELIMITER ;

-- =====================================================
-- 11. SMART MATCHING (simple version)
-- Find possible matches based on same category and similar location
-- =====================================================

SELECT 
    lost.item_id AS lost_id,
    lost.item_name AS lost_item,
    found.item_id AS found_id,
    found.item_name AS found_item,
    lost.location,
    lost.report_date AS lost_date,
    found.report_date AS found_date
FROM Items lost
JOIN Items found ON lost.category_id = found.category_id
WHERE lost.status = 'lost'
  AND found.status = 'found'
  AND lost.location = found.location
ORDER BY lost.report_date;

-- =====================================================
-- 12. USEFUL QUERIES FOR VIVA DEMO
-- =====================================================

-- Show all tables
SHOW TABLES;

-- Show foreign key relationships
SELECT 
    TABLE_NAME, COLUMN_NAME, 
    REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'smart_lost_found' 
  AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Final success message
SELECT 'Smart Lost & Found System created successfully!' AS Status;
SELECT * FROM vw_dashboard;
