resource "aws_vpc" "default" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public" {
  count = "${length(var.subnet_cidrs_public)}"

  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.subnet_cidrs_public[count.index]}"
  availability_zone = "${var.availability_zones[count.index]}"

  tags = {
    Name = "${var.public_subnet_tags[count.index]}"
  }
}

# resource "aws_subnet" "private" {
#   count = "${length(var.subnet_cidrs_private)}"

#   vpc_id = "${aws_vpc.default.id}"
#   cidr_block = "${var.subnet_cidrs_private[count.index]}"
#   availability_zone = "${var.availability_zones[count.index]}"

#   tags = {
#     Name = "${var.private_subnet_tags[count.index]}"
#   }
# }

resource "aws_subnet" "subnet_private-A" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.3.0/24"
  #map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private-A"
  }
}

resource "aws_subnet" "subnet_private-B" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "10.0.4.0/24"
  #map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private-B"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "VPC IGW"
  }
}

resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
    
  } 

  tags = {
    Name = "Public Subnet RT"
  }
}

resource "aws_route_table_association" "web-public-rt" {
  count = "${length(var.subnet_cidrs_public)}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.web-public-rt.id}"

}

resource "aws_route_table" "web-private-rt" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "Private Subnet RT"
  }
}

resource "aws_route_table_association" "web-private-rt" {

  subnet_id      = aws_subnet.subnet_private-A.id
  route_table_id = "${aws_route_table.web-private-rt.id}"

}

resource "aws_route_table_association" "rta_subnet_public" {
  subnet_id      = "${aws_subnet.subnet_private-B.id}"
  route_table_id = "${aws_route_table.web-private-rt.id}"
}