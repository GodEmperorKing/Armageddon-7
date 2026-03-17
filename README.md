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

## Teardown & State Management
To manage cloud costs, active compute and networking resources (EC2, RDS, NAT Gateway, VPC) were terminated at the conclusion of the lab. Persistent identity and security configurations (IAM Roles, Secrets Manager entries) were retained for integration into subsequent infrastructure-as-code deployments (Lab 1B).
