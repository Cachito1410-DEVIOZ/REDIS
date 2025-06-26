##Private module variables
locals {
  map_locations_code = { ##Mapping for location
    eu2 = "eastus2"
    cu1 = "centralus"
  }

  redi_code              = "redi"
  pvep_code              = "pvep"
  vnet_code              = "vnet"
  snet_code              = "snet"
  rsgr_code              = "rsgr"
  infra_environment_code = "f"
  snet_objetivo          = "rdi"

  # Estructura que contiene los parámetros para crear el redis.
  map_redi_params = {
    for region in [var.location_code] :
    local.map_locations_code[lower(region)] => {
      redi_name               = format("%s%s%s%s%s", lower(local.redi_code), lower(region), lower(var.globals.app_code), lower(var.globals.env_code), var.resource_sequential),
      pvep_name               = format("%s%s%s%s%s", lower(local.pvep_code), lower(region), lower(var.globals.app_code), lower(var.globals.env_code), var.resource_sequential)
      rsgr_name               = format("%s%s%s%s%s", upper(local.rsgr_code), upper(region), upper(var.globals.app_code), upper(var.globals.env_code), var.globals.rsgr_sequential),
      vnet_name               = format("%s%s%s%s%s", lower(local.vnet_code), lower(region), lower(var.globals.app_code), lower(var.globals.env_code), var.globals.rsgr_sequential),
      snet_name               = format("%s%s%s%s%s%s", lower(local.snet_code), lower(region), lower(var.globals.app_code), lower(local.snet_objetivo), lower(var.globals.env_code), var.resource_sequential),
      resource_group_name_env = length(var.redi_vnet_rg_name) == 0 ? upper(format("%s%s%s%s%s", local.rsgr_code, region, var.globals.app_code, var.globals.env_code, var.globals.rsgr_sequential)) : upper(var.redi_vnet_rg_name[local.map_locations_code[lower(region)]])
      redi_existing_subnet_id = var.redi_subnet_id
      redi_pve_ip_static      = local.pve_ip_static_required ? var.redi_pve_ip_static : null
    }
  }

  # Estructura que contiene los nombres de las reglas del firewall.
  map_redi_firewall_rules_name = {
    for region in [var.location_code] :
    local.map_locations_code[region] => formatlist("%s%d", "BCP_RULE_0", range(1, length(local.redi_start_ip_restriction) + 1))
  }

  # Estructura que contiene las ips de las reglas del firewall.
  map_redi_firewall_start_ips = {
    for region in [var.location_code] :
    local.map_locations_code[region] => local.redi_start_ip_restriction
  }

  map_redi_firewall_end_ips = {
    for region in [var.location_code] :
    local.map_locations_code[region] => local.redi_end_ip_restriction
  }

  redi_name_rules = flatten([for region, names in local.map_redi_firewall_rules_name : [for name in names : { location = region, name = name }]])
  redi_start_ip   = flatten([for region, ips in local.map_redi_firewall_start_ips : [for ip in ips : { location = region, ip = ip }]])
  redi_end_ip     = flatten([for region, ips in local.map_redi_firewall_end_ips : [for ip in ips : { location = region, ip = ip }]])

  redi_assosiation_ip_name = {
    for index in range(length(local.redi_name_rules)) : format("%s-%s", local.redi_name_rules[index].name, local.redi_name_rules[index].location) => {
      name_rule = local.redi_name_rules[index].name,
      start_ip  = local.redi_start_ip[index].ip,
      end_ip    = local.redi_end_ip[index].ip,
      location  = local.redi_name_rules[index].location
    }
  }
  ##flatten([for region, names in local.map_redi_firewall_rules_name : [for region, ips in local.map_redi_firewall_rules_ips : [for name in names : [for ip in ips : {location=region, name=name, ip=ip}]]]])

  #VNET Injection flags
  is_vnet_injection = var.enable_vnet_injection ? true : false

  #Private endpoint flags
  is_private_endpoint    = var.enable_private_endpoint ? true : false
  pve_ip_static_required = var.redi_pve_ip_static != null ? true : false

  #Habilitación de acceso público
  public_network_access_enabled = (var.redi_perfil == "Internet" || (var.redi_perfil == "Intranet" && var.enable_vnet_injection)) ? true : false

  #Default LBS REDI
  redi_enable_non_ssl_port = false
  redi_minimum_tls_version = "1.2"
  redi_ip_aks_egress       = var.redi_ip_aks_egress


  ips_bcp_datacenter_start = ["200.4.200.130", "200.37.27.130", "216.244.162.194", "216.244.165.194", "45.178.199.21", "45.178.199.22", "45.178.197.37", "45.178.197.38"]
  ips_daas_start           = ["40.67.155.109", "20.36.220.196"]
  ips_devsecops_start      = ["20.49.0.185"]
  ips_iaac_start           = ["20.186.114.165"]
  ips_proxy_start          = ["8.36.116.0", "8.39.144.0", "31.186.239.0", "45.250.160.0", "162.10.0.0", "163.116.128.0"]
  ips_pivots_db_start      = ["20.242.120.247", "20.49.14.17"]

  ips_bcp_datacenter_end = ["200.4.200.130", "200.37.27.130", "216.244.162.194", "216.244.165.194", "45.178.199.21", "45.178.199.22", "45.178.197.37", "45.178.197.38"]
  ips_daas_end           = ["40.67.155.109", "20.36.220.196"]
  ips_devsecops_end      = ["20.49.0.185"]
  ips_iaac_end           = ["20.186.114.165"]
  ips_proxy_end          = ["8.36.116.254", "8.39.144.254", "31.186.239.254", "45.250.163.254", "162.10.127.254", "163.116.255.254"]
  ips_pivots_db_end      = ["20.242.120.247", "20.49.14.17"]


  redi_start_ip_restriction = concat(local.ips_bcp_datacenter_start, local.ips_daas_start, local.ips_devsecops_start, local.ips_iaac_start, local.ips_proxy_start, local.ips_pivots_db_start)
  redi_end_ip_restriction   = concat(local.ips_bcp_datacenter_end, local.ips_daas_end, local.ips_devsecops_end, local.ips_iaac_end, local.ips_proxy_end, local.ips_pivots_db_end)
  ##

  ##Tags
  tags = {
    provisionedBy = upper(var.globals.provisioned_by)
    codApp        = upper(var.globals.app_code)
    environment   = upper(var.globals.env_name)
    lbsVersion    = "1.4"
    moduleVersion = "5.1.0"
  }

  # La configuracion de zonas solo aplica para SKU de tipo premium, ya no depende del entorno (https://confluence.devsecopsbcp.com/display/ADT/LET_REDI_001)
  availability_zones = (
    (var.redi_sku_name != "Premium") ? [] :
    (var.redi_sku_name == "Premium" && length(var.availability_zones) == 0) ? ["1", "2", "3"] : var.availability_zones
  )

  #Default version
  redi_version = "6"

}
