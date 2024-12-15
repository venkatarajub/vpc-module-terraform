resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_internet_gateway" "igmain"  {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.common_tags,
        var.ig_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_subnet" "public" {
    count = length(var.public_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_cidrs[count.index]
    availability_zone = local.az_zones[count.index]
    map_public_ip_on_launch = true
    tags = merge(
        var.common_tags,
        var.public_subnet_tags,
        {
            Name = "${local.resource_name}-public-${local.az_zones[count.index]}"
        }
    )
}

resource "aws_subnet" "private" {
    count = length(var.private_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.private_cidrs[count.index]
    availability_zone = local.az_zones[count.index]
    map_public_ip_on_launch = false
    tags = merge(
        var.common_tags,
        var.private_subnet_tags,
        {
            Name = "${local.resource_name}-private-${local.az_zones[count.index]}"
        }
    )
}

resource "aws_subnet" "database" {
    count = length(var.database_cidrs)
    vpc_id = aws_vpc.main.id
    cidr_block = var.database_cidrs[count.index]
    availability_zone = local.az_zones[count.index]
    map_public_ip_on_launch = true
    tags = merge(
        var.common_tags,
        var.database_subnet_tags,
        {
            Name = "${local.resource_name}-database-${local.az_zones[count.index]}"
        }
    )
}

resource "aws_db_subnet_group" "database" {
    name = local.resource_name
    subnet_ids = aws_subnet.database[*].id
    tags =  merge(
        var.common_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_eip" "my_eip" {
    domain = "vpc"
    tags = merge(
        var.common_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_nat_gateway" "natmain" {
    allocation_id = aws_eip.my_eip.id
    subnet_id = aws_subnet.public[0].id
    tags = merge(
        var.common_tags,
        {
            Name = local.resource_name
        }
    )
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-public"
        }
    )
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-private"
        }
    )
}

resource "aws_route_table" "database" {
    vpc_id = aws_vpc.main.id
    tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-database"
        }
    )
}

resource "aws_route" "public" {
    route_table_id  = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igmain.id
}

resource "aws_route" "private" {
    route_table_id  = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natmain.id
}

resource "aws_route" "database" {
    route_table_id  = aws_route_table.database.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natmain.id
}

resource "aws_route_table_association" "public" {
    count = length(var.public_cidrs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
    count = length(var.private_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
    count = length(var.database_cidrs)
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database.id
}