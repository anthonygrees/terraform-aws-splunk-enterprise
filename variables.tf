#
# Variables
#
variable "aws_profile" {
}
variable "aws_key_pair_file" {
}
variable "aws_key_pair_name" {
}
variable "splunk_password" {
}
variable "aws_region" {
}
variable "aws_availability_zone_a" {
  default = "a"
}
variable "aws_availability_zone_b" {
  default = "b"
}
///////////////////////////////
// Tags
//////////////////////////////
variable "tag_customer" {
  default = "Testing"
}

variable "tag_project" {
  default = "Testing"
}

variable "tag_name" {
  default = "Splunk"
}

variable "tag_dept" {
  default = "Testing"
}

variable "tag_contact" {
  default = "Testing"
}

variable "tag_application" {
  default = "Splunk-Ent"
}

variable "tag_ttl" {
  default = 4
}