# MikroTik RouterOS Terraform Project

## Project Overview

This is a Terraform project for managing a MikroTik RBD52G-5HacD2HnD router (RouterOS 7.20.1) using Infrastructure as Code. The project manages network configuration, firewall rules, DHCP, NAT, containers, and cloud services for a homelab environment.

## Network Architecture

### Network Topology
- **ISP Network**: `192.168.0.0/24` (Gateway: `192.168.0.1`)
- **Lab Network**: `192.168.1.0/24` (Gateway: `192.168.1.1` via MikroTik)
- **MikroTik WAN IP**: `192.168.0.98` (on ISP network, ether1)
- **MikroTik LAN IP**: `192.168.1.1` (lab gateway, bridge-lan)

### Key Devices
- **MSI Cubi N ADL**: `192.168.1.250` - Proxmox node pve01
- **Skull Canyon NUC**: `192.168.1.251` - Proxmox node pve02
- **Raspberry Pi 4**: `192.168.1.241`
- **Raspberry Pi 3**: `192.168.1.242`
- **Raspberry Pi Zero**: `192.168.0.62` - Gatus ISP monitoring (on WAN side)
- **ISP Monitor Container**: `192.168.1.249` - Blackbox Exporter
- **TP-Link Switch**: `192.168.1.254`

### Lab IP Layout
| Range | Use |
|---|---|
| `.1` | MikroTik |
| `.2`–`.9` | Network gear (spare) |
| `.10`–`.49` | k8s LoadBalancer pool (MetalLB) |
| `.50`–`.99` | DHCP pool |
| `.100`–`.199` | LXCs (VMID = last octet) |
| `.200`–`.239` | k3s VMs (VMID = last octet) |
| `.240`–`.248` | Pis and other physical hosts |
| `.249` | MikroTik ISP monitor container |
| `.250`–`.252` | Proxmox nodes (pve01, pve02, spare) |
| `.253` | Proxmox QDevice (reserved) |
| `.254` | TP-Link switch |

Static leases sit outside the DHCP pool. Nothing static or in the MetalLB range may fall inside `.50`–`.99`.

### Bridge Configuration
- LAN bridge `bridge-lan` aggregates: ether2, ether3, ether4, ether5
- Container uses VETH interface attached to bridge

## File Structure

```
.
├── main.tf                    # All resource definitions
├── variables.tf               # Variable definitions with defaults
├── versions.tf                # Provider and Terraform version config
├── outputs.tf                 # Output definitions
├── terraform.tfvars           # Variable values (gitignored, local only)
├── .gitignore                 # Git ignore patterns
├── .pre-commit-config.yaml    # fmt, validate, tflint, terraform-docs hooks
├── .tflint.hcl                # TFLint rules
├── README.md                  # User documentation (TF docs auto-generated)
└── CLAUDE.md                  # This file - AI assistant context
```

## Coding Conventions

### Critical Rules

1. **DRY Principle**: NEVER hardcode values that are used in multiple places
   - ❌ BAD: `address = "192.168.1.0/24"` scattered throughout
   - ✅ GOOD: `address = var.lan.cidr` everywhere

2. **Comment Style**: Simple section headers only
   - ❌ BAD: `# ============================================================================`
   - ✅ GOOD: `# USER MANAGEMENT`

3. **Variable Usage**: Use variables for ALL configurable values
   - Network CIDRs, IPs, ports, names, etc.
   - If it might change, it's a variable

4. **Use Locals for Computed Values**: Extract/compute from variables
   ```hcl
   locals {
     lan_gateway_ip  = split("/", var.lan.gateway)[0]
     dhcp_pool_range = "${var.dhcp.pool_start}-${var.dhcp.pool_end}"
   }
   ```

5. **Use `for_each` for Collections**: Never duplicate resource blocks
   - Bridge ports: `for_each = toset(var.lan.bridge_ports)`
   - Static leases: `for_each = var.static_leases`
   - Disabled services: `for_each = var.services_to_disable`

### Resource Naming

- Resource names: snake_case (e.g., `bridge_lan`, `dhcp_server`)
- Variable names: snake_case with descriptive names
- Comments: Concise, describe purpose not implementation

### Dependencies

- Use `depends_on` for firewall rules to maintain exact ordering
- Firewall order is CRITICAL for security (drop rule must be last)

## MikroTik-Specific Considerations

### Cloud-Managed Resources

**IMPORTANT**: Some resources are auto-managed by MikroTik Cloud:
- WireGuard interface for Back To Home VPN is auto-created when `back-to-home-vpn=enabled`
- DO NOT create `routeros_interface_wireguard` for Back To Home VPN
- Only manage the cloud setting: `routeros_ip_cloud.cloud_settings`

### API Access

Terraform connects via `api://` (port 8728), so the API service must be enabled:
```routeros
/ip service enable api
```

Terraform does NOT disable `api`/`api-ssl` (those entries are commented out in `services_to_disable`), since doing so would lock Terraform out.

