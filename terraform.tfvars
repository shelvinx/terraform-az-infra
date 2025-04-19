location = "uksouth"

tags = {
  "ManagedBy"   = "Terraform",
  "Environment" = "Test"
}

# Naming Moduel Suffixes
workload_suffix = "webapp"
env_suffix      = "test"

# Network Variables
vnet_test_address_space    = ["10.0.0.0/16"]
vm_subnet_1_address_prefix = ["10.0.1.0/24"]

# Compute Variables
os_type         = "Windows"
vm_sku_size     = "Standard_D2als_v6"
vm_zone         = null # null for no zone
priority        = "Spot"
spot_max_price  = -1 # -1 for no max price
eviction_policy = "Deallocate"