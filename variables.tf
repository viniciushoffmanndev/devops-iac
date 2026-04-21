# Variáveis de configuração (Podem manter o default, são seguras)
variable "region" {
  description = "Região padrão do GCP"
  type        = string
  default     = "us-central1"
}

variable "suffix" {
  description = "Sufixo único para evitar conflito de project_id"
  type        = string
  default     = "002"
}

# Variáveis sensíveis/específicas (Remova o default)
variable "billing_account" {
  description = "ID da conta de faturamento - Deve ser definido no tfvars"
  type        = string
}

variable "organization_id" {
  description = "ID da organização - Deve ser definido no tfvars"
  type        = string
}

variable "password"{
  description = "Senha do usuário do Google Workspace - Deve ser definido no tfvars"
  type = string
  sensitive = true # Marca a variável como sensível para evitar exposição acidental
}