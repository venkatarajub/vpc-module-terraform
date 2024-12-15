variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "common_tags" {
    default = {
        project = "expense"
        terrafrom = true
    }
}

variable "vpc_tags" {
    default = {}

}
variable "environment" {
    default = "dev"
}

variable "project" {
    default = "expense"
}

variable "ig_tags" {
    default = {}
}

variable "public_cidrs" {
    type = list
    validation {
        condition = length(var.public_cidrs) == 2
         error_message = "Please provide the 2 valid cidrs"
    }
}

variable "public_subnet_tags" {
    default = {}
}

variable "private_cidrs" {
    type = list
    validation {
        condition = length(var.private_cidrs) == 2
         error_message = "Please provide the 2 valid cidrs"
    }
}
variable "private_subnet_tags" {
    default = {}
}

variable "database_cidrs" {
    type = list
    validation {
        condition = length(var.database_cidrs) == 2
         error_message = "Please provide the 2 valid cidrs"
    }
}
variable "database_subnet_tags" {
    default = {}
}
variable "is_peering_required" {
    type = bool
    default = false

}

variable "peer_owner_id" {
    default = "195275676275"
}
