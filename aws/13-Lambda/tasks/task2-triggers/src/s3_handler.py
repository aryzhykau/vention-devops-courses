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
s3_client = boto3.client('s3')

def handler(event, context):
    """
    Lambda handler for S3 events
    """
    logger.info(f"Processing S3 event: {json.dumps(event)}")
    
    try:
        # Process each record in the event
        results = []
        for record in event['Records']:
            result = process_record(record)
            results.append(result)
            
        logger.info(f"Successfully processed {len(results)} records")
        return {
            'statusCode': 200,
            'body': {
                'message': 'Success',
                'requestId': context.aws_request_id,
                'timestamp': datetime.utcnow().isoformat(),
                'results': results
            }
        }
        
    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}")
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
    Process individual S3 event record
    """
    # Extract S3 event information
    bucket = record['s3']['bucket']['name']
    key = record['s3']['object']['key']
    event_name = record['eventName']
    event_time = record['eventTime']
    
    logger.info(f"Processing {event_name} event for s3://{bucket}/{key}")
    
    try:
        if event_name.startswith('ObjectCreated:'):
            return handle_object_created(bucket, key)
        elif event_name.startswith('ObjectRemoved:'):
            return handle_object_removed(bucket, key)
        else:
            logger.warning(f"Unsupported event type: {event_name}")
            return {
                'status': 'skipped',
                'event': event_name,
                'bucket': bucket,
                'key': key,
                'timestamp': event_time
            }
            
    except Exception as e:
        logger.error(f"Error processing record: {str(e)}")
        return {
            'status': 'error',
            'event': event_name,
            'bucket': bucket,
            'key': key,
            'error': str(e),
            'timestamp': event_time
        }

def handle_object_created(bucket, key):
    """
    Handle S3 object creation event
    """
    # Get object metadata
    response = s3_client.head_object(Bucket=bucket, Key=key)
    content_type = response.get('ContentType', 'application/octet-stream')
    size = response.get('ContentLength', 0)
    
    # Process based on content type
    if content_type.startswith('text/'):
        # Process text files
        content = get_object_content(bucket, key)
        result = process_text_content(content)
    elif content_type.startswith('image/'):
        # Process image files
        result = {
            'type': 'image',
            'size': size,
            'format': content_type.split('/')[-1]
        }
    else:
        result = {
            'type': 'other',
            'size': size,
            'format': content_type
        }
    
    return {
        'status': 'processed',
        'event': 'ObjectCreated',
        'bucket': bucket,
        'key': key,
        'contentType': content_type,
        'size': size,
        'result': result,
        'timestamp': datetime.utcnow().isoformat()
    }

def handle_object_removed(bucket, key):
    """
    Handle S3 object removal event
    """
    return {
        'status': 'processed',
        'event': 'ObjectRemoved',
        'bucket': bucket,
        'key': key,
        'timestamp': datetime.utcnow().isoformat()
    }

def get_object_content(bucket, key):
    """
    Get S3 object content
    """
    response = s3_client.get_object(Bucket=bucket, Key=key)
    return response['Body'].read().decode('utf-8')

def process_text_content(content):
    """
    Process text file content
    """
    # Add your text processing logic here
    # For example:
    lines = content.split('\n')
    word_count = sum(len(line.split()) for line in lines)
    char_count = sum(len(line) for line in lines)
    
    return {
        'type': 'text',
        'lines': len(lines),
        'words': word_count,
        'characters': char_count
    } 