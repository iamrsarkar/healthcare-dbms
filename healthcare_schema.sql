SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS healthcare_db
  DEFAULT CHARACTER SET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

use healthcare_db;
-- ---------- Hospital Module ----------

create table Patient (
patient_id int primary key,
name varchar(35) not null,
dob date,
gender ENUM('M','F','O') DEFAULT 'O',
mobile_no int, 
email varchar(30),
address varchar(150) 
)ENGINE=InnoDB;

CREATE TABLE Doctor (
  doctor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  specialization VARCHAR(120),
  dept VARCHAR(80),
  contact VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Ward (
  ward_id INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(80), -- e.g., ICU, General, Maternity
  capacity INT DEFAULT 0,
  charges_per_day DECIMAL(10,2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;


CREATE TABLE Treatment (
  treatment_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  ward_id INT,
  diagnosis VARCHAR(500),
  treatment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  cost DECIMAL(12,2) DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_treatment_patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_treatment_doctor FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_treatment_ward FOREIGN KEY (ward_id) REFERENCES Ward(ward_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_treatment_patient ON Treatment(patient_id);
CREATE INDEX idx_treatment_doctor ON Treatment(doctor_id);
CREATE INDEX idx_treatment_date ON Treatment(treatment_date);




-- ---------- Insurance Module ----------
CREATE TABLE Insurance_Provider (
  provider_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  contact VARCHAR(100),
  coverage_area VARCHAR(200),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Policy (
  policy_id INT AUTO_INCREMENT PRIMARY KEY,
  provider_id INT NOT NULL,
  policy_type VARCHAR(100),
  coverage_amount DECIMAL(15,2) DEFAULT 0.00,
  premium DECIMAL(12,2) DEFAULT 0.00,
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_policy_provider FOREIGN KEY (provider_id) REFERENCES Insurance_Provider(provider_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Associative table for Patient <-> Policy (M:N)
CREATE TABLE Patient_Policy (
  patient_policy_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  policy_id INT NOT NULL,
  policy_number VARCHAR(100),
  active BOOLEAN DEFAULT TRUE,
  enrollment_date DATE,
  UNIQUE KEY ux_patient_policy (patient_id, policy_id, policy_number),
  CONSTRAINT fk_pp_patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pp_policy FOREIGN KEY (policy_id) REFERENCES Policy(policy_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Claim (
  claim_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  policy_id INT NOT NULL,
  treatment_id INT NOT NULL,
  claim_amount DECIMAL(15,2) NOT NULL,
  status ENUM('Pending','Approved','Rejected','Under Review') DEFAULT 'Pending',
  claim_date DATE DEFAULT (CURRENT_DATE),
  remark VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_claim_patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_claim_policy FOREIGN KEY (policy_id) REFERENCES Policy(policy_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_claim_treatment FOREIGN KEY (treatment_id) REFERENCES Treatment(treatment_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  -- one-to-one-ish constraint: a treatment should map to at most one claim
  UNIQUE KEY ux_claim_treatment (treatment_id)
) ENGINE=InnoDB;

CREATE INDEX idx_claim_patient ON Claim(patient_id);
CREATE INDEX idx_claim_status ON Claim(status);






-- ---------- Insurance Module ----------
CREATE TABLE Insurance_Provider (
  provider_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  contact VARCHAR(100),
  coverage_area VARCHAR(200),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Policy (
  policy_id INT AUTO_INCREMENT PRIMARY KEY,
  provider_id INT NOT NULL,
  policy_type VARCHAR(100),
  coverage_amount DECIMAL(15,2) DEFAULT 0.00,
  premium DECIMAL(12,2) DEFAULT 0.00,
  start_date DATE,
  end_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_policy_provider FOREIGN KEY (provider_id) REFERENCES Insurance_Provider(provider_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Associative table for Patient <-> Policy (M:N)
CREATE TABLE Patient_Policy (
  patient_policy_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  policy_id INT NOT NULL,
  policy_number VARCHAR(100),
  active BOOLEAN DEFAULT TRUE,
  enrollment_date DATE,
  UNIQUE KEY ux_patient_policy (patient_id, policy_id, policy_number),
  CONSTRAINT fk_pp_patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pp_policy FOREIGN KEY (policy_id) REFERENCES Policy(policy_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Claim (
  claim_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  policy_id INT NOT NULL,
  treatment_id INT NOT NULL,
  claim_amount DECIMAL(15,2) NOT NULL,
  status ENUM('Pending','Approved','Rejected','Under Review') DEFAULT 'Pending',
  claim_date DATE DEFAULT (CURRENT_DATE),
  remark VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_claim_patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_claim_policy FOREIGN KEY (policy_id) REFERENCES Policy(policy_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_claim_treatment FOREIGN KEY (treatment_id) REFERENCES Treatment(treatment_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  -- one-to-one-ish constraint: a treatment should map to at most one claim
  UNIQUE KEY ux_claim_treatment (treatment_id)
) ENGINE=InnoDB;

CREATE INDEX idx_claim_patient ON Claim(patient_id);
CREATE INDEX idx_claim_status ON Claim(status);


-- ---------- Pharmacy Module ----------
CREATE TABLE Supplier (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  contact VARCHAR(100),
  address VARCHAR(300),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Medicine (
  medicine_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  category VARCHAR(100),
  price DECIMAL(10,2) DEFAULT 0.00,
  stock INT DEFAULT 0,
  supplier_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_medicine_supplier FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_medicine_name ON Medicine(name);


-- Prescription: each prescription is issued by a doctor for a patient.
-- Medicines linked via Prescription_Medicine for M:N
CREATE TABLE Prescription (
  prescription_id INT AUTO_INCREMENT PRIMARY KEY,
  patient_id INT NOT NULL,
  doctor_id INT NOT NULL,
  issue_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  notes VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_prescription_patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_prescription_doctor FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_prescription_patient ON Prescription(patient_id);

-- Associative table Prescription_Medicine to support multiple medicines per prescription.
CREATE TABLE Prescription_Medicine (
  presc_med_id INT AUTO_INCREMENT PRIMARY KEY,
  prescription_id INT NOT NULL,
  medicine_id INT NOT NULL,
  dosage VARCHAR(80),       -- e.g., "1 tablet"
  frequency VARCHAR(80),    -- e.g., "2 times/day"
  duration_days INT,
  quantity INT DEFAULT 1,
  CONSTRAINT fk_pm_prescription FOREIGN KEY (prescription_id) REFERENCES Prescription(prescription_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_pm_medicine FOREIGN KEY (medicine_id) REFERENCES Medicine(medicine_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  UNIQUE KEY ux_presc_med (prescription_id, medicine_id)
) ENGINE=InnoDB;

CREATE INDEX idx_pm_prescription ON Prescription_Medicine(prescription_id);

CREATE TABLE Pharmacy_Billing (
  bill_id INT AUTO_INCREMENT PRIMARY KEY,
  prescription_id INT NOT NULL UNIQUE, -- 1:1 mapping
  total_amount DECIMAL(12,2) NOT NULL,
  payment_status ENUM('Unpaid','Paid','Refunded') DEFAULT 'Unpaid',
  billing_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_bill_prescription FOREIGN KEY (prescription_id) REFERENCES Prescription(prescription_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_billing_status ON Pharmacy_Billing(payment_status);


-- ---------- Lab Module ----------
CREATE TABLE Lab_Test (
  test_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  cost DECIMAL(10,2) DEFAULT 0.00,
  normal_range VARCHAR(120),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Test_Report (
  report_id INT AUTO_INCREMENT PRIMARY KEY,
  test_id INT NOT NULL,
  patient_id INT NOT NULL,
  doctor_id INT, -- doctor who requested / analyzed the test
  result TEXT,
  test_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tr_test FOREIGN KEY (test_id) REFERENCES Lab_Test(test_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_tr_patient FOREIGN KEY (patient_id) REFERENCES Patient(patient_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_tr_doctor FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_testreport_patient ON Test_Report(patient_id);
CREATE INDEX idx_testreport_test ON Test_Report(test_id);


-- ---------- Useful Views and Procedures ----------
-- View: patient current policies
CREATE OR REPLACE VIEW vw_patient_policies AS
SELECT p.patient_id, p.name AS patient_name, pol.policy_id, pol.policy_type, pol.coverage_amount, pp.policy_number, pp.active
FROM Patient p
JOIN Patient_Policy pp ON p.patient_id = pp.patient_id
JOIN Policy pol ON pp.policy_id = pol.policy_id;

-- Stored Procedure: Auto-approve claims under ₹10,000 (Pending)
DELIMITER $$
CREATE PROCEDURE AutoApproveClaims(IN threshold DECIMAL(12,2))
BEGIN
  UPDATE Claim
  SET status = 'Approved'
  WHERE status = 'Pending' AND claim_amount < threshold;
END$$
DELIMITER ;

-- Optionally: create an EVENT to run AutoApproveClaims daily (requires event_scheduler=ON)
-- Uncomment if you want scheduler-based auto-approval
-- DELIMITER $$
-- CREATE EVENT ev_auto_approve_claims
-- ON SCHEDULE EVERY 1 DAY
-- DO
-- BEGIN
--   CALL AutoApproveClaims(10000.00);
-- END$$
-- DELIMITER ;

-- ---------- Sample Data (tiny set to test structure) ----------
INSERT INTO Insurance_Provider (name, contact, coverage_area) VALUES ('HealthSecure Ltd', 'health@secure.com', 'National');
INSERT INTO Supplier (name, contact, address) VALUES ('MediSupply Co', 'sales@medisupply.com', 'Kolkata Warehouse');

INSERT INTO Patient (name, dob, gender, contact, address) VALUES ('Amit Roy', '1994-07-12', 'M', '9876543210', 'Salt Lake, Kolkata');
INSERT INTO Doctor (name, specialization, dept, contact) VALUES ('Dr. S. Banerjee', 'Cardiology', 'Cardio', '9123456780');
INSERT INTO Ward (type, capacity, charges_per_day) VALUES ('ICU', 10, 5000.00);

INSERT INTO Policy (provider_id, policy_type, coverage_amount, premium, start_date, end_date)
VALUES (1, 'Individual Health', 500000.00, 6000.00, '2025-01-01', '2025-12-31');

INSERT INTO Patient_Policy (patient_id, policy_id, policy_number, active, enrollment_date)
VALUES (1, 1, 'HS-IND-0001', TRUE, '2025-02-01');

INSERT INTO Treatment (patient_id, doctor_id, ward_id, diagnosis, treatment_date, cost)
VALUES (1, 1, 1, 'Acute chest pain', '2025-09-01 10:00:00', 12000.00);

INSERT INTO Claim (patient_id, policy_id, treatment_id, claim_amount, status, claim_date)
VALUES (1, 1, 1, 11500.00, 'Pending', '2025-09-02');

INSERT INTO Medicine (name, category, price, stock, supplier_id) VALUES ('Paracetamol', 'Analgesic', 5.00, 500, 1);
INSERT INTO Prescription (patient_id, doctor_id, notes) VALUES (1, 1, 'Take as needed for fever');

INSERT INTO Prescription_Medicine (prescription_id, medicine_id, dosage, frequency, duration_days, quantity)
VALUES (1, 1, '500 mg', '3 times/day', 5, 15);

INSERT INTO Pharmacy_Billing (prescription_id, total_amount, payment_status)
VALUES (1, 75.00, 'Paid');

INSERT INTO Lab_Test (name, cost, normal_range) VALUES ('CBC', 300.00, '4.5-11 x10^3/µL');
INSERT INTO Test_Report (test_id, patient_id, doctor_id, result, test_date)
VALUES (1, 1, 1, 'Normal', '2025-09-01 09:00:00');

-- Restore FK checks
SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
