variable "region" {
  description = "AWS region"
  default     = "us-west-1"
}


variable "filesystems" {
  type = list(string)
  default = ["efs1","efs2"]
}

variable "subnets" {
  type = list(string)
  description = "The private subnet IDs in which the EFS will have a mount."
  default = ["subnet-111", "subnet-222", "subnet-333"]
}


