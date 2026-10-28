
# ==========================================
# 1. VPC
# ==========================================

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "product-catalog-vpc"
  }
}

# ==========================================
# 2. PUBLIC SUBNETS
# ==========================================

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "product-catalog-public-1"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "product-catalog-public-2"
    "kubernetes.io/role/elb" = "1"
  }
}

# ==========================================
# 3. PRIVATE SUBNETS
# ==========================================

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "ap-southeast-2a"

  tags = {
    Name                              = "product-catalog-private-1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "ap-southeast-2b"

  tags = {
    Name                              = "product-catalog-private-2"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# ==========================================
# 4. INTERNET GATEWAY
# ==========================================

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "product-catalog-igw"
  }
}

# ==========================================
# 5. ELASTIC IP FOR NAT
# ==========================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "product-catalog-nat-eip"
  }
}

# ==========================================
# 6. NAT GATEWAY
# ==========================================

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "product-catalog-nat"
  }
}

# ==========================================
# 7. PUBLIC ROUTE TABLE
# ==========================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "product-catalog-public-rt"
  }
}

# ==========================================
# 8. PRIVATE ROUTE TABLE
# ==========================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "product-catalog-private-rt"
  }
}

# ==========================================
# 9. PUBLIC SUBNET ASSOCIATIONS
# ==========================================

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# ==========================================
# 10. PRIVATE SUBNET ASSOCIATIONS
# ==========================================

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}
