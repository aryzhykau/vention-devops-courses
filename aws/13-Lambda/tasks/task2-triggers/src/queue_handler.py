import json
import logging
import os
import boto3
import traceback
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize AWS clients
sqs_client = boto3.client('sqs')
sns_client = boto3.client('sns')

def handler(event, context):
    """
    Lambda handler for SQS/SNS events
    """
    logger.info(f"Processing queue event: {json.dumps(event)}")
    
    try:
        # Process each record in the event
        results = []
        failed_records = []
        
        for record in event['Records']:
            try:
                result = process_record(record)
                results.append(result)
            except Exception as e:
                logger.error(f"Error processing record: {str(e)}")
                failed_records.append({
                    'recordIdentifier': get_record_identifier(record),
                    'error': str(e)
                })
        
        # Log processing summary
        logger.info(f"Processed {len(results)} records successfully")
        if failed_records:
            logger.error(f"Failed to process {len(failed_records)} records")
        
        return {
            'statusCode': 200 if not failed_records else 207,  # 207 Multi-Status
            'body': {
                'message': 'Processing complete',
                'requestId': context.aws_request_id,
                'timestamp': datetime.utcnow().isoformat(),
                'successful': results,
                'failed': failed_records
            }
        }
        
    except Exception as e:
        logger.error(f"Error processing event: {str(e)}")
        logger.error(traceback.format_exc())
        return {
            'statusCode': 500,
            'body': {
                'message': 'Error',
                'error': str(e)
            }
        }

def process_record(record):
    """
    Process individual record from queue
    """
    # Determine record type (SNS or SQS)
    if 'Sns' in record:
        return process_sns_record(record)
    else:
        return process_sqs_record(record)

def process_sns_record(record):
    """
    Process SNS notification record
    """
    message_id = record['Sns']['MessageId']
    timestamp = record['Sns']['Timestamp']
    topic_arn = record['Sns']['TopicArn']
    
    try:
        # Parse message content
        message = json.loads(record['Sns']['Message'])
        
        # Process message based on type
        if isinstance(message, dict) and 'type' in message:
            result = process_typed_message(message)
        else:
            result = process_generic_message(message)
            
        return {
            'status': 'processed',
            'source': 'sns',
            'messageId': message_id,
            'topicArn': topic_arn,
            'timestamp': timestamp,
            'result': result
        }
        
    except json.JSONDecodeError:
        # Handle raw string messages
        return {
            'status': 'processed',
            'source': 'sns',
            'messageId': message_id,
            'topicArn': topic_arn,
            'timestamp': timestamp,
            'result': {
                'type': 'raw',
                'content': record['Sns']['Message']
            }
        }

def process_sqs_record(record):
    """
    Process SQS message record
    """
    message_id = record['messageId']
    receipt_handle = record['receiptHandle']
    queue_url = get_queue_url_from_arn(record['eventSourceARN'])
    
    try:
        # Parse message body
        body = json.loads(record['body'])
        
        # Process message
        result = process_message_body(body)
        
        # Delete successfully processed message
        sqs_client.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=receipt_handle
        )
        
        return {
            'status': 'processed',
            'source': 'sqs',
            'messageId': message_id,
            'queueUrl': queue_url,
            'timestamp': datetime.utcnow().isoformat(),
            'result': result
        }
        
    except json.JSONDecodeError:
        # Handle raw string messages
        return {
            'status': 'processed',
            'source': 'sqs',
            'messageId': message_id,
            'queueUrl': queue_url,
            'timestamp': datetime.utcnow().isoformat(),
            'result': {
                'type': 'raw',
                'content': record['body']
            }
        }

def process_typed_message(message):
    """
    Process typed message with specific handling
    """
    message_type = message['type']
    
    if message_type == 'notification':
        return handle_notification(message)
    elif message_type == 'alert':
        return handle_alert(message)
    elif message_type == 'data':
        return handle_data(message)
    else:
        return {
            'type': message_type,
            'status': 'unhandled',
            'message': f'Unhandled message type: {message_type}'
        }

def process_generic_message(message):
    """
    Process generic message content
    """
    return {
        'type': 'generic',
        'processed': True,
        'content': message
    }

def handle_notification(message):
    """
    Handle notification type message
    """
    return {
        'type': 'notification',
        'priority': message.get('priority', 'normal'),
        'subject': message.get('subject', 'No subject'),
        'content': message.get('content', ''),
        'timestamp': datetime.utcnow().isoformat()
    }

def handle_alert(message):
    """
    Handle alert type message
    """
    return {
        'type': 'alert',
        'severity': message.get('severity', 'info'),
        'source': message.get('source', 'unknown'),
        'message': message.get('message', ''),
        'timestamp': datetime.utcnow().isoformat()
    }

def handle_data(message):
    """
    Handle data type message
    """
    return {
        'type': 'data',
        'dataset': message.get('dataset', 'unknown'),
        'records': message.get('records', []),
        'processed': True,
        'timestamp': datetime.utcnow().isoformat()
    }

def get_record_identifier(record):
    """
    Get unique identifier for record
    """
    if 'Sns' in record:
        return record['Sns']['MessageId']
    else:
        return record['messageId']

def get_queue_url_from_arn(queue_arn):
    """
    Convert SQS ARN to URL
    """
    # ARN format: arn:aws:sqs:region:account-id:queue-name
    parts = queue_arn.split(':')
    region = parts[3]
    account_id = parts[4]
    queue_name = parts[5]
    
    return f"https://sqs.{region}.amazonaws.com/{account_id}/{queue_name}" 