# F5, Terraform, Consul, and Ansible Scale demo

A series of Terraform templates and Ansible playbooks that demonstrates the following actions in AWS:
1. Provisioning a scaling group of F5 VEs behind a NLB using Terraform
2. Performing initial setup steps of the F5 VEs using F5 [Declarative Onboarding](https://clouddocs.f5.com/products/extensions/f5-declarative-onboarding/latest/).
3. Using Terraform local provisioners and an Ansible Playbook to push an [F5 AS3](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/) declaration defining the load balancing configuration on the F5 VE.
4. Leveraging the F5 AS3 [Service Discovery](https://clouddocs.f5.com/products/extensions/f5-appsvcs-extension/latest/declarations/discovery.html) functionality to pull load balancing pool members from Consul.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.5 |
| aws | >= 2.3 |
| null | >= 3.0 |
| random | >= 2.3 |
| template | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.3 |
| null | >= 3.0 |

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| key\_pair | n/a | `any` | n/a |
| bigip\_count | Number of F5 BIG-IPs in cluster to provision | `number` | `2` |
| nginx\_count | Number of Nginx nodes in cluster to provision | `number` | `3` |

## Outputs

| Name | Description |
|------|-------------|
| bigip\_management\_ips | List of management public IPs to access provisioned F5 appliances. |
| bigip\_admin\_credentials | List of random passwords for the admin user to access provisioned F5 appliances. |
| nlb\_dns\_name | DNS name for tier one load balancer that targets the F5 demo VIP. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->