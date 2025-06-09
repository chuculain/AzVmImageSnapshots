// This README explains The Azure VM image management project.

# Purpose of the Project
## Explore
It is an exploration of how a Virtual Machine can be deployed, imaged, and then recreated from that image.
I want the recreated VM to have an ephemeral disk. So that I may measure the IOPS performance.
I want azure to be used as the cloud service provider.

## Use cases
- User runs pipeline 1 to create 1st generation VM from Azure Windows-latest image.
- User runs pipeline 2 to capture a generalized image of the 1st generation VM and to store it in a compute gallery.
- User runs pipeline 3 to create a 2nd generation VM from the compute gallery image. 
- VM can be created from captured generalized image stored in Azure compute gallery.
- A second generation VM will persist until the user decides to approve its deletion.
- A user will need to be able to launch a powershell script remotely on the 2nd generation VM to be able to measure disk IOPS performance. 

# Technology Stack
## Software development environment
Use bicep to code deployment of azure resources.
Use powershell to code azure vm image capture to compute gallery.
Use yml to code for az pipeline run.

## Virtual Machine
Use OS Windows latest.
2 CPU of modest performance (enough to execute powershell scripts via terminal)
No GPU required.
4 GB of RAM
A first generation VM will use a managed disk.
A second generation VM will use an ephemeral cache disk.

## Network to VM for developer access
Allow for remote Az CLI powershell script run.
No need to allow for remote desktop access. 

# Project Structure and Best Practices

## 1. Directory Structure
- **infra/**: Place all Bicep (IaC) files here for clarity and azd compatibility.
- **scripts/**: Place all PowerShell and automation scripts here.
- **azure-pipelines.yml**: CI/CD pipeline definition.

## 2. Security
- Never hardcode credentials. Use Azure Key Vault or pipeline secrets for sensitive values.
- Use managed identities for authentication where possible.

## 3. IaC (Bicep)
- Use parameter files for environment-specific values.
- Add comments to Bicep files for clarity.
- Use resource tags for traceability.

## 4. Automation
- Scripts should include error handling and logging.
- Use azd or az cli for deployments, but prefer azd for new projects.

## 5. Pipeline
- Store secrets in Azure DevOps variable groups or Key Vault.
- Use pipeline stages for infra, image, and VM deployment.
- It is expected for any pipeline that creates a VM resource, a cleanup stage will be run after approval by the user. 

## 6. Azure resources
- Deploy to centralcanada location
- Use the cheapest VM SKU for the region.
- Encode resource deletion into pipeline cleanup stage activated after user approval.

## 7. Naming Conventions
- Use clear and descriptive names for resources.
- Use a consistent naming pattern, using env subscription, location and resource type. e.g., 
`dcacevm1`, 
`dcacedisk`, 
`dcacecg`.
- inspire yourself from the Azure naming conventions for resources.
- inspire yourself from Sumerian mythology for names of resources.
---
