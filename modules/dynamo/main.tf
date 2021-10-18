resource "aws_dynamodb_table" "ddbtable" {
    name             = "item_information"
    hash_key         = "item_id"
    billing_mode   = "PROVISIONED"
    read_capacity  = 5
    write_capacity = 5
    attribute {
        name = "item_id"
        type = "S"
    }
}


# ------------------------ AWS Backup to S3 ------------------------ 
resource "aws_backup_plan" "dynamodb_backup" {
  name = "dynamodb_backup_plan"

  rule {
    rule_name         = "dynamodb_backup_rule"
    target_vault_name = "${aws_backup_vault.dynamodb_backup_vault.name}"
    schedule          = "cron(0 15 * * ? *)"
  }
}

resource "aws_backup_vault" "dynamodb_backup_vault" {
  name        = "dynamodb_backup_vault"
}

resource "aws_iam_role" "dynamodb_backup_role" {
  name               = "dynamodb_backup_role"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "dynamodb_backup_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = "${aws_iam_role.dynamodb_backup_role.name}"
}

resource "aws_backup_selection" "example" {
  iam_role_arn = "${aws_iam_role.dynamodb_backup_role.arn}"
  name         = "dynamo_db_backup_selection"
  plan_id      = "${aws_backup_plan.dynamodb_backup.id}"

  resources = [
    "${aws_dynamodb_table.ddbtable.arn}"
  ]
}