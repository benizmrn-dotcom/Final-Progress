#
#CodePP
#

resource "aws_codepipeline" "app" {
  name     = "${var.env}-${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.artifacts.bucket
  }

  # --------------------
  # Source Stage
  # --------------------
  stage {
    name = "Source"

    action {
      name             = "GitHubSource"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn = var.codestar_connection_arn
        FullRepositoryId = "benizmrn-dotcom/nagoyameshi"
        BranchName       = var.branch
      }
    }
  }

  # --------------------
  # Build Stage
  # --------------------
  stage {
    name = "Build"

    action {
      name             = "CodeBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.app.name
      }
    }
  }

  # --------------------
  # Deploy Stage (ECS)
  # --------------------
  stage {
    name = "Deploy"

    action {
      name            = "ECSDeploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]

      configuration = {
        ClusterName = var.cluster_name
        ServiceName = var.service_name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

#
#S3_for_artifact
#
resource "aws_s3_bucket" "artifacts" {
bucket = "${var.env}-${var.project_name}-pipeline-artifacts"
}

#
#IAM
#
resource "aws_iam_role" "codepipeline" {
name = "${var.env}-${var.project_name}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codepipeline.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "codepipeline" {
  role = aws_iam_role.codepipeline.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      },

      {
        Effect = "Allow"
        Action = [
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ]
        Resource = "*"
      },

        {
        Effect = "Allow",
        Action = [
            "ecs:*",
            ],
        Resource = "*"
        },
        {
        Effect = "Allow"
        Action = [
            "iam:PassRole"
        ]
        Resource = "*"
        },

      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = "*"
      }
    ]
  })
}
