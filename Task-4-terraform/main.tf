

module "efs_and_mount_targets" {
  source = "./modules/efs_and_mount_targets"

  filesystems = var.filesystems
  subnets     = var.subnets
}

output "filesystems" {
  value = module.efs_and_mount_targets.filesystems
}

