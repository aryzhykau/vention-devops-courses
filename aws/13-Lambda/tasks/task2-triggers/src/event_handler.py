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
events_client = boto3.client('events')

def handler(event, context):
    """
    Lambda handler for EventBridge events
    """
    logger.info(f"Processing EventBridge event: {json.dumps(event)}")
    
    try:
        # Get environment
        environment = os.environ.get('ENVIRONMENT', 'dev')
        
        # Process event based on type
        if is_scheduled_event(event):
            result = handle_scheduled_event(event)
        else:
            result = handle_custom_event(event)
            
        # Return success response
        return {
            'statusCode': 200,
            'body': {
                'message': 'Success',
                'environment': environment,
                'requestId': context.aws_request_id,
                'timestamp': datetime.utcnow().isoformat(),
                'result': result
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

def is_scheduled_event(event):
    """
    Check if the event is a scheduled event
    """
    return (
        'detail-type' in event and
        event['detail-type'] == 'Scheduled Event' and
        event['source'] == 'aws.events'
    )

def handle_scheduled_event(event):
    """
    Handle scheduled EventBridge event
    """
    logger.info("Processing scheduled event")
    
    # Get schedule information
    schedule_time = event['time']
    account = event['account']
    region = event['region']
    
    # Add your scheduled task logic here
    # For example:
    task_result = execute_scheduled_task()
    
    return {
        'type': 'scheduled',
        'schedule_time': schedule_time,
        'account': account,
        'region': region,
        'task_result': task_result,
        'timestamp': datetime.utcnow().isoformat()
    }

def handle_custom_event(event):
    """
    Handle custom EventBridge event
    """
    logger.info("Processing custom event")
    
    # Extract event information
    event_type = event.get('detail-type', 'Unknown')
    source = event.get('source', 'Unknown')
    detail = event.get('detail', {})
    
    # Process based on event type
    if event_type == 'CustomEvent':
        result = process_custom_event(detail)
    else:
        result = {
            'status': 'unhandled',
            'message': f'Unhandled event type: {event_type}'
        }
    
    return {
        'type': 'custom',
        'event_type': event_type,
        'source': source,
        'result': result,
        'timestamp': datetime.utcnow().isoformat()
    }

def execute_scheduled_task():
    """
    Execute scheduled task logic
    """
    # Add your scheduled task implementation here
    # For example:
    tasks_processed = 0
    errors = []
    
    try:
        # Simulate task execution
        tasks_processed = 5
        logger.info(f"Successfully processed {tasks_processed} tasks")
    except Exception as e:
        errors.append(str(e))
        logger.error(f"Error executing scheduled task: {str(e)}")
    
    return {
        'tasks_processed': tasks_processed,
        'errors': errors,
        'status': 'success' if not errors else 'error'
    }

def process_custom_event(detail):
    """
    Process custom event details
    """
    # Add your custom event processing logic here
    # For example:
    event_id = detail.get('eventId')
    event_data = detail.get('data', {})
    
    # Process the event data
    processed_data = {
        'id': event_id,
        'processed': True,
        'data': event_data
    }
    
    logger.info(f"Processed custom event: {json.dumps(processed_data)}")
    return processed_data 