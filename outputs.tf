# Copyright 2025 Automate the Cloud Inc.
# SPDX-License-Identifier: Apache-2.0

output "metadata" {
  description = <<-EOT
    Everything the module created, in one object, so that other configurations need only one reference:

    - `details` - The scope, purpose and environment, each with its `name`, `abbr` (lowercase, words joined by underscores) and `machine` (lowercase letters and numbers only) forms, and the `tags` applied to every resource.
    - `aws` - The `account.id`, and the `region` `name`, `abbr` (such as `use1` for `us-east-1`) and `description`.
    - `eip` - The Elastic IP address:

      - `public_ip` - The address itself.
      - `allocation_id` - The ID to attach it with: pass it to `aws_eip_association`, `aws_nat_gateway`, or a `subnet_mapping` in `aws_lb`. `id` is the same value.
      - `arn`, `public_dns`, `domain` (`vpc`), `public_ipv4_pool` (`amazon`), `network_border_group` (the Region), `region`, `tags` and `tags_all`.
      - `association_id`, `instance`, `network_interface`, `private_ip` and `private_dns` - What the address is associated with, as of the last time Terraform read it. Empty when it is associated with nothing.
      - `address`, `associate_with_private_ip`, `carrier_ip`, `customer_owned_ip`, `customer_owned_ipv4_pool`, `ipam_pool_id` and `ptr_record` - Settings the module does not use. Empty unless set outside the module.
  EOT
  value = {
    details = {
      scope = {
        name    = local.scope.name
        abbr    = local.scope.abbr
        machine = local.scope.machine
      }
      purpose = {
        name    = local.purpose.name
        abbr    = local.purpose.abbr
        machine = local.purpose.machine
      }
      environment = {
        name    = local.environment.name
        abbr    = local.environment.abbr
        machine = local.environment.machine
      }
      tags = local.tags
    }

    aws = {
      account = {
        id = local.aws.account.id
      }
      region = {
        name        = local.aws.region.name
        abbr        = local.aws.region.abbr
        description = local.aws.region.description
      }
    }

    # One entry per resource.
    eip = local.output_resources.eip
  }
}

locals {
  # Each resource's attributes are listed one by one. Referencing a whole resource
  # would also reference any attribute the provider deprecates later, and every
  # caller's plan would print deprecation warnings.
  output_resources = {
    eip = {
      address                   = aws_eip.this.address
      allocation_id             = aws_eip.this.allocation_id
      arn                       = aws_eip.this.arn
      associate_with_private_ip = aws_eip.this.associate_with_private_ip
      association_id            = aws_eip.this.association_id
      carrier_ip                = aws_eip.this.carrier_ip
      customer_owned_ip         = aws_eip.this.customer_owned_ip
      customer_owned_ipv4_pool  = aws_eip.this.customer_owned_ipv4_pool
      domain                    = aws_eip.this.domain
      id                        = aws_eip.this.id
      instance                  = aws_eip.this.instance
      ipam_pool_id              = aws_eip.this.ipam_pool_id
      network_border_group      = aws_eip.this.network_border_group
      network_interface         = aws_eip.this.network_interface
      private_dns               = aws_eip.this.private_dns
      private_ip                = aws_eip.this.private_ip
      ptr_record                = aws_eip.this.ptr_record
      public_dns                = aws_eip.this.public_dns
      public_ip                 = aws_eip.this.public_ip
      public_ipv4_pool          = aws_eip.this.public_ipv4_pool
      region                    = aws_eip.this.region
      tags                      = aws_eip.this.tags
      tags_all                  = aws_eip.this.tags_all
    }
  }
}
