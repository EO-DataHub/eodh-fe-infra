resource "aws_ecr_repository" "ecrs" {
  for_each             = toset(var.ecr_names)
  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = false
  }
}
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle" {
  for_each   = toset(var.ecr_names)
  repository = aws_ecr_repository.ecrs[each.key].name
  policy     = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "keep last 3 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
