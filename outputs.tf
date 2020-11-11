output "bigip_management_ips" {
    value = module.f5_ltm[*].f5_management_ip
}

output "bigip_admin_credentials" {
    value = module.f5_ltm[*].f5_admin_password
}