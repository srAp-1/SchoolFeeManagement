CREATE INDEX idx_lastname ON Students (LastName);
CREATE INDEX idx_fees_month_year ON Fees (MonthYear);

-- Students Table
CREATE TABLE Students(
    StudentID INT AUTO_INCREMENT,
    FirstName VARCHAR(20),
    LastName VARCHAR(20),
    DOB DATE,
    ClassID INT,
    PRIMARY KEY (StudentID),
    FOREIGN KEY (ClassID) REFERENCES Classes (ClassID)
);

-- Parent Table
CREATE TABLE Parents(
    ParentID INT AUTO_INCREMENT,
    StudentID INT,
    FatherName VARCHAR(30),
    MotherName VARCHAR(30),
    Phone1 VARCHAR(13),
    Phone2 VARCHAR(13),
    Address VARCHAR(40),
    PRIMARY KEY (ParentID, StudentID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);

-- Transports Table
CREATE TABLE Transports(
    TransportID INT AUTO_INCREMENT,
    StudentID INT,
    RouteName VARCHAR(30),
    Fee DECIMAL(5, 2),
    VechileNumber VARCHAR(30),
    PRIMARY KEY (TransportID, StudentID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);

-- Default Fees Table
CREATE TABLE Fees(
    FeeID INT AUTO_INCREMENT,
    StudentID INT,
    MonthYear DATE,
    TutionFee DECIMAL(10, 2) DEFAULT 0,
    TransportFee DECIMAL(10, 2) DEFAULT 0,
    OtherFee DECIMAL(10, 2) DEFAULT 0,
    Total DECIMAL(10, 2),
    PRIMARY KEY (FeeID , StudentID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);

-- Payment Table
CREATE TABLE Payments(
    PaymentID INT AUTO_INCREMENT,
    FeeID INT NOT NULL,
    StudentID INT NOT NULL,
    MonthYear DATE,
    TotalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    Discount DECIMAL(10, 2) DEFAULT 0,
    AmountPaid DECIMAL(10, 2) NOT NULL DEFAULT 0,
    AmountPending DECIMAL(10, 2) NOT NULL DEFAULT 0,
    PRIMARY KEY (PaymentID, StudentID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID),
    FOREIGN KEY (FeeID) REFERENCES Fees (FeeID)
);

-- Paid Status Table
CREATE TABLE PaidStatus(
    PaymentID INT,
    StudentID INT,
    MonthYear DATE,
    Outstanding DECIMAL(10, 2),
    Paid DECIMAL(10, 2),
    Pending DECIMAL(10, 2),
    PRIMARY KEY (PaymentID, StudentID),
    FOREIGN KEY (PaymentID) REFERENCES Payments (PaymentID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);

-- Classes Table
CREATE TABLE Classes(
    ClassID INT AUTO_INCREMENT,
    ClassName VARCHAR(20),
    ClassFee DECIMAL(10, 2),
    PRIMARY KEY (ClassID)
);


-- VIEWS

-- StudentDetailsView
CREATE VIEW StudentDetailsView AS
SELECT 
    s.StudentID, s.FirstName, s.LastName, s.DOB,
    c.ClassName,
    p.FatherName, P.MotherName, p.Phone1, p.Phone2, P.Address
FROM 
    Students s
    LEFT JOIN Classes c ON s.ClassID = c.ClassID
    LEFT JOIN Parents p ON s.StudentID = p.StudentID;


-- TRIGGERS

-- Trigger for Fetch class fee from classes table
DELIMITER //

CREATE TRIGGER after_student_insert
AFTER INSERT ON Students
FOR EACH ROW
BEGIN
    DECLARE class_fee DECIMAL(10, 2);
    
    -- Get the fee for the student's class
    SELECT ClassFee INTO class_fee
    FROM Classes
    WHERE ClassID = NEW.ClassID;

    -- Insert a new record into the Fees table
    INSERT INTO Fees (StudentID, TutionFee, TransportFee, OtherFee, Total)
    VALUES (NEW.StudentID, class_fee, 0, 0, class_fee);
END;
//

DELIMITER ;


-- Trigger for calculating total in Fees table
DELIMITER //

CREATE TRIGGER calculate_total_before_insert
BEFORE INSERT ON Fees
FOR EACH ROW
BEGIN
    SET NEW.Total = NEW.TutionFee + NEW.TransportFee + NEW.OtherFee;
END //

CREATE TRIGGER calcualte_total_before_update
BEFORE UPDATE ON Fees
FOR EACH ROW
BEGIN
    SET NEW.Total = NEW.TutionFee + NEW.TransportFee + NEW.OtherFee;
END //

DELIMITER ;

-- Trigger to reflect total from fees to totalamount of payments
DELIMITER //

CREATE TRIGGER after_fees_insert
AFTER INSERT ON Fees
FOR EACH ROW
BEGIN
    INSERT INTO Payments (StudentID, FeeID, TotalAmount, Discount, AmountPaid, AmountPending)
    VALUES (NEW.StudentID, NEW.FeeID, NEW.Total, 0, 0, NEW.Total);
END;
//

DELIMITER ;

-- Trigger to update payment table 
DELIMITER //

CREATE TRIGGER after_fees_update
AFTER UPDATE ON Fees
FOR EACH ROW
BEGIN
    UPDATE Payments
    SET TotalAmount = NEW.Total - Discount,
        AmountPending = NEW.Total - Discount - AmountPaid
    WHERE FeeID = NEW.FeeID;
END;
//

DELIMITER ;


-- Trigger to update when amount is paid
DELIMITER //

CREATE TRIGGER paid_amount_update
BEFORE UPDATE ON Payments
FOR EACH ROW
BEGIN
    SET NEW.AmountPending = GREATEST(NEW.TotalAmount - NEW.Discount - New.AmountPaid, 0);
END;
//

DELIMITER ;


-- Trigger ot calculate PendingAmount previous month add and show it in Current PendingAmount
DELIMITER //

CREATE TRIGGER before_payment_insert
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    DECLARE last_amount_pending DECIMAL(10, 2) DEFAULT 0;

    -- last pending amount for the student
    SELECT COALESCE(AmountPending, 0) INTO last_amount_pending
    FROM Payments
    WHERE StudentID = NEW.StudentID
    ORDER BY MonthYear DESC
    LIMIT 1;

    -- calculating the new AmountPending
    SET NEW.AmountPending = GREATEST((last_amount_pending + NEW.TotalAmount - COALESCE( NEW.AmountPaid, 0)), 0);
END;
//

DELIMITER ;


-- Trigger to update and insert PaidStatus
DELIMITER //

CREATE TRIGGER after_payment_update
AFTER UPDATE ON Payments
FOR EACH ROW
BEGIN
    DECLARE total_paid DECIMAL(10, 2);
    DECLARE total_owed DECIMAL(10, 2);

    -- Calculate the total amout paid by the student
    SELECT COALESCE(SUM(AmountPaid), 0) INTO total_paid
    FROM Payments
    WHERE StudentID = NEW.StudentID;

    -- Calculate the total amount owed by the student
    SELECT COALESCE(SUM(TotalAmount), 0) INTO total_owed
    FROM Payments
    WHERE StudentID = NEW.StudentID;

    -- Check if there's a existing record in PaidStatus for the same Student
    IF EXISTS(SELECT 1 FROM PaidStatus WHERE PaymentID = NEW.PaymentID AND StudentID = NEW.StudentID) THEN
        UPDATE PaidStatus
        SET Outstanding = total_owed,
            Paid = total_paid,
            Pending = GREATEST(total_owed - total_paid, 0)
        WHERE PaymentID = NEW.PaymentID AND StudentID = NEW.StudentID;
    ELSE
        -- Insert new record if the student does not exist in PaidStatus
        INSERT INTO PaidStatus(PaymentID, StudentID, MonthYear, Outstanding, Paid, Pending)
        VALUES(NEW.PaymentID, NEW.StudentID, NEW.MonthYear, total_owed, total_paid, GREATEST(total_owed - total_paid, 0));
    END IF;
END;
//

DELIMITER;

