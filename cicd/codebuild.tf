resource "aws_codebuild_project" "app" {

  name         = "${var.env}-${var.project_name}-build"
  service_role = aws_iam_role.codebuild.arn

  source {
    type = "CODEPIPELINE"
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:7.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    # AWS基本
    environment_variable {
      name  = "AWS_REGION"
      value = "ap-northeast-1"
    }

    # ECR
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name  = "REPOSITORY_URI"
      value = var.REPOSITORY_URI
    }

    # Docker
    environment_variable {
      name  = "CONTAINER_NAME"
      value = "nagoyameshi"
    }

    # ECS Cluster
    environment_variable {
      name  = "ECS_CLUSTER_NAME"
      value = "${var.env}-ecs-cluster"
    }

    # Task Definition
    environment_variable {
      name  = "MIGRATION_TASK_DEFINITION"
      value = "${var.env}-laravel-task"
    }

    # ===== ECS RunTask に必要 =====
    environment_variable {
      name  = "SUBNET_ID_1"
      value = var.subnets[0]
    }

    environment_variable {
      name  = "SUBNET_ID_2"
      value = var.subnets[1]
    }

    environment_variable {
      name  = "SECURITY_GROUP_ID"
      value = var.ecs_sg_id
    }
  }
}


############
# IAM Role for CodeBuild
############
resource "aws_iam_role" "codebuild" {
  name = "${var.env}-${var.project_name}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

############
# ECR access
############
resource "aws_iam_role_policy_attachment" "codebuild_ecr" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

############
# CloudWatch Logs
############
resource "aws_iam_role_policy_attachment" "codebuild_logs" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

############
# ECS access (RunTask用)
############
resource "aws_iam_role_policy_attachment" "codebuild_ecs" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

############
# SSM access
############
resource "aws_iam_role_policy" "codebuild_ssm" {
  name = "${var.project_name}-ssm"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:PutParameter"
        ]
        Resource = "*"
      }
    ]
  })
}

############
# PassRole
############
resource "aws_iam_role_policy" "codebuild_passrole" {
  name = "${var.project_name}-passrole"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
      }
    ]
  })
}

############
# CodeConnections (GitHub接続)
############
resource "aws_iam_policy" "codeconnections" {
  name = "${var.env}-${var.project_name}-codeconnections"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codeconnections:GetConnection",
          "codeconnections:GetConnectionToken",
          "codeconnections:UseConnection"
        ]
        Resource = var.codestar_connection_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codeconnections" {
  role       = aws_iam_role.codebuild.name
  policy_arn = aws_iam_policy.codeconnections.arn
}

resource "aws_iam_role_policy" "codebuild_s3_access" {
  name = "${var.project_name}-codebuild-s3"
  role = aws_iam_role.codebuild.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::${var.env}-${var.project_name}-pipeline-artifacts/*"
      },

      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::${var.env}-${var.project_name}-pipeline-artifacts"
      }

    ]
  })
}