variable "vpc_cidr" {
  default     = "192.168.0.0/16"
  description = "CIDR du VPC"
}

variable "subnet_cidr" {
  default     = "192.168.0.0/24"
  description = "CIDR du subnet"
}

variable "availability_zone" {
  default     = "eu-north-1a"
  description = "Zone de disponibilité AWS"
}

variable "private_ip_base" {
  default     = "192.168.0"
  description = "Base pour les IP privées"
}

variable "instance_names" {
  default     = []
  type        = list(string)
  description = "Préfixe du nom des instances"
}

variable "instance_count" {
  default     = 1
  description = "Nombre d'instances à déployer"
}

variable "ansible_inventory_path" {
  description = "Chemin du fichier Ansible hosts.yml"
  type        = string
  default     = "~/projet/hosts.ini"
}