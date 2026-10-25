locals {
  # Extract IP without CIDR for use in configurations
  lan_gateway_ip = split("/", var.lan.gateway)[0]
  wan_gateway_ip = split("/", var.wan.interface_ip)[0]

  # DHCP pool range
  dhcp_pool_range = "${var.dhcp.pool_start}-${var.dhcp.pool_end}"

  # Zones the router forwards to bind9: the internal domain and the LAN's reverse zone (192.168.1.0/24 -> 1.168.192.in-addr.arpa)
  # shortcut: the reverse zone name assumes a /24 LAN, derive it from the prefix length if the LAN ever changes size
  internal_dns_zones = toset([
    var.internal_dns.domain,
    "${join(".", reverse(slice(split(".", split("/", var.lan.cidr)[0]), 0, 3)))}.in-addr.arpa",
  ])

  # container image
  container_image = var.container.image
}

# SYSTEM CONFIGURATION
resource "routeros_system_identity" "identity" {
  name = var.identity
}

resource "routeros_system_clock" "timezone" {
  time_zone_name = var.timezone
}

resource "routeros_snmp" "snmp_settings" {
  enabled = var.snmp_enabled
}

# USER MANAGEMENT
#resource "routeros_system_user" "gary" {
#  name     = var.mikrotik_username
#  group    = "full"
#  password = var.mikrotik_password
#}

resource "routeros_system_user_sshkeys" "ssh_keys" {
  for_each = var.ssh_keys
  user     = var.mikrotik.username
  key      = each.value
  comment  = each.key
}

# Read-only API login for the mktxp exporter in k3s (LAB-158): api and read only, and only from the k3s nodes' range
resource "routeros_system_user_group" "mktxp" {
  name    = "mktxp"
  policy  = ["api", "read"]
  comment = "mktxp exporter in k3s, read-only API"
}

resource "routeros_system_user" "mktxp" {
  name     = var.mktxp.username
  group    = routeros_system_user_group.mktxp.name
  password = var.mktxp.password
  address  = var.mktxp.address
  comment  = "mktxp exporter in k3s"
}

# Note: Disabling admin user should be done manually after verifying gary user works
# resource "routeros_user" "admin_disabled" {
#   name     = "admin"
#   disabled = true
# }

# BRIDGE CONFIGURATION
resource "routeros_interface_bridge" "bridge_lan" {
  name = var.lan.bridge_name
}

resource "routeros_interface_bridge_port" "lan_ports" {
  for_each = toset(var.lan.bridge_ports)

  bridge    = routeros_interface_bridge.bridge_lan.name
  interface = each.value
}

# IP ADDRESSING
resource "routeros_ip_address" "wan_address" {
  address   = var.wan.interface_ip
  interface = var.wan.interface
  comment   = "WAN interface"
}

resource "routeros_ip_address" "lan_address" {
  address   = var.lan.gateway
  interface = routeros_interface_bridge.bridge_lan.name
  comment   = "LAN gateway"
  depends_on = [
    routeros_interface_bridge.bridge_lan
  ]
}

# ROUTING
resource "routeros_ip_route" "default_route" {
  gateway = var.wan.gateway
  comment = "Default route to ISP gateway"
  depends_on = [
    routeros_ip_address.wan_address
  ]
}

# DNS CONFIGURATION
# Root CA of Cloudflare Gateway's DoH certificate (Google Trust Services, from pki.goog), so the router can verify it
resource "routeros_system_certificate" "gts_root_r4" {
  name        = "gts-root-r4"
  common_name = "GTS Root R4"
  import {
    cert_file_content = file("${path.module}/certs/gts-root-r4.pem")
  }
}

resource "routeros_ip_dns" "dns_settings" {
  # Also resolves the DoH hostname itself, which RouterOS needs a plain server for
  servers               = var.dns_servers
  allow_remote_requests = var.dns_allow_remote_requests
  use_doh_server        = var.dns_doh_server
  verify_doh_cert       = var.dns_doh_server != null

  depends_on = [routeros_system_certificate.gts_root_r4]
}

