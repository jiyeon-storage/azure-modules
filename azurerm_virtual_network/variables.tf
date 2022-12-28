variable "env" {
  type        = string
  description = "Environment like prod, stg, dev, alpha"
}

variable "team" {
  type        = string
  description = "The team tag used to managed resources"
}

variable "purpose" {
  type        = string
  description = "The team tag used to managed resources"
}

variable "prefix" {
  type        = string
  description = "The instance name"
}

variable "location" {
  type        = string
  description = "Location to deploy resources."
}

variable "resource_group_name" {
  type = string
}

variable "cidrs" {
  type = list(string)
}

variable "subnet_cidrs" {
  type = any
}

variable "subnet_tags" {
  type    = any
  default = null
}

variable "dns_servers" {
  type    = list(string)
  default = null
}

variable "subnet_service_endpoints" {
  type    = any
  default = {}
}

variable "subnet_enforce_private_link_endpoint_network_policies" {
  type    = any
  default = {}
}

variable "subnet_enforce_private_link_service_network_policies" {
  type    = any
  default = {}
}

variable "subnet_delegation" {
  type    = any
  default = {}
}

variable "route_tables_ids" {
  type    = any
  default = null
}
