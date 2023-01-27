variable "namespace" {
  description = "Namespace where Terraboard is deployed"
  type        = string
  default     = "default"
}

variable "image_registry" {
  description = "Image registry, e.g. gcr.io, docker.io"
  type        = string
  default     = "docker.io"
}

variable "image_repository" {
  description = "Image to start for this pod"
  type        = string
  default     = "camptocamp/terraboard"
}

variable "image_tag" {
  description = "Image tag to use"
  type        = string
  default     = "2.2.0"
}

variable "container_name" {
  description = "Name of the Terraboard container"
  type        = string
  default     = "terraboard"
}

variable "match_labels" {
  description = "Match labels to add to the Terraboard deployment, will be merged with labels"
  type        = map(any)
  default     = {}
}

variable "labels" {
  description = "Labels to add to the Terraboard deployment"
  type        = map(any)
  default     = {}
}

variable "host" {
  description = "Public facing hostname for Terraboard"
  type        = string
  default     = "http://localhost:8080"
}

variable "config" {
  description = "Terraboard config"
  type = object({
    log = optional(object({
      level  = optional(string, "info")
      format = optional(string, "plain")
      }), {
      level  = "info"
      format = "plain"
    })
    database = object({
      host          = string
      port          = optional(number, 5432)
      user          = string
      password      = string
      name          = string
      no-sync       = optional(bool, false)
      sync-interval = optional(number, 5)
      sslmode       = optional(string, "require")
    })
    provider = optional(object({
      no-locks      = optional(bool, true)
      no-versioning = optional(bool, true)
      }), {
      no-locks      = true
      no-versioning = true
    })
    aws = list(object({
      endpoint          = optional(string)
      region            = optional(string)
      access-key        = string
      secret-access-key = string
      dynamodb-table    = optional(string)
      s3 = list(object({
        bucket           = string
        force-path-style = optional(bool, true)
        key-prefix       = optional(string)
        file-extension   = optional(list(string), [".tfstate"])
      }))
    }))
    web = optional(
      object({
        port       = optional(number, 9090)
        base-url   = optional(string)
        logout-url = optional(string)
      }),
      {
        port     = 9090
        base-url = "/"
      }
    )
  })
}

variable "service_name" {
  description = "Name of service to deploy"
  type        = string
  default     = "terraboard"
}

variable "service_type" {
  description = "Type of service to deploy"
  type        = string
  default     = "ClusterIP"
}