### Container Setup

Container requires:
- VETH interface created first
- VETH attached to bridge
- Container uses VETH for networking

### Firewall Rule Order

Firewall rules MUST be in this exact order (use `depends_on` chains):
1. Allow established/related
2. Allow specific devices (MAC/IP) and the ISP network (`192.168.0.0/24`)
3. Allow specific forwards
4. DROP all WAN input (MUST BE LAST input rule)
5. General forward rules

## Variable Structure

### Variable Organization
Variables are grouped by function:
- Connection settings (host, username, password)
- System config (timezone, SNMP)
- Network config (WAN/LAN settings)
- DNS settings
- DHCP settings
- Container settings
- Firewall settings
- Service settings
- Cloud settings

### Complex Variable Types

**Static Leases** (map of objects):
```hcl
variable "static_leases" {
  type = map(object({
    ip_address  = string
    mac_address = string
    comment     = string
  }))
}
```

**Services to Disable** (map of objects):
```hcl
variable "services_to_disable" {
  type = map(object({
    port    = number
    comment = string
  }))
}
```

## Common Tasks

### Adding a New Static Lease

1. Add entry to `static_leases` variable in `terraform.tfvars`:
```hcl
static_leases = {
  new_device = {
    ip_address  = "192.168.1.100"
    mac_address = "AA:BB:CC:DD:EE:FF"
    comment     = "New Device Description"
  }
}
```

2. Run `terraform apply` - the `for_each` will handle it

### Changing Network Scheme

1. Update CIDRs in the `lan` object in `terraform.tfvars`:
```hcl
lan = {
  cidr    = "10.0.1.0/24"
  gateway = "10.0.1.1/24"
  # ...
}
```

2. Update related IPs (static leases, etc.)
3. All resources referencing `var.lan.cidr` update automatically

### Adding a Firewall Rule

1. Add resource to `main.tf` under firewall section
2. Set proper `depends_on` to maintain rule order
3. Use variables for all IPs, ports, interfaces

### Disabling/Enabling a Service

Modify the `services_to_disable` map in `terraform.tfvars`:
```hcl
services_to_disable = {
  # Comment out or remove entries to enable
  # ftp = { port = 21, comment = "FTP service" }
  telnet = { port = 23, comment = "Telnet service" }
}
```

## Anti-Patterns to Avoid

❌ **Hardcoding values used multiple times**
❌ **Creating duplicate resource blocks instead of using `for_each`**
❌ **Using decorative comment borders**
❌ **Creating resources for cloud-managed infrastructure**
❌ **Breaking firewall rule order dependencies**
❌ **Forgetting to add `depends_on` for firewall rules**
❌ **Using inline values instead of variables in resources**

## Terraform Best Practices

### State Management
- Use remote state for production (GCS, S3, Terraform Cloud)
- Never commit `terraform.tfvars` (contains credentials)
- Keep state file secure

### Workflow
1. Edit variables or resources
2. Run `terraform fmt` to format
3. Run `terraform validate` to check syntax
4. Run `terraform plan` to preview changes
5. Run `terraform apply` to implement
6. Commit `.tf` files (NOT `.tfvars`) to git

### Provider Version
- Terraform `~> 1.13`, provider `terraform-routeros/routeros` pinned to `1.99.1`
- Pin versions in production
- Test updates in non-production first

## Security Considerations

1. **API Access**: Only enable when running Terraform
2. **Firewall Order**: Critical for security - never break rule order
3. **Service Hardening**: Disable unnecessary services
4. **Credentials**: Use `sensitive = true` for password variables
5. **WAN Input**: Always keep drop rule as last input rule

## Integration Points

### With Proxmox
- Proxmox host at `192.168.1.250`
- Can use Terraform outputs for Proxmox provider inputs
- Consider dynamic inventory for Ansible

### With Ansible
- Export outputs as JSON: `terraform output -json > ansible/inventory/terraform.json` (NOTE: all outputs in `outputs.tf` are currently commented out)
- Use outputs for inventory generation
- Ansible manages container/VM configuration

### With Monitoring
- Blackbox Exporter at `192.168.1.250:9115`
- RPi Zero at `192.168.0.62` for ISP-side monitoring
- Firewall allows monitoring traffic from WAN to Blackbox

## User Preferences

- Senior DevOps engineer with GCP/GKE background
- Extensive Terraform and Ansible experience
- Prefers clean, maintainable IaC
- Values DRY principles and operational simplicity
- Technical enough to understand implementation details

## When Making Changes

1. Always check if a value should be a variable
2. Always use existing variables rather than creating new ones
3. Always maintain DRY principles
4. Always preserve firewall rule ordering
5. Always keep comments simple and clean
6. Never create resources for cloud-managed infrastructure
7. Test changes with `terraform plan` before committing
8. NEVER run terraform apply
9. NEVER run terraform destroy
10. NEVER run terraform destroy -auto-approve
