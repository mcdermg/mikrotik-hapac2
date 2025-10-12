# Mikrotik hAP ac2

## Bootstrap
The process for resetting and allowing this IaC to be able to run is as follows:

1. `/system reset-configuration no-defaults=yes skip-backup=yes`
2. Connect RJ45 to the hAP ac2 via ether2-4
3. Connect via WinBox using neighbors and MAC address
4. `/user add name=gary group=full password=**********`
5. `/ip service enable api`
6. `/ip address add address=192.168.0.98/24 interface=ether1`
7. `/ip route add gateway=192.168.0.1`
8. `ssh-keygen -f "/home/gary/.ssh/known_hosts" -R "192.168.0.98"`
9. ssh to thr router via `ssh gary@xxx.xxx.x.xx`
10. `/user set admin disabled=yes`
11. Import existing resources into Terraform state:
```bash
terraform import routeros_ip_address.wan_address "*1"
```
12. `/container config set registry-url=https://ghcr.io tmpdir=usb1-part1/pull layer-dir=usb1-part1/layers` There is an issue with TF provider not creating resource [container_config](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/container_config)
13. `terraform plan -compact-warnings`
14. `terraform apply -compact-warnings`

### Terraform issues

#### Container Config
There appears to be an issue with [container_config](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/container_config)as the `ram_high` element generates an error on any apply.

```
│ Error: from RouterOS device: unknown parameter ram-high
│
│   with routeros_container_config.registry,
│   on main.tf line 290, in resource "routeros_container_config" "registry":
│  290: resource "routeros_container_config" "registry" {
│
```

