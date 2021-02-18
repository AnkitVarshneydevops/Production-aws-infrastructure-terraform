#Create an PostgreSql RDS
resource "aws_db_subnet_group" "default" {
  name        = "test-subnet-group"
  description = "Terraform example RDS subnet group"
  subnet_ids  = [ aws_subnet.subnet_private-A.id, aws_subnet.subnet_private-B.id ]
}


resource "aws_db_instance" "postgresql" {
  #count = "${length(var.subnet_cidrs_private)}"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "10.13"
  instance_class       = var.db_instance_type
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  availability_zone    = var.a_z
  multi_az             = "false"
  db_subnet_group_name      = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible = "false"
  apply_immediately = "true"
  #identifier = "${var.app_name}-${var.env_type}-rds"
  skip_final_snapshot = "true"
  parameter_group_name = "default.postgres10"
  #count = var.is_db && var.db_type == "postgresql" ? 1 : 0
  
}

#Create an mySql RDS
# resource "aws_db_instance" "mysql" {
#   allocated_storage    = 20
#   storage_type         = "gp2"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = var.db_instance_type
#   name                 = var.db_name
#   username             = var.db_username
#   password             = var.db_password
#   availability_zone    = var.availability_zone
#   vpc_security_group_ids = [aws_security_group.rds_sg[count.index].id]
#   publicly_accessible = "false"
#   apply_immediately = "true"
#   identifier = "${var.app_name}-${var.env_type}-rds"
#   skip_final_snapshot = "true"
#   parameter_group_name = "default.mysql5.7"
#   count = var.is_db && var.db_type == "mysql" ? 1 : 0
# }

#Create RDS Security Group
resource "aws_security_group" "rds_sg" {
  #name = "${var.app_name}-${var.env_type}_rds_sg"
  #count = var.is_db ? 1 : 0
  #depends_on = [aws_security_group.sg_group]
  vpc_id      = "${aws_vpc.default.id}"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["180.151.15.236/32", "180.151.78.218/32", "180.151.78.220/32", "180.151.78.222/32", "111.93.242.34/32", "182.74.4.226/32"]
    #security_groups = [aws_security_group.sg_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

#   tags = {
#     Name = "${var.app_name}-${var.env_type}_rds_sg"
#   }
}

# output "RDS-Endpoint" {

#   value = aws_db_instance.default.address
# }
