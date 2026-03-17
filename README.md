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