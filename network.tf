# Nacteni informaci o vychozi (defaultni) VPC v regionu eu-central-1
data "aws_vpc" "myvpc" {
  default = true
}

# Nacteni vsech podsiti (subnets), ktere k teto vychozi VPC patri
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.myvpc.id]
  }
}