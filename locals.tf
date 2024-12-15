locals {
  resource_name = "${var.project}-${var.environment}"
  az_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  peer_vpc_id = data.aws_vpc.default.id
}
