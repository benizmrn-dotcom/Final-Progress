resource "aws_db_subnet_group" "this" {
  name       = "${var.env}-${var.project_name}-db-subnet"
  subnet_ids = var.private_subnet_ids

}


resource "aws_db_instance" "this" {
  identifier = "${var.env}-${var.project_name}-rds"

  engine         = "mysql"
  engine_version = "8.0"

  instance_class = "db.t3.micro"

  allocated_storage = 20

  db_name                   = var.db_name
  username                  = var.db_username
  password                  = "password"
  vpc_security_group_ids    = [var.rds_sg_id]
  db_subnet_group_name      = aws_db_subnet_group.this.name
  multi_az                  = true
  publicly_accessible       = false
  backup_retention_period   = 0
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = true
  final_snapshot_identifier = "${var.env}-final-snapshot"
  deletion_protection       = false
}

