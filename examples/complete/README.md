# Complete

Two Elastic IP addresses, `nat-a` and `nat-b`, created with one module block and `for_each`, in `us-west-2` through the module's `region` input while the provider is configured for `us-east-1`. Both share one `details` value, with short forms set for the purpose and environment and an extra `CostCenter` tag, so their `Name` tags are `example-eip-dev-usw2-nat-a` and `example-eip-dev-usw2-nat-b`.

Neither address is associated with anything. To give each NAT gateway in a VPC its own address, pass `module.eip["nat-a"].metadata.eip.allocation_id` to the gateway's `allocation_id`.

AWS charges by the hour for every public IPv4 address, including an Elastic IP address that is not associated with anything. See [Amazon VPC pricing](https://aws.amazon.com/vpc/pricing/). Destroy the example when you are done.

## Run it

```shell
terraform init
terraform apply
```

Remove it with `terraform destroy`.

<!-- BEGIN_TF_DOCS -->
### Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement_terraform) (>= 1.9)

- <a name="requirement_aws"></a> [aws](#requirement_aws) (~> 6.0)

### Outputs

The following outputs are exported:

#### <a name="output_eips"></a> [eips](#output_eips)

Description: Each Elastic IP address's public IP, allocation ID and Name tag, by target
<!-- END_TF_DOCS -->
