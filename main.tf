#######################################
# VARIABLES
#######################################

variable "region" {
  
}

variable "billing_account" {

}

variable "organization_id" {

}

variable "suffix" {
  
}

#######################################
# LOCALS (PADRÃO DE NOMES CONFORME DIAGRAMA)
#######################################

locals {
  prefix = "pais"

  projects = {
    # Comercial -> Mobile
    mobile_dev = {
      name = "${local.prefix}-comercial-mobile-dev"
      folder_key = "mobile"
    }
    mobile_prod = {
      name = "${local.prefix}-comercial-mobile-prod"
      folder_key = "mobile"
    }

    # Comercial -> ERP
    erp_dev = {
      name = "${local.prefix}-comercial-erp-dev"
      folder_key = "erp"
    }
    erp_prod = {
      name = "${local.prefix}-comercial-erp-prod"
      folder_key = "erp"
    }

    # Financeira -> Sales
    sales_dev = {
      name = "${local.prefix}-financeira-sales-dev"
      folder_key = "sales"
    }
    sales_prod = {
      name = "${local.prefix}-financeira-sales-prod"
      folder_key = "sales"
    }

    # Projeto de IaC (Mantido conforme código original, fora do diagrama principal)
    devops_iac = {
      name = "${local.prefix}-devops-iac"
      folder_key = "devops"
    }
  }

  apis = [
    "compute.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}

#######################################
# PROVIDER
#######################################

provider "google" {
  project = "${local.prefix}-devops-iac-${var.suffix}"
  region  = var.region
  user_project_override = true
}

#######################################
# FOLDERS (ESTRUTURA HIERÁRQUICA)
#######################################

# Nível 1: Root (pais)
resource "google_folder" "root" {
  display_name = local.prefix
  parent       = "organizations/${var.organization_id}"
  
}

# Nível 2: Departamentos
resource "google_folder" "comercial" {
  display_name = "comercial"
  parent       = google_folder.root.name
  
}

resource "google_folder" "financeira" {
  display_name = "financeira"
  parent       = google_folder.root.name
  
}

resource "google_folder" "devops" {
  display_name = "devops"
  parent       = google_folder.root.name
  
}

# Nível 3: Times/Produtos
resource "google_folder" "mobile" {
  display_name = "mobile"
  parent       = google_folder.comercial.name
  
}

resource "google_folder" "erp" {
  display_name = "ERP"
  parent       = google_folder.comercial.name
  
}

resource "google_folder" "sales" {
  display_name = "sales"
  parent       = google_folder.financeira.name
  
}

#######################################
# PROJECTS (DINÂMICO)
#######################################

locals {
  # Mapeamento para facilitar a atribuição da pasta
  folder_map = {
    "mobile"  = google_folder.mobile.name
    "erp"     = google_folder.erp.name
    "sales"   = google_folder.sales.name
    "devops"  = google_folder.devops.name
  }
}

resource "google_project" "projects" {
  for_each = local.projects

  name            = each.value.name
  project_id      = "${each.value.name}-${var.suffix}"
  billing_account = var.billing_account
  folder_id       = local.folder_map[each.value.folder_key]
  
  
}

#######################################
# ENABLE APIs
#######################################

resource "google_project_service" "apis" {
  for_each = {
    for pair in setproduct(
      [for p in google_project.projects : p.project_id],
      local.apis
    ) :
    "${pair[0]}-${pair[1]}" => {
      project = pair[0]
      service = pair[1]
    }
  }

  project = each.value.project
  service = each.value.service
}