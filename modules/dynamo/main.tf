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
