-- Hospital Patient & Appointment Analytics — example queries
-- Run after insert_data.sql (PostgreSQL)

-- ---------------------------------------------------------------------------
-- 1) Total number of patients registered in the system
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS total_patients
FROM patients;

-- ---------------------------------------------------------------------------
-- 2) Total number of doctors on staff
-- ---------------------------------------------------------------------------
SELECT COUNT(*) AS total_doctors
FROM doctors;

-- ---------------------------------------------------------------------------
-- 3) Appointments per department (joins appointments → doctors → departments)
-- ---------------------------------------------------------------------------
SELECT
    d.department_name,
    COUNT(a.appointment_id) AS appointment_count
FROM appointments AS a
INNER JOIN doctors AS doc ON a.doctor_id = doc.doctor_id
INNER JOIN departments AS d ON doc.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY appointment_count DESC;

-- ---------------------------------------------------------------------------
-- 4) Busiest doctors — most appointments overall
-- ---------------------------------------------------------------------------
SELECT
    doc.doctor_name,
    COUNT(a.appointment_id) AS appointment_count
FROM appointments AS a
INNER JOIN doctors AS doc ON a.doctor_id = doc.doctor_id
GROUP BY doc.doctor_id, doc.doctor_name
ORDER BY appointment_count DESC;

-- ---------------------------------------------------------------------------
-- 5) Patients with more than one visit (repeat visitors)
-- ---------------------------------------------------------------------------
SELECT
    p.patient_id,
    p.patient_name,
    COUNT(a.appointment_id) AS visit_count
FROM patients AS p
INNER JOIN appointments AS a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.patient_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY visit_count DESC;

-- ---------------------------------------------------------------------------
-- 6) Cancelled appointment rate (as a percentage of all appointments)
-- ---------------------------------------------------------------------------
SELECT
    ROUND(
        100.0 * SUM(CASE WHEN a.status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS cancelled_rate_percent
FROM appointments AS a;

-- ---------------------------------------------------------------------------
-- 7) Monthly revenue (paid bills only; uses appointment date for the month)
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 8) Unpaid bills — detail list
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 9) Average billing amount across all bills
-- ---------------------------------------------------------------------------
SELECT ROUND(AVG(b.total_amount), 2) AS average_bill_amount
FROM billing AS b;

-- ---------------------------------------------------------------------------
-- 10) Department with the highest revenue (paid bills only)
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 11) Doctor who saw the most unique patients
-- ---------------------------------------------------------------------------
SELECT
    doc.doctor_name,
    COUNT(DISTINCT a.patient_id) AS unique_patients
FROM appointments AS a
INNER JOIN doctors AS doc ON a.doctor_id = doc.doctor_id
WHERE a.status = 'Completed'
GROUP BY doc.doctor_id, doc.doctor_name
ORDER BY unique_patients DESC
LIMIT 1;

-- ---------------------------------------------------------------------------
-- 12) Top 5 most expensive bills
-- ---------------------------------------------------------------------------
SELECT
    b.bill_id,
    b.appointment_id,
    b.total_amount,
    b.payment_status
FROM billing AS b
ORDER BY b.total_amount DESC
LIMIT 5;

-- ---------------------------------------------------------------------------
-- 13) Appointments grouped by status
-- ---------------------------------------------------------------------------
SELECT
    a.status,
    COUNT(*) AS appointment_count
FROM appointments AS a
GROUP BY a.status
ORDER BY appointment_count DESC;

-- ---------------------------------------------------------------------------
-- 14) Patient count by city
-- ---------------------------------------------------------------------------
SELECT
    p.city,
    COUNT(*) AS patient_count
FROM patients AS p
GROUP BY p.city
ORDER BY patient_count DESC, p.city;

-- ---------------------------------------------------------------------------
-- 15) Recent appointments (last 10 by date, newest first)
-- ---------------------------------------------------------------------------
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
