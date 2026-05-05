-- ============================================================
--  HEALTHCARE ANALYTICS SQL PROJECT (MySQL 8.0+)
--  Showcases: Window Functions, CTEs, Aggregations, Ranking
-- ============================================================


-- ============================================================
--  SCHEMA SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS healthcare_db;
USE healthcare_db;

CREATE TABLE departments (
    department_id   INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    floor           INT
);

CREATE TABLE doctors (
    doctor_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    specialisation  VARCHAR(100),
    department_id   INT,
    hire_date       DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE patients (
    patient_id      INT AUTO_INCREMENT PRIMARY KEY,
    full_name       VARCHAR(100) NOT NULL,
    date_of_birth   DATE NOT NULL,
    gender          CHAR(1) CHECK (gender IN ('M','F','O')),
    registered_on   DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE appointments (
    appointment_id  INT AUTO_INCREMENT PRIMARY KEY,
    patient_id      INT,
    doctor_id       INT,
    appointment_date DATE NOT NULL,
    diagnosis       VARCHAR(200),
    billing_amount  DECIMAL(10,2),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)
);

CREATE TABLE lab_results (
    result_id       INT AUTO_INCREMENT PRIMARY KEY,
    patient_id      INT,
    test_name       VARCHAR(100),
    result_value    DECIMAL(10,2),
    unit            VARCHAR(20),
    recorded_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id)
);


-- ============================================================
--  SAMPLE DATA
-- ============================================================

INSERT INTO departments (name, floor) VALUES
    ('Cardiology',       3),
    ('Neurology',        4),
    ('Emergency',        1),
    ('Oncology',         5),
    ('General Medicine', 2);

INSERT INTO doctors (full_name, specialisation, department_id, hire_date) VALUES
    ('Dr. Sarah Müller',    'Cardiologist',         1, '2015-03-12'),
    ('Dr. James Okafor',    'Neurologist',          2, '2018-07-01'),
    ('Dr. Priya Nair',      'Emergency Medicine',   3, '2020-01-15'),
    ('Dr. Lucas Becker',    'Oncologist',           4, '2013-09-22'),
    ('Dr. Amara Diallo',    'General Practitioner', 5, '2019-05-30'),
    ('Dr. Helena Voss',     'Cardiologist',         1, '2017-11-08'),
    ('Dr. Marco Rossi',     'Neurologist',          2, '2021-02-20');

INSERT INTO patients (full_name, date_of_birth, gender, registered_on) VALUES
    ('Emily Clarke',    '1985-04-10', 'F', '2022-01-05'),
    ('Tom Hartmann',    '1970-08-23', 'M', '2022-03-18'),
    ('Layla Hassan',    '1990-12-01', 'F', '2022-06-07'),
    ('David Kim',       '1955-07-15', 'M', '2023-01-20'),
    ('Nina Wolf',       '2000-02-28', 'F', '2023-04-11'),
    ('Carlos Mendez',   '1963-10-05', 'M', '2023-07-30'),
    ('Aisha Patel',     '1978-05-19', 'F', '2024-01-09'),
    ('Ben Strauss',     '1948-11-30', 'M', '2024-03-22');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, diagnosis, billing_amount) VALUES
    (1, 1, '2023-02-10', 'Hypertension',         320.00),
    (1, 6, '2023-08-15', 'Arrhythmia',            540.00),
    (2, 2, '2023-03-05', 'Migraine',              280.00),
    (2, 7, '2023-09-20', 'Epilepsy monitoring',   650.00),
    (3, 3, '2023-04-22', 'Appendicitis',          1200.00),
    (4, 4, '2023-05-14', 'Lung cancer screening', 980.00),
    (4, 1, '2023-11-02', 'Hypertension follow-up',180.00),
    (5, 5, '2023-06-30', 'Annual check-up',        90.00),
    (6, 3, '2023-07-11', 'Chest pain',             760.00),
    (6, 1, '2024-01-15', 'Heart failure',          1450.00),
    (7, 2, '2024-02-08', 'Stroke assessment',      870.00),
    (8, 4, '2024-02-28', 'Prostate cancer',        1100.00),
    (8, 5, '2024-03-10', 'Post-op follow-up',       150.00),
    (1, 5, '2024-04-01', 'Diabetes screening',      200.00),
    (3, 6, '2024-04-18', 'Palpitations',            430.00);

INSERT INTO lab_results (patient_id, test_name, result_value, unit, recorded_at) VALUES
    (1, 'Blood Pressure Systolic', 145, 'mmHg', '2023-02-10 09:00:00'),
    (1, 'Blood Pressure Systolic', 138, 'mmHg', '2023-08-15 10:30:00'),
    (1, 'Blood Pressure Systolic', 130, 'mmHg', '2024-04-01 11:00:00'),
    (2, 'Cholesterol',             220, 'mg/dL', '2023-03-05 08:45:00'),
    (2, 'Cholesterol',             195, 'mg/dL', '2023-09-20 09:00:00'),
    (4, 'PSA Level',                 4.5, 'ng/mL','2023-05-14 10:00:00'),
    (6, 'Troponin',                  0.9, 'ng/mL','2023-07-11 14:00:00'),
    (6, 'Troponin',                  2.1, 'ng/mL','2024-01-15 08:00:00'),
    (7, 'D-Dimer',                   1.8, 'mg/L', '2024-02-08 11:30:00'),
    (8, 'PSA Level',                 8.2, 'ng/mL','2024-02-28 09:00:00');


-- ============================================================
--  WINDOW FUNCTION QUERIES
-- ============================================================

