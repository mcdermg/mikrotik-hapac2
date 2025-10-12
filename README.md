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
terraform import routeros_system_user.gary "*1"
terraform import routeros_ip_address.wan_address "*1"
```
12. `terraform plan` (should show no changes if imports worked correctly)
13. `terraform apply`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | ~> 1.88 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | 1.88.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [routeros_container.monitor_isp](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/container) | resource |
| [routeros_interface_bridge.bridge_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge) | resource |
| [routeros_interface_bridge_port.lan_ports](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge_port) | resource |
| [routeros_interface_bridge_port.veth_container](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_bridge_port) | resource |
| [routeros_interface_veth.veth_container](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/interface_veth) | resource |
| [routeros_ip_address.lan_address](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_address) | resource |
| [routeros_ip_address.wan_address](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_address) | resource |
| [routeros_ip_cloud.cloud_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_cloud) | resource |
| [routeros_ip_dhcp_server.dhcp_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server) | resource |
| [routeros_ip_dhcp_server_lease.static_leases](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server_lease) | resource |
| [routeros_ip_dhcp_server_network.lan_network](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dhcp_server_network) | resource |
| [routeros_ip_dns.dns_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_dns) | resource |
| [routeros_ip_firewall_connection_tracking.connection_tracking](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_connection_tracking) | resource |
| [routeros_ip_firewall_filter.allow_android_mac](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_established_related](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_laptop_ip](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_laptop_mac](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_monitoring_blackbox](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_rpi_zero_http_https_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_rpi_zero_icmp_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_rpi_zero_ping](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_rpi_zero_ping_wan](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_wan_subnet_forward](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.block_wan_input](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_nat.masquerade](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_firewall_nat) | resource |
| [routeros_ip_pool.lan_pool](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_pool) | resource |
| [routeros_ip_route.default_route](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_route) | resource |
| [routeros_ip_service.disabled_services](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/ip_service) | resource |
| [routeros_snmp.snmp_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/snmp) | resource |
| [routeros_system_clock.timezone](https://registry.terraform.io/providers/terraform-routeros/routeros/latest/docs/resources/system_clock) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_android_mac"></a> [android\_mac](#input\_android\_mac) | Android device MAC address for firewall allow rule | `string` | `"46:52:CC:BD:BD:AA"` | no |
| <a name="input_api_port"></a> [api\_port](#input\_api\_port) | RouterOS API port | `number` | `8291` | no |
| <a name="input_blackbox_exporter_host"></a> [blackbox\_exporter\_host](#input\_blackbox\_exporter\_host) | Blackbox Exporter host IP (MSI Cubi) | `string` | `"192.168.1.250"` | no |
| <a name="input_blackbox_exporter_port"></a> [blackbox\_exporter\_port](#input\_blackbox\_exporter\_port) | Blackbox Exporter port for ISP monitoring | `number` | `9115` | no |
| <a name="input_cloud_back_to_home_vpn"></a> [cloud\_back\_to\_home\_vpn](#input\_cloud\_back\_to\_home\_vpn) | Enable back-to-home VPN | `string` | `"enabled"` | no |
| <a name="input_cloud_ddns_enabled"></a> [cloud\_ddns\_enabled](#input\_cloud\_ddns\_enabled) | Enable Cloud DDNS | `bool` | `true` | no |
| <a name="input_connection_tracking_udp_timeout"></a> [connection\_tracking\_udp\_timeout](#input\_connection\_tracking\_udp\_timeout) | UDP connection tracking timeout | `string` | `"10s"` | no |
| <a name="input_container_gateway"></a> [container\_gateway](#input\_container\_gateway) | Container gateway IP address | `string` | `"192.168.1.1"` | no |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Container image to deploy | `string` | `"celestial-industries/monitor_isp:latest"` | no |
| <a name="input_container_ip"></a> [container\_ip](#input\_container\_ip) | Container IP address with CIDR | `string` | `"192.168.1.249/24"` | no |
| <a name="input_container_start_on_boot"></a> [container\_start\_on\_boot](#input\_container\_start\_on\_boot) | Start container on boot | `bool` | `true` | no |
| <a name="input_container_veth_name"></a> [container\_veth\_name](#input\_container\_veth\_name) | Container VETH interface name | `string` | `"veth-container"` | no |
| <a name="input_dhcp_pool_end"></a> [dhcp\_pool\_end](#input\_dhcp\_pool\_end) | DHCP pool end IP | `string` | `"192.168.1.254"` | no |
| <a name="input_dhcp_pool_name"></a> [dhcp\_pool\_name](#input\_dhcp\_pool\_name) | DHCP pool name | `string` | `"lan-pool"` | no |
| <a name="input_dhcp_pool_start"></a> [dhcp\_pool\_start](#input\_dhcp\_pool\_start) | DHCP pool start IP | `string` | `"192.168.1.10"` | no |
| <a name="input_dhcp_server_name"></a> [dhcp\_server\_name](#input\_dhcp\_server\_name) | DHCP server name | `string` | `"dhcp-lan"` | no |
| <a name="input_dns_allow_remote_requests"></a> [dns\_allow\_remote\_requests](#input\_dns\_allow\_remote\_requests) | Allow remote DNS requests | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | DNS server IP addresses | `list(string)` | <pre>[<br>  "8.8.8.8",<br>  "1.1.1.1"<br>]</pre> | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | HTTP port | `number` | `80` | no |
| <a name="input_https_port"></a> [https\_port](#input\_https\_port) | HTTPS port | `number` | `443` | no |
| <a name="input_lan_bridge_name"></a> [lan\_bridge\_name](#input\_lan\_bridge\_name) | LAN bridge interface name | `string` | `"bridge-lan"` | no |
| <a name="input_lan_bridge_ports"></a> [lan\_bridge\_ports](#input\_lan\_bridge\_ports) | List of interfaces to add to LAN bridge | `list(string)` | <pre>[<br>  "ether2",<br>  "ether3",<br>  "ether4",<br>  "ether5"<br>]</pre> | no |
| <a name="input_lan_cidr"></a> [lan\_cidr](#input\_lan\_cidr) | LAN network CIDR | `string` | `"192.168.1.0/24"` | no |
| <a name="input_lan_gateway"></a> [lan\_gateway](#input\_lan\_gateway) | LAN gateway IP address with CIDR | `string` | `"192.168.1.1/24"` | no |
| <a name="input_laptop_ip"></a> [laptop\_ip](#input\_laptop\_ip) | Laptop IP address for firewall allow rule | `string` | `"192.168.0.134"` | no |
| <a name="input_laptop_mac"></a> [laptop\_mac](#input\_laptop\_mac) | Laptop MAC address for firewall allow rule | `string` | `"A0:29:19:EF:38:9E"` | no |
| <a name="input_mikrotik_host"></a> [mikrotik\_host](#input\_mikrotik\_host) | MikroTik API endpoint with port | `string` | n/a | yes |
| <a name="input_mikrotik_insecure"></a> [mikrotik\_insecure](#input\_mikrotik\_insecure) | Skip TLS verification (useful for self-signed certs) | `bool` | `true` | no |
| <a name="input_mikrotik_password"></a> [mikrotik\_password](#input\_mikrotik\_password) | MikroTik password for authentication | `string` | n/a | yes |
| <a name="input_mikrotik_username"></a> [mikrotik\_username](#input\_mikrotik\_username) | MikroTik username for authentication | `string` | n/a | yes |
| <a name="input_rpi_zero_ip"></a> [rpi\_zero\_ip](#input\_rpi\_zero\_ip) | Raspberry Pi Zero IP address (ISP monitoring device) | `string` | `"192.168.0.62"` | no |
| <a name="input_services_to_disable"></a> [services\_to\_disable](#input\_services\_to\_disable) | Map of services to disable with their port numbers | <pre>map(object({<br>    port    = number<br>    comment = string<br>  }))</pre> | <pre>{<br>  "api": {<br>    "comment": "RouterOS API",<br>    "port": 8728<br>  },<br>  "api_ssl": {<br>    "comment": "RouterOS API-SSL",<br>    "port": 8729<br>  },<br>  "ftp": {<br>    "comment": "FTP service",<br>    "port": 21<br>  },<br>  "telnet": {<br>    "comment": "Telnet service",<br>    "port": 23<br>  },<br>  "www": {<br>    "comment": "HTTP web service",<br>    "port": 80<br>  }<br>}</pre> | no |
| <a name="input_snmp_enabled"></a> [snmp\_enabled](#input\_snmp\_enabled) | Enable SNMP monitoring | `bool` | `true` | no |
| <a name="input_ssh_port"></a> [ssh\_port](#input\_ssh\_port) | SSH port | `number` | `22` | no |
| <a name="input_static_leases"></a> [static\_leases](#input\_static\_leases) | Static DHCP lease assignments | <pre>map(object({<br>    ip_address  = string<br>    mac_address = string<br>    comment     = string<br>  }))</pre> | <pre>{<br>  "container": {<br>    "comment": "ISP Monitor Container",<br>    "ip_address": "192.168.1.249",<br>    "mac_address": "02:00:00:00:00:02"<br>  },<br>  "msi_cubi": {<br>    "comment": "MSI Cubi N ADL",<br>    "ip_address": "192.168.1.250",<br>    "mac_address": "D8:43:AE:11:DA:27"<br>  },<br>  "pi3_node1": {<br>    "comment": "pi 3 node 1",<br>    "ip_address": "192.168.1.251",<br>    "mac_address": "B8:27:EB:5D:29:38"<br>  },<br>  "pi4": {<br>    "comment": "Pi 4",<br>    "ip_address": "192.168.1.252",<br>    "mac_address": "2C:CF:67:7E:30:1C"<br>  },<br>  "tplink_switch": {<br>    "comment": "TL-SG105PE Switch",<br>    "ip_address": "192.168.1.253",<br>    "mac_address": "3C:6A:D2:25:91:13"<br>  }<br>}</pre> | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | System timezone | `string` | `"America/Argentina/Buenos_Aires"` | no |
| <a name="input_wan_cidr"></a> [wan\_cidr](#input\_wan\_cidr) | WAN network CIDR (ISP network) | `string` | `"192.168.0.0/24"` | no |
| <a name="input_wan_gateway"></a> [wan\_gateway](#input\_wan\_gateway) | ISP gateway IP address | `string` | `"192.168.0.1"` | no |
| <a name="input_wan_interface"></a> [wan\_interface](#input\_wan\_interface) | WAN interface name | `string` | `"ether1"` | no |
| <a name="input_wan_interface_ip"></a> [wan\_interface\_ip](#input\_wan\_interface\_ip) | MikroTik WAN interface IP address with CIDR | `string` | `"192.168.0.98/24"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blackbox_exporter_endpoint"></a> [blackbox\_exporter\_endpoint](#output\_blackbox\_exporter\_endpoint) | Blackbox Exporter endpoint for monitoring |
| <a name="output_bridge_lan_name"></a> [bridge\_lan\_name](#output\_bridge\_lan\_name) | Name of the LAN bridge interface |
| <a name="output_container_interface"></a> [container\_interface](#output\_container\_interface) | Container veth interface name |
| <a name="output_container_ip"></a> [container\_ip](#output\_container\_ip) | Container IP address |
| <a name="output_dhcp_pool_range"></a> [dhcp\_pool\_range](#output\_dhcp\_pool\_range) | DHCP pool IP range |
| <a name="output_dhcp_server_name"></a> [dhcp\_server\_name](#output\_dhcp\_server\_name) | DHCP server name |
| <a name="output_disabled_services"></a> [disabled\_services](#output\_disabled\_services) | Services disabled for security |
| <a name="output_dns_servers"></a> [dns\_servers](#output\_dns\_servers) | Configured DNS servers |
| <a name="output_lan_bridge_ports"></a> [lan\_bridge\_ports](#output\_lan\_bridge\_ports) | Interfaces added to LAN bridge |
| <a name="output_lan_cidr"></a> [lan\_cidr](#output\_lan\_cidr) | LAN network CIDR |
| <a name="output_lan_gateway"></a> [lan\_gateway](#output\_lan\_gateway) | LAN gateway IP address |
| <a name="output_monitoring_device_ip"></a> [monitoring\_device\_ip](#output\_monitoring\_device\_ip) | ISP monitoring device IP (RPi Zero on WAN) |
| <a name="output_static_leases"></a> [static\_leases](#output\_static\_leases) | Static DHCP lease assignments |
| <a name="output_wan_address"></a> [wan\_address](#output\_wan\_address) | WAN interface IP address |
| <a name="output_wan_cidr"></a> [wan\_cidr](#output\_wan\_cidr) | WAN network CIDR |
| <a name="output_wan_gateway"></a> [wan\_gateway](#output\_wan\_gateway) | WAN gateway (ISP router) |
<!-- END_TF_DOCS -->
