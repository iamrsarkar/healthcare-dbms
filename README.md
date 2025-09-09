# 🏥 Healthcare + Insurance + Pharmacy Integrated DBMS

This project contains a **MySQL-ready SQL schema** that models a complete **Healthcare Management System** with integration across **Hospital, Insurance, Pharmacy, and Lab modules**.  
It supports patient treatments, prescriptions, pharmacy billing, lab tests, and insurance claims — all in one normalized database.

---

## 📂 Features

- **Hospital Module**: Patients, Doctors, Wards, Treatments
- **Insurance Module**: Providers, Policies, Patient-Policy M:N mapping, Claims
- **Pharmacy Module**: Suppliers, Medicines, Prescriptions, Pharmacy Billing
- **Lab Module**: Lab Tests and Test Reports
- **Associative Tables** for many-to-many relations:
  - `Patient_Policy` (Patients ↔ Policies)
  - `Prescription_Medicine` (Prescriptions ↔ Medicines)
- **Constraints & Indexes**: Foreign keys, unique constraints, and helpful indexes
- **Stored Procedure**:
  - `AutoApproveClaims` → automatically approves claims under a configurable threshold
- **Sample Data** included for quick testing
- **Views** for reporting, e.g. `vw_patient_policies`

---

## ⚙️ Setup Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/iamrsarkar/healthcare-dbms.git
   cd healthcare-dbms
Open MySQL and run the script:

bash
Copy code
mysql -u your_username -p < healthcare_schema.sql
The database healthcare_db will be created with all tables, views, procedures, and sample data.

🧪 Example Queries
1. Auto-approve small claims
sql
Copy code
CALL AutoApproveClaims(10000.00);
2. Detect unusual claims
sql
Copy code
SELECT c.claim_id, p.name AS patient_name, c.claim_amount, t.cost
FROM Claim c
JOIN Treatment t ON c.treatment_id = t.treatment_id
JOIN Patient p ON c.patient_id = p.patient_id
WHERE c.claim_amount > 1.3 * t.cost;
3. Top prescribed medicines (last 6 months)
sql
Copy code
SELECT m.name, COUNT(pm.prescription_id) AS times_prescribed
FROM Prescription_Medicine pm
JOIN Medicine m ON pm.medicine_id = m.medicine_id
JOIN Prescription p ON pm.prescription_id = p.prescription_id
WHERE p.issue_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY m.medicine_id
ORDER BY times_prescribed DESC
LIMIT 10;
📊 ER Diagram (Conceptual)
Patients receive Treatments from Doctors in Wards

Policies are issued by Insurance Providers, and patients may have multiple policies

Claims are raised against treatments and linked to policies

Prescriptions contain multiple Medicines supplied by Suppliers

Lab Tests produce Reports for patients

(You can generate a visual ER diagram using tools like MySQL Workbench or dbdiagram.io)

🚀 Next Steps
Add Triggers (e.g., decrement medicine stock on billing)

Build Analytics Views (e.g., top claimants, average hospital stay)

Extend to include Discharge summaries, Appointments, and Billing modules

