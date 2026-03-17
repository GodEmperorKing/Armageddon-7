variable "aws_region" {
  description = "AWS Region for the Palpaking fleet to patrol."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix for naming. Students should change from 'Palpaking' to their own."
  type        = string
  default     = "Palpaking"
}

variable "vpc_cidr" {
  description = "VPC CIDR."
  type        = string
  default     = "10.239.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."
  type        = list(string)
  default     = ["10.239.1.0/24", "10.239.2.0/24", "10.239.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."
  type        = list(string)
  default     = ["10.239.101.0/24", "10.239.102.0/24", "10.239.103.0/24"]
}

variable "azs" {
  description = "Availability Zones list."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 app host."
  type        = string
  default     = "ami-0532be01f26a3de55"
}

variable "ec2_instance_type" {
  description = "EC2 instance size for the app."
  type        = string
  default     = "t3.micro"
}

variable "db_engine" {
  description = "RDS engine."
  type        = string
  default     = "mysql" # FIXED TYPO HERE
}

variable "db_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "lab1db"
}

variable "db_username" {
  description = "DB master username."
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "DB master password."
  type        = string
  sensitive   = true
  default     = "iamarmageddon"
}

variable "sns_email_endpoint" {
  description = "Email for SNS subscription."
  type        = string
  default     = "youralltoeasy@gmail.com"
}