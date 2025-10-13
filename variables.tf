# MIKROTIK CONNECTION
variable "mikrotik" {
  description = "MikroTik connection configuration"
  type = object({
    host     = string
    username = string
    password = string
    insecure = bool
  })
  sensitive = true
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
variable "wan" {
  description = "WAN configuration"
  type = object({
    interface    = string
    cidr         = string
    interface_ip = string
    gateway      = string
  })
}

variable "lan" {
  description = "LAN configuration"
  type = object({
    bridge_name  = string
    cidr         = string
    gateway      = string
    bridge_ports = list(string)
  })
}

# DNS CONFIGURATION
variable "dns_servers" {
  description = "DNS server IP addresses"
  type        = list(string)
  default = [
    "8.8.8.8",
    "1.1.1.1",
  ]
}

variable "dns_allow_remote_requests" {
  description = "Allow remote DNS requests"
  type        = bool
  default     = true
}

# DHCP CONFIGURATION
variable "dhcp" {
  description = "DHCP configuration"
  type = object({
    pool_name   = string
    pool_start  = string
    pool_end    = string
    server_name = string
  })
}

variable "static_leases" {
  description = "Static DHCP lease assignments"
  type = map(object({
    ip_address  = string
    mac_address = string
    comment     = string
  }))
}

# CONTAINER CONFIGURATION
variable "container" {
  description = "Container configuration"
  type = object({
    veth_name     = string
    ip            = string
    gateway       = string
    image         = string
    start_on_boot = bool
  })
}

# FIREWALL CONFIGURATION
variable "laptop_mac" {
  description = "Laptop MAC address for firewall allow rule"
  type        = string
}

variable "android_mac" {
  description = "Android device MAC address for firewall allow rule"
  type        = string
}

variable "laptop_ip" {
  description = "Laptop IP address for firewall allow rule"
  type        = string
}

variable "rpi_zero_ip" {
  description = "Raspberry Pi Zero IP address (ISP monitoring device)"
  type        = string
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
    #api = {
    #  port    = 8728
    #  comment = "RouterOS API"
    #}
    #api_ssl = {
    #  port    = 8729
    #  comment = "RouterOS API-SSL"
    #}
  }
}

# CLOUD/DDNS CONFIGURATION
variable "routeros_ip_cloud" {
  description = "Cloud/DDNS configuration"
  type = object({
    back_to_home_vpn     = string
    ddns_enabled         = string
    ddns_update_interval = string
    update_time          = bool
  })
  default = {
    back_to_home_vpn     = "enabled"
    ddns_enabled         = "yes"
    ddns_update_interval = "5m"
    update_time          = true
  }
}

# CONNECTION TRACKING
variable "connection_tracking_udp_timeout" {
  description = "UDP connection tracking timeout"
  type        = string
  default     = "10s"
}

# TODO: for `routeros_container_config` resources that is currently broken in provider
#variable "container_registry_url" {
#  description = "Container registry URL"
#  type        = string
#  default     = "https://ghcr.io"
#}

variable "proxmox_port" {
  description = "Proxmox port"
  type        = number
  default     = 8006
}
