variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment tag (dev|staging|prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "migration-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.28"
}

variable "vpc_cidr" {
  description = "CIDR for the created VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_capacity" {
  description = "Desired number of nodes in the managed node group"
  type        = number
  default     = 2
}

variable "node_min_capacity" {
  description = "Minimum number of nodes in the managed node group"
  type        = number
  default     = 1
}

variable "node_max_capacity" {
  description = "Maximum number of nodes in the managed node group"
  type        = number
  default     = 3
}

variable "ssh_key_name" {
  description = "Optional SSH keypair name for nodes (leave empty in production for security)"
  type        = string
  default     = ""
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs for the EKS VPC"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "demo-eks-cluster"
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_capacity" {
  description = "Minimum worker nodes"
  type        = number
  default     = 1
}

variable "node_max_capacity" {
  description = "Maximum worker nodes"
  type        = number
  default     = 3
}

variable "node_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "ssh_key_name" {
  description = "SSH key pair name for worker nodes (optional)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment tag"
  type        = string
  default     = "dev"
}