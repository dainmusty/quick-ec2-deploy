# This security group is used for public instances, such as EC2 instances in public subnets or load balancers.
resource "aws_security_group" "public_sg" {
  vpc_id = var.vpc_id
  tags   = { Name = "${var.ResourcePrefix}-public-sg" }

  dynamic "ingress" {
    for_each = var.public_sg_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = lookup(ingress.value, "description", null)

      cidr_blocks   = lookup(ingress.value, "cidr_blocks", [])
      security_groups = lookup(ingress.value, "sg_ids", [])
    }
  }

  dynamic "egress" {
    for_each = var.public_sg_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      description = lookup(egress.value, "description", null)

      cidr_blocks   = lookup(egress.value, "cidr_blocks", [])
      security_groups = lookup(egress.value, "sg_ids", [])
    }
  }
}

# This security group is used for private instances, such as EC2 instances in private subnets or EKS node groups.
resource "aws_security_group" "private_sg" {
  vpc_id = var.vpc_id
  tags   = { Name = "${var.ResourcePrefix}-private-sg" }

  dynamic "ingress" {
    for_each = var.private_sg_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      description = lookup(ingress.value, "description", null)

      cidr_blocks   = lookup(ingress.value, "cidr_blocks", [])
      security_groups = lookup(ingress.value, "sg_ids", [])
    }
  }

  dynamic "egress" {
    for_each = var.private_sg_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      description = lookup(egress.value, "description", null)

      cidr_blocks   = lookup(egress.value, "cidr_blocks", [])
      security_groups = lookup(egress.value, "sg_ids", [])
    }
  }
}

