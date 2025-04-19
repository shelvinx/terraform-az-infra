# Terraform Azure Infrastructure

This project provisions an Azure Virtual Machine using [Terraform](https://www.terraform.io/) using Azure Verified Modules.

## Features

- Automated deployment of Azure VM
- Configurable VM size, OS, and networking
- Resource Group and supporting resources creation

## Prerequisites

- [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) installed
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) installed and authenticated
- Azure subscription

## Usage

1. **Clone the repository**
    ```sh
    git clone https://github.com/yourusername/your-repo.git
    cd your-repo
    ```

2. **Initialize Terraform**
    ```sh
    terraform init
    ```

3. **Review and customize variables** in `variables.tf` as needed.

4. **Plan the deployment**
    ```sh
    terraform plan
    ```

5. **Apply the configuration**
    ```sh
    terraform apply
    ```

6. **Destroy resources (optional)**
    ```sh
    terraform destroy
    ```

## Project Structure

```
.
├── main.tf
├── variables.tf
├── outputs.tf
└── readme.md
```

## Resources

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Documentation](https://docs.microsoft.com/azure/)
