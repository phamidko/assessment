variable "filesystems" {
  type        = list(string)
  description = "List of filesystem names"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs"
}

output "filesystems" {
  value = var.filesystems
  description = "List of created filesystemss"
}

locals {
    subnet_filesystems = distinct(flatten([
        for subnet in var.subnets :[
            for filesystem in var.filesystems :{
                filesystem  = filesystem
                subnet      = subnet
            }
        ]
    ]))
}

resource "aws_efs_file_system" "this" {
    for_each = { for i, name in var.filesystems : i => name } 
    performance_mode = "generalPurpose" 
    tags = {
        Name = each.value
    }
    
}

resource "aws_efs_mount_target" "this" {
    for_each      = { for entry in local.subnet_filesystems: "${entry.subnet}.${entry.filesystem}" => entry }
    file_system_id = aws_efs_file_system.this[0].name
    subnet_id     = each.value.subnet
}
