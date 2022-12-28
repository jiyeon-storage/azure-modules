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

variable "lock" {
  type        = bool
  description = "If true, the resource group is locked and cannot be deleted"
  default     = false
}

variable "lock_level" {
  default     = "CanNotDelete"
  description = "Specifies the Level to be used for this Lock. Possible values are CanNotDelete and ReadOnly"
}

variable "lock_descriptions" {
  description = "Specifies some notes about the lock. Maximum of 512 characters"
  default     = ""
}
