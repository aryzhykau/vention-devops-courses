import json
import logging
import os
import traceback
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    """
    Lambda handler for API Gateway events
    """
    logger.info(f"Processing API Gateway event: {json.dumps(event)}")
    
    try:
        # Get environment
        environment = os.environ.get('ENVIRONMENT', 'dev')
        
        # Parse request
        request_body = parse_request(event)
        
        # Process request
        result = process_request(request_body)
        
        # Return success response
        return create_response(200, {
            'message': 'Success',
            'environment': environment,
            'requestId': context.aws_request_id,
            'timestamp': datetime.utcnow().isoformat(),
            'data': result
        })
        
    except ValueError as e:
        logger.error(f"Validation error: {str(e)}")
        return create_response(400, {
            'message': 'Bad Request',
            'error': str(e)
        })
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        logger.error(traceback.format_exc())
        return create_response(500, {
            'message': 'Internal Server Error',
            'error': str(e)
        })

def parse_request(event):
    """
    Parse and validate the API Gateway event
    """
    # Get request body
    if 'body' not in event:
        raise ValueError("Missing request body")
        
    try:
        if isinstance(event['body'], str):
            body = json.loads(event['body'])
        else:
            body = event['body']
    except json.JSONDecodeError:
        raise ValueError("Invalid JSON in request body")
        
    # Validate request
    validate_request(body)
    
    return body

def validate_request(body):
    """
    Validate the request body
    """
    # Add your validation logic here
    # For example:
    required_fields = ['action', 'data']
    for field in required_fields:
        if field not in body:
            raise ValueError(f"Missing required field: {field}")
            
    valid_actions = ['create', 'read', 'update', 'delete']
    if body['action'] not in valid_actions:
        raise ValueError(f"Invalid action. Must be one of: {valid_actions}")

def process_request(request):
    """
    Process the validated request
    """
    # Add your business logic here
    # For example:
    action = request['action']
    data = request['data']
    
    result = {
        'action': action,
        'processed': True,
        'timestamp': datetime.utcnow().isoformat(),
        'data': data
    }
    
    logger.info(f"Processed request: {json.dumps(result)}")
    return result

def create_response(status_code, body):
    """
    Create API Gateway response object
    """
    return {
        'statusCode': status_code,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
            'Access-Control-Allow-Methods': 'GET,OPTIONS,POST,PUT'
        },
        'body': json.dumps(body)
    } 