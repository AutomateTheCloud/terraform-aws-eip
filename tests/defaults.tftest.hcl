# Copyright 2025 Automate the Cloud Inc.
# SPDX-License-Identifier: Apache-2.0

# Offline tests: every provider is mocked, so no AWS account is used.
mock_provider "aws" {
  mock_data "aws_region" {
    defaults = { region = "us-east-1", description = "US East (N. Virginia)" }
  }
  mock_data "aws_caller_identity" {
    defaults = { account_id = "111111111111" }
  }
  mock_resource "aws_eip" {
    defaults = {
      allocation_id = "eipalloc-0123456789abcdef0"
      id            = "eipalloc-0123456789abcdef0"
      public_ip     = "192.0.2.10"
      domain        = "vpc"
    }
  }
}

variables {
  details = { scope = "Test", purpose = "Defaults", environment = "test" }
}

# With only the required inputs, the module allocates one address from Amazon's pool,
# for use in a VPC, and associates it with nothing.
run "defaults_plan" {
  command = plan

  assert {
    condition = alltrue([
      aws_eip.this.domain == "vpc",
      aws_eip.this.address == null,
      aws_eip.this.associate_with_private_ip == null,
      aws_eip.this.customer_owned_ipv4_pool == null,
    ])
    error_message = "Unexpected configuration with only the required inputs."
  }
}

run "defaults_apply" {
  command = apply

  assert {
    condition = alltrue([
      output.metadata.eip.allocation_id == "eipalloc-0123456789abcdef0",
      output.metadata.eip.public_ip == "192.0.2.10",
      output.metadata.eip.domain == "vpc",
      output.metadata.aws.region.name == "us-east-1",
      output.metadata.aws.region.abbr == "use1",
      output.metadata.aws.account.id == "111111111111",
    ])
    error_message = "Unexpected metadata output."
  }
}

run "tags" {
  command = plan
  variables {
    details = { scope = "Test", purpose = "Defaults", environment = "test", additional_tags = { CostCenter = "1234" } }
  }
  assert {
    condition = aws_eip.this.tags == tomap({
      Scope       = "Test"
      Purpose     = "Defaults"
      Environment = "test"
      CostCenter  = "1234"
      Name        = "test-defaults-test-use1"
    })
    error_message = "Unexpected tags."
  }
}

# The Name tag is set by the module, even when additional_tags has one.
run "name_tag_wins" {
  command = plan
  variables {
    details = { scope = "Test", purpose = "Defaults", environment = "test", additional_tags = { Name = "other" } }
  }
  assert {
    condition     = aws_eip.this.tags["Name"] == "test-defaults-test-use1"
    error_message = "The module's Name tag must not be replaced by additional_tags."
  }
}

run "eip_target_suffix" {
  command = plan
  variables { eip_target = "bastion" }
  assert {
    condition     = aws_eip.this.tags["Name"] == "test-defaults-test-use1-bastion"
    error_message = "eip_target must be added to the end of the Name tag."
  }
}

# Regression: eip_target = null failed the plan with "Cannot include a null value in a
# string template". It is now not nullable, so null means the default, "".
run "eip_target_null" {
  command = plan
  variables { eip_target = null }
  assert {
    condition     = aws_eip.this.tags["Name"] == "test-defaults-test-use1"
    error_message = "eip_target = null must behave like the default."
  }
}

# Regression: an empty abbreviation override used to replace the generated one with "",
# so the Name tag started with a hyphen.
run "abbreviation_override" {
  command = plan
  variables {
    details = { scope = "Automate the Cloud", scope_abbr = "atc-org", purpose = "Elastic IP", purpose_abbr = "", environment = "Production" }
  }
  assert {
    condition = alltrue([
      output.metadata.details.scope.abbr == "atc-org",
      output.metadata.details.scope.machine == "atcorg",
      output.metadata.details.purpose.abbr == "elastic_ip",
      output.metadata.details.purpose.machine == "elasticip",
      aws_eip.this.tags["Name"] == "atc-org-elastic_ip-production-use1",
    ])
    error_message = "Unexpected abbreviations."
  }
}

run "details_scope_required" {
  command = plan
  variables { details = { scope = " ", purpose = "p", environment = "e" } }
  expect_failures = [var.details]
}

run "details_purpose_required" {
  command = plan
  variables { details = { scope = "s", purpose = "", environment = "e" } }
  expect_failures = [var.details]
}

run "details_environment_required" {
  command = plan
  variables { details = { scope = "s", purpose = "p", environment = "" } }
  expect_failures = [var.details]
}
