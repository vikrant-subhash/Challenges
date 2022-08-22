data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.env_code
  }
}

#Creation of 2 Public Subnets --> Presentation Tier in 3 Tier Architecture

resource "aws_subnet" "public" {
  count = length(var.public_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env_code}-public-${count.index}"
  }
}

#Creation of 2 Private Subnets --> Application Tier in 3 Tier Architecture

resource "aws_subnet" "private" {
  count = length(var.private_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env_code}-private-${count.index}"
  }
}

#Creation of 2 Private Subnets for Database --> Data  Tier in 3 Tier Architecture

resource "aws_subnet" "privatedb" {
  count = length(var.privatedb_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.privatedb_cidr[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.env_code}-privatedb-${count.index}"
  }
}


# One internet gateway to route the traffic to the Internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.env_code
  }
}

# Two elastic IP's for Nat gateways

resource "aws_eip" "nat" {
  count = length(var.private_cidr)

  vpc = true
  tags = {
    Name = "${var.env_code}-nat-${count.index}"
  }
}

#Two Nat gateways for Private Subnets to go to internet for patches and updates
resource "aws_nat_gateway" "main" {
  count         = length(var.public_cidr)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.env_code}-${count.index}"
  }
}

#One Internet gateway route tables

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}

# Two route tables 
resource "aws_route_table" "private" {
  count  = length(var.private_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private-${count.index}"
  }
}



resource "aws_route_table" "privatedb" {
  count  = length(var.privatedb_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.env_code}-privatedb-${count.index}"
  }
}

#Route table associtation between internet gateways and Public subnets

resource "aws_route_table_association" "public" {
  count          = length(var.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#Route table associtation between Nat gateways and Private subnets of Application Tier

resource "aws_route_table_association" "private" {
  count          = length(var.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#Route table associtation between Nat gateways and Private subnets of Data tier

resource "aws_route_table_association" "privatedb" {
  count          = length(var.privatedb_cidr)
  subnet_id      = aws_subnet.privatedb[count.index].id
  route_table_id = aws_route_table.privatedb[count.index].id
}

