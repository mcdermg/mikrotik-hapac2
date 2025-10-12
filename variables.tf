# MIKROTIK CONNECTION
variable "mikrotik_host" {
  description = "MikroTik API endpoint with port"
  type        = string
}


variable "mikrotik_username" {
  description = "MikroTik username for authentication"
  type        = string
  sensitive   = true
}

variable "mikrotik_password" {
  description = "MikroTik password for authentication"
  type        = string
  sensitive   = true
}

variable "mikrotik_insecure" {
  description = "Skip TLS verification (useful for self-signed certs)"
  type        = bool
  default     = true
}

# SYSTEM CONFIGURATION
variable "timezone" {
  description = "System timezone"
  type        = string
  default     = "America/Argentina/Buenos_Aires"
}

variable "snmp_enabled" {
  description = "Enable SNMP monitoring"
  type        = bool
  default     = true
}

# NETWORK CONFIGURATION
variable "wan_interface" {
  description = "WAN interface name"
  type        = string
  default     = "ether1"
}

variable "wan_cidr" {
  description = "WAN network CIDR (ISP network)"
  type        = string
  default     = "192.168.0.0/24"
}

variable "wan_interface_ip" {
  description = "MikroTik WAN interface IP address with CIDR"
  type        = string
  default     = "192.168.0.98/24"
}

variable "wan_gateway" {
  description = "ISP gateway IP address"
  type        = string
  default     = "192.168.0.1"
}

variable "lan_bridge_name" {
  description = "LAN bridge interface name"
  type        = string
  default     = "bridge-lan"
}

variable "lan_cidr" {
  description = "LAN network CIDR"
  type        = string
  default     = "192.168.1.0/24"
}

variable "lan_gateway" {
  description = "LAN gateway IP address with CIDR"
  type        = string
  default     = "192.168.1.1/24"
}

variable "lan_bridge_ports" {
  description = "List of interfaces to add to LAN bridge"
  type        = list(string)
  default     = ["ether2", "ether3", "ether4", "ether5"]
}

# DNS CONFIGURATION
variable "dns_servers" {
  description = "DNS server IP addresses"
  type        = list(string)
  default     = ["8.8.8.8", "1.1.1.1"]
}

variable "dns_allow_remote_requests" {
  description = "Allow remote DNS requests"
  type        = bool
  default     = true
}

# DHCP CONFIGURATION
variable "dhcp_pool_name" {
  description = "DHCP pool name"
  type        = string
  default     = "lan-pool"
}

variable "dhcp_pool_start" {
  description = "DHCP pool start IP"
  type        = string
  default     = "192.168.1.10"
}

variable "dhcp_pool_end" {
  description = "DHCP pool end IP"
  type        = string
  default     = "192.168.1.254"
}

variable "dhcp_server_name" {
  description = "DHCP server name"
  type        = string
  default     = "dhcp-lan"
}

variable "static_leases" {
  description = "Static DHCP lease assignments"
  type = map(object({
    ip_address  = string
    mac_address = string
    comment     = string
  }))
  default = {
    pi3_node1 = {
      ip_address  = "192.168.1.251"
      mac_address = "B8:27:EB:5D:29:38"
      comment     = "pi 3 node 1"
    }
    pi4 = {
      ip_address  = "192.168.1.252"
      mac_address = "2C:CF:67:7E:30:1C"
      comment     = "Pi 4"
    }
    msi_cubi = {
      ip_address  = "192.168.1.250"
      mac_address = "D8:43:AE:11:DA:27"
      comment     = "MSI Cubi N ADL"
    }
    tplink_switch = {
      ip_address  = "192.168.1.253"
      mac_address = "3C:6A:D2:25:91:13"
      comment     = "TL-SG105PE Switch"
    }
    container = {
      ip_address  = "192.168.1.249"
      mac_address = "02:00:00:00:00:02"
      comment     = "ISP Monitor Container"
    }
  }
}

# CONTAINER CONFIGURATION
variable "container_veth_name" {
  description = "Container VETH interface name"
  type        = string
  default     = "veth-container"
}

variable "container_ip" {
  description = "Container IP address with CIDR"
  type        = string
  default     = "192.168.1.249/24"
}

variable "container_gateway" {
  description = "Container gateway IP address"
  type        = string
  default     = "192.168.1.1"
}

variable "container_image" {
  description = "Container image to deploy"
  type        = string
  default     = "celestial-industries/monitor_isp:latest"
}

variable "container_start_on_boot" {
  description = "Start container on boot"
  type        = bool
  default     = true
}

# FIREWALL CONFIGURATION
variable "laptop_mac" {
  description = "Laptop MAC address for firewall allow rule"
  type        = string
  default     = "A0:29:19:EF:38:9E"
}

variable "android_mac" {
  description = "Android device MAC address for firewall allow rule"
  type        = string
  default     = "46:52:CC:BD:BD:AA"
}

variable "laptop_ip" {
  description = "Laptop IP address for firewall allow rule"
  type        = string
  default     = "192.168.0.134"
}

variable "rpi_zero_ip" {
  description = "Raspberry Pi Zero IP address (ISP monitoring device)"
  type        = string
  default     = "192.168.0.62"
}

variable "ssh_port" {
  description = "SSH port"
  type        = number
  default     = 22
}

variable "api_port" {
  description = "RouterOS API port"
  type        = number
  default     = 8291
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  default     = 443
}

variable "blackbox_exporter_port" {
  description = "Blackbox Exporter port for ISP monitoring"
  type        = number
  default     = 9115
}

variable "blackbox_exporter_host" {
  description = "Blackbox Exporter host IP (MSI Cubi)"
  type        = string
  default     = "192.168.1.250"
}

# SERVICE CONFIGURATION
variable "services_to_disable" {
  description = "Map of services to disable with their port numbers"
  type = map(object({
    port    = number
    comment = string
  }))
  default = {
    ftp = {
      port    = 21
      comment = "FTP service"
    }
    telnet = {
      port    = 23
      comment = "Telnet service"
    }
    www = {
      port    = 80
      comment = "HTTP web service"
    }
    api = {
      port    = 8728
      comment = "RouterOS API"
    }
    api_ssl = {
      port    = 8729
      comment = "RouterOS API-SSL"
    }
  }
}

# CLOUD/DDNS CONFIGURATION
variable "cloud_ddns_enabled" {
  description = "Enable Cloud DDNS"
  type        = bool
  default     = true
}

variable "cloud_back_to_home_vpn" {
  description = "Enable back-to-home VPN"
  type        = string
  default     = "enabled"
}

# CONNECTION TRACKING
variable "connection_tracking_udp_timeout" {
  description = "UDP connection tracking timeout"
  type        = string
  default     = "10s"
}
