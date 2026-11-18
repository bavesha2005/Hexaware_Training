CREATE DATABASE HospitalClinicalDB;
GO
USE HospitalClinicalDB;
GO

CREATE TABLE dbo.Patients (
    PatientID INT IDENTITY(1,1) NOT NULL,
    PatientName NVARCHAR(120) NOT NULL,
    Address NVARCHAR(250) NOT NULL,
    Phone VARCHAR(20) NULL,
    Email NVARCHAR(150) NULL,
    CONSTRAINT PK_Patients PRIMARY KEY (PatientID),
    CONSTRAINT UQ_Patients_Email UNIQUE (Email),
    CONSTRAINT CK_Patients_Name_NotBlank CHECK (LEN(LTRIM(RTRIM(PatientName))) > 0)
);

CREATE TABLE dbo.Departments (
    DepartmentID INT IDENTITY(1,1) NOT NULL,
    DepartmentName NVARCHAR(100) NOT NULL,
    Location NVARCHAR(100) NULL,
    CONSTRAINT PK_Departments PRIMARY KEY (DepartmentID),
    CONSTRAINT UQ_Departments_Name UNIQUE (DepartmentName)
);

CREATE TABLE dbo.Doctors (
    DoctorID INT IDENTITY(1,1) NOT NULL,
    DoctorName NVARCHAR(120) NOT NULL,
    DepartmentID INT NOT NULL,
    Email NVARCHAR(150) NULL,
    Phone VARCHAR(20) NULL,
    CONSTRAINT PK_Doctors PRIMARY KEY (DoctorID),
    CONSTRAINT UQ_Doctors_Email UNIQUE (Email),
    CONSTRAINT FK_Doctors_Departments FOREIGN KEY (DepartmentID)
        REFERENCES dbo.Departments(DepartmentID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT CK_Doctors_Name_NotBlank CHECK (LEN(LTRIM(RTRIM(DoctorName))) > 0)
);

CREATE TABLE dbo.Visits (
    VisitID INT IDENTITY(1,1) NOT NULL,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    VisitDate DATE NOT NULL,
    Diagnosis NVARCHAR(500) NOT NULL,
    Prescription NVARCHAR(1000) NULL,
    ClinicalNotes NVARCHAR(MAX) NULL,
    VisitStatus VARCHAR(20) NOT NULL
        CONSTRAINT DF_Visits_VisitStatus DEFAULT ('Open'),
    CONSTRAINT PK_Visits PRIMARY KEY (VisitID),
    CONSTRAINT FK_Visits_Patients FOREIGN KEY (PatientID)
        REFERENCES dbo.Patients(PatientID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT FK_Visits_Doctors FOREIGN KEY (DoctorID)
        REFERENCES dbo.Doctors(DoctorID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT CK_Visits_VisitDate CHECK (VisitDate >= '19000101' AND VisitDate <= CONVERT(DATE, GETDATE())),
    CONSTRAINT CK_Visits_Status CHECK (VisitStatus IN ('Open', 'In Progress', 'Closed', 'Cancelled'))
);

CREATE TABLE dbo.Billing (
    BillingID INT IDENTITY(1,1) NOT NULL,
    VisitID INT NOT NULL,
    BillAmount DECIMAL(12,2) NOT NULL,
    BillingDate DATE NOT NULL
        CONSTRAINT DF_Billing_BillingDate DEFAULT (CONVERT(DATE, GETDATE())),
    BillingStatus VARCHAR(20) NOT NULL
        CONSTRAINT DF_Billing_BillingStatus DEFAULT ('Open'),
    CONSTRAINT PK_Billing PRIMARY KEY (BillingID),
    CONSTRAINT UQ_Billing_VisitID UNIQUE (VisitID),
    CONSTRAINT FK_Billing_Visits FOREIGN KEY (VisitID)
        REFERENCES dbo.Visits(VisitID)
        ON DELETE NO ACTION ON UPDATE CASCADE,
    CONSTRAINT CK_Billing_BillAmount CHECK (BillAmount >= 0),
    CONSTRAINT CK_Billing_BillingDate CHECK (BillingDate >= '19000101' AND BillingDate <= CONVERT(DATE, GETDATE())),
    CONSTRAINT CK_Billing_Status CHECK (BillingStatus IN ('Open', 'Paid', 'Partially Paid', 'Cancelled'))
);

INSERT INTO dbo.Patients (PatientName, Address, Phone, Email) VALUES
(N'Arun Kumar', N'12 Lake View Road, Chennai', '9876500001', N'arun.patient@example.com'),
(N'Priya Sharma', N'24 Gandhi Street, Coimbatore', '9876500002', N'priya.patient@example.com'),
(N'Rahul Das', N'8 Park Avenue, Bengaluru', '9876500003', N'rahul.patient@example.com'),
(N'Meena Raj', N'15 Beach Road, Chennai', '9876500004', N'meena.patient@example.com'),
(N'Karthik S', N'31 Main Road, Madurai', '9876500005', N'karthik.patient@example.com'),
(N'Divya Nair', N'9 MG Road, Kochi', '9876500006', N'divya.patient@example.com'),
(N'Vijay Anand', N'17 Anna Nagar, Chennai', '9876500007', N'vijay.patient@example.com'),
(N'Sneha Iyer', N'22 Race Course Road, Coimbatore', '9876500008', N'sneha.patient@example.com'),
(N'Farhan Ali', N'6 Residency Road, Bengaluru', '9876500009', N'farhan.patient@example.com'),
(N'Lakshmi P', N'44 West Street, Madurai', '9876500010', N'lakshmi.patient@example.com');

INSERT INTO dbo.Departments (DepartmentName, Location) VALUES
(N'Cardiology', N'Block A'),
(N'Neurology', N'Block B'),
(N'Orthopaedics', N'Block C'),
(N'Paediatrics', N'Block D'),
(N'Dermatology', N'Block E');

INSERT INTO dbo.Doctors (DoctorName, DepartmentID, Email, Phone) VALUES
(N'Dr. Anand Menon', 1, N'anand.menon@hospital.com', '9000000001'),
(N'Dr. Sudha Rao', 2, N'sudha.rao@hospital.com', '9000000002'),
(N'Dr. Vikram Shah', 3, N'vikram.shah@hospital.com', '9000000003'),
(N'Dr. Meera Nair', 4, N'meera.nair@hospital.com', '9000000004'),
(N'Dr. Kiran Das', 5, N'kiran.das@hospital.com', '9000000005'),
(N'Dr. Ramesh Iyer', 1, N'ramesh.iyer@hospital.com', '9000000006');

INSERT INTO dbo.Visits
    (PatientID, DoctorID, VisitDate, Diagnosis, Prescription, ClinicalNotes, VisitStatus)
VALUES
(1, 1, '2026-10-03', N'Hypertension', N'Amlodipine 5mg once daily', N'Blood pressure reviewed. Follow-up advised.', 'Closed'),
(2, 2, '2026-10-07', N'Migraine', N'Prescribed migraine medication', N'Patient reports recurring headaches.', 'Open'),
(3, 3, '2026-10-12', N'Knee pain', N'Pain relief medication', N'Pain increases while walking.', 'In Progress'),
(4, 1, '2026-10-15', N'Chest discomfort', N'Further tests advised', N'ECG requested for evaluation.', 'Open'),
(5, 3, '2026-11-02', N'Back pain', N'Physiotherapy advised', N'Posture and mobility assessed.', 'Closed'),
(6, 4, '2026-11-05', N'Viral fever', N'Paracetamol as advised', N'Fever for two days.', 'Closed'),
(7, 5, '2026-11-08', N'Skin allergy', N'Topical cream prescribed', N'Rash observed on both arms.', 'Open'),
(8, 2, '2026-11-10', N'Sleep disturbance', N'Sleep hygiene advised', N'Sleep pattern discussed.', 'In Progress'),
(9, 6, '2026-11-12', N'High blood pressure', N'Medication reviewed', N'Blood pressure monitored.', 'Open'),
(10, 4, '2026-11-14', N'Common cold', N'Symptomatic treatment', N'Mild symptoms reported.', 'Open');

INSERT INTO dbo.Billing (VisitID, BillAmount, BillingDate, BillingStatus) VALUES
(1, 850.00, '2026-10-03', 'Paid'),
(2, 1200.00, '2026-10-07', 'Open'),
(3, 950.00, '2026-10-12', 'Paid'),
(4, 1800.00, '2026-10-15', 'Open'),
(5, 700.00, '2026-11-02', 'Paid'),
(6, 500.00, '2026-11-05', 'Paid'),
(7, 650.00, '2026-11-08', 'Open'),
(8, 1100.00, '2026-11-10', 'Open'),
(9, 900.00, '2026-11-12', 'Paid'),
(10, 450.00, '2026-11-14', 'Open');

ALTER TABLE dbo.Patients
ADD InsuranceID VARCHAR(30) NULL;

EXEC sp_rename 'dbo.Departments', 'HospitalDepartments';

ALTER TABLE dbo.Doctors
DROP CONSTRAINT CK_Doctors_Name_NotBlank;

SELECT * FROM dbo.Patients;
SELECT * FROM dbo.HospitalDepartments;
SELECT * FROM dbo.Doctors;
SELECT * FROM dbo.Visits;
SELECT * FROM dbo.Billing;

SELECT
    p.PatientID,
    p.PatientName,
    p.Address,
    p.InsuranceID,
    v.VisitDate,
    v.Diagnosis,
    d.DoctorName,
    hd.DepartmentName,
    b.BillAmount,
    b.BillingStatus
FROM dbo.Patients AS p
INNER JOIN dbo.Visits AS v ON v.PatientID = p.PatientID
INNER JOIN dbo.Doctors AS d ON d.DoctorID = v.DoctorID
INNER JOIN dbo.HospitalDepartments AS hd ON hd.DepartmentID = d.DepartmentID
LEFT JOIN dbo.Billing AS b ON b.VisitID = v.VisitID
ORDER BY v.VisitDate DESC;

UPDATE dbo.Patients
SET InsuranceID = 'INS-10001'
WHERE PatientID = 1;

UPDATE dbo.Visits
SET VisitStatus = 'Closed'
WHERE VisitID = 2;

SELECT
    p.PatientName,
    v.VisitDate,
    v.Diagnosis,
    v.VisitStatus
FROM dbo.Patients AS p
INNER JOIN dbo.Visits AS v ON v.PatientID = p.PatientID
WHERE v.VisitDate >= '2026-11-01'
  AND v.VisitDate < '2026-12-01'
ORDER BY v.VisitDate;

SELECT
    d.DoctorName,
    hd.DepartmentName,
    d.Email
FROM dbo.Doctors AS d
INNER JOIN dbo.HospitalDepartments AS hd ON hd.DepartmentID = d.DepartmentID
WHERE hd.DepartmentName = 'Cardiology';

SELECT
    d.DoctorName,
    hd.DepartmentName
FROM dbo.Doctors AS d
INNER JOIN dbo.HospitalDepartments AS hd ON hd.DepartmentID = d.DepartmentID
WHERE d.DoctorName LIKE 'Dr. M%';

SELECT
    p.PatientName,
    v.VisitDate,
    v.Diagnosis
FROM dbo.Patients AS p
INNER JOIN dbo.Visits AS v ON v.PatientID = p.PatientID
WHERE p.PatientName LIKE '%a%'
  AND v.VisitDate >= '2026-10-01'
  AND v.VisitDate < '2026-11-01';

UPDATE dbo.Billing
SET BillingStatus = 'Paid'
WHERE BillingID = 2;

DELETE FROM dbo.Billing
WHERE BillingID = 10;

SELECT * FROM dbo.Billing WHERE BillingID = 10;
