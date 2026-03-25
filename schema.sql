-- Hospital Patient & Appointment Analytics — database schema
-- Target: PostgreSQL 14+ (works with minor edits in MySQL; see README)

-- Departments must exist before doctors reference them.
CREATE TABLE departments (
    department_id   INTEGER PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);

CREATE TABLE patients (
    patient_id   INTEGER PRIMARY KEY,
    patient_name VARCHAR(120) NOT NULL,
    age          INTEGER NOT NULL CHECK (age >= 0 AND age <= 120),
    gender       VARCHAR(20) NOT NULL,
    city         VARCHAR(100) NOT NULL
);

CREATE TABLE doctors (
    doctor_id       INTEGER PRIMARY KEY,
    doctor_name     VARCHAR(120) NOT NULL,
    department_id   INTEGER NOT NULL REFERENCES departments (department_id),
    specialization  VARCHAR(150) NOT NULL
);

CREATE TABLE appointments (
    appointment_id   INTEGER PRIMARY KEY,
    patient_id       INTEGER NOT NULL REFERENCES patients (patient_id),
    doctor_id        INTEGER NOT NULL REFERENCES doctors (doctor_id),
    appointment_date DATE NOT NULL,
    status           VARCHAR(40) NOT NULL
);

CREATE TABLE billing (
    bill_id         INTEGER PRIMARY KEY,
    appointment_id  INTEGER NOT NULL REFERENCES appointments (appointment_id),
    total_amount      NUMERIC(12, 2) NOT NULL CHECK (total_amount >= 0),
    payment_status    VARCHAR(20) NOT NULL,
    payment_date      DATE
);
