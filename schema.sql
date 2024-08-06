-- Student Table
CREATE TABLE Students(
    StudentID INT AUTO_INCREMENT,
    FirstName VARCHAR(20),
    LastName VARCHAR(20),
    DOB DATE,
    ClassID INT,
    PRIMARY KEY (StudentID),
    FOREIGN KEY (ClassID) REFERENCES Classes (ClassID)
);

-- Parents 
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

-- Transport 
CREATE TABLE Transports(
    TransportID INT AUTO_INCREMENT,
    StudentID INT,
    RouteName VARCHAR(30),
    Fee DECIMAL(5, 2),
    VechileNumber VARCHAR(30),
    PRIMARY KEY (TransportID, StudentID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);

-- Default Fees 
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

-- Payment 
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

-- Paid status Table
CREATE TABLE PaidStatus(
    PaymentID INT,
    StudentID INT,
    MonthYear DATE,
    Outstanding DECIMAL(10, 2),
    LastPaid DECIMAL(10, 2),
    Pending DECIMAL(10, 2),
    PRIMARY KEY (PaymentID, StudentID),
    FOREIGN KEY (PaymentID) REFERENCES Payments (PaymentID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);

CREATE TABLE Classes(
    ClassID INT AUTO_INCREMENT,
    ClassName VARCHAR(20),
    ClassFee DECIMAL(10, 2),
    PRIMARY KEY (ClassID)
);

/*
CREATE TABLE TotalFee(
    StudentID INT,
    FeeID INT,
    Total DECIMAL(10, 2) DEFAULT 0,
    PRIMARY KEY (StudentID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID),
    FOREIGN KEY (FeeID) REFERENCES Fees (FeeID) 
);
*/
/*
-- PaidAmount Table
CREATE TABLE PaidAmount(
    FeeID INT NOT NULL,
    StudentID INT NOT NULL,
    PaymentID INT NOT NULL,
    AmountPaid DECIMAL(10, 2) DEFAULT 0,
    PRIMARY KEY(StudentID,FeeID)
    FOREIGN KEY (FeeID) REFERENCES Fees (FeeID),
    FOREIGN KEY (StudentID) REFERENCES Students (StudentID)
);
*/

-- trigger for caluculating total fee
/*
DELIMITER //

CREATE TRIGGER calculate_total_fee
AFTER INSERT ON Fees
FOR EACH ROW
BEGIN
    
    IF EXISTS (SELECT 1 FROM TotalFee WHERE StudentID = NEW.StudentID AND FeeID = NEW.FeeID) THEN
        UPDATE TotalFee
        SET Total = NEW.TutionFee + NEW.TransportFee + NEW.OtherFee
        WHERE StudentID = NEW.StudentID AND FeeID = NEW.FeeID;
    ELSE
        INSERT INTO TotalFee (Student, FeeID, Total)
        VALUES (NEW.StudentID, NEW.FeeID, NEW.TutionFee + NEW.TransportFee + NEW.OtherFee)
    END IF;

END;
//

DELIMITER ;
*/


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


-- trigger for calculating total in Fees table
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

-- trigger for if amount is paid
/*
DELIMITER //

CREATE TRIGGER paid_amount_insert
AFTER INSERT ON Payments
FOR EACH ROW
BEGIN
    UPDATE Payments
    SET AmountPending = AmountPending - NEW.AmountPaid
    WHERE FeeID = New.FeeID;
END;
//

DELIMITER;
*/


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


/*
-- calculate amount pending previous months
DELIMITER //

CREATE TRIGGER before_payment_insert
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    DECLARE last_amount_pending DECIMAL(10, 2) DEFAULT 0;
    DECLARE last_total_amount DECIMAL(10, 2) DEFAULT 0;
    DECLARE last_amount_paid DECIMAL(10, 2) DEFAULT 0;

    -- get last payments for the student
    SELECT AmountPending, TotalAmount, AmountPaid
    INTO last_amount_pending, last_total_amount, last_amount_paid
    FROM Payments
    WHERE StudentId = NEW.StudentID
    ORDER BY MonthYear DESC
    LIMIT 1;

    SET NEW.AmountPending = GREATEST((last_amount_pending + last_total_amount - last_amount_paid) + NEW.TotalAmount - NEW.AmountPaid - NEW.Discount, 0);
END;
//

DELIMITER ;
*/

-- calculate PendingAmount previous month add and show it in Current PendingAmount
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


-- trigger to update and insert PaidStatus
DELIMITER //

CREATE TRIGGER after_payment_update
AFTER UPDATE ON Payments
FOR EACH ROW
BEGIN
    -- check if there's an existing record in for the same student
    IF EXISTS(SELECT 1 FROM PaidStatus WHERE PaymentID = NEW.PaymentID AND StudentID = NEW.StudentID)
    THEN UPDATE PaidStatus
    SET Outstanding = NEW.AmountPending, LastPaid = NEW.AmountPaid,
       Pending = GREATEST(NEW.AmountPending - NEW.AmountPaid, 0)
    WHERE PaymentID = NEW.PaymentID and StudentID = NEW.StudentID;
    ELSE
        -- insert new if the student does not exist
        INSERT INTO PaidStatus(PaymentID, StudentID, MonthYear, Outstanding, LastPaid, Pending)
        VALUES(NEW.PaymentID, NEW.StudentID, NEW.MonthYear, NEW.AmountPending, NEW.AmountPaid, GREATEST(NEW.AmountPending - NEW.AmountPaid, 0));
    END IF;
END;
//

DELIMITER ;
