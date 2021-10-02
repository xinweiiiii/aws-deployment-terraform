resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "fulfiment-cron-main" # Hardcoded as lambda deploy using serverless structure
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.fulfilment_scheduler_rule.arn}"
}

resource "aws_cloudwatch_event_rule" "fulfilment_scheduler_rule" {
    name                = "fulfilment_scheduler_rule"
    description         = "schedule events for lambda"
    schedule_expression = "cron(0 0 ? * * *)"
}

resource "aws_cloudwatch_event_target" "lambda_schedular_target" {
    rule =  "${aws_cloudwatch_event_rule.fulfilment_scheduler_rule.name}"
    arn  =   "arn:aws:lambda:ap-southeast-1:972988805757:function:fulfiment-cron-main" # Hardcoded as lambda deploy using serverless
}