# Copyright 2026 Automate the Cloud Inc.
# SPDX-License-Identifier: Apache-2.0

# One Elastic IP address, allocated in the provider's Region and associated with
# nothing. Attach it later to an instance, a network interface or a NAT gateway.

terraform {
  required_version = ">= 1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "eip" {
  source = "../../"

  details = {
    scope       = "Example"
    purpose     = "Basic EIP"
    environment = "Development"
  }
}

output "eip" {
  description = "The Elastic IP address and its allocation ID"
  value = {
    public_ip     = module.eip.metadata.eip.public_ip
    allocation_id = module.eip.metadata.eip.allocation_id
  }
}
