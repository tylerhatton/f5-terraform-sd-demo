variable "key_pair" {}

variable "bigip_count" {
  default     = 2
  description = "Number of F5 BIG-IPs in cluster to provision"
}

variable "nginx_count" {
  default     = 3
  description = "Number of Nginx nodes in cluster to provision"
}