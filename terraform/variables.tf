variable "flow" {
  type    = string
  default = "01-2026"
}

variable "cloud_id" {
  type    = string
  default = "b1ge547o5mi21fckj2g5"
}

variable "folder_id" {
  type    = string
  default = "b1g3hnoudkl70j2fgeu2"
}

variable "CMCF" {
  type = map(number)
  default = {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }
}

# Исправленная переменная без использования другой переменной в default
variable "balancer_name" {
  type    = string
  default = "alb-fops"
}

# Параметры для разных типов ВМ
variable "vm_sizes" {
  type = map(object({
    cores  = number
    memory = number
    disk   = number
  }))
  default = {
    small = {
      cores  = 2
      memory = 2
      disk   = 10
    }
    medium = {
      cores  = 2
      memory = 2
      disk   = 10
    }
    large = {
      cores  = 2
      memory = 2
      disk   = 10
    }
  }
}