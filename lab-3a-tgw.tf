    ### Tokyo Transit Gateway (The Shinjuku Hub)
    
    ### Explanation/Context: This is the central router for the Japan Medical network.
    resource "aws_ec2_transit_gateway" "shinjuku_tgw01" {
      description = "Tokyo Hub Transit Gateway"
      tags = {
        Name = "${local.name_prefix}-tgw01"
      }
    }
    
    ### Explanation/Context: Attaching the existing Lab 2 VPC to the new Hub.
    resource "aws_ec2_transit_gateway_vpc_attachment" "shinjuku_vpc_attach01" {
      subnet_ids         = aws_subnet.palpaking_private_subnets[*].id
      transit_gateway_id = aws_ec2_transit_gateway.shinjuku_tgw01.id
      vpc_id             = aws_vpc.palpaking_vpc01.id
      
      tags = {
        Name = "${local.name_prefix}-tgw-attach01"
      }
    }
