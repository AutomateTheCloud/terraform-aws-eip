resource "aws_eip" "this" {
  domain = "vpc"
  tags = merge(
    local.tags,
    tomap({
      "Name" = "${local.scope.abbr}-${local.purpose.abbr}-${local.environment.abbr}-${local.aws.region.abbr}${var.eip_target != "" ? "-${var.eip_target}" : ""}"
    })
  )
  provider = aws.this
}
