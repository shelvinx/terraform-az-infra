# Number of VMs
windows_vm_count = 1
linux_vm_count   = 0

location = "uksouth"

tags = {
  "deployment"    = "terraform",
  "configuration" = "ansible"
}

# Naming Moduel Suffixes
workload_suffix = "tf"
env_suffix      = "test"

# Network Variables
vnet_test_address_space    = ["10.1.0.0/16"]
vm_subnet_1_address_prefix = ["10.1.1.0/24"]

# Default VM SKU
windows_vm_sku_size = "Standard_D2als_v6"
linux_vm_sku_size   = "Standard_D2als_v6"

# Pricing Options
priority        = "Spot"
spot_max_price  = 0.20
eviction_policy = "Deallocate"

# Patching Mode
patch_mode = "AutomaticByOS" # Azure Edition VM's use "AutomaticByPlatform"

# Key Vault Variables
key_vault_name = "rain"
key_vault_rg   = "rg-platform"

# GitHub Variables
github_username   = "shelvinx"
ansible_repo_name = "ansible-playbooks"
