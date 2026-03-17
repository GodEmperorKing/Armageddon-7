# Lab 1: Deliverables & Verification 🚀

This document contains the verification evidence for the successful deployment, configuration, and security testing of the Lab 1 AWS infrastructure.

## 1. Automated Architecture & Security Verification
This SEIR Gate verification script confirms that the IAM roles, Secrets Manager configurations, EC2 instances, and RDS network security groups are properly deployed and locked down.
* **Evidence:** All checks passed, confirming the database is private and strictly accessible via the proper security group routing.
![Security Gate Verification](./Screenshot 2026-03-12 225852.jpg)

## 2. Infrastructure as Code (Terraform) Execution
The final state of the infrastructure (Lab 1C) was successfully deployed using Terraform, proving the automated provisioning of SSM parameters, VPC networks, and RDS resources.
* **Evidence:** `terraform apply` completed successfully with all expected outputs generated (VPC ID, Subnet IDs, RDS Endpoint, etc.).
![Terraform Apply Output](./Screenshot 2026-03-13 004030.jpg)

## 3. Systems Manager (SSM) & Secrets Manager Verification
The application relies on dynamically retrieving secure strings rather than hardcoding credentials. These tests verify the EC2 instance can successfully query these managed services.
* **Evidence:** Successfully fetched the database endpoint, name, and port from SSM Parameter Store.
![SSM Parameter Retrieval](./Screenshot 2026-03-10 113838.png)

* **Evidence:** Successfully fetched the decrypted database master credentials from AWS Secrets Manager.
![Secrets Manager Retrieval](./Screenshot 2026-03-10 114257.png)
*(Note: Alternative view of combined parameter and secret retrieval captured in `Screenshot 2026-03-10 115054.jpg`)*

## 4. Application Functionality Test
Testing the application locally on the EC2 web server to ensure it is running and properly serving the API endpoints.
* **Evidence:** The `curl http://localhost/list` command successfully returned the expected HTML list structure, confirming the local web server is active.
![Application Localhost Test](./Screenshot 2026-03-10 132705.png)

## 5. CloudWatch Logging & Monitoring
To ensure operational visibility, the application is configured to stream logs to AWS CloudWatch and trigger alarms based on specific metrics.
* **Evidence:** The log group `lab-1a/app` was successfully created and verified via the AWS CLI.
![CloudWatch Log Group Creation](./Screenshot 2026-03-10 120103.png)

* **Evidence:** Successfully queried and filtered the CloudWatch log events for errors (returning empty, indicating healthy operation).
![CloudWatch Log Filtering](./Screenshot 2026-03-08 231044.png)
*(Note: Additional log filtering evidence captured in `Screenshot 2026-03-10 125317.png`)*

* **Evidence:** The CloudWatch Metric Alarm (`lab-db-connection`) was successfully provisioned to monitor database connection failures.
![CloudWatch Alarms Verification](./Screenshot 2026-03-10 131958.png)

---
**Status:** All Lab 1 requirements successfully built, secured, and verified.
# Lab 1: Foundational AWS Web Architecture & Database Integration 🏗️

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

![API Localhost Verification](./application-localhost-test.png)

## Teardown & State Management
To manage cloud costs, active compute and networking resources (EC2, RDS, NAT Gateway, VPC) were terminated at the conclusion of the lab. Persistent identity and security configurations (IAM Roles, Secrets Manager entries) were retained for integration into subsequent infrastructure-as-code deployments (Lab 1B).
