### Sao Paulo VPC (The Liberdade Outer Rim)

### Explanation: Explicitly tell Terraform to build this in Brazil.
provider "aws" {
  alias  = "saopaulo"
  region = "sa-east-1"
}

### Explanation: The new isolated network for the clinics, using my specific IP block.
resource "aws_vpc" "liberdade_vpc01" {
  provider             = aws.saopaulo
  cidr_block           = "10.239.0.0/16" 
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "liberdade-vpc01"
  }
}

### Explanation: An Internet Gateway so the Brazil instances can eventually reach out for patches.
resource "aws_internet_gateway" "liberdade_igw01" {
  provider = aws.saopaulo
  vpc_id   = aws_vpc.liberdade_vpc01.id

  tags = {
    Name = "liberdade-igw01"
  }
}
