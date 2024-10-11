variable "environment" {}

variable "windows_ad_domain_name" {}

variable "users_dn" {}

variable "domain_admins_dn" {}

# Groups
variable "group_basename" {
  default = "Test Group"
}

variable "sam_account_name" {
  default = "TESTGROUP"
}

variable "scope" {
  default = "global"
}

variable "category" {
  default = "security"
}

# GPO
variable "gpo_name" {
  default = "Test GPO"
}

# Users
variable "user_basename" {
  default = "Test User"
}

variable "initial_password" {
  default = "SuperSecure1234!!"
}
