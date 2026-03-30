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

variable "input_key" {
  description = "S3 key for input data"
  type        = string
  default     = "input/data.json"
}

variable "output_key" {
  description = "S3 key for output results"
  type        = string
  default     = "output/results.json"
}

variable "enable_bedrock" {
  description = "Enable Bedrock analysis"
  type        = string
  default     = "true"
}

variable "bedrock_model_id" {
  description = "Bedrock model ID"
  type        = string
  default     = "amazon.nova-lite-v1:0"
}