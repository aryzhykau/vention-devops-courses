# SNS-SQS Best Practices

## Message Design
- Keep messages small and concise
- Include only necessary metadata
- Use message attributes for filtering
- Consider using message batching for efficiency

## Queue Configuration
1. **Visibility Timeout**
   - Set appropriate visibility timeout based on processing time
   - Consider retry scenarios
   - Monitor for message timeouts

2. **Dead Letter Queues**
   - Always configure DLQ for production queues
   - Set appropriate maximum receives
   - Monitor DLQ regularly

3. **Queue Settings**
   - Enable long polling when possible
   - Set appropriate message retention period
   - Configure delay queues when needed

## SNS Topics
1. **Topic Design**
   - Use clear naming conventions
   - Implement proper access controls
   - Consider FIFO topics for ordered delivery

2. **Subscription Filter Policies**
   - Use message filtering to reduce unnecessary processing
   - Keep filter policies simple
   - Monitor filter policy matches and misses

## Security
1. **Access Control**
   - Use least privilege principle
   - Implement resource-based policies
   - Enable encryption at rest
   - Use VPC endpoints when possible

2. **Monitoring**
   - Set up CloudWatch alarms for queue depth
   - Monitor failed deliveries
   - Track message age metrics

## Performance
1. **Scaling**
   - Use multiple consumers for high-throughput queues
   - Implement proper error handling and retries
   - Monitor throughput metrics

2. **Cost Optimization**
   - Delete processed messages promptly
   - Use batch operations when possible
   - Monitor API usage

## Architecture Patterns
1. **Fan-out Pattern**
   - Use SNS for fan-out to multiple SQS queues
   - Consider message filtering at subscription
   - Monitor delivery status

2. **Error Handling**
   - Implement exponential backoff
   - Use DLQ for failed messages
   - Log error details for debugging

## Operational Excellence
1. **Monitoring**
   - Set up dashboards for key metrics
   - Configure alerts for anomalies
   - Monitor costs and usage

2. **Documentation**
   - Document queue and topic configurations
   - Maintain subscriber list
   - Document retry and error handling policies

## Testing
1. **Load Testing**
   - Test with expected message volumes
   - Verify throughput capabilities
   - Test failure scenarios

2. **Integration Testing**
   - Test end-to-end message flow
   - Verify message format handling
   - Test error scenarios 