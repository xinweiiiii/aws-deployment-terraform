# Take down temporarily cos very costly 


# -------------------------------------- AWS WAF ------------------------------------------------------
# module "waf" {
#     source = "umotif-public/waf-webaclv2/aws"
#     version = "~> 3.1.0"

#     name_prefix = "test-waf-setup"
#     alb_arn     = var.ALB

#     scope = "REGIONAL"

#     create_alb_association = true

#     allow_default_action = true # set to allow if not specified

#     visibility_config = {
#         metric_name = "test-waf-setup-waf-main-metrics"
#     }


#     rules = [
#         {
#         name     = "AWSManagedRulesCommonRuleSet-rule-1"
#         priority = "1"

#         override_action = "none"

#         visibility_config = {
#             metric_name                = "AWSManagedRulesCommonRuleSet-metric"
#         }

#         managed_rule_group_statement = {
#             name        = "AWSManagedRulesCommonRuleSet"
#             vendor_name = "AWS"
#             excluded_rule = [
#             "SizeRestrictions_QUERYSTRING",
#             "SizeRestrictions_BODY",
#             "GenericRFI_QUERYARGUMENTS"
#             ]
#         }
#         },
#         {
#         name     = "AWSManagedRulesKnownBadInputsRuleSet-rule-2"
#         priority = "2"

#         override_action = "count"

#         visibility_config = {
#             metric_name = "AWSManagedRulesKnownBadInputsRuleSet-metric"
#         }

#         managed_rule_group_statement = {
#             name        = "AWSManagedRulesKnownBadInputsRuleSet"
#             vendor_name = "AWS"
#         }
#         },
#         {
#         name     = "AWSManagedRulesPHPRuleSet-rule-3"
#         priority = "3"

#         override_action = "none"

#         visibility_config = {
#             cloudwatch_metrics_enabled = false
#             metric_name                = "AWSManagedRulesPHPRuleSet-metric"
#             sampled_requests_enabled   = false
#         }

#         managed_rule_group_statement = {
#             name        = "AWSManagedRulesPHPRuleSet"
#             vendor_name = "AWS"
#         }
#         },
#         ### Byte Match Rule example
#         # Refer to https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#byte-match-statement
#         # for all of the options available.
#         # Additional examples available in the examples directory
#         {
#         name     = "ByteMatchRule-4"
#         priority = "4"

#         action = "count"

#         visibility_config = {
#             cloudwatch_metrics_enabled = false
#             metric_name                = "ByteMatchRule-metric"
#             sampled_requests_enabled   = false
#         }

#         byte_match_statement = {
#             field_to_match = {
#             uri_path = "{}"
#             }
#             positional_constraint = "STARTS_WITH"
#             search_string         = "/path/to/match"
#             priority              = 0
#             type                  = "NONE"
#         }
#         },
#         ### Geo Match Rule example
#         {
#         name     = "GeoMatchRule-5"
#         priority = "5"

#         action = "allow"

#         visibility_config = {
#             cloudwatch_metrics_enabled = false
#             metric_name                = "GeoMatchRule-metric"
#             sampled_requests_enabled   = false
#         }

#         geo_match_statement = {
#             country_codes = ["NL", "GB", "US"]
#         }
#         },

#         ### NOT rule example (can be applied to byte_match, geo_match, and ip_set rules)
#         {
#         name     = "NotByteMatchRule-8"
#         priority = "8"

#         action = "count"

#         visibility_config = {
#             cloudwatch_metrics_enabled = false
#             metric_name                = "NotByteMatchRule-metric"
#             sampled_requests_enabled   = false
#         }

#         not_statement = {
#             byte_match_statement = {
#             field_to_match = {
#                 uri_path = "{}"
#             }
#             positional_constraint = "STARTS_WITH"
#             search_string         = "/path/to/match"
#             priority              = 0
#             type                  = "NONE"
#             }
#         }
#     }
#   ]
# }


# -------------------------------------- AWS SHIELD ------------------------------------------------------
# resource "aws_shield_protection" "cloudfront" {
#   name         = "example"
#   resource_arn = "" ## Add Cloudfront arn
# }

# resource "aws_shield_protection" "load_balancer" {
#   name         = "example"
#   resource_arn = "var.ALB" 
# }