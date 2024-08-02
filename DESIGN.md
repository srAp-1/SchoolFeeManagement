# School Fee Management System

This is a MySQL database schema for a comprehensive school fee management system. It helps track student information, fees, payments, and transportation details.

## Tables

7. **Classes**: Stores information about different classes and their associated fees.
   - Includes: ClassName, ClassFee

1. **Students**: Stores basic information about students.
   - Includes: StudentID, FirstName, LastName, Date of Birth

2. **Parents**: Keeps parent information linked to students.
   - Includes: ParentID, StudentID, FatherName, MotherName, Phone numbers, Address

3. **Transports**: Manages transportation details for students.
   - Includes: TransportID, StudentID, RouteName, Fee, VehicleNumber

4. **Fees**: Stores fee information for each student.
   - Includes: FeeID, StudentID, MonthYear, TuitionFee, TransportFee, OtherFee, Total

5. **Payments**: Tracks payments made by students.
   - Includes: PaymentID, FeeID, StudentID, MonthYear, TotalAmount, Discount, AmountPaid, AmountPending

6. **PaidStatus**: Keeps track of payment status for each student.
   - Includes: PaymentID, StudentID, MonthYear, Outstanding, LastPaid, Pending

## How It Works

### Class Fee Assignment

1. When a new student is inserted into the `Students` table:
   - A trigger automatically creates a fee record in the `Fees` table.
   - The trigger retrieves the appropriate fee amount from the `Classes` table based on the student's assigned class.
   - This ensures that each student is automatically assigned the correct tuition fee for their class.


### Fee Calculation

1. When a new fee record is inserted into the `Fees` table:
   - A trigger automatically calculates the total fee by summing TuitionFee, TransportFee, and OtherFee.
   - This total is stored in the `Total` column of the `Fees` table.

2. After a fee record is inserted:
   - Another trigger creates a corresponding record in the `Payments` table.
   - It sets the `TotalAmount` equal to the calculated total fee.
   - `AmountPaid` is initially set to 0.
   - `AmountPending` is set to the total fee amount.

### Payment Processing

1. When a payment is made:
   - The `Payments` table is updated with the amount paid.
   - A trigger recalculates the `AmountPending` by subtracting the paid amount from the total amount.

2. The system considers previous unpaid fees:
   - Before inserting a new payment record, a trigger checks for any pending amount from previous months.
   - It adds this previous pending amount to the current month's fee to calculate the total pending amount.

### Tracking Payment Status

1. After each payment update:
   - A trigger updates or inserts a record in the `PaidStatus` table.
   - It records the outstanding amount, last paid amount, and current pending amount.

2. This allows for easy tracking of each student's payment history and current status.

## Key Features

- **Automatic Class Fee Assignment**: The system automatically assigns the correct tuition fee to new students based on their class, reducing manual data entry and potential errors.


- **Automatic Total Calculation**: The system automatically calculates the total fee for each student, considering tuition, transport, and other fees.

- **Pending Amount Tracking**: It keeps track of pending amounts from previous months, ensuring that old dues are not forgotten.

- **Real-time Payment Status**: The payment status is updated in real-time whenever a payment is made or a fee is updated.

- **Transport Management**: The system integrates transport fees and details, allowing for comprehensive fee management.

- **Flexible Fee Structure**: Different types of fees (tuition, transport, others) can be managed separately, allowing for a flexible fee structure.

## Triggers

The system uses several triggers to automate calculations and updates:

1. `after_student_insert`: Automatically creates a fee record when a new student is added.
   - Retrieves the class fee from the `Classes` table based on the student's assigned class.
   - Inserts a new record into the `Fees` table with the correct tuition fee.
   - Sets the initial transport fee and other fees to 0.
   - The total fee is then calculated by the existing triggers on the `Fees` table.

2. `calculate_total_before_insert` and `calcualte_total_before_update`: Calculate total fee before inserting or updating fee records.
3. `after_fees_insert`: Creates a payment record when a new fee is added.
4. `after_fees_update`: Updates payment records when fees are modified.
5. `before_payment_insert`: Calculates pending amounts considering previous unpaid fees.
6. `paid_amount_update`: Updates pending amount when a payment is made.
7. `after_payment_update`: Updates the paid status record after a payment is made or updated.

These triggers ensure that all calculations are done automatically and consistently, reducing the chance of human error in fee management.

This system helps school administrators easily manage and track student fees, payments, and related information, providing a comprehensive solution for school fee management.