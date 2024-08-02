-- WE CANNOT TRUNCATE A TABLE TAHT HAS FK CONSTRAINTS APPLIED ON IT
SHOW DATABASES;

USE schoolmanagement;

SHOW TABLES;

DROP TABLE Transport,Payments, Fees, Parents, Students;

DROP TABLE Students;


-- Records for Classes Table
INSERT INTO Classes(ClassName, ClassFee)
VALUES('Class101', 350),
        ('Class102', 450),
        ('Class103', 500),
        ('Class104', 550),
        ('Class105', 600);

-- VALUER FOR STUDENT TABLE
INSERT INTO Students (FirstName, LastName, DOB, Class)
VALUES ('Hans Raj', 'Sahoo', '2018-02-23', 'Class101'),
        ('Kartik', 'Malik', '2018-01-12', 'Class101'),
        ('Adaysha', 'Priyadarshini', '2019-4-14', 'Class101'),
        ('Biraj', 'Behera', '2020-01-4', 'Class102'),
        ('Nibedita', 'Malik', '2020-2-6', 'Class103'),
        ('Swadhin', 'Malik', '2020-01-15', 'Class102'),
        ('Rudra Prasad', 'Sahoo', '2018-12-28', 'Class102'),
        ('Abhimany', 'Padhi', '2019-03-5', 'Class103'),
        ('Gudi', 'Sethy', '2020-05-16', 'Class104'),
        ('Sai Samarth', 'Sahoo', '2019-06-09', 'Class104'),
        ('Chandrans', 'Mohanty', '2019-10-15', 'Class103'),
        ('Sudipt', 'Jena', '2020-10-07', 'Class105'),
        ('Sai Subham', 'Biswal', '2018-11-21', 'Class105');

-- FEE TABLE
INSERT INTO Fees (StudentID, MonthYear, TutionFee, TransportFee, OtherFee)
VALUES (1, '2022-04-15', 300, 450, 0);

INSERT INTO Fees (StudentID, MonthYear, TutionFee, TransportFee, OtherFee)
VALUES (2, '2022-02-14', 300, 0, 0),
        (3, '2022-3-15', 300, 0, 0),
        (4, '2022-1-10', 300, 300, 0),
        (5, '2022-2-07', 300, 0, 0),
        (6, '2022-4-05', 300, 400, 0),
        (7, '2022-1-03', 300, 0, 0),
        (8, '2022-2-06', 300, 0, 0),
        (9, '2022-3-12', 300, 450, 0),
        (10, '2022-4-11', 300, 0, 0),
        (11, '2022-3-9', 300, 450,0),
        (12, '2022-1-4', 300, 0, 0),
        (13, '2022-4-16',300, 0, 0);




UPDATE Fees SET OtherFee = 150 WHERE StudentID = 1;


-- Payment Table
UPDATE Payments SET MonthYear = '2022-04-15', AmountPaid = 700  WHERE StudentID = 1;
UPDATE Payments SET Discount = 200 WHERE StudentID = 1;

-- View Tables

SHOW TABLES;
DESCRIBE Payments;


-- Show Tables
SELECT * FROM Classes;
SELECT * FROM Fees;
SELECT * FROM Students;
SELECT * FROM Parents;
SELECT * FROM Teachers;
SELECT * FROM Transport;
SELECT * FROM Payments;
SELECT * FROM PaidStatus;
-- SELECT * FROM TotalFee;

-- Delete Tables
DROP TABLE Fees;
DROP TABLE Payments;
DROP TABLE Students;
DROP TABLE Parents;
DROP TABLE Teachers;
DROP TABLE Transports;
DROP TABLE PaidStatus;

-- Triggers
SHOW TRIGGERS;

DROP TRIGGER calculate_total_before_insert;
DROP TRIGGER after_fees_insert;
DROP TRIGGER calcualte_total_before_update;
DROP TRIGGER after_fees_update;
DROP TRIGGER before_payment_insert;
DROP TRIGGER paid_amount_update;
DROP TRIGGER after_payment_update;

TRUNCATE TABLE Students;
TRUNCATE TABLE Fees;
TRUNCATE TABLE Payments;
TRUNCATE TABLE PaidStatus;

SET foreign_key_checks = 0;
, 'Class101'


DELETE FROM Students;

DELETE FROM Payments WHERE StudentID = 1;
DELETE FROM Fees WHERE StudentID = 1;
DELETE FROM PaidStatus WHERE StudentID = 1;

DROP TRIGGER calculate_total_fee;


-- modification

ALTER TABLE Fees AUTO_INCREMENT = 1;

ALTER TABLE Fees
MODIFY COLUMN TutionFee DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE Fees
MODIFY COLUMN OtherFee DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE Fees
MODIFY COLUMN TransportFee DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE Fees
ADD COLUMN Total DECIMAL(10, 2);

ALTER TABLE Payments 
ADD COLUMN Discount DECIMAL(10, 2) DEFAULT 0 AFTER TotalAmount;

ALTER TABLE Students
ADD COLUMN Class VARCHAR(20);

 

SHOW ERRORS;

