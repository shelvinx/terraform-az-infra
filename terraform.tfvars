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
vnet_test_address_space    = ["10.0.1.0/16"]
vm_subnet_1_address_prefix = ["10.0.1.0/24"]

# Compute Variables
windows_vm_sku_size     = "Standard_D2as_v6"
linux_vm_sku_size       = "Standard_D2as_v6"
priority        = "Spot"
spot_max_price  = 0.07
eviction_policy = "Deallocate"