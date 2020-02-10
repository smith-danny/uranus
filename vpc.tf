#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "kubernetes" {
  cidr_block = "12.0.0.0/16"

  tags = map(
    "Name", "Kubernetes VPC",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "kubernetes" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "12.0.${count.index}.0/24"
  vpc_id            = aws_vpc.kubernetes.id

  tags = map(
    "Name", "Kubernetes Subnet",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "kubernetes" {
  vpc_id = aws_vpc.kubernetes.id

  tags = {
    Name = "Kubernetes IGW"
  }
}

resource "aws_route_table" "kubernetes" {
  vpc_id = aws_vpc.kubernetes.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubernetes.id
  }
}

resource "aws_route_table_association" "kubernetes" {
  count = 2

  subnet_id      = aws_subnet.kubernetes.*.id[count.index]
  route_table_id = aws_route_table.kubernetes.id
}
