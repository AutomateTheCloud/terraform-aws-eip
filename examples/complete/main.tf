# Copyright 2025 Automate the Cloud Inc.
# SPDX-License-Identifier: Apache-2.0

# Several Elastic IP addresses, one per entry in a map, allocated in us-west-2 through
# the module's region input while the provider stays in us-east-1. eip_target tells
# them apart in the Name tag, and every address carries the same details and tags.
# None is associated with anything.

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

locals {
  details = {
    scope            = "Example"
    purpose          = "Complete EIP"
    purpose_abbr     = "eip"
    environment      = "Development"
    environment_abbr = "dev"
    additional_tags  = { CostCenter = "1234" }
  }

  # One address per name. The names end up in the Name tag:
  # example-eip-dev-usw2-nat-a and example-eip-dev-usw2-nat-b.
  targets = toset(["nat-a", "nat-b"])
}

module "eip" {
  source   = "../../"
  for_each = local.targets

  region     = "us-west-2"
  details    = local.details
  eip_target = each.key
}

output "eips" {
  description = "Each Elastic IP address's public IP, allocation ID and Name tag, by target"
  value = {
    for k, m in module.eip : k => {
      public_ip     = m.metadata.eip.public_ip
      allocation_id = m.metadata.eip.allocation_id
      name          = m.metadata.eip.tags["Name"]
    }
  }
}
