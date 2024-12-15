resource "aws_vpc_peering_connection" "peering" {
    count = var.is_peering_required ? 1 : 0
    peer_owner_id = var.peer_owner_id
    peer_vpc_id = local.peer_vpc_id
    vpc_id = aws_vpc.main.id
    auto_accept   = true
    tags = merge(
        var.common_tags,
        {
            Name = "${local.resource_name}-peering"
        }
    )
}

resource "aws_route" "public-default" {
    count = var.is_peering_required ? 1 : 0
    route_table_id  = aws_route_table.public.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "private-default" {
    count = var.is_peering_required ? 1 : 0
    route_table_id  = aws_route_table.private.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "database-default" {
    count = var.is_peering_required ? 1 : 0
    route_table_id  = aws_route_table.database.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}

resource "aws_route" "default" {
    count = var.is_peering_required ? 1 : 0
    route_table_id  = data.aws_route_table.main.id
    destination_cidr_block = var.vpc_cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peering[count.index].id
}