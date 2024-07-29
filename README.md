### Task-1

```
cd Task-1-cron
./script.sh -e=myemail@mydomain.com,myemail@mydomain.com -t=4

```

### Task-2

Describe how you would design and manage application workloads deployed across multiple environments (e.g test/staging/prod) running in AWS.

First, it is cruical to understand the specific needs of the application and current deployment landing zone pattern.

- We should create hard network boundary between test/staging and production to prevent data leak and cross-talk.
- For VPC design, We must use VPC private endpoints and private subnets to further isolate the workloads. If the k8s service (HTTPS) needs to be exposed for external access, we deploy ingress-controller operator to provision external loadbalancer in public subnet.
- CI/CD pipeline via Jenkins, Artifactory, Container registery and ArgoCD /FluxCD. Think about canary/blue-green deployment pattern
- Sometimes vpc-peering required for log/metric aggregation in the central Monitoring/Prometheus Cluster in federated collection pattern.

### Task-3

1. Create IAM policy and role. Follow https://github.com/kubernetes-sigs/aws-efs-csi-driver/blob/master/docs/iam-policy-create.md
2. Tnstall aws-efs-csi driver
3. SC, PV, PVC
4. Mount to deployment. Check `Task-3-k8s/pod.yaml`

### Task-4

Run

```
cd Task-4-terraform
terraform init
terraform plan \
    -var 'subnets=["subnet-111","subnet-222","subnet-333"]' \
    -var 'filesystems=["efs1","efs2","efs3"]'



```

Output

```
...
  # module.efs_and_mount_targets.aws_efs_mount_target.this["subnet-333.efs3"] will be created
  + resource "aws_efs_mount_target" "this" {
      + availability_zone_id   = (known after apply)
      + availability_zone_name = (known after apply)
      + dns_name               = (known after apply)
      + file_system_arn        = (known after apply)
      + file_system_id         = (known after apply)
      + id                     = (known after apply)
      + ip_address             = (known after apply)
      + mount_target_dns_name  = (known after apply)
      + network_interface_id   = (known after apply)
      + owner_id               = (known after apply)
      + security_groups        = (known after apply)
      + subnet_id              = "subnet-333"
    }

Plan: 12 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + filesystems = [
      + "efs1",
      + "efs2",
      + "efs3",
    ]
╷

```
