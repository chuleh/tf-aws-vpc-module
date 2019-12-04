locals {
  vpc_id = element(
    concat(
      aws_vpc.vpc.*.id,
    ),
    0,
  )
}

# VPC
resource "aws_vpc" "vpc" {
  count                = var.create_vpc ? 1 : 0
  cidr_block           = var.cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge({ "Name" = format("%s", var.name) }, var.tags, var.vpc_tags)
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = var.create_vpc && length(var.public_subnets) > 0 && (length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0
  vpc_id                  = local.vpc_id
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge({ "Name" = format("%s", var.name) }, var.tags, var.subnet_tags)
}

# Private subnets
resource "aws_subnet" "private" {
  count             = var.create_vpc && length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  vpc_id            = local.vpc_id
  cidr_block        = element(concat(var.private_subnets, [""]), count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge({ "Name" = format("%s", var.name) }, var.tags, var.subnet_tags)
}

# RDS Subnets
resource "aws_subnet" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 ? length(var.database_subnets) : 0

  vpc_id            = local.vpc_id
  cidr_block        = var.database_subnets[count.index]
  availability_zone = element(var.azs, count.index)
}

resource "aws_db_subnet_group" "database" {
  count = var.create_vpc && length(var.database_subnets) > 0 && var.create_database_subnet_group ? 1 : 0

  name        = lower(var.name)
  description = "Database subnet group for ${var.name}"
  subnet_ids  = aws_subnet.database.*.id
}


# Internet gateway
resource "aws_internet_gateway" "igw" {
  count  = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = local.vpc_id
}

# Public routes
resource "aws_route_table" "rt" {
  count = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = local.vpc_id
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.rt[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

# route table associations
resource "aws_route_table_association" "rt_assoc" {
  count          = var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.rt[0].id
}

# own dns
resource "aws_vpc_dhcp_options" "main" {
  domain_name = var.vpc_dns_server
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}