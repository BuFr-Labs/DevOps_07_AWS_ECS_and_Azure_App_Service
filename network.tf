# Načtení informací o výchozí (defaultní) VPC v regionu eu-central-1
data "aws_vpc" "myvpc" {
  default = true
}

# Načtení všech podsítí (subnets), které k této výchozí VPC patří
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.myvpc.id]
  }
}