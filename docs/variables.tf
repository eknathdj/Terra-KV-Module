#╔═════════════════════╗
#   PROJECT VARIABLES
#╚═════════════════════╝

variable "g_location" {
  type        = string
  description = "Location where the project's resources should be deployed"
  default     = "West Europe"
}

variable "m_tags" {
  type        = map(any)
  description = "Common Tags of the project"
  default = {
    DummyTag = "DummyValue"
  }
}

variable "m_environment_tag" {
  type        = string
  description = <<-EOF
    The environment tag used while labeling provisioned resources. Allowed values:
    - `d` for development
    - `t` for test
    - `q` for qualification
    - `p` for production
    - `m` for mutualized resource
  EOF
  default     = "d"

  validation {
    condition     = contains(["d", "t", "q", "p", "m"], lower(var.m_environment_tag))
    error_message = "Unsupported environment tag specified. Supported values: 'd','t','q','p','m'."
  }
}
