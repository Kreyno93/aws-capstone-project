variable "region_us_west_2" {
  type        = string
  description = "value for the region"
  default     = "us-west-2"
}

variable "aws_availability_zone_a" {
  type        = string
  description = "value for the availability zone"
  default     = "us-west-2a"
}

variable "aws_availability_zone_b" {
  type        = string
  description = "value for the availability zone"
  default     = "us-west-2b"
}

variable "aws_instance_type_t2micro" {
  type        = string
  description = "value for the instance type"
  default     = "t2.micro"
}