# Cloudflare for backend
variable "cloudflare_api_token" {
  description = "Cloudflare API token for provider for backend"
  type        = string
  sensitive   = true
}

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

variable "ssh_keys" {
  description = "Public SSH keys for the MikroTik user, keyed by machine name"
  type        = map(string)
}

# SYSTEM CONFIGURATION
variable "identity" {
  description = "Router identity (hostname)"
  type        = string
  default     = "MikroTik"
}

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
  description = "Upstream DNS servers the router forwards to for every name outside the internal domain (Cloudflare)"
  type        = list(string)
  default = [
    "1.1.1.1",
    "1.0.0.1",
  ]
}

variable "internal_dns" {
  description = "Internal domain and where the router forwards it and the LAN's reverse zone: the floating IP keepalived keeps on whichever bind9 is up (homelab-proxmox var.bind9_vip, CT 115 and CT 119). One IP, because a forwarder uses its servers round-robin and keeps asking a dead one"
  type = object({
    domain  = string
    servers = list(string)
  })
  default = {
    domain  = "homelab.local"
    servers = ["192.168.1.153"]
  }
}

variable "dns_allow_remote_requests" {
  description = "Allow remote DNS requests"
  type        = bool
  default     = true
}

variable "dns_doh_server" {
  description = "DoH URL for upstream queries: the Cloudflare Gateway Home location (homelab-proxmox: tf output -raw gateway_doh_url), which blocks ads. null keeps plain DNS to dns_servers"
  type        = string
  default     = null
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

variable "dhcp_dynamic_lease_identifiers" {
  description = "Client identifiers the DHCP server uses to match dynamic leases"
  type        = string
  default     = "client-mac,client-id"
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
variable "trusted_devices" {
  description = "MAC addresses on the ISP network allowed into the router and the lab, keyed by device name. The `android` key is also used by the Proxmox dst-nat rule"
  type        = map(string)
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

variable "container_registry_url" {
  description = "Container registry URL"
  type        = string
  default     = "https://ghcr.io"
}

variable "container_disk" {
  description = "Disk holding container layers, tmpdir and root dirs"
  type        = string
  default     = "/usb1-part1"
}

variable "proxmox_port" {
  description = "Proxmox port"
  type        = number
  default     = 8006
}
