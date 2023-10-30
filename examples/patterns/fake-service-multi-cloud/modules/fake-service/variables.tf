variable "name" {
  description = "service name"
  type        = string  
}

variable "upstream_uris" {
  description = "service upstream uris"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
}