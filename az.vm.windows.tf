# AVM Virtual Machine
module "windows_vm" {
  for_each = local.windows_vm_instances
  source   = "Azure/avm-res-compute-virtualmachine/azurerm"
  version  = "0.20.0"

  location                   = var.location
  resource_group_name        = module.resource_group.name
  name                       = "${module.naming.virtual_machine.name}-${each.value.vm_name}"
  os_type                    = "Windows"
  sku_size                   = each.value.sku_size
  zone                       = null
  encryption_at_host_enabled = false

  account_credentials = {
    admin_credentials = {
      username                           = "azureuser"
      password                           = data.azurerm_key_vault_secret.azure_admin_password.value
      generate_admin_password_or_ssh_key = false
    }
  }


  os_disk = {
    name                 = "${module.naming.managed_disk.name}-${each.key}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-g2"
    version   = "latest"
  }

  network_interfaces = {
    network_interface_1 = {
      name = "${module.naming.network_interface.name}-${each.key}"
      ip_configurations = {
        ip_configurations_1 = {
          name                          = "ipconfig-${each.key}"
          private_ip_subnet_resource_id = module.vnet_test.subnets.vm_subnet_1.resource_id
          public_ip_address_resource_id = module.pip_windows[each.key].resource_id
        }
      }
    }
  }

  managed_identities = {
    user_assigned_resource_ids = [data.azurerm_user_assigned_identity.uai_tfvm.id]
  }

  priority        = each.value.priority
  max_bid_price   = var.spot_max_price
  eviction_policy = var.eviction_policy

  # Required when using Azure Edition which uses "HotPatching"
  patch_mode = var.patch_mode

  extensions = {
    script = {
      name                       = "ConfigurationScript"
      publisher                  = "Microsoft.Compute"
      type                       = "CustomScriptExtension"
      type_handler_version       = "1.10"
      auto_upgrade_minor_version = true
      settings                   = <<SETTINGS
      {
        "fileUris": [
          "https://raw.githubusercontent.com/${var.github_username}/terraform-az-infra/refs/heads/main/scripts/vm-config.ps1"
        ],
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File vm-config.ps1"
      }
      SETTINGS
    }
    keyvault = {
      name                       = "KeyVaultForWindows-${each.key}" # Unique name per VM
      publisher                  = "Microsoft.Azure.KeyVault"
      type                       = "KeyVaultForWindows"
      type_handler_version       = "3.0" # Using a common version
      auto_upgrade_minor_version = true
      settings = jsonencode({
        secretsManagementSettings = {
          pollingIntervalInS       = "60"
          certificateStoreName     = "My"  # Standard Windows certificate store
          linkOnRenewal            = false # Set to true if needed
          certificateStoreLocation = "LocalMachine"
          observedCertificates = [
            # Dynamically construct the Key Vault secret URI for the certificate
            "https://${var.key_vault_name}.vault.azure.net/secrets/${each.key}-cert"
          ]
        }
        # Authentication using the VM's User Assigned Managed Identity
        authenticationSettings = {
          msiEndpoint = "http://169.254.169.254/metadata/identity"
          # Use the client ID of the assigned identity
          msiClientId = data.azurerm_user_assigned_identity.uai_tfvm.client_id
        }
      })
      # No protected_settings needed when using Managed Identity
    }
  }

  tags = each.value.tags
}

resource "terraform_data" "trigger_ansible" {
  # This tells Terraform to always trigger this block on every successful run
  triggers_replace = [
    timestamp()
  ]

  # This ensures Terraform waits until ALL VMs in the module are fully created
  depends_on = [
    module.windows_vm,
    # You can also add your linux VM module here if you have one:
    # module.linux_vm 
  ]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = <<EOT
      Write-Host "Triggering Ansible workflow in GitHub..."
      gh workflow run ansible-runner.yml --repo ${var.github_username}/${var.ansible_repo_name} --ref main
      
      Write-Host "Waiting for GitHub to register the run..."
      Start-Sleep -Seconds 5
      
      # Fetch the latest Run ID
      $runJson = gh run list --repo ${var.github_username}/${var.ansible_repo_name} --workflow ansible-runner.yml --limit 1 --json databaseId
      $runId = ($runJson | ConvertFrom-Json)[0].databaseId
      
      Write-Host "Watching GitHub Run ID: $runId"
      
      # Dynamic step-by-step polling loop
      $status = "in_progress"
      $completedSteps = @()
      
      while ($status -eq "in_progress" -or $status -eq "queued" -or $status -eq "waiting" -or $status -eq "requested") {
          Start-Sleep -Seconds 5
          # Fetch the full job data including individual steps
          $runInfo = gh run view $runId --repo ${var.github_username}/${var.ansible_repo_name} --json status,conclusion,jobs | ConvertFrom-Json
          $status = $runInfo.status
          
          # If the job has started, iterate through its steps
          if ($runInfo.jobs -and $runInfo.jobs.Count -gt 0) {
              foreach ($step in $runInfo.jobs[0].steps) {
                  # If a step is done, and we haven't printed it yet, print it!
                  if ($step.status -eq "completed" -and $completedSteps -notcontains $step.name) {
                      # Emulate the gh interface, but printing linearly line-by-line
                      if ($step.conclusion -eq "success") {
                          Write-Host "  ✓ $($step.name)"
                      } elseif ($step.conclusion -eq "skipped") {
                          Write-Host "  - $($step.name) (skipped)"
                      } else {
                          Write-Host "  X $($step.name) (failed)"
                      }
                      $completedSteps += $step.name
                  }
              }
          }
      }
      
      if ($runInfo.conclusion -ne "success") {
          Write-Error "Ansible workflow failed with conclusion: $($runInfo.conclusion)"
          exit 1
      }
      
      Write-Host "Ansible workflow completed successfully!"
    EOT
  }
}
