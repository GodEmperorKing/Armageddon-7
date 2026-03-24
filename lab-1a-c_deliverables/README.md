# Lab 1 (A-C): Foundational AWS Web Architecture & Database Integration 🏗️

## Overview
This project demonstrates the manual configuration and deployment of a secure, highly available, two-tier web application architecture on AWS. The environment was built from scratch utilizing a custom Virtual Private Cloud (VPC), a public-facing web server (EC2), and a private, secure backend database (RDS). 

A core focus of this lab is **security and least-privilege access**. Instead of hardcoding database credentials into the application code, the credentials are encrypted and stored in AWS Secrets Manager. The EC2 instance securely retrieves these credentials at runtime using an assigned IAM Role and custom inline policies.

## Architecture & Technologies Used
* **Amazon VPC:** Custom network encompassing `10.239.0.0/16`, utilizing 3 Availability Zones with a mix of public and private subnets, managed via an Internet Gateway and a Regional NAT Gateway.
* **Amazon EC2:** Amazon Linux 2023 (`t3.micro`) web server deployed in a public subnet, bootstrapped dynamically via a `user_data.sh` script to install dependencies and run the application.
* **Amazon RDS:** Managed MySQL 8.4.7 database (`db.t3.micro`) deployed securely without public access.
* **AWS Secrets Manager:** Securely stores and manages the RDS master credentials (`lab1a-rds-mysql`).
* **AWS IAM:** Custom role (`ec2-rds-role`) with attached inline JSON policies allowing the EC2 instance to read specifically designated secrets.
* **Security Groups:** * **Web SG:** Allows inbound HTTP (80) globally and SSH (22) restricted to a specific administrator IP.
  * **Database SG:** Strictly limits inbound MySQL (3306) traffic to originate *only* from the Web Security Group.

## Key Features & Implementation
1. **Infrastructure Provisioning:** Built a custom networking backbone (VPC, Subnets, Gateways) to isolate backend resources from the public internet.
2. **Dynamic Bootstrapping:** Configured an EC2 User Data script that automatically injects environment variables (Region, Secret IDs) and launches a Python-based web API upon server boot.
3. **Secure Credential Injection:** The application securely fetches its database connection strings from AWS Secrets Manager using standard AWS SDKs, ensuring zero plaintext passwords exist in the application code.
4. **API Endpoints Tested:** * `/init` - Initializes the database tables.
   * `/add?note=[text]` - Writes data to the secure private database.
   * `/list` - Retrieves and displays stored database records.

## 5. Verification Evidence & Deliverables

### A. Infrastructure & Security Proof
**Objective:** Verify that the foundational compute, database, and identity layers are correctly provisioned and securely configured.

* **Infrastructure Provisioning:** Terraform output confirms the successful creation and launching of the VPC, subnets, and `lab-ec2-app` compute resources.
![Infrastructure Provisioning](./terraform-apply-output.png)

* **Security Group Verification (The Database Shield):** The architecture strictly enforces network isolation. Verification confirms the RDS database security group drops all traffic except inbound port 3306 requests originating specifically from the EC2 web server's Security Group.
![Security Gate Verification](./security-gate-verification.png)

* **IAM Role & Secrets Retrieval (Least Privilege):** The EC2 instance successfully fetches sensitive database credentials from AWS Secrets Manager and configuration data from Systems Manager (SSM). This serves as definitive proof that the `ec2-rds-role` IAM profile is successfully attached and the inline policies are granting the correct access.
![Secrets Manager Fetch](./secrets-manager-retrieval.png)
*(Note: Additional verification of combined SSM and Secrets retrieval can be seen in `combined-ssm-secrets-retrieval.png`)*

### B. Application & End-to-End Data Path Proof
**Objective:** Confirm the application layer can securely initialize, write to, and read from the private database using the injected secrets.

* **End-to-End Functionality:** The application successfully bootstraps the database (`/init`), writes custom records (`/add`), and retrieves them (`/list`), proving the VPC routing, Security Groups, and database connection strings are all perfectly aligned.
![App Data Validation](./application-localhost-test.png)

### C. Observability & Monitoring Proof
**Objective:** Ensure the environment is instrumented for rapid incident response and troubleshooting.

* **Log Aggregation:** The CloudWatch Agent on the EC2 instance is successfully streaming application logs (`/var/log/rdsapp.log`) to the designated CloudWatch Log Group.
![CloudWatch Logs Overview](./cloudwatch-logs-overview.png)

* **Proactive Alarming:** A CloudWatch Alarm is properly configured to monitor the logs for the specific `ERROR` keyword, which was critical in detecting the database connectivity failure outlined in the Incident Report below.
![CloudWatch Alarms Verification](./cloudwatch-alarms-verification.png)

---

## 🚨 Incident Report: Database Connectivity Failure

* **What failed?** The production application was intermittently failing and returning a "500 Internal Server Error" when users tried to access the `/list` endpoint. The application was completely unable to reach the RDS database.

* **How was it detected?** The failure was detected via CloudWatch Logs (which captured the database connection `ERROR` tracebacks in `/var/log/rdsapp.log`) and a CloudWatch Alarm (`lab-db-connection`) configured to trigger when DBConnectionFailures reached the threshold.

* **Root cause:** Network Isolation. The RDS Database Security Group was manually modified, and the inbound rule allowing TCP traffic on Port 3306 from the EC2 instance's Security Group was removed. This blocked all network traffic between the web server and the database.

* **Time to Recovery (MTTR):** *Approximately 35 minutes from initial investigation to restoring connectivity.*

### 🛡️ Preventive Actions
* **To reduce MTTR:** We should automate the deployment of our CloudWatch Alarms and CloudWatch Agent configurations using Infrastructure as Code (IaC) like CloudFormation or Terraform. During the incident, the CloudWatch Agent had stalled and the alarm was missing/unauthorized, which delayed our ability to quickly observe the logs.
* **To prevent recurrence:** Implement stricter IAM (Identity and Access Management) policies or AWS Config rules to prevent unauthorized users from modifying or deleting critical Security Group rules in the production environment.

---

## Teardown & State Management
To manage cloud costs, active compute and networking resources (EC2, RDS, NAT Gateway, VPC) were terminated at the conclusion of the lab. Persistent identity and security configurations (IAM Roles, Secrets Manager entries) were retained for integration into subsequent infrastructure-as-code deployments.