# Hospital Patient & Appointment Analytics

A small, SQL-only sample project that models a hospital’s patients, departments, doctors, appointments, and billing. It is meant to show relational design and practical reporting queries—no app layer, no frameworks, just the database.

**Database engine:** **PostgreSQL** (14+) is the primary target. The SQL uses standard features (`EXTRACT`, joins, CTEs) that also work in **MySQL 8+** with the same files in most cases; enable foreign key support in MySQL as usual.

---

## What’s inside

| File | Purpose |
|------|---------|
| `schema.sql` | Creates tables, primary keys, and foreign keys |
| `insert_data.sql` | Loads realistic sample rows |
| `queries.sql` | Business-style analytics queries with comments |

---

## Schema summary

- **departments** — Clinical areas (e.g. Cardiology, Pediatrics).
- **patients** — Demographics and city.
- **doctors** — Linked to a department; includes specialization.
- **appointments** — Links a patient to a doctor on a date with a status (`Completed`, `Cancelled`, `No Show`, etc.).
- **billing** — One row per bill tied to an appointment; tracks amount, paid vs unpaid, and payment date.

Relationships: doctors belong to departments; appointments connect patients and doctors; billing references appointments.

---

## SQL concepts demonstrated

- Joins across multiple tables  
- `GROUP BY`, `HAVING`, `ORDER BY`, and `LIMIT`  
- Aggregates: `COUNT`, `SUM`, `AVG`, `MIN`/`MAX` (where useful)  
- Conditional aggregation (`CASE` inside aggregates)  
- Subqueries and **CTEs** (`WITH`) for readable multi-step logic  
- Percentages and rounding for KPI-style outputs  

Window functions are not required here; the queries stay approachable for beginners.

---

## Business questions answered (in `queries.sql`)

1. How many patients are registered?  
2. How many doctors are on staff?  
3. How many appointments does each department have?  
4. Which doctors have the most appointments?  
5. Which patients have more than one visit?  
6. What share of appointments are cancelled?  
7. What is monthly revenue from **paid** bills?  
8. Which bills are still unpaid?  
9. What is the average bill amount?  
10. Which department has the highest revenue (paid bills)?  
11. Which doctor has seen the most **distinct** patients (completed visits)?  
12. What are the top five highest bills?  
13. How many appointments fall into each status?  
14. How many patients live in each city?  
15. What are the most recent appointments (with patient and doctor names)?  

---

## How to run the SQL files

### PostgreSQL (recommended)

1. Create a database (once):  
   `createdb hospital_analytics`  
   (or use `psql` and `CREATE DATABASE hospital_analytics;`)

2. From a terminal:  
   `psql -d hospital_analytics -f schema.sql`  
   `psql -d hospital_analytics -f insert_data.sql`  
   `psql -d hospital_analytics -f queries.sql`

3. Or paste each file into a GUI client (pgAdmin, DBeaver, etc.) and execute in order: **schema → insert → queries**.

### MySQL (optional)

Run the same three files in order. Use `InnoDB` and MySQL 8+ so `CHECK` constraints and `EXTRACT` behave as expected. If anything differs on your version, compare error messages to your vendor’s docs for `REFERENCES` and `CHECK`.

---

## Conclusion

This repo is a compact portfolio piece: clear table design, believable hospital data, and queries that mirror real reporting asks. Extend it with views, indexes, or more tables when you are ready—the foundation stays small on purpose.
