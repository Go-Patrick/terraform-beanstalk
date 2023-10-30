data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.2.20231016.0-kernel-6.1-x86_64"]
  }
}