# Internal names go to bind9 through its floating IP, everything else to var.dns_servers
resource "routeros_ip_dns_forwarders" "internal" {
  name        = "internal"
  dns_servers = var.internal_dns.servers
}

resource "routeros_ip_dns_record" "internal_fwd" {
  for_each = local.internal_dns_zones

  type            = "FWD"
  name            = each.key
  forward_to      = routeros_ip_dns_forwarders.internal.name
  match_subdomain = true
  comment         = "Internal zone to bind9"
}

# DHCP CONFIGURATION
resource "routeros_ip_pool" "lan_pool" {
  name = var.dhcp.pool_name
  ranges = [
    local.dhcp_pool_range,
  ]
}

resource "routeros_ip_dhcp_server" "dhcp_lan" {
  name                      = var.dhcp.server_name
  interface                 = routeros_interface_bridge.bridge_lan.name
  address_pool              = routeros_ip_pool.lan_pool.name
  dynamic_lease_identifiers = var.dhcp_dynamic_lease_identifiers
  disabled                  = false
  depends_on = [
    routeros_ip_pool.lan_pool,
    routeros_interface_bridge.bridge_lan
  ]
}

resource "routeros_ip_dhcp_server_network" "lan_network" {
  address = var.lan.cidr
  gateway = local.lan_gateway_ip
  # Clients ask the router, which knows both the internal and the public names
  dns_server = [local.lan_gateway_ip]
  domain     = var.internal_dns.domain
  depends_on = [
    routeros_ip_dhcp_server.dhcp_lan
  ]
}

# DHCP SERVER LEASES (Static assignments)
resource "routeros_ip_dhcp_server_lease" "static_leases" {
  for_each = var.static_leases

  address     = each.value.ip_address
  mac_address = each.value.mac_address
  comment     = each.value.comment
  server      = routeros_ip_dhcp_server.dhcp_lan.name
}

# FIREWALL NAT
resource "routeros_ip_firewall_nat" "masquerade" {
  chain         = "srcnat"
  action        = "masquerade"
  out_interface = var.wan.interface
  comment       = "NAT internet"
}

## NAT rule for Android to Proxmox access
# TODO: Variableize
resource "routeros_ip_firewall_nat" "android_proxmox_nat" {
  chain           = "dstnat"
  action          = "dst-nat"
  protocol        = "tcp"
  dst_address     = local.wan_gateway_ip
  dst_port        = var.proxmox_port
  to_addresses    = var.static_leases.msi_cubi.ip_address
  to_ports        = var.proxmox_port
  src_mac_address = var.trusted_devices.android
  comment         = "Android-Proxmox-MAC"
}

# FIREWALL FILTER RULES
# Order is enforced by routeros_move_items.firewall_order, not by depends_on
resource "routeros_ip_firewall_filter" "allow_established_related" {
  chain            = "input"
  action           = "accept"
  connection_state = "established,related"
  comment          = "Allow established and related connections"
}

resource "routeros_ip_firewall_filter" "drop_invalid_input" {
  chain            = "input"
  action           = "drop"
  connection_state = "invalid"
  comment          = "Drop invalid"
}

resource "routeros_ip_firewall_filter" "allow_icmp_input" {
  chain    = "input"
  action   = "accept"
  protocol = "icmp"
  comment  = "Allow ICMP"
}

resource "routeros_ip_firewall_filter" "allow_trusted_input" {
  for_each = var.trusted_devices

  chain           = "input"
  action          = "accept"
  in_interface    = var.wan.interface
  src_mac_address = each.value
  comment         = "Allow trusted ${each.key} to router"
}

resource "routeros_ip_firewall_filter" "block_wan_input" {
  chain        = "input"
  action       = "drop"
  in_interface = var.wan.interface
  comment      = "Block connections from internet"
}

resource "routeros_ip_firewall_filter" "allow_established_related_forward" {
  chain            = "forward"
  action           = "accept"
  connection_state = "established,related,untracked"
  comment          = "Allow established and related connections"
}

