resource "aws_ecs_cluster" "this" {
  name = "${var.env}-ecs-cluster"
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.env}-laravel-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

container_definitions = jsonencode([
  {
    name  = "nagoyameshi"
    image = var.app_image

    portMappings = [
      {
        containerPort = 80
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/myapp"
        awslogs-region        = "ap-northeast-1"
        awslogs-stream-prefix = "ecs"
      }
    }

environment = [
  # App
  {
    name  = "APP_NAME"
    value = "Laravel"
  },
  {
    name  = "APP_ENV"
    value = "production"
  },
  {
    name  = "APP_DEBUG"
    value = "false"
  },
  {
    name  = "APP_URL"
    value = var.app_url
  },

  # Log
  {
    name  = "LOG_CHANNEL"
    value = "stack"
  },
  {
    name  = "LOG_LEVEL"
    value = "debug"
  },

  # Database
  {
    name  = "DB_CONNECTION"
    value = "mysql"
  },
  {
    name  = "DB_PORT"
    value = "3306"
  },
  {
    name  = "DB_DATABASE"
    value = var.db_database
  },

  # Session / Queue / Cache
  {
    name  = "CACHE_DRIVER"
    value = "file"
  },
  {
    name  = "SESSION_DRIVER"
    value = "file"
  },
  {
    name  = "SESSION_DOMAIN"
    value = "benizmrnuehara.com"
  },
  {
    name  = "SESSION_SECURE_COOKIE"
    value = "true"
  },
  {
    name  = "SESSION_SAME_SITE"
    value = "lax"
  },
  {
    name  = "QUEUE_CONNECTION"
    value = "sync"
  },

  # Mail
  {
    name  = "MAIL_MAILER"
    value = "smtp"
  },
  {
    name  = "MAIL_HOST"
    value = "email-smtp.ap-northeast-1.amazonaws.com"
  },
  {
    name  = "MAIL_PORT"
    value = "587"
  },
  {
    name  = "MAIL_ENCRYPTION"
    value = "tls"
  },
  {
    name  = "MAIL_FROM_NAME"
    value = "Laravel"
  },

  # Proxy / HTTPS
  {
    name  = "TRUSTED_PROXIES"
    value = "*"
  },
  {
    name  = "TRUSTED_HOSTS"
    value = "benizmrnuehara.com"
  },
  {
    name  = "HTTPS"
    value = "on"
  },
  {
    name  = "SERVER_PORT"
    value = "443"
  },
  {
  name  = "LOG_CHANNEL"
  value = "stderr"
},
{
  name  = "LOG_LEVEL"
  value = "debug"
}
]

    secrets = [
      {
        name      = "DB_HOST"
        valueFrom = "/myapp/${var.env}/DB_HOST"
      },
      {
        name      = "DB_USERNAME"
        valueFrom = "/myapp/${var.env}/DB_USERNAME"
      },
      {
        name      = "DB_PASSWORD"
        valueFrom = "/myapp/${var.env}/DB_PASSWORD"
      },
      {
        name      = "APP_KEY"
        valueFrom = "/myapp/${var.env}/app_key"
      },
      {
        name      = "MAIL_USERNAME"
        valueFrom = "/myapp/${var.env}/MAIL_USERNAME"
      },
      {
        name      = "MAIL_PASSWORD"
        valueFrom = "/myapp/${var.env}/MAIL_PASSWORD"
      },
      {
        name      = "MAIL_FROM_ADDRESS"
        valueFrom = "/myapp/${var.env}/MAIL_FROM_ADDRESS"
      },
      {
        name      = "STRIPE_KEY"
        valueFrom = "myapp/${var.env}/STRIPE_KEY"
      },
            {
        name      = "STRIPE_SECRET"
        valueFrom = "myapp/${var.env}/STRIPE_SECRET"
      }
    ]
  }
])
}


resource "aws_ecs_service" "this" {
  name            = "myapp-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = var.desired_count
  enable_execute_command = true
  deployment_controller {
    type = "ECS"
  }
  network_configuration {
    subnets         = var.private_subnet_ids
    assign_public_ip = false
    security_groups = var.ecs_security_groups
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nagoyameshi"
    container_port   = 80
  }
    force_new_deployment = true
   enable_ecs_managed_tags = true
}

resource "aws_appautoscaling_target" "ecs" {
  min_capacity       = 1
  max_capacity       = 4

  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}
resource "aws_appautoscaling_policy" "ecs_cpu" {
  name               = "${var.env}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"

  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}