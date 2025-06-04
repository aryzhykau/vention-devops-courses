# Amazon CloudFront Core Concepts

## Distribution
A CloudFront distribution is the main configuration unit that defines how content is delivered to end users. It includes:
- Origins: Where your content is stored
- Cache behaviors: How content is cached and delivered
- Edge locations: Where content is cached globally
- Security settings: How content is protected

## Origins
Origins are the source locations where CloudFront gets your content:

1. Amazon S3 Bucket
   - Static website hosting
   - Private content with OAI
   - Versioned content

2. Application Load Balancer
   - Dynamic content
   - Application backend
   - Custom headers

3. Custom Origin
   - HTTP/HTTPS servers
   - On-premises servers
   - Other cloud providers

## Cache Behaviors
Cache behaviors define how CloudFront handles requests:

1. Path Patterns
   - URL matching patterns
   - Multiple behaviors per distribution
   - Priority ordering

2. TTL Settings
   - Minimum TTL
   - Maximum TTL
   - Default TTL
   - Cache control headers

3. Viewer Protocol Policy
   - HTTP and HTTPS
   - HTTPS only
   - Redirect HTTP to HTTPS

4. Allowed HTTP Methods
   - GET, HEAD
   - GET, HEAD, OPTIONS
   - All methods (including POST, PUT, DELETE, PATCH)

## Edge Locations and Regional Caches

1. Edge Locations
   - Global points of presence (PoPs)
   - Cache content close to users
   - Automatic routing to nearest location

2. Regional Edge Caches
   - Larger caches between origin and edge locations
   - Reduce load on origin
   - Improve cache hit ratio

## SSL/TLS Certificates

1. Default CloudFront Certificate
   - *.cloudfront.net domain
   - Free and automatic

2. Custom SSL Certificates
   - ACM integration
   - Custom domain support
   - SNI support

3. Security Protocols
   - TLS versions
   - Cipher suites
   - HTTPS requirements

## Security Features

1. Origin Access Identity (OAI)
   - S3 bucket access control
   - Private content distribution
   - Bucket policy integration

2. Signed URLs and Cookies
   - Time-based access control
   - IP address restrictions
   - Custom policy options

3. Field-Level Encryption
   - Sensitive data protection
   - End-to-end encryption
   - Custom key management

4. AWS WAF Integration
   - Web application firewall
   - Rule sets and conditions
   - Security automation

5. Geographic Restrictions
   - Whitelist/blacklist countries
   - Compliance requirements
   - Content licensing

## Monitoring and Logging

1. CloudWatch Integration
   - Metrics and alarms
   - Performance monitoring
   - Error tracking

2. Access Logs
   - Detailed request logs
   - S3 bucket storage
   - Analysis capabilities

3. Real-time Logs
   - Low latency logging
   - Kinesis Data Streams
   - Real-time analysis

## Performance Optimization

1. Origin Shield
   - Additional caching layer
   - Reduced origin load
   - Regional optimization

2. Compression
   - Automatic compression
   - Supported file types
   - Bandwidth savings

3. Cache Optimization
   - Query string forwarding
   - Cookie handling
   - Header forwarding

## Cost Components

1. Data Transfer
   - Origin to edge locations
   - Edge locations to viewers
   - Regional pricing

2. Request Pricing
   - HTTP/HTTPS requests
   - Invalidation requests
   - SSL certificate costs

3. Optional Features
   - Field-level encryption
   - WAF usage
   - Real-time logs

## Integration with AWS Services

1. Route 53
   - DNS management
   - Health checks
   - Latency-based routing

2. AWS Certificate Manager
   - SSL/TLS certificates
   - Automatic renewal
   - Domain validation

3. AWS Shield
   - DDoS protection
   - Network layer security
   - Application layer protection

4. AWS WAF
   - Web application firewall
   - Security rules
   - Bot protection 