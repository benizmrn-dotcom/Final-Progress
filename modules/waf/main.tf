resource "aws_wafv2_ip_set" "allowed_ips" {
  count = var.env == "dev" ? 1 : 0

  name               = "${var.env}-allowed-ips"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = var.allowed_ip_addresses
}

resource "aws_wafv2_web_acl" "waf" {
  name  = "${var.env}-cloudfront-waf"
  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  dynamic "rule" {
    for_each = var.env == "prod" ? [1] : []

    content {
      name     = "BlockOutsideJapan"
      priority = 0

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            geo_match_statement {
              country_codes = ["JP"]
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.env}-block-outside-japan"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = var.env == "dev" ? [1] : []

    content {
      name     = "BlockExceptAllowedIPs"
      priority = 0

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.allowed_ips[0].arn
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${var.env}-block-except-allowed-ips"
        sampled_requests_enabled   = true
      }
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.env}-cloudfront-waf"
    sampled_requests_enabled   = true
  }
}