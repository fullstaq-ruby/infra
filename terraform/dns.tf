resource "azurerm_dns_zone" "website" {
  name                = var.dns_name
  resource_group_name = "fullstaq-ruby-infra-maintainers"
}


resource "azurerm_dns_a_record" "website_gh_pages" {
  name                = "@"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153"
  ]
  ttl = 86400
}

resource "azurerm_dns_aaaa_record" "website_gh_pages" {
  name                = "@"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  records = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153"
  ]
  ttl = 86400
}

resource "azurerm_dns_cname_record" "website_gh_pages_www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  record              = azurerm_dns_zone.website.name
  ttl                 = 86400
}

resource "azurerm_dns_txt_record" "website_verification" {
  name                = "@"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  ttl                 = 86400
  record {
    value = "google-site-verification=usrLESAOrudLzVFrFcTxPGqMikectAoaWT8aJe0cLFc"
  }
  record {
    value = var.entra_id_domain_validation_value
  }
}

resource "azurerm_dns_txt_record" "website_dmarc" {
  name                = "_dmarc"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  ttl                 = 86400
  record {
    value = "\"v=DMARC1;\" \"p=none;\""
  }
}


resource "azurerm_dns_a_record" "backend" {
  name                = "backend"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  records             = [var.backend_server_ipv4]
  ttl                 = 86400
}

resource "azurerm_dns_aaaa_record" "backend" {
  name                = "backend"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  records             = [var.backend_server_ipv6]
  ttl                 = 86400
}


resource "azurerm_dns_zone" "apt" {
  name                = "apt.${var.dns_name}"
  resource_group_name = "fullstaq-ruby-infra-maintainers"
}

resource "azurerm_role_assignment" "caddy-update-dns-apt" {
  scope                = azurerm_dns_zone.apt.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.caddy.object_id
}

resource "azurerm_dns_ns_record" "apt" {
  name                = "apt"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  ttl                 = 86400
  records             = azurerm_dns_zone.apt.name_servers
}

resource "azurerm_dns_a_record" "apt" {
  name                = "@"
  zone_name           = azurerm_dns_zone.apt.name
  resource_group_name = azurerm_dns_zone.apt.resource_group_name
  records             = [var.backend_server_ipv4]
  ttl                 = 86400
}

resource "azurerm_dns_aaaa_record" "apt" {
  name                = "@"
  zone_name           = azurerm_dns_zone.apt.name
  resource_group_name = azurerm_dns_zone.apt.resource_group_name
  records             = [var.backend_server_ipv6]
  ttl                 = 86400
}


resource "azurerm_dns_zone" "yum" {
  name                = "yum.${var.dns_name}"
  resource_group_name = "fullstaq-ruby-infra-maintainers"
}

resource "azurerm_role_assignment" "caddy-update-dns-yum" {
  scope                = azurerm_dns_zone.yum.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.caddy.object_id
}

resource "azurerm_dns_ns_record" "yum" {
  name                = "yum"
  zone_name           = azurerm_dns_zone.website.name
  resource_group_name = azurerm_dns_zone.website.resource_group_name
  ttl                 = 86400
  records             = azurerm_dns_zone.yum.name_servers
}

resource "azurerm_dns_a_record" "yum" {
  name                = "@"
  zone_name           = azurerm_dns_zone.yum.name
  resource_group_name = azurerm_dns_zone.yum.resource_group_name
  records             = [var.backend_server_ipv4]
  ttl                 = 86400
}

resource "azurerm_dns_aaaa_record" "yum" {
  name                = "@"
  zone_name           = azurerm_dns_zone.yum.name
  resource_group_name = azurerm_dns_zone.yum.resource_group_name
  records             = [var.backend_server_ipv6]
  ttl                 = 86400
}