-- ------------------------------------------------------------
--  1. Cumulative revenue per doctor over time
--     Shows: SUM() OVER (PARTITION BY ... ORDER BY ...)
-- ------------------------------------------------------------
SELECT
    d.full_name                                     AS doctor,
    a.appointment_date,
    a.billing_amount,
    SUM(a.billing_amount)
        OVER (
            PARTITION BY a.doctor_id
            ORDER BY a.appointment_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )                                           AS cumulative_revenue
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
ORDER BY d.full_name, a.appointment_date;


-- ------------------------------------------------------------
--  2. Rank doctors by total revenue within each department
--     Shows: RANK() OVER (PARTITION BY ... ORDER BY ...)
-- ------------------------------------------------------------
WITH doctor_revenue AS (
    SELECT
        d.doctor_id,
        d.full_name,
        dep.name          AS department,
        SUM(a.billing_amount) AS total_revenue
    FROM doctors d
    JOIN appointments a ON d.doctor_id = a.doctor_id
    JOIN departments dep ON d.department_id = dep.department_id
    GROUP BY d.doctor_id, d.full_name, dep.name
)
SELECT
    department,
    full_name,
    total_revenue,
    RANK() OVER (
        PARTITION BY department
        ORDER BY total_revenue DESC
    )           AS revenue_rank
FROM doctor_revenue
ORDER BY department, revenue_rank;


-- ------------------------------------------------------------
--  3. Patient lab result trend: compare each reading to
--     the previous one for the same test
--     Shows: LAG() OVER (PARTITION BY ... ORDER BY ...)
-- ------------------------------------------------------------
SELECT
    p.full_name                                    AS patient,
    lr.test_name,
    DATE(lr.recorded_at)                            AS test_date,
    lr.result_value,
    lr.unit,
    LAG(lr.result_value)
        OVER (
            PARTITION BY lr.patient_id, lr.test_name
            ORDER BY lr.recorded_at
        )                                          AS previous_value,
    ROUND(
        lr.result_value -
        LAG(lr.result_value)
            OVER (
                PARTITION BY lr.patient_id, lr.test_name
                ORDER BY lr.recorded_at
            ), 2
    )                                              AS change
FROM lab_results lr
JOIN patients p ON lr.patient_id = p.patient_id
ORDER BY p.full_name, lr.test_name, lr.recorded_at;


-- ------------------------------------------------------------
--  4. Moving 3-appointment average billing per doctor
--     Shows: AVG() OVER (...ROWS BETWEEN...)
-- ------------------------------------------------------------
SELECT
    d.full_name                                   AS doctor,
    a.appointment_date,
    a.billing_amount,
    ROUND(
        AVG(a.billing_amount)
            OVER (
                PARTITION BY a.doctor_id
                ORDER BY a.appointment_date
                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
            ), 2
    )                                             AS moving_avg_3
FROM appointments a
JOIN doctors d ON a.doctor_id = d.doctor_id
ORDER BY d.full_name, a.appointment_date;


-- ------------------------------------------------------------
--  5. Percentile rank of each appointment billing amount
--     across all appointments (hospital-wide)
--     Shows: PERCENT_RANK() OVER ()
-- ------------------------------------------------------------
SELECT
    a.appointment_id,
    p.full_name                                   AS patient,
    d.full_name                                   AS doctor,
    a.billing_amount,
    ROUND(
        PERCENT_RANK() OVER (ORDER BY a.billing_amount) * 100, 1
    )                                             AS billing_percentile
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
ORDER BY billing_percentile DESC;


-- ------------------------------------------------------------
--  6. First and most recent appointment date per patient
--     Shows: FIRST_VALUE() / LAST_VALUE() OVER ()
-- ------------------------------------------------------------
SELECT DISTINCT
    p.full_name                                   AS patient,
    FIRST_VALUE(a.appointment_date)
        OVER (
            PARTITION BY a.patient_id
            ORDER BY a.appointment_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )                                         AS first_appointment,
    LAST_VALUE(a.appointment_date)
        OVER (
            PARTITION BY a.patient_id
            ORDER BY a.appointment_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        )                                         AS latest_appointment,
    COUNT(a.appointment_id)
        OVER (PARTITION BY a.patient_id)          AS total_visits
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
ORDER BY total_visits DESC;


-- ------------------------------------------------------------
--  7. Identify high-risk patients: flag if latest lab value
--     is higher than their personal average (z-score style)
--     Shows: AVG, STDDEV, LAST_VALUE, conditional logic
-- ------------------------------------------------------------
WITH stats AS (
    SELECT
        patient_id,
        test_name,
        ROUND(AVG(result_value), 2)              AS avg_value,
        ROUND(STDDEV(result_value), 2)           AS stddev_value,
        LAST_VALUE(result_value)
            OVER (
                PARTITION BY patient_id, test_name
                ORDER BY recorded_at
                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
            )                                    AS latest_value
    FROM lab_results
    GROUP BY patient_id, test_name, result_value, recorded_at
)
SELECT DISTINCT
    p.full_name                                  AS patient,
    s.test_name,
    s.avg_value,
    s.latest_value,
    CASE
        WHEN s.latest_value > s.avg_value + s.stddev_value THEN 'HIGH RISK'
        WHEN s.latest_value < s.avg_value - s.stddev_value THEN 'IMPROVING'
        ELSE 'STABLE'
    END                                          AS risk_flag
FROM stats s
JOIN patients p ON s.patient_id = p.patient_id
ORDER BY risk_flag, p.full_name;