The provider has an [example](https://github.com/terraform-routeros/terraform-provider-routeros/blob/main/examples/resources/routeros_container_config/resource.tf) of:

```
resource "routeros_container_config" "config" {
  registry_url = "https://registry-1.docker.io"
  ram_high     = "0"
  tmpdir       = "/usb1-part1/containers/tmp"
  layer_dir    = "/usb1-part1/containers/layers"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | 1.88.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | 1.88.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [routeros_container.monitor_isp](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/container) | resource |
| [routeros_interface_bridge.bridge_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/interface_bridge) | resource |
| [routeros_interface_bridge_port.lan_ports](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/interface_bridge_port) | resource |
| [routeros_interface_bridge_port.veth_container](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/interface_bridge_port) | resource |
| [routeros_interface_veth.veth_container](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/interface_veth) | resource |
| [routeros_ip_address.lan_address](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_address) | resource |
| [routeros_ip_address.wan_address](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_address) | resource |
| [routeros_ip_cloud.cloud_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_cloud) | resource |
| [routeros_ip_dhcp_server.dhcp_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_dhcp_server) | resource |
| [routeros_ip_dhcp_server_lease.static_leases](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_dhcp_server_lease) | resource |
| [routeros_ip_dhcp_server_network.lan_network](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_dhcp_server_network) | resource |
| [routeros_ip_dns.dns_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_dns) | resource |
| [routeros_ip_firewall_connection_tracking.connection_tracking](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_connection_tracking) | resource |
| [routeros_ip_firewall_filter.allow_android_mac](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_established_related](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_laptop_ip](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_laptop_mac](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_monitoring_blackbox](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_rpi_zero_http_https_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_rpi_zero_icmp_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_rpi_zero_ping](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_rpi_zero_ping_wan](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_wan_subnet_forward](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.block_wan_input](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_nat.masquerade](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_firewall_nat) | resource |
| [routeros_ip_pool.lan_pool](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_pool) | resource |
| [routeros_ip_route.default_route](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_route) | resource |
| [routeros_ip_service.disabled_services](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/ip_service) | resource |
| [routeros_snmp.snmp_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/snmp) | resource |
| [routeros_system_clock.timezone](https://registry.terraform.io/providers/terraform-routeros/routeros/1.88.0/docs/resources/system_clock) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_android_mac"></a> [android\_mac](#input\_android\_mac) | Android device MAC address for firewall allow rule | `string` | n/a | yes |
| <a name="input_api_port"></a> [api\_port](#input\_api\_port) | RouterOS API port | `number` | `8291` | no |
| <a name="input_blackbox_exporter_host"></a> [blackbox\_exporter\_host](#input\_blackbox\_exporter\_host) | Blackbox Exporter host IP (MSI Cubi) | `string` | n/a | yes |
| <a name="input_blackbox_exporter_port"></a> [blackbox\_exporter\_port](#input\_blackbox\_exporter\_port) | Blackbox Exporter port for ISP monitoring | `number` | `9115` | no |
| <a name="input_cloud_back_to_home_vpn"></a> [cloud\_back\_to\_home\_vpn](#input\_cloud\_back\_to\_home\_vpn) | Enable back-to-home VPN | `string` | `"enabled"` | no |
| <a name="input_cloud_ddns_enabled"></a> [cloud\_ddns\_enabled](#input\_cloud\_ddns\_enabled) | Enable Cloud DDNS | `string` | `"yes"` | no |
| <a name="input_connection_tracking_udp_timeout"></a> [connection\_tracking\_udp\_timeout](#input\_connection\_tracking\_udp\_timeout) | UDP connection tracking timeout | `string` | `"10s"` | no |
| <a name="input_container"></a> [container](#input\_container) | Container configuration | <pre>object({<br>    veth_name     = string<br>    ip            = string<br>    gateway       = string<br>    image         = string<br>    start_on_boot = bool<br>  })</pre> | n/a | yes |
| <a name="input_dhcp"></a> [dhcp](#input\_dhcp) | DHCP configuration | <pre>object({<br>    pool_name   = string<br>    pool_start  = string<br>    pool_end    = string<br>    server_name = string<br>  })</pre> | n/a | yes |
| <a name="input_dns_allow_remote_requests"></a> [dns\_allow\_remote\_requests](#input\_dns\_allow\_remote\_requests) | Allow remote DNS requests | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | DNS server IP addresses | `list(string)` | <pre>[<br>  "8.8.8.8",<br>  "1.1.1.1"<br>]</pre> | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | HTTP port | `number` | `80` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | HTTPS port | `number` | `443` | no |
| <a name="input_lan"></a> [lan](#input\_lan) | LAN configuration | <pre>object({<br>    bridge_name  = string<br>    cidr         = string<br>    gateway      = string<br>    bridge_ports = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_laptop_ip"></a> [laptop\_ip](#input\_laptop\_ip) | Laptop IP address for firewall allow rule | `string` | n/a | yes |
| <a name="input_laptop_mac"></a> [laptop\_mac](#input\_laptop\_mac) | Laptop MAC address for firewall allow rule | `string` | n/a | yes |
| <a name="input_mikrotik"></a> [mikrotik](#input\_mikrotik) | MikroTik connection configuration | <pre>object({<br>    host     = string<br>    username = string<br>    password = string<br>    insecure = bool<br>  })</pre> | n/a | yes |
| <a name="input_rpi_zero_ip"></a> [rpi\_zero\_ip](#input\_rpi\_zero\_ip) | Raspberry Pi Zero IP address (ISP monitoring device) | `string` | n/a | yes |
| <a name="input_services_to_disable"></a> [services\_to\_disable](#input\_services\_to\_disable) | Map of services to disable with their port numbers | <pre>map(object({<br>    port    = number<br>    comment = string<br>  }))</pre> | <pre>{<br>  "ftp": {<br>    "comment": "FTP service",<br>    "port": 21<br>  },<br>  "telnet": {<br>    "comment": "Telnet service",<br>    "port": 23<br>  },<br>  "www": {<br>    "comment": "HTTP web service",<br>    "port": 80<br>  }<br>}</pre> | no |
| <a name="input_snmp_enabled"></a> [snmp\_enabled](#input\_snmp\_enabled) | Enable SNMP monitoring | `bool` | `true` | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | SSH port | `number` | `22` | no |
| <a name="input_static_leases"></a> [static\_leases](#input\_static\_leases) | Static DHCP lease assignments | <pre>map(object({<br>    ip_address  = string<br>    mac_address = string<br>    comment     = string<br>  }))</pre> | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | System timezone | `string` | `"America/Argentina/Buenos_Aires"` | no |
| <a name="input_wan"></a> [wan](#input\_wan) | WAN configuration | <pre>object({<br>    interface    = string<br>    cidr         = string<br>    interface_ip = string<br>    gateway      = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
