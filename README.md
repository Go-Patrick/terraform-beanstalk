# Set up Beanstalk for multiple environments with Terraform

## How to use this repository:
- This repository is designed for multiple environments (dev,qa,staging,...), so first create workspaces with

```bash
terraform workspace new <name>
```
- After creating new workspace, create a .tfvars file for environment variables. The name of that find should match the workspace name too. For example if your workspace is **dev**, then create a **dev.tfvars**
- This repository use remote state storage, so first create your own bucket and then modify the name in the **provider.tf** file
- Then run this to init new project
```bash
terraform init
```
- Then for each environment, you use use specific variable, you can run for each use this:
```bash
terraform plan -var-file=`terraform workspace show`.tfvars
```
- Then apply changes:
```
terraform apply -auto-approve -var-file=`terraform workspace show`.tfvars
```
- Then for others environments, you can do above steps again