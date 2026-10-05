# Copyright 2025 Automate the Cloud Inc.
# SPDX-License-Identifier: Apache-2.0

variable "details" {
  description = <<-EOT
    Names and tags shared by every resource in the module. `scope`, `purpose` and `environment` become the `Scope`, `Purpose` and `Environment` tags, and are converted to abbreviations that other modules can use in resource names (see the `metadata` output). [The `details` input](https://github.com/AutomateTheCloud/terraform-aws-eip#the-details-input) explains why it is required.

    - `scope` - (Required) What the resource belongs to, such as an organization or project: `Automate the Cloud`.
    - `purpose` - (Required) What the resource is for: `Web Site`.
    - `environment` - (Required) The environment: `Production`.
    - `scope_abbr`, `purpose_abbr`, `environment_abbr` - (Optional) Abbreviations to use instead of the generated ones, which are lowercase with words joined by underscores (`Web Site` becomes `web_site`).
    - `additional_tags` - (Optional) More tags for every resource, such as `{ CostCenter = "1234" }`.
  EOT
  type = object({
    scope            = string
    scope_abbr       = optional(string)
    purpose          = string
    purpose_abbr     = optional(string)
    environment      = string
    environment_abbr = optional(string)
    additional_tags  = optional(map(string), {})
  })
  nullable = false

  validation {
    condition     = trimspace(var.details.scope) != ""
    error_message = "Scope not specified."
  }

  validation {
    condition     = trimspace(var.details.purpose) != ""
    error_message = "Purpose not specified."
  }

  validation {
    condition     = trimspace(var.details.environment) != ""
    error_message = "Environment not specified."
  }
}

variable "eip_target" {
  description = <<-EOT
    What the address is for, such as `bastion` or `nat-a`. It is added to the end of the `Name` tag, after a hyphen: `<scope>-<purpose>-<environment>-<region>-<eip_target>`. The default, `""`, adds nothing. Use it to tell apart several addresses created with the same `details` in one Region.
  EOT
  type        = string
  default     = ""
  nullable    = false
}

variable "region" {
  description = <<-EOT
    The AWS Region to allocate the Elastic IP address in, such as `us-west-2`. Defaults to the Region of the AWS provider passed to the module. The address can be used only by instances and network interfaces in the same Region. Changing it releases the address and allocates a new one, with a different IP address.
  EOT
  type        = string
  default     = null
}
