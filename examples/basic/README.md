# Basic Elastic IP address

One Elastic IP address in `us-east-1`, associated with nothing. The output shows the address and its allocation ID, which you pass to whatever you attach it to later: an `aws_eip_association`, an `aws_nat_gateway`, or a Network Load Balancer's subnet mapping.

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

#### <a name="output_eip"></a> [eip](#output_eip)

Description: The Elastic IP address and its allocation ID
<!-- END_TF_DOCS -->
