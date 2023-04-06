terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">= 3.29.0"
    }
    local = {
      source = "hashicorp/local"
    }
  }
  required_version = ">= 1.1.0"
}

locals {
  cloudflare_account_id = var.cloudflare_account_id
  api_token = var.api_token
  zone_id = var.zone_id
  domain = var.domain
}

provider "cloudflare" {
  api_token = local.api_token
}

resource "cloudflare_teams_account" "vincentchuck" {
  account_id = local.cloudflare_account_id

  block_page {
    enabled          = true
    name             = "vincentchuck"
    header_text      = "This website is blocked"
    footer_text      = "Blocked by Cloudflare team settings"
    logo_path        = "https://example.com/logo.png"
    background_color = "#e8e8e8"
  }

  antivirus {
    enabled_download_phase = true
    enabled_upload_phase   = false
    fail_closed            = false
  }

  proxy {
    tcp = true
    udp = true
  }

  logging {
    redact_pii = true
    settings_by_rule_type {
      dns {
        log_all    = true
        log_blocks = false
      }
      http {
        log_all    = true
        log_blocks = false
      }
      l4 {
        log_all    = true
        log_blocks = false
      }
    }
  }

  activity_log_enabled = true
  tls_decrypt_enabled  = false

}

resource "cloudflare_teams_rule" "block_malware" {
  account_id = local.cloudflare_account_id

  name        = "Block malware"
  description = "Block known threats based on Cloudflare’s threat intelligence"

  enabled    = true
  precedence = 10

  # Block all security risks
  filters = ["dns"]
  traffic = "any(dns.security_category[*] in {178 80 83 176 175 117 131 134 151 153 68})"
  action  = "block"

  rule_settings {
    block_page_enabled = true
  }
}
