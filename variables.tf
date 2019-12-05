variable "create_vpc" {
  description = "is vpc created"
  type        = bool
  default     = true
}

variable "name" {
  description = "name for all resources"
  default     = ""
}

variable "cidr" {
  description = "cidr block"
  default     = ""
}

variable "instance_tenancy" {
  description = "tenancy"
  default     = "default"
}

variable "enable_dns_hostnames" {
  description = "hostnames"
  default     = "true"
}

variable "enable_dns_support" {
  description = "dns support"
  default     = "true"
}

variable "public_subnets" {
  description = "pub sub"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "priv sub"
  type        = list(string)
  default     = []
}

variable "azs" {
  description = "availability zones"
  type        = list(string)
  default     = []
}


variable "map_public_ip_on_launch" {
  description = "map on launch"
  default     = "false"
}

variable "database_subnets" {
  description = "list of db subnets"
  type        = list(string)
  default     = []
}

variable "create_database_subnet_group" {
  description = "should database subnet groups be created"
  type        = bool
  default     = false
}

variable "create_database_nat_gateway_route" {
  description = "nat gw to give db inet access"
  type        = bool
  default     = false
}

variable "tags" {
  description = "map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_tags" {
  description = "Additional tags for the vpc"
  type        = map(string)
  default     = {}
}

variable "subnet_tags" {
  description = "Additional tags for the subnets"
  type        = map(string)
  default     = {}
}