resource "routeros_ip_firewall_filter" "drop_invalid_forward" {
  chain            = "forward"
  action           = "drop"
  connection_state = "invalid"
  comment          = "Drop invalid"
}

resource "routeros_ip_firewall_filter" "allow_trusted_forward" {
  for_each = var.trusted_devices

  chain           = "forward"
  action          = "accept"
  in_interface    = var.wan.interface
  src_mac_address = each.value
  dst_address     = var.lan.cidr
  comment         = "Allow trusted ${each.key} to lab"
}

# dst-nat is excluded so the Android to Proxmox NAT rule keeps working
resource "routeros_ip_firewall_filter" "block_wan_forward" {
  chain                = "forward"
  action               = "drop"
  in_interface         = var.wan.interface
  connection_state     = "new"
  connection_nat_state = "!dstnat"
  comment              = "Block new connections from ISP network to lab"
}

resource "routeros_move_items" "firewall_order" {
  resource_path = "/ip/firewall/filter"
  sequence = concat(
    [
      routeros_ip_firewall_filter.allow_established_related.id,
      routeros_ip_firewall_filter.drop_invalid_input.id,
      routeros_ip_firewall_filter.allow_icmp_input.id,
    ],
    values(routeros_ip_firewall_filter.allow_trusted_input)[*].id,
    [
      routeros_ip_firewall_filter.block_wan_input.id,
      routeros_ip_firewall_filter.allow_established_related_forward.id,
      routeros_ip_firewall_filter.drop_invalid_forward.id,
    ],
    values(routeros_ip_firewall_filter.allow_trusted_forward)[*].id,
    [
      routeros_ip_firewall_filter.block_wan_forward.id,
    ],
  )
}

# IP SERVICES CONFIGURATION
resource "routeros_ip_service" "disabled_services" {
  for_each = var.services_to_disable

  numbers  = each.key
  port     = each.value.port
  disabled = true
}

# CLOUD/DDNS CONFIGURATION
resource "routeros_ip_cloud" "cloud_settings" {
  back_to_home_vpn     = var.routeros_ip_cloud.back_to_home_vpn
  ddns_enabled         = var.routeros_ip_cloud.ddns_enabled
  ddns_update_interval = var.routeros_ip_cloud.ddns_update_interval
  update_time          = var.routeros_ip_cloud.update_time
}

# CONNECTION TRACKING
resource "routeros_ip_firewall_connection_tracking" "connection_tracking" {
  udp_timeout = var.connection_tracking_udp_timeout
}

# CONTAINER CONFIGURATION

# CONTAINER CONFIG
resource "routeros_container_config" "registry" {
  registry_url = var.container_registry_url
  tmpdir       = "${var.container_disk}/pull"
  layer_dir    = "${var.container_disk}/layers"
}

# VETH INTERFACE FOR CONTAINER
resource "routeros_interface_veth" "veth_container" {
  name = var.container.veth_name
  address = [
    var.container.ip,
  ]
  gateway = var.container.gateway
}

resource "routeros_interface_bridge_port" "veth_container" {
  bridge    = routeros_interface_bridge.bridge_lan.name
  interface = routeros_interface_veth.veth_container.name
  depends_on = [
    routeros_interface_veth.veth_container,
  ]
}

# CONTAINER
# TODO: set restart_policy = "on-failure" once the provider supports it (RouterOS 7.24+, not in provider 1.99.1).
# Set by hand until then: /container set [find] restart-policy=on-failure
resource "routeros_container" "monitor_isp" {
  interface     = routeros_interface_veth.veth_container.name
  remote_image  = local.container_image
  root_dir      = "${var.container_disk}/monitor_isp"
  start_on_boot = var.container.start_on_boot
  comment       = "ISP monitoring container with Blackbox Exporter"
  depends_on = [
    routeros_interface_veth.veth_container,
    routeros_interface_bridge_port.veth_container,
    routeros_container_config.registry,
  ]
  lifecycle {
    # Provider 1.99.1 reads running from a status field RouterOS 7.20+ no longer returns
    ignore_changes = [
      running,
      stop_signal,
    ]
  }
}
