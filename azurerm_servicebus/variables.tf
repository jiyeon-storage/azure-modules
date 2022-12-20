variable "name" {
  type        = string
  description = "The name of the namespace."
}

variable "resource_group_name" {
  type        = string
  description = "A container that holds related resources for an Azure solution"
}

variable "location" {
  type        = string
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
}

variable "sku" {
  type        = string
  default     = "Standard"
  description = "The SKU of the namespace. The options are: `Basic`, `Standard`, `Premium`."
}

variable "capacity" {
  type        = number
  default     = 0
  description = "The number of message units."
}

variable "topics" {
  type        = any
  default     = []
  description = "List of topics."
}

variable "authorization_rules" {
  type        = any
  default     = []
  description = "List of namespace authorization rules."
}

variable "queues" {
  type        = any
  default     = []
  description = "List of queues."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = " Map of tags to assign to the resources."
}

variable "prefix" {
  type        = string
}
variable "env" {
  type        = string
}
variable "team" {
  type        = string
}
variable "purpose" {
  type        = string
}