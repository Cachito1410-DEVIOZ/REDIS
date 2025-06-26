##Public Global variables
variable "globals" {
  description = "Variables globales estaticas: app_code, env_name, env_code, provisioned_by y rsgr_sequential. Valor permitido: module.app.globals"
  type = object({
    app_code        = string
    env_name        = string
    env_code        = string
    provisioned_by  = string
    rsgr_sequential = string
  })

  validation {
    condition     = length(var.globals.app_code) == 4
    error_message = "Application Code must be a 4 letters string."
  }
  validation {
    condition     = contains(["tfe", "tfc"], var.globals.provisioned_by)
    error_message = "Variables provisioned_by permited values are jenkins & tfe."
  }
}

variable "location_code" {
  description = "Lista que especifica los códigos de las regiones del recurso. Ejemplos: eu2 o cu1 "
  type        = string
}

variable "resource_sequential" {
  description = "Especifica el correlativo del recurso a desplegar por el modulo."
  type        = string
}

variable "tags" {
  description = "Mapa que especifica los tags personalizado del recurso. Ejemplo: {tag01=\"valor01\"}"
  type        = map(any)
  default     = {}
}

##Public REDI module variables
variable "redi_sku_name" { # Standard | Premium
  description = "Especifica el flavor SKU con el que se desplegarar redis caché. Ejemplo: Standard | Premium"
  type        = string

  validation {
    condition     = contains(["Standard", "Premium"], var.redi_sku_name)
    error_message = "Variables provisioned_by permited values are Standard and Premium."
  }

}

variable "redi_perfil" { # Internet | Intranet
  description = "Especifica el perfil que tendrá el redis caché. Ejemplo: Internet | Intranet"
  type        = string

  validation {
    condition     = contains(["Internet", "Intranet"], var.redi_perfil)
    error_message = "Variables redi_perfil permited values are Internet and Intranet."
  }
}

variable "redi_subnet_id" { # 
  description = "Especifica el id de una subnet existente para usarse como subnet del redis caché. Ver README."
  type        = string
  default     = ""
}

variable "redi_ip_aks_egress" { # Ip egress de AKS el cual será añadido en el whitelist del redis.
  description = "Especifica la ip del egress del AKS el cual será añadido al whitelist del redis caché.Valor permitido: module.aksv_kubernetes.egress_ip "
  type        = map(any)
  default     = {}
}

variable "redi_family" { # Precios que se utilizara.
  description = "Especifica el grupo de precios que se utilizará. Los valores válidos son: C | P. Ver README."
  type        = string

  validation {
    condition     = contains(["C", "P"], var.redi_family)
    error_message = "Permited values are C, P."
  }
}

variable "redi_capacity" {
  description = "Especifica el tamaño de la caché de redis para implementar. Ejemplo:  1 | 2 | 3 | 4 | 5. Ver README."
  type        = string
  validation {
    condition     = contains(["0", "1", "2", "3", "4", "5", "6"], var.redi_capacity)
    error_message = "Permited values are 0 | 1 | 2 | 3 | 4 | 5 | 6."
  }
}

variable "redi_shard_count" {
  description = "Especifica la cantidad de shards"
  type        = number
  default     = null
}

variable "redi_vnet_rg_name" {
  description = "Resource group de la vnet de ambiente"
  type        = map(string)
  default     = {}
}

variable "redi_lgan_segu_id" {
  description = "Id de los log analitycs de seguridad. Valor permitido: module.infr_env.lgan_segu_ids "
  type        = map(any)
}

variable "availability_zones" {
  description = "Lista que especifica  las zonas de disponibilidad. Ejemplo: [\"1\", \"2\", \"3\"]"
  type        = list(string)
  default     = []
}

variable "schedule_updates" {
  description = "Lista de mapas con los días y hora para la actualización programada. Ver README."
  type        = list(map(any))
  default = [
    {
      "day"  = "Sunday"
      "hour" = 5
    },
    {
      "day"  = "Saturday"
      "hour" = 5
    }
  ]
}

variable "enable_private_endpoint" { # Habilitación de private endpoint.
  description = "Habilitar conexión por Private endpoint. Default: false "
  type        = bool
  default     = false
}

variable "enable_vnet_injection" { # Habilitación de VNET injection. Solo se puede habilitar en SKU Premium.
  description = "Habilitar VNET Injection. Default: false "
  type        = bool
  default     = false
}

variable "redi_pve_ip_static" {
  description = "Especifica el ip estático asignado para el private-endpoint. Ver Readme"
  type        = string
  default     = null
}

