# Copyright 2025 Automate the Cloud Inc.
# SPDX-License-Identifier: Apache-2.0

resource "aws_eip" "this" {
  region = var.region
  domain = "vpc"

  tags = merge(
    local.tags,
    {
      "Name" = join("-", compact([local.scope.abbr, local.purpose.abbr, local.environment.abbr, local.aws.region.abbr, var.eip_target]))
    }
  )
}
