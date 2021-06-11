# ====================================================================================
# Common Variables (across all forms)
# ====================================================================================

variable "subscription_id" {
    type = string
    default = "d79193eb-3ccd-4b78-ae11-0c0507247e5b"
}

variable "common_tags" {
    type = map
    default = {"Deployment" = "SplunkInfra", "Project" = "Splunk"}
}

variable "location" {
    type = string
    default = "australiaeast"
}

variable "instance_count" {
    description = "How many servers to spin up"
    type = number
    default = 2
}

# ====================================================================================
# Network
# ====================================================================================

variable "vnet_name" {
  default = "splunk_vnet"  
}

variable "vnet_address_space" {
    default = ["10.0.0.0/16"]
}

# ====================================================================================
# VMs
# ====================================================================================

variable "username" {
    type = string
    default = "splunk-admin"
}

variable "password" {
    type = string
    default = "SecureP@$$"
}
# ====================================================================================
# Resource Groups
# ====================================================================================

variable "rg_name" {
  default = "splunk"
}
