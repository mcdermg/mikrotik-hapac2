# Mikrotik hAP ac2

## State Backend
State is stored in Cloudflare R2 using the `s3` backend (see `backend.tf`):

- Bucket: `iac-state`
- Key: `homelab/mikrotik-hapac2/terraform.tfstate`
- Locking: `use_lockfile = true` writes a `.tflock` object next to the state using a conditional write (`If-None-Match`), so no DynamoDB table is needed

Credentials and the endpoint are not in the backend block and come from a git ignored `.envrc` loaded by [direnv](https://direnv.net/):

```bash
#!/usr/bin/env bash
export AWS_ACCESS_KEY_ID=<r2-access-key-id>
export AWS_SECRET_ACCESS_KEY=<r2-secret-access-key>
export AWS_ENDPOINT_URL_S3=https://<account-id>.r2.cloudflarestorage.com
```

The keys are from an R2 Account API token (R2 Object Storage → Account Details → API Tokens → Manage) with **Object Read & Write** scoped to the `iac-state` bucket only. They are stored in the password manager.

To set up on a new machine:

1. Create `.envrc` as above and run `direnv allow`
2. `tofu init`
3. `tofu plan -compact-warnings` and confirm no unexpected changes

## Lab IP Layout
Layout for `192.168.1.0/24`. The DHCP pool and static leases are set in `terraform.tfvars`.

| Range | Use |
|---|---|
| `.1` | MikroTik |
| `.2`–`.9` | Network gear (spare) |
| `.10`–`.49` | k8s LoadBalancer pool (MetalLB) |
| `.50`–`.99` | DHCP pool |
| `.100`–`.199` | LXCs (VMID = last octet), except `.153`: the bind9 floating DNS IP (keepalived) |
| `.200`–`.239` | k3s VMs (VMID = last octet) |
| `.240`–`.248` | Pis and other physical hosts (Pi 4 `.241`, Pi 3 `.242`) |
| `.249` | MikroTik ISP monitor container |
| `.250`–`.252` | Proxmox nodes (pve01 `.250`, pve02 `.251`, spare `.252`) |
| `.253` | Proxmox QDevice (reserved) |
| `.254` | TP-Link switch |

Static leases can sit outside the DHCP pool. Nothing static or in the MetalLB range may fall inside `.50`–`.99`.

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
9. ssh to the router via `ssh gary@192.168.0.98`
10. `/user set admin disabled=yes`
11. Import existing resources into OpenTofu state:
```bash
tofu import routeros_ip_address.wan_address "*1"
```
12. `tofu plan -compact-warnings`
13. `tofu apply -compact-warnings`

## Administration Device Change
If switching main device for OpenTofu and accessing the router then the values for the IP and MAC address present in the rules need to be updated. OpenTofu won't be able to access after a change so ssh access via `ssh user@routerIP` with associated password will allow access and then update rules via:

```
/ip firewall filter set [find comment="Allow laptop by MAC"] src-mac-address=XX:YY:11:22:33:AA

/ip firewall filter set [find comment="Allow laptop by IP"] src-address=XXX.XXX.XXX.XXX
```

**NOTE**: MAC address should use all uppercase for letters otherwise OpenTofu will throw an error via the provider and its validation.

To verify run:

```
/ip firewall filter print where comment~"laptop"
```

Confirm updated and matching.

Also add route locally on the new device via:

```
nmcli connection modify "Wired connection 1" +ipv4.routes "192.168.1.0/24 192.168.0.98"
nmcli connection up "Wired connection 1"
```
**NOTE:** Change connection name as required and ranges if different in the above commands.

For a temporary route use:

```
sudo ip route add 192.168.1.0/24 via 192.168.0.98
```

**NOTE:** This is not persistent on device reboot.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |
| <a name="requirement_routeros"></a> [routeros](#requirement\_routeros) | 1.99.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_routeros"></a> [routeros](#provider\_routeros) | 1.99.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [routeros_container.monitor_isp](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/container) | resource |
| [routeros_container_config.registry](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/container_config) | resource |
| [routeros_interface_bridge.bridge_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/interface_bridge) | resource |
| [routeros_interface_bridge_port.lan_ports](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/interface_bridge_port) | resource |
| [routeros_interface_bridge_port.veth_container](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/interface_bridge_port) | resource |
| [routeros_interface_veth.veth_container](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/interface_veth) | resource |
| [routeros_ip_address.lan_address](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_address) | resource |
| [routeros_ip_address.wan_address](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_address) | resource |
| [routeros_ip_cloud.cloud_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_cloud) | resource |
| [routeros_ip_dhcp_server.dhcp_lan](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_dhcp_server) | resource |
| [routeros_ip_dhcp_server_lease.static_leases](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_dhcp_server_lease) | resource |
| [routeros_ip_dhcp_server_network.lan_network](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_dhcp_server_network) | resource |
| [routeros_ip_dns.dns_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_dns) | resource |
| [routeros_ip_dns_forwarders.internal](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_dns_forwarders) | resource |
| [routeros_ip_dns_record.internal_fwd](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_dns_record) | resource |
| [routeros_ip_firewall_connection_tracking.connection_tracking](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_connection_tracking) | resource |
| [routeros_ip_firewall_filter.allow_established_related](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_established_related_forward](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_icmp_input](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_trusted_forward](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.allow_trusted_input](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.block_wan_forward](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.block_wan_input](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.drop_invalid_forward](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_filter.drop_invalid_input](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_filter) | resource |
| [routeros_ip_firewall_nat.android_proxmox_nat](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_nat) | resource |
| [routeros_ip_firewall_nat.masquerade](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_firewall_nat) | resource |
| [routeros_ip_pool.lan_pool](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_pool) | resource |
| [routeros_ip_route.default_route](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_route) | resource |
| [routeros_ip_service.disabled_services](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/ip_service) | resource |
| [routeros_move_items.firewall_order](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/move_items) | resource |
| [routeros_snmp.snmp_settings](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/snmp) | resource |
| [routeros_system_clock.timezone](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/system_clock) | resource |
| [routeros_system_identity.identity](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/system_identity) | resource |
| [routeros_system_user_sshkeys.ssh_keys](https://registry.terraform.io/providers/terraform-routeros/routeros/1.99.1/docs/resources/system_user_sshkeys) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloudflare_api_token"></a> [cloudflare\_api\_token](#input\_cloudflare\_api\_token) | Cloudflare API token for provider for backend | `string` | n/a | yes |
| <a name="input_connection_tracking_udp_timeout"></a> [connection\_tracking\_udp\_timeout](#input\_connection\_tracking\_udp\_timeout) | UDP connection tracking timeout | `string` | `"10s"` | no |
| <a name="input_container"></a> [container](#input\_container) | Container configuration | <pre>object({<br/>    veth_name     = string<br/>    ip            = string<br/>    gateway       = string<br/>    image         = string<br/>    start_on_boot = bool<br/>  })</pre> | n/a | yes |
| <a name="input_container_disk"></a> [container\_disk](#input\_container\_disk) | Disk holding container layers, tmpdir and root dirs | `string` | `"/usb1-part1"` | no |
| <a name="input_container_registry_url"></a> [container\_registry\_url](#input\_container\_registry\_url) | Container registry URL | `string` | `"https://ghcr.io"` | no |
| <a name="input_dhcp"></a> [dhcp](#input\_dhcp) | DHCP configuration | <pre>object({<br/>    pool_name   = string<br/>    pool_start  = string<br/>    pool_end    = string<br/>    server_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_dhcp_dynamic_lease_identifiers"></a> [dhcp\_dynamic\_lease\_identifiers](#input\_dhcp\_dynamic\_lease\_identifiers) | Client identifiers the DHCP server uses to match dynamic leases | `string` | `"client-mac,client-id"` | no |
| <a name="input_dns_allow_remote_requests"></a> [dns\_allow\_remote\_requests](#input\_dns\_allow\_remote\_requests) | Allow remote DNS requests | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Upstream DNS servers the router forwards to for every name outside the internal domain (Cloudflare) | `list(string)` | <pre>[<br/>  "1.1.1.1",<br/>  "1.0.0.1"<br/>]</pre> | no |
| <a name="input_identity"></a> [identity](#input\_identity) | Router identity (hostname) | `string` | `"MikroTik"` | no |
| <a name="input_internal_dns"></a> [internal\_dns](#input\_internal\_dns) | Internal domain and where the router forwards it and the LAN's reverse zone: the floating IP keepalived keeps on whichever bind9 is up (homelab-proxmox var.bind9\_vip, CT 115 and CT 119). One IP, because a forwarder uses its servers round-robin and keeps asking a dead one | <pre>object({<br/>    domain  = string<br/>    servers = list(string)<br/>  })</pre> | <pre>{<br/>  "domain": "homelab.local",<br/>  "servers": [<br/>    "192.168.1.153"<br/>  ]<br/>}</pre> | no |
| <a name="input_lan"></a> [lan](#input\_lan) | LAN configuration | <pre>object({<br/>    bridge_name  = string<br/>    cidr         = string<br/>    gateway      = string<br/>    bridge_ports = list(string)<br/>  })</pre> | n/a | yes |
| <a name="input_mikrotik"></a> [mikrotik](#input\_mikrotik) | MikroTik connection configuration | <pre>object({<br/>    host     = string<br/>    username = string<br/>    password = string<br/>    insecure = bool<br/>  })</pre> | n/a | yes |
| <a name="input_proxmox_port"></a> [proxmox\_port](#input\_proxmox\_port) | Proxmox port | `number` | `8006` | no |
| <a name="input_routeros_ip_cloud"></a> [routeros\_ip\_cloud](#input\_routeros\_ip\_cloud) | Cloud/DDNS configuration | <pre>object({<br/>    back_to_home_vpn     = string<br/>    ddns_enabled         = string<br/>    ddns_update_interval = string<br/>    update_time          = bool<br/>  })</pre> | <pre>{<br/>  "back_to_home_vpn": "enabled",<br/>  "ddns_enabled": "yes",<br/>  "ddns_update_interval": "5m",<br/>  "update_time": true<br/>}</pre> | no |
| <a name="input_services_to_disable"></a> [services\_to\_disable](#input\_services\_to\_disable) | Map of services to disable with their port numbers | <pre>map(object({<br/>    port    = number<br/>    comment = string<br/>  }))</pre> | <pre>{<br/>  "ftp": {<br/>    "comment": "FTP service",<br/>    "port": 21<br/>  },<br/>  "telnet": {<br/>    "comment": "Telnet service",<br/>    "port": 23<br/>  },<br/>  "www": {<br/>    "comment": "HTTP web service",<br/>    "port": 80<br/>  }<br/>}</pre> | no |
| <a name="input_snmp_enabled"></a> [snmp\_enabled](#input\_snmp\_enabled) | Enable SNMP monitoring | `bool` | `true` | no |
| <a name="input_ssh_keys"></a> [ssh\_keys](#input\_ssh\_keys) | Public SSH keys for the MikroTik user, keyed by machine name | `map(string)` | n/a | yes |
| <a name="input_static_leases"></a> [static\_leases](#input\_static\_leases) | Static DHCP lease assignments | <pre>map(object({<br/>    ip_address  = string<br/>    mac_address = string<br/>    comment     = string<br/>  }))</pre> | n/a | yes |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | System timezone | `string` | `"America/Argentina/Buenos_Aires"` | no |
| <a name="input_trusted_devices"></a> [trusted\_devices](#input\_trusted\_devices) | MAC addresses on the ISP network allowed into the router and the lab, keyed by device name. The `android` key is also used by the Proxmox dst-nat rule | `map(string)` | n/a | yes |
| <a name="input_wan"></a> [wan](#input\_wan) | WAN configuration | <pre>object({<br/>    interface    = string<br/>    cidr         = string<br/>    interface_ip = string<br/>    gateway      = string<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
