output "instance_public_ips" {
  description = "Adresses IP publiques des instances EC2"
  value       = [for instance in aws_instance.project : instance.public_ip]
}

output "instance_private_ips" {
  description = "Adresses IP privées des instances EC2"
  value       = [for instance in aws_instance.project : instance.private_ip]
}

output "vpc_id" {
  description = "ID du VPC principal"
  value       = aws_vpc.main_vpc.id
}

output "subnet_id" {
  description = "ID du subnet principal"
  value       = aws_subnet.main_subnet.id
}

output "security_group_id" {
  description = "ID du security group principal"
  value       = aws_security_group.main_sg.id
}

output "instance_names" {
  value       = [for instance in aws_instance.project : instance.tags.Name]
  description = "Noms des instances EC2"
}

output "ansible_inventory" {
  description = "Contenu de l'inventaire Ansible généré dynamiquement"
  value = join("\n", flatten([
    for idx, instance in aws_instance.project : [
      "[${var.instance_names[idx]}]",
      "${var.instance_names[idx]} ansible_host=${instance.public_ip} ansible_private_ip=${instance.private_ip} ansible_user=ubuntu"
    ]
  ]))
}

resource "local_file" "ansible_inventory" {
  content = join("\n", flatten([
    for idx, instance in aws_instance.project : [
      "[${var.instance_names[idx]}]",
      "${var.instance_names[idx]} ansible_host=${instance.public_ip} ansible_private_ip=${instance.private_ip} ansible_user=ubuntu"
    ]
  ]))
  filename = pathexpand(var.ansible_inventory_path)
}