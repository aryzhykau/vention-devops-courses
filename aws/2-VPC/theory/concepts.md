# VPC Core Concepts

## Network Fundamentals

### VPC Basics
- Logically isolated virtual network
- Region-specific service
- Custom IP address range (CIDR)
- Control over network configuration
- Multiple VPCs per region

### CIDR and IP Addressing
- IPv4 CIDR blocks (primary)
- IPv6 CIDR blocks (optional)
- Private IP ranges (RFC 1918)
  - 10.0.0.0/8
  - 172.16.0.0/12
  - 192.168.0.0/16
- Subnet sizing and planning

## Network Components

### Subnets
- Subset of VPC CIDR block
- AZ-specific
- Public vs Private
- CIDR block planning
- Reserved IP addresses

### Route Tables
- Controls network traffic
- Main route table
- Custom route tables
- Local routes
- Route propagation

### Internet Gateway (IGW)
- Enables internet access
- One per VPC
- IPv4 and IPv6 support
- Public subnet routing
- High availability built-in

### NAT Gateway/Instance
- Private subnet internet access
- Managed vs self-managed
- AZ-specific deployment
- Bandwidth scaling
- High availability options

## Security Components

### Security Groups
```json
{
    "GroupId": "sg-123456",
    "Description": "Web Servers",
    "InboundRules": [
        {
            "Protocol": "tcp",
            "Port": 80,
            "Source": "0.0.0.0/0"
        }
    ],
    "OutboundRules": [
        {
            "Protocol": "-1",
            "Port": "-1",
            "Destination": "0.0.0.0/0"
        }
    ]
}
```

### Network ACLs
- Stateless packet filtering
- Subnet level security
- Numbered rules
- Allow and deny rules
- Default NACL behavior

## Connectivity Options

### VPC Peering
- Direct VPC-to-VPC connection
- Cross-region support
- No transitive peering
- CIDR overlap considerations
- Route table configuration

### Transit Gateway
- Hub-and-spoke networking
- Regional resource
- Cross-account support
- Route table associations
- Bandwidth aggregation

### VPC Endpoints
1. Interface Endpoints
   - Powered by PrivateLink
   - ENI with private IP
   - Security group control

2. Gateway Endpoints
   - S3 and DynamoDB
   - Route table entries
   - No ENI required

### Direct Connect
- Dedicated network connection
- Physical infrastructure
- Virtual interfaces
- BGP routing
- Redundancy options

## Advanced Features

### VPC Flow Logs
```json
{
    "version": 2,
    "account-id": "123456789012",
    "interface-id": "eni-1234567890",
    "srcaddr": "10.0.0.1",
    "dstaddr": "10.0.0.2",
    "srcport": 80,
    "dstport": 443,
    "protocol": 6,
    "packets": 1,
    "bytes": 100,
    "start": 1234567890,
    "end": 1234567890,
    "action": "ACCEPT",
    "log-status": "OK"
}
```

### Traffic Mirroring
- Packet capture
- Network monitoring
- Security analysis
- Troubleshooting
- Content inspection

### Reachability Analyzer
- Network path analysis
- Connectivity testing
- Configuration validation
- Path visualization
- Troubleshooting tool

## DNS and DHCP

### DNS Resolution
- VPC DNS hostname
- Custom DNS servers
- Route 53 integration
- Split-horizon DNS
- Private hosted zones

### DHCP Options Sets
- Domain name
- DNS servers
- NTP servers
- NetBIOS configuration
- Lease time 