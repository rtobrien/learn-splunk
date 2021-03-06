# ====================================================================================
# Common Variables (across all forms)
# ====================================================================================

subscription_id  = "d79193eb-3ccd-4b78-ae11-0c0507247e5b"
common_tags      = {"Deployment" = "SplunkInfra", "Project" = "Splunk"}
location         = "australiaeast"
instance_count   = 1
win_instance_count = 2

# ====================================================================================
# Network
# ====================================================================================

vnet_name          = "splunk_vnet"  
vnet_address_space = ["10.0.0.0/16"]

# ====================================================================================
# VMs
# ====================================================================================

username = "osadmin"
password = "SecureP@$$"

# ====================================================================================
# Resource Groups
# ====================================================================================

rg_name = "splunk"