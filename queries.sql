-- Example analytics queries (PostgreSQL). Run after insert_data.sql.

-- Counts
-- ------------------------------------------------------------------

-- How many patients are in the table?
SELECT COUNT(*) AS total_patients
FROM patients;

-- How many doctors?
SELECT COUNT(*) AS total_doctors
FROM doctors;

-- Volume by department (join appointments to doctors to departments)
SELECT
    d.department_name,
    COUNT(a.appointment_id) AS appointment_count
FROM appointments AS a
INNER JOIN doctors AS doc ON a.doctor_id = doc.doctor_id
INNER JOIN departments AS d ON doc.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY appointment_count DESC;

-- Doctors with the most appointments
SELECT
    doc.doctor_name,
    COUNT(a.appointment_id) AS appointment_count
FROM appointments AS a
INNER JOIN doctors AS doc ON a.doctor_id = doc.doctor_id
GROUP BY doc.doctor_id, doc.doctor_name
ORDER BY appointment_count DESC;

-- Patients who booked more than once
SELECT
    p.patient_id,
    p.patient_name,
    COUNT(a.appointment_id) AS visit_count
FROM patients AS p
INNER JOIN appointments AS a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY visit_count DESC;

-- Share of appointments that were cancelled
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN a.status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS cancelled_rate_percent
FROM appointments AS a;

-- Revenue and billing
-- ------------------------------------------------------------------

-- Paid revenue by month (month comes from the appointment date)
SELECT
    EXTRACT(YEAR FROM a.appointment_date) AS revenue_year,
    EXTRACT(MONTH FROM a.appointment_date) AS revenue_month,
    SUM(b.total_amount) AS monthly_revenue
FROM billing AS b
INNER JOIN appointments AS a ON b.appointment_id = a.appointment_id
WHERE b.payment_status = 'Paid'
GROUP BY
    EXTRACT(YEAR FROM a.appointment_date),
    EXTRACT(MONTH FROM a.appointment_date)
ORDER BY revenue_year, revenue_month;

-- Unpaid bills, largest first
SELECT
    b.bill_id,
    b.appointment_id,
    b.total_amount,
    p.patient_name,
    a.appointment_date
FROM billing AS b
INNER JOIN appointments AS a ON b.appointment_id = a.appointment_id
INNER JOIN patients AS p ON a.patient_id = p.patient_id
WHERE b.payment_status = 'Unpaid'
ORDER BY b.total_amount DESC;

-- Average bill amount
SELECT ROUND(AVG(b.total_amount), 2) AS average_bill_amount
FROM billing AS b;

-- Department with the highest paid revenue
WITH dept_revenue AS (
    SELECT
        d.department_name,
        SUM(b.total_amount) AS total_revenue
    FROM billing AS b
    INNER JOIN appointments AS a ON b.appointment_id = a.appointment_id
    INNER JOIN doctors AS doc ON a.doctor_id = doc.doctor_id
    INNER JOIN departments AS d ON doc.department_id = d.department_id
    WHERE b.payment_status = 'Paid'
    GROUP BY d.department_id, d.department_name
)
SELECT department_name, total_revenue
FROM dept_revenue
ORDER BY total_revenue DESC
LIMIT 1;

-- Doctor with the most distinct patients (completed visits only)
SELECT
    doc.doctor_name,
    COUNT(DISTINCT a.patient_id) AS unique_patients
FROM appointments AS a
INNER JOIN doctors AS doc ON a.doctor_id = doc.doctor_id
WHERE a.status = 'Completed'
GROUP BY doc.doctor_id, doc.doctor_name
ORDER BY unique_patients DESC
LIMIT 1;

-- Five highest bills
SELECT
    b.bill_id,
    b.appointment_id,
    b.total_amount,
    b.payment_status
FROM billing AS b
ORDER BY b.total_amount DESC
LIMIT 5;

-- Status and geography
-- ------------------------------------------------------------------

-- Appointments by status
SELECT
    a.status,
    COUNT(*) AS appointment_count
FROM appointments AS a
GROUP BY a.status
ORDER BY appointment_count DESC;

-- Patients per city
SELECT
    p.city,
    COUNT(*) AS patient_count
FROM patients AS p
GROUP BY p.city
ORDER BY patient_count DESC, p.city;

-- Ten most recent appointments
SELECT
    a.appointment_id,
    a.appointment_date,
    a.status,
    p.patient_name,
    doc.doctor_name
FROM appointments AS a
INNER JOIN patients AS p ON a.patient_id = p.patient_id
INNER JOIN doctors AS doc ON a.doctor_id = doc.doctor_id
ORDER BY a.appointment_date DESC, a.appointment_id DESC
LIMIT 10;
