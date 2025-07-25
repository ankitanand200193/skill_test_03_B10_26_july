variable "region" {
  default = "ap-south-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami" {
  description = "Ubuntu 22.04 LTS AMI ID"
  default     = "ami-0f918f7e67a3323f0" # Ubuntu 22.04 (us-east-1)
}

variable "key_name" {
  description = "Name of the AWS key pair"
  default     = "AnkitAnandHeroViredB10"
}
