# Healthcare-Analytics-SQL-Project-MySQL-
# Healthcare Analytics — SQL Project

A portfolio SQL project demonstrating advanced querying skills using a realistic hospital management dataset. Built with **MySQL 8.0+**, it covers schema design, relational data modelling, and a suite of analytical queries powered by **window functions**.

---

## Overview

This project simulates a hospital's core data operations — tracking departments, doctors, patients, appointments, and lab results — and uses that data to answer real analytical questions a healthcare organisation might ask.

**Skills demonstrated:**
- Relational schema design with normalisation and foreign key constraints
- Window functions: `SUM`, `AVG`, `RANK`, `LAG`, `FIRST_VALUE`, `LAST_VALUE`, `PERCENT_RANK`
- Common Table Expressions (CTEs)
- Aggregations, conditional logic (`CASE WHEN`), and statistical functions (`STDDEV`)

---

## Schema

Five related tables:

```
departments   →   doctors   →   appointments   ←   patients
                                                        ↓
                                                   lab_results
```

| Table | Description |
|---|---|
| `departments` | Hospital departments (Cardiology, Neurology, etc.) |
| `doctors` | Doctors with specialisation and department |
| `patients` | Patient demographics and registration date |
| `appointments` | Visits linking patients to doctors, with diagnosis and billing |
| `lab_results` | Timestamped lab readings per patient (blood pressure, cholesterol, etc.) |

---

## Analytical Queries

### 1. Cumulative revenue per doctor over time
Running total of billing per doctor using a partitioned ordered window.
```sql
SUM(billing_amount) OVER (PARTITION BY doctor_id ORDER BY appointment_date
  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
```

### 2. Revenue rank within department
Ranks each doctor by total revenue, scoped to their department. Uses a CTE for clarity.
```sql
RANK() OVER (PARTITION BY department ORDER BY total_revenue DESC)
```

### 3. Lab result trend — change from previous reading
Computes the delta between consecutive test readings per patient and test type.
```sql
LAG(result_value) OVER (PARTITION BY patient_id, test_name ORDER BY recorded_at)
```

### 4. Moving 3-appointment average billing
Smooths billing volatility with a sliding 3-row window per doctor.
```sql
AVG(billing_amount) OVER (PARTITION BY doctor_id ORDER BY appointment_date
  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
```

### 5. Billing percentile rank — hospital-wide
Shows where each appointment sits in the overall billing distribution.
```sql
PERCENT_RANK() OVER (ORDER BY billing_amount)
```

### 6. First and most recent visit per patient
Pulls earliest and latest appointment dates alongside total visit count.
```sql
FIRST_VALUE(appointment_date) OVER (...)
LAST_VALUE(appointment_date)  OVER (...)
COUNT(appointment_id)         OVER (PARTITION BY patient_id)
```

### 7. High-risk patient flagging
Compares each patient's latest lab value to their personal average ± standard deviation, producing a `HIGH RISK / STABLE / IMPROVING` flag.
```sql
CASE
  WHEN latest_value > avg_value + stddev_value THEN 'HIGH RISK'
  WHEN latest_value < avg_value - stddev_value THEN 'IMPROVING'
  ELSE 'STABLE'
END
```

---

## How to Run

**Requirements:** MySQL 8.0+

```bash
# Run the script from the terminal
mysql -u your_username -p < healthcare_sql_project.sql
```

Or paste the contents into [db-fiddle.com](https://www.db-fiddle.com) (select MySQL 8.0) to run it live in the browser with no setup.

---

## File Structure

```
├── healthcare_sql_project.sql   # Schema, sample data, and all queries
└── README.md
```

---

## Author
Samuel Amponsah Nyarko
Built as a portfolio project to demonstrate SQL proficiency — particularly window functions and analytical querying in a real-world domain.

