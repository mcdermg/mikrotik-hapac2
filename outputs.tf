# NETWORK OUTPUTS
output "bridge_lan_name" {
  description = "Name of the LAN bridge interface"
  value       = routeros_interface_bridge.bridge_lan.name
}

output "lan_gateway" {
  description = "LAN gateway IP address"
  value       = routeros_ip_address.lan_address.address
}

output "wan_address" {
  description = "WAN interface IP address"
  value       = routeros_ip_address.wan_address.address
}

output "wan_gateway" {
  description = "WAN gateway (ISP router)"
  value       = var.wan_gateway
}

output "lan_cidr" {
  description = "LAN network CIDR"
  value       = var.lan_cidr
}

output "wan_cidr" {
  description = "WAN network CIDR"
  value       = var.wan_cidr
}

# DHCP OUTPUTS
output "dhcp_pool_range" {
  description = "DHCP pool IP range"
  value       = routeros_ip_pool.lan_pool.ranges
}

output "dhcp_server_name" {
  description = "DHCP server name"
  value       = routeros_ip_dhcp_server.dhcp_lan.name
}

output "dns_servers" {
  description = "Configured DNS servers"
  value       = var.dns_servers
}

output "static_leases" {
  description = "Static DHCP lease assignments"
  value = {
    for key, lease in routeros_ip_dhcp_server_lease.static_leases :
    key => {
      ip_address  = lease.address
      mac_address = lease.mac_address
      comment     = lease.comment
    }
  }
}

# INTERFACE OUTPUTS
output "container_interface" {
  description = "Container veth interface name"
  value       = routeros_interface_veth.veth_container.name
}

output "container_ip" {
  description = "Container IP address"
  value       = var.container_ip
}

output "lan_bridge_ports" {
  description = "Interfaces added to LAN bridge"
  value       = var.lan_bridge_ports
}

# SERVICE OUTPUTS
output "disabled_services" {
  description = "Services disabled for security"
  value = {
    for key, service in var.services_to_disable :
    key => {
      port    = service.port
      comment = service.comment
    }
  }
}

# MONITORING OUTPUTS
output "blackbox_exporter_endpoint" {
  description = "Blackbox Exporter endpoint for monitoring"
  value       = "${var.blackbox_exporter_host}:${var.blackbox_exporter_port}"
}

output "monitoring_device_ip" {
  description = "ISP monitoring device IP (RPi Zero on WAN)"
  value       = var.rpi_zero_ip
}

# CONFIGURATION SUMMARY
#output "configuration_summary" {
#  description = "High-level configuration summary"
#  value = {
#    timezone              = var.timezone
#    wan_interface         = var.wan_interface
#    lan_bridge            = var.lan_bridge_name
#    container_image       = var.container_image
#  }
#}
