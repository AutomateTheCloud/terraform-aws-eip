# Terraform module for Amazon EC2 Elastic IP addresses

Allocates an Elastic IP address: a static public IPv4 address that stays with your AWS account until you release it. You can attach it to an EC2 instance, a network interface, a NAT gateway or a Network Load Balancer, and move it from one to another without the address changing.

The module allocates the address and tags it. It associates it with nothing, so you decide what it is attached to and when.

## What it configures

| Setting | Default | Input |
|---|---|---|
| Where the address can be used | A VPC (`domain = "vpc"`) | Not an input |
| Where the address comes from | Amazon's pool of IPv4 addresses | Not an input |
| Region | The AWS provider's Region | `region` |
| `Name` tag | `<scope>-<purpose>-<environment>-<region>`, such as `automate_the_cloud-web_site-production-use1` | `details`, `eip_target` |
| Other tags | `Scope`, `Purpose`, `Environment`, and any `additional_tags` | `details` |
| Association with an instance, network interface or NAT gateway | None: see [Using the address](https://github.com/AutomateTheCloud/terraform-aws-eip#using-the-address) | Not in the module |

## Usage

```hcl
module "eip" {
  source  = "AutomateTheCloud/eip/aws"
  version = "~> 1.0"

  details = {
    scope       = "Automate the Cloud"
    purpose     = "Web Site"
    environment = "Production"
  }

  eip_target = "bastion"
}

resource "aws_eip_association" "bastion" {
  allocation_id = module.eip.metadata.eip.allocation_id
  instance_id   = aws_instance.bastion.id
}
```

`details` is the only required input. It sets the `Scope`, `Purpose` and `Environment` tags, and the `Name` tag, here `automate_the_cloud-web_site-production-use1-bastion`. `eip_target` is optional and only adds to the `Name` tag.

The module uses your default `aws` provider and allocates the address in that provider's Region. An address can be used only in its own Region. To allocate one somewhere else without configuring another provider, set `region`:

```hcl
module "eip_us_west_2" {
  source  = "AutomateTheCloud/eip/aws"
  version = "~> 1.0"

  region  = "us-west-2"
  details = { scope = "Automate the Cloud", purpose = "Web Site", environment = "Production" }
}
```

Because `region` and `eip_target` are ordinary inputs, one module block can allocate several addresses, in one Region or many, with `for_each`, as the [complete example](https://github.com/AutomateTheCloud/terraform-aws-eip/tree/main/examples/complete) does.

To use a provider configured for another account, pass it explicitly with `providers = { aws = aws.other_account }`.

## The `details` input

Most modules ask only for what the resource itself needs. This one also requires `details`: three names that say what the Elastic IP address belongs to, what it is for, and which environment it is in. Every Automate the Cloud module takes the same input, and requiring it is deliberate.

```hcl
details = {
  scope       = "Automate the Cloud" # what it belongs to: an organization, team or project
  purpose     = "Web Site"           # what it is for
  environment = "Production"         # which environment
}
```

**Every resource can be traced.** The three names become the `Scope`, `Purpose` and `Environment` tags on every resource the module creates. Months later, anyone looking at an Elastic IP address in the AWS console, or at a line on the bill, can see who it belongs to and why it exists. With cost allocation tags turned on in AWS Billing, the same tags split your bill by project and environment. Because the input is required and checked, no resource can be created without them.

**One definition for a whole stack.** Write `details` once and pass the same value to every module, so the Elastic IP address, the NAT gateway that uses it, its VPC and everything else are tagged alike. Tags you want everywhere, such as a cost center or the Terraform workspace, go in `additional_tags`:

```hcl
locals {
  details = {
    scope           = "Automate the Cloud"
    purpose         = "Web Site"
    environment     = "Production"
    additional_tags = { CostCenter = "1234", IaC = "true" }
  }
}

module "site_eip" {
  source  = "AutomateTheCloud/eip/aws"
  version = "~> 1.0"

  details    = local.details
  eip_target = "nat-a"
}
```

**Consistent names.** The module turns each name into two short forms other resources can be named with: `abbr`, lowercase with words joined by underscores (`Web Site` becomes `web_site`), and `machine`, lowercase letters and numbers only (`website`), for resources that allow no underscores. It also works out a short form of the Region, such as `use1` for `us-east-1`. Every module derives these the same way, so names stay consistent across a stack. To choose your own short forms, set `scope_abbr`, `purpose_abbr` or `environment_abbr`, for example `environment_abbr = "prd"`.

**One output to reach everything.** All of it comes back in the `metadata` output, along with everything the module created, so a configuration needs only one reference: `module.site_eip.metadata.eip.public_ip` for the address, or `module.site_eip.metadata.aws.region.abbr` for the Region's short form.

## Examples

Each example is a complete configuration you can run with `terraform init` and `terraform apply`.

- [Basic Elastic IP address](https://github.com/AutomateTheCloud/terraform-aws-eip/tree/main/examples/basic): one address in the provider's Region.
- [Complete](https://github.com/AutomateTheCloud/terraform-aws-eip/tree/main/examples/complete): two addresses from one module block with `for_each`, in another Region through `region`, told apart by `eip_target`.

## Things to know

### Every address costs money

AWS charges by the hour for every public IPv4 address in your account, and an Elastic IP address is charged whether it is associated with anything or not. See [Amazon VPC pricing](https://aws.amazon.com/vpc/pricing/). Release addresses you no longer use by removing the module block, or destroying it.

### Using the address

The module only allocates the address. Attach it with whatever uses it, by passing `metadata.eip.allocation_id`:

- An EC2 instance or a network interface: an `aws_eip_association` resource, as in the [usage example](https://github.com/AutomateTheCloud/terraform-aws-eip#usage).
- A public NAT gateway: the `allocation_id` argument of `aws_nat_gateway`.
- A Network Load Balancer: the `allocation_id` of a `subnet_mapping` block in `aws_lb`.

According to the [Elastic IP address documentation](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-eips.html), the address can be attached only to something in the same Region, in a VPC that has an internet gateway, and it can be moved to another instance or network interface at any time without the address changing.

### Releasing the address

Destroying the module releases the address back to AWS. Changing `region` releases it too, and allocates a new address with a different IP. Anything that depends on the address, such as a DNS record, a firewall rule on another network, or a partner's allow list, then has to change. Changing only `details` or `eip_target` updates the tags in place, and the address stays the same.

### How many you can have

Each account can have five Elastic IP addresses per Region by default. Request more in the Service Quotas console, under Amazon Elastic Compute Cloud (Amazon EC2), "EC2-VPC Elastic IPs".

## Contributing

Contributions are welcome, after review. Read [CONTRIBUTING.md](https://github.com/AutomateTheCloud/terraform-aws-eip/blob/main/CONTRIBUTING.md) before opening a pull request, and report security problems as described in [SECURITY.md](https://github.com/AutomateTheCloud/terraform-aws-eip/blob/main/SECURITY.md).

## Testing

The tests in `tests/` run offline against mocked AWS providers, so they need no AWS account:

```shell
terraform init
terraform test
```

## Reference

The sections below are generated from the code by [terraform-docs](https://terraform-docs.io). To update them, run `terraform-docs .`.

<!-- BEGIN_TF_DOCS -->
### Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement_terraform) (>= 1.9)

- <a name="requirement_aws"></a> [aws](#requirement_aws) (>= 6.0)

### Required Inputs

The following input variables are required:

#### <a name="input_details"></a> [details](#input_details)

Description: Names and tags shared by every resource in the module. `scope`, `purpose` and `environment` become the `Scope`, `Purpose` and `Environment` tags, and are converted to abbreviations that other modules can use in resource names (see the `metadata` output). [The `details` input](https://github.com/AutomateTheCloud/terraform-aws-eip#the-details-input) explains why it is required.

- `scope` - (Required) What the resource belongs to, such as an organization or project: `Automate the Cloud`.
- `purpose` - (Required) What the resource is for: `Web Site`.
- `environment` - (Required) The environment: `Production`.
- `scope_abbr`, `purpose_abbr`, `environment_abbr` - (Optional) Abbreviations to use instead of the generated ones, which are lowercase with words joined by underscores (`Web Site` becomes `web_site`).
- `additional_tags` - (Optional) More tags for every resource, such as `{ CostCenter = "1234" }`.

Type:

```hcl
object({
    scope            = string
    scope_abbr       = optional(string)
    purpose          = string
    purpose_abbr     = optional(string)
    environment      = string
    environment_abbr = optional(string)
    additional_tags  = optional(map(string), {})
  })
```

### Optional Inputs

The following input variables are optional (have default values):

#### <a name="input_eip_target"></a> [eip_target](#input_eip_target)

Description: What the address is for, such as `bastion` or `nat-a`. It is added to the end of the `Name` tag, after a hyphen: `<scope>-<purpose>-<environment>-<region>-<eip_target>`. The default, `""`, adds nothing. Use it to tell apart several addresses created with the same `details` in one Region.

Type: `string`

Default: `""`

#### <a name="input_region"></a> [region](#input_region)

Description: The AWS Region to allocate the Elastic IP address in, such as `us-west-2`. Defaults to the Region of the AWS provider passed to the module. The address can be used only by instances and network interfaces in the same Region. Changing it releases the address and allocates a new one, with a different IP address.

Type: `string`

Default: `null`

### Outputs

The following outputs are exported:

#### <a name="output_metadata"></a> [metadata](#output_metadata)

Description: Everything the module created, in one object, so that other configurations need only one reference:

- `details` - The scope, purpose and environment, each with its `name`, `abbr` (lowercase, words joined by underscores) and `machine` (lowercase letters and numbers only) forms, and the `tags` applied to every resource.
- `aws` - The `account.id`, and the `region` `name`, `abbr` (such as `use1` for `us-east-1`) and `description`.
- `eip` - The Elastic IP address:

  - `public_ip` - The address itself.
  - `allocation_id` - The ID to attach it with: pass it to `aws_eip_association`, `aws_nat_gateway`, or a `subnet_mapping` in `aws_lb`. `id` is the same value.
  - `arn`, `public_dns`, `domain` (`vpc`), `public_ipv4_pool` (`amazon`), `network_border_group` (the Region), `region`, `tags` and `tags_all`.
  - `association_id`, `instance`, `network_interface`, `private_ip` and `private_dns` - What the address is associated with, as of the last time Terraform read it. Empty when it is associated with nothing.
  - `address`, `associate_with_private_ip`, `carrier_ip`, `customer_owned_ip`, `customer_owned_ipv4_pool`, `ipam_pool_id` and `ptr_record` - Settings the module does not use. Empty unless set outside the module.
<!-- END_TF_DOCS -->

## License

This module is licensed under the [Apache License 2.0](https://github.com/AutomateTheCloud/terraform-aws-eip/blob/main/LICENSE). See [NOTICE](https://github.com/AutomateTheCloud/terraform-aws-eip/blob/main/NOTICE) for the copyright notice.

The Automate the Cloud name and logo are not covered by this license.

---

Maintained by [Automate the Cloud](https://automatethe.cloud), a Kentucky 501(c)(3) that teaches cloud infrastructure and helps nonprofits run theirs.
