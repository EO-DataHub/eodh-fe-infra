module "ecr" {
  source = "../modules/ecr"
  ecr_names = [
    "ac-api",
  ]
}
resource "aws_ecr_repository_policy" "ecrs-policy" {
  for_each   = module.ecr.ecr_repositories
  repository = each.value
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "cross_access",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::296062554912:root", //  PROD
          ]
        },
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:ListImages"
        ]
      }
    ]
  })
}