# Amazon Elastic Load Balancer Core Concepts

## Load Balancer Types

### 1. Application Load Balancer (ALB)
- Layer 7 load balancing
- HTTP/HTTPS traffic
- Advanced routing capabilities:
  - Path-based routing
  - Host-based routing
  - Query string routing
  - HTTP header routing
- Support for WebSocket and HTTP/2
- Authentication integration
- SSL/TLS termination

### 2. Network Load Balancer (NLB)
- Layer 4 load balancing
- TCP/UDP/TLS traffic
- Ultra-high performance
- Static IP addresses
- Preserve source IP address
- Long-lived connections
- Elastic IP per AZ

### 3. Gateway Load Balancer (GWLB)
- Layer 3/4 load balancing
- GENEVE protocol (port 6081)
- Transparent network gateway
- Security appliance integration
- Scales with demand
- Preserves source/destination IP

## Target Groups

### Configuration
1. Target Type
   - Instance
   - IP address
   - Lambda function
   - Application Load Balancer

2. Protocol
   - HTTP/HTTPS (ALB)
   - TCP/UDP/TLS (NLB)
   - GENEVE (GWLB)

3. Port
   - Application port
   - Health check port
   - Override port

### Health Checks
1. Settings
   - Protocol
   - Port
   - Path (for HTTP/HTTPS)
   - Interval
   - Timeout
   - Healthy threshold
   - Unhealthy threshold

2. Advanced Options
   - Success codes
   - Custom response codes
   - Detailed health status

## Listeners and Rules

### Listener Configuration
1. Protocol
   - HTTP/HTTPS (ALB)
   - TCP/UDP/TLS (NLB)
   - GENEVE (GWLB)

2. Port
   - Standard ports
   - Custom ports
   - Port ranges (NLB)

### Rule Types
1. Path Pattern
   - Exact match
   - Wildcard match
   - Regular expressions

2. Host Header
   - Domain matching
   - Wildcard domains
   - Multiple domains

3. HTTP Headers
   - Custom headers
   - Standard headers
   - Value matching

4. Query Strings
   - Key-value pairs
   - Multiple values
   - Value matching

### Actions
1. Forward
   - Single target group
   - Multiple target groups
   - Weighted distribution

2. Redirect
   - URL redirection
   - HTTPS redirect
   - Custom status code

3. Fixed Response
   - Custom status code
   - Content type
   - Message body

4. Authenticate
   - OIDC
   - Cognito
   - Custom authentication

## SSL/TLS Termination

### Certificate Management
1. ACM Integration
   - Certificate provisioning
   - Automatic renewal
   - Regional certificates

2. Certificate Types
   - Single domain
   - Wildcard
   - Multi-domain (SAN)

### Security Policies
1. TLS Versions
   - TLS 1.0/1.1/1.2/1.3
   - Protocol enforcement
   - Cipher suites

2. Security Features
   - Perfect Forward Secrecy
   - OCSP Stapling
   - Server Order Preference

## Monitoring and Logging

### CloudWatch Integration
1. Metrics
   - Request count
   - Latency
   - HTTP status codes
   - Connection count
   - TLS negotiation errors

2. Alarms
   - Health status
   - Performance thresholds
   - Error rates
   - Capacity limits

### Access Logging
1. Log Types
   - Application logs
   - Access logs
   - Error logs

2. Log Fields
   - Request details
   - Client information
   - Processing time
   - Response details

## Advanced Features

### Cross-Zone Load Balancing
1. Configuration
   - Enable/disable per load balancer
   - AZ failover
   - Connection draining

2. Pricing
   - Inter-AZ data transfer
   - Cost implications
   - Optimization strategies

### Sticky Sessions
1. Application-Based
   - Application-generated cookie
   - Custom cookie name
   - Cookie duration

2. Load Balancer-Generated
   - Duration-based cookie
   - Cookie encryption
   - Cookie attributes

### Connection Settings
1. Idle Timeout
   - Connection persistence
   - Timeout configuration
   - WebSocket support

2. Deregistration Delay
   - Connection draining
   - Custom delay
   - Immediate removal

## Integration with AWS Services

### Auto Scaling
1. Target Tracking
   - Scaling policies
   - Capacity management
   - Performance optimization

2. Health Check Integration
   - Instance health
   - Custom health checks
   - Replacement triggers

### Route 53
1. DNS Integration
   - Alias records
   - Health checks
   - Failover routing

2. Regional Failover
   - Multi-region setup
   - Disaster recovery
   - Global routing

### WAF and Shield
1. Security Integration
   - WAF rules
   - DDoS protection
   - Rate limiting

2. Monitoring
   - Security events
   - Attack patterns
   - Mitigation actions 