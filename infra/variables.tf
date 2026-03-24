variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "finops-ai-advisor"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}