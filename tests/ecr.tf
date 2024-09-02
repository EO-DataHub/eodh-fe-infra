module "ecr" {
  source = "../modules/ecr"
  ecr_names = [
    "ac-api",
  ]
}
