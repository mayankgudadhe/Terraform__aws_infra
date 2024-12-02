# Terraform AWS Infrastructure

This Terraform configuration script defines the infrastructure for creating resources across two AWS regions: `Mumbai (ap-south-1)` and `US East (us-east-1)`. The primary resources managed by this script include Virtual Private Clouds (VPCs), subnets, Internet Gateways, security groups, EC2 instances, and VPC peering between Mumbai and NVIR regions.

## Requirements

- [Terraform](https://www.terraform.io/) installed.
- AWS account with necessary permissions to create resources.
- SSH key pair (`id_rsa` and `id_rsa.pub`) for EC2 instances.

## Overview

The script configures the following resources:

### Mumbai Region (ap-south-1)

- **VPC**: A new VPC with CIDR block `10.10.0.0/16`.
- **Internet Gateway**: An Internet Gateway (IGW) for the Mumbai VPC.
- **Subnets**:
  - **Public Subnet**: `10.10.1.0/24`, located in Availability Zone `ap-south-1a`.
  - **Private Subnet**: `10.10.2.0/24`, located in Availability Zone `ap-south-1b`.
- **Route Tables**:
  - **Public Route Table**: Routes traffic to the Internet Gateway.
  - **Private Route Table**: Routes traffic to NVIR region via VPC peering.
- **Security Groups**: Custom security groups allowing SSH (port 22) and HTTP (port 80) traffic.
- **EC2 Instances**:
  - **Public EC2 Instance**: An EC2 instance in the public subnet, accessible via SSH.
  - **Private EC2 Instance**: An EC2 instance in the private subnet, with SSH access configured through the public instance.

### NVIR Region (us-east-1)

- **VPC**: A new VPC with CIDR block `10.20.0.0/16`.
- **Internet Gateway**: An Internet Gateway (IGW) for the NVIR VPC.
- **Subnets**:
  - **Public Subnet**: `10.20.1.0/24`.
  - **Private Subnet**: `10.20.2.0/24`.
- **Route Tables**:
  - **Public Route Table**: Routes traffic to the Internet Gateway.
  - **Private Route Table**: Routes traffic to Mumbai region via VPC peering.
- **Security Groups**: Custom security groups allowing SSH (port 22) and HTTP (port 80) traffic.
- **EC2 Instances**: No specific EC2 instances are created in NVIR in this configuration.
  
### VPC Peering Connection

- **Peering Connection**: Establishes a VPC peering connection between the Mumbai (`ap-south-1`) and NVIR (`us-east-1`) regions, enabling communication between private subnets across regions.

### EC2 Key Pairs

- **Key Pairs**: Generates two key pairs (one for each region), which are used for SSH access to EC2 instances.

## Providers

This script uses the following AWS providers:

- **Mumbai Region (ap-south-1)**: For resources in the Mumbai region.
- **US East Region (us-east-1)**: For resources in the NVIR region.

## Setup Instructions

1. **Clone this repository** to your local machine.
   
2. **Initialize Terraform**:
   - Navigate to the directory containing the `.tf` files.
   - Run the following command to initialize Terraform:
     ```bash
     terraform init
     ```

3. **Apply Terraform Configuration**:
   - Run the following command to apply the configuration and create the resources:
     ```bash
     terraform apply
     ```
     - Terraform will show you an execution plan. Type `yes` to confirm.

4. **SSH Access**:
   - Generate an SSH key pair using the command:
     ```bash
     ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa
     ```
     - Ensure that the public key is located in `~/.ssh/id_rsa.pub` to allow Terraform to use it.

5. **Output**:
   - Once the script runs successfully, Terraform will create a VPC in both regions and provision the necessary resources. The outputs of the resources created, including instance IPs, can be viewed using:
     ```bash
     terraform output
     ```

6. **Cleanup**:
   - To destroy the created resources, run the following command:
     ```bash
     terraform destroy
     ```

## Resources Managed

- **VPC**: Virtual Private Cloud for isolating resources.
- **Subnets**: Both public and private subnets in Mumbai and NVIR regions.
- **Internet Gateways**: Enabling Internet access for public subnets.
- **Route Tables**: Routing traffic between subnets and across regions.
- **Security Groups**: Configuring access control for EC2 instances.
- **EC2 Instances**: Public and private instances with SSH access.
- **VPC Peering**: Enabling communication between Mumbai and NVIR VPCs.

## Notes

- Make sure to adjust the region, AMI IDs, or instance types as per your requirements.
- You can customize security group rules to restrict access based on your needs.
- The provided AMI ID (`ami-0327f51db613d7bd2`) is for Amazon Linux 2, but you may need to update it based on your preferred operating system.

## Conclusion

This Terraform script simplifies the creation of a multi-region AWS infrastructure with VPC peering, EC2 instances, and other essential resources, enabling you to build a scalable and secure cloud environment across AWS regions.
