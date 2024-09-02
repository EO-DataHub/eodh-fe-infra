resource "aws_ecs_cluster" "cluster" {
  name = var.cluster-name
}

resource "aws_iam_instance_profile" "ecsprofile" {
  name = "ecsprofile"
  role = aws_iam_role.ecsrole.name
}
resource "aws_iam_role" "ecsrole" {
  name = "ecsrole-${var.cluster-name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }
]
}
EOF
}
resource "aws_iam_policy_attachment" "ecspolicy-attach" {
  name       = "ecspolicyattach"
  roles      = [aws_iam_role.ecsrole.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

//iam roles ecstaskexecution
resource "aws_iam_role" "ecs-task-execution-role" {
  name = "${var.env-name}-ecs-task-execution-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "ecs-tasks.amazonaws.com"
                ]
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "task-execution-attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs-task-execution-role.name
}
