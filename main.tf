locals {
  # Extract IP without CIDR for use in configurations
  lan_gateway_ip = split("/", var.lan.gateway)[0]
  wan_gateway_ip = split("/", var.wan.interface_ip)[0]

  # DHCP pool range
  dhcp_pool_range = "${var.dhcp.pool_start}-${var.dhcp.pool_end}"

  # container image
  container_image = var.container.image
}

# SYSTEM CONFIGURATION
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
resource "routeros_ip_dns" "dns_settings" {
  servers               = var.dns_servers
  allow_remote_requests = var.dns_allow_remote_requests
}

# DHCP CONFIGURATION
resource "routeros_ip_pool" "lan_pool" {
  name = var.dhcp.pool_name
  ranges = [
    local.dhcp_pool_range,
  ]
}

resource "routeros_ip_dhcp_server" "dhcp_lan" {
  name         = var.dhcp.server_name
  interface    = routeros_interface_bridge.bridge_lan.name
  address_pool = routeros_ip_pool.lan_pool.name
  disabled     = false
  depends_on = [
    routeros_ip_pool.lan_pool,
    routeros_interface_bridge.bridge_lan
  ]
}

resource "routeros_ip_dhcp_server_network" "lan_network" {
  address    = var.lan.cidr
  gateway    = local.lan_gateway_ip
  dns_server = var.dns_servers
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

# TODO: blackbox_exporter_host is 192.168.1.250 (pve01) but the exporter is meant to run in the
# ISP monitor container at 192.168.1.249. Nothing answers on 9115 at either IP. Check the container
# on the router, then point this at .249 or drop the rule.
resource "routeros_ip_firewall_filter" "allow_monitoring_blackbox" {
  chain       = "forward"
  action      = "accept"
  src_address = var.wan.cidr
  dst_address = var.blackbox_exporter_host
  protocol    = "tcp"
  dst_port    = tostring(var.blackbox_exporter_port)
  comment     = "Allow monitoring to Blackbox Exporter"
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
      routeros_ip_firewall_filter.allow_monitoring_blackbox.id,
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

#  TODO: Not needed container will create manually as far as I can tell via routeros / command
# CREATE DIRECTORIES ON USB
#resource "routeros_file" "container_pull_dir" {
#  name = "usb1-part1/pull"
#}
#
#resource "routeros_file" "container_layers_dir" {
#  name = "usb1-part1/layers"
#}
#
#resource "routeros_file" "container_root_dir" {
#  name = "usb1-part1/monitor_isp"
#}

# CONTAINER CONFIG
#resource "routeros_container_config" "registry" {
#  registry_url = var.container_registry_url
#  tmpdir       = "usb1-part1/pull"
#  layer_dir    = "usb1-part1/layers"
#  # TODO: Provider is usiong wrong naming its memory-high
#  #ram_high     = "0"
#  #memory-high   = "0"
#  depends_on = [
#    #routeros_file.container_pull_dir,
#    #routeros_file.container_layers_dir
#  ]
#}

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
resource "routeros_container" "monitor_isp" {
  interface     = routeros_interface_veth.veth_container.name
  remote_image  = local.container_image
  root_dir      = "usb1-part1/monitor_isp"
  start_on_boot = var.container.start_on_boot
  comment       = "ISP monitoring container with Blackbox Exporter"
  depends_on = [
    routeros_interface_veth.veth_container,
    routeros_interface_bridge_port.veth_container,
    #routeros_file.container_root_dir
    #routeros_container_config.registry,
  ]
  lifecycle {
    ignore_changes = [
      running,
      stop_signal,
    ]
  }
}
