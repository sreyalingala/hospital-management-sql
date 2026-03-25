-- Hospital Patient and Appointment Analytics (PostgreSQL)

DROP TABLE IF EXISTS billing;
DROP TABLE IF EXISTS appointments;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id   INTEGER PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE patients (
    patient_id   INTEGER PRIMARY KEY,
    patient_name VARCHAR(120) NOT NULL,
    age          INTEGER NOT NULL,
    gender       VARCHAR(20) NOT NULL,
    city         VARCHAR(100) NOT NULL,
    CONSTRAINT chk_patients_age CHECK (age >= 0 AND age <= 120)
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
    status           VARCHAR(40) NOT NULL,
    CONSTRAINT chk_appointments_status CHECK (
        status IN ('Completed', 'Cancelled', 'No Show')
    )
);

-- One bill row per appointment (adjust if you later split line items).
CREATE TABLE billing (
    bill_id         INTEGER PRIMARY KEY,
    appointment_id  INTEGER NOT NULL UNIQUE REFERENCES appointments (appointment_id),
    total_amount      NUMERIC(12, 2) NOT NULL,
    payment_status    VARCHAR(20) NOT NULL,
    payment_date      DATE,
    CONSTRAINT chk_billing_amount CHECK (total_amount >= 0),
    CONSTRAINT chk_billing_payment_status CHECK (
        payment_status IN ('Paid', 'Unpaid')
    ),
    CONSTRAINT chk_billing_paid_has_date CHECK (
        (payment_status = 'Unpaid' AND payment_date IS NULL)
        OR (payment_status = 'Paid' AND payment_date IS NOT NULL)
    )
);

CREATE INDEX idx_appointments_patient ON appointments (patient_id);
CREATE INDEX idx_appointments_doctor ON appointments (doctor_id);
CREATE INDEX idx_appointments_date ON appointments (appointment_date);
CREATE INDEX idx_doctors_department ON doctors (department_id);
CREATE INDEX idx_billing_payment_status ON billing (payment_status);
