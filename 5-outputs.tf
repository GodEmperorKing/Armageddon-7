### Explanation: Outputs are your mission report—what got built and where to find it.

output "palpaking_vpc_id" {
  value = aws_vpc.palpaking_vpc01.id
}

output "palpaking_public_subnet_ids" {
  value = aws_subnet.palpaking_public_subnets[*].id
}

output "palpaking_private_subnet_ids" {
  value = aws_subnet.palpaking_private_subnets[*].id
}

output "palpaking_ec2_instance_id" {
  value = aws_instance.palpaking_ec201.id
}

output "palpaking_rds_endpoint" {
  value = aws_db_instance.palpaking_rds01.address
}

output "palpaking_sns_topic_arn" {
  value = aws_sns_topic.palpaking_sns_topic01.arn
}

output "palpaking_log_group_name" {
  value = aws_cloudwatch_log_group.palpaking_log_group01.name
}