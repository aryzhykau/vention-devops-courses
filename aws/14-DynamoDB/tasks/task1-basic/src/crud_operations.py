import boto3
import logging
import json
import os
from botocore.exceptions import ClientError
from typing import Dict, List, Optional, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')

class DynamoDBOperations:
    def __init__(self, table_name: str):
        """
        Initialize DynamoDB operations with table name
        """
        self.table = dynamodb.Table(table_name)
        self.table_name = table_name

    def create_item(self, item: Dict[str, Any]) -> Dict[str, Any]:
        """
        Create a new item in the table
        """
        try:
            response = self.table.put_item(Item=item)
            logger.info(f"Successfully created item in table {self.table_name}")
            return {
                'success': True,
                'message': 'Item created successfully',
                'data': item
            }
        except ClientError as e:
            logger.error(f"Error creating item: {str(e)}")
            return {
                'success': False,
                'message': str(e),
                'error': e.response['Error']['Code']
            }

    def get_item(self, key: Dict[str, Any]) -> Dict[str, Any]:
        """
        Retrieve an item from the table by its key
        """
        try:
            response = self.table.get_item(Key=key)
            item = response.get('Item')
            
            if item:
                logger.info(f"Successfully retrieved item from table {self.table_name}")
                return {
                    'success': True,
                    'message': 'Item retrieved successfully',
                    'data': item
                }
            else:
                logger.warning(f"Item not found in table {self.table_name}")
                return {
                    'success': False,
                    'message': 'Item not found',
                    'error': 'NotFound'
                }
        except ClientError as e:
            logger.error(f"Error retrieving item: {str(e)}")
            return {
                'success': False,
                'message': str(e),
                'error': e.response['Error']['Code']
            }

    def update_item(self, key: Dict[str, Any], updates: Dict[str, Any]) -> Dict[str, Any]:
        """
        Update an existing item in the table
        """
        try:
            # Construct update expression and attribute values
            update_expression = "SET "
            expression_attribute_values = {}
            expression_attribute_names = {}
            
            for field, value in updates.items():
                placeholder = f":val_{field}"
                name_placeholder = f"#{field}"
                update_expression += f" {name_placeholder} = {placeholder},"
                expression_attribute_values[placeholder] = value
                expression_attribute_names[name_placeholder] = field
            
            # Remove trailing comma
            update_expression = update_expression.rstrip(',')
            
            response = self.table.update_item(
                Key=key,
                UpdateExpression=update_expression,
                ExpressionAttributeValues=expression_attribute_values,
                ExpressionAttributeNames=expression_attribute_names,
                ReturnValues="ALL_NEW"
            )
            
            logger.info(f"Successfully updated item in table {self.table_name}")
            return {
                'success': True,
                'message': 'Item updated successfully',
                'data': response.get('Attributes', {})
            }
        except ClientError as e:
            logger.error(f"Error updating item: {str(e)}")
            return {
                'success': False,
                'message': str(e),
                'error': e.response['Error']['Code']
            }

    def delete_item(self, key: Dict[str, Any]) -> Dict[str, Any]:
        """
        Delete an item from the table
        """
        try:
            response = self.table.delete_item(Key=key)
            logger.info(f"Successfully deleted item from table {self.table_name}")
            return {
                'success': True,
                'message': 'Item deleted successfully'
            }
        except ClientError as e:
            logger.error(f"Error deleting item: {str(e)}")
            return {
                'success': False,
                'message': str(e),
                'error': e.response['Error']['Code']
            }

    def query_items(self, key_condition: str, values: Dict[str, Any]) -> Dict[str, Any]:
        """
        Query items using key condition expression
        """
        try:
            response = self.table.query(
                KeyConditionExpression=key_condition,
                ExpressionAttributeValues=values
            )
            
            items = response.get('Items', [])
            logger.info(f"Successfully queried {len(items)} items from table {self.table_name}")
            
            return {
                'success': True,
                'message': 'Query executed successfully',
                'data': items,
                'count': len(items)
            }
        except ClientError as e:
            logger.error(f"Error querying items: {str(e)}")
            return {
                'success': False,
                'message': str(e),
                'error': e.response['Error']['Code']
            }

    def batch_write_items(self, items: List[Dict[str, Any]]) -> Dict[str, Any]:
        """
        Write multiple items in batch
        """
        try:
            with self.table.batch_writer() as batch:
                for item in items:
                    batch.put_item(Item=item)
            
            logger.info(f"Successfully batch wrote {len(items)} items to table {self.table_name}")
            return {
                'success': True,
                'message': f'Successfully wrote {len(items)} items',
                'count': len(items)
            }
        except ClientError as e:
            logger.error(f"Error in batch write: {str(e)}")
            return {
                'success': False,
                'message': str(e),
                'error': e.response['Error']['Code']
            }

    def scan_table(self, filter_expression: Optional[str] = None, 
                  values: Optional[Dict[str, Any]] = None) -> Dict[str, Any]:
        """
        Scan the entire table with optional filter
        """
        try:
            if filter_expression and values:
                response = self.table.scan(
                    FilterExpression=filter_expression,
                    ExpressionAttributeValues=values
                )
            else:
                response = self.table.scan()
            
            items = response.get('Items', [])
            logger.info(f"Successfully scanned {len(items)} items from table {self.table_name}")
            
            return {
                'success': True,
                'message': 'Scan executed successfully',
                'data': items,
                'count': len(items)
            }
        except ClientError as e:
            logger.error(f"Error scanning table: {str(e)}")
            return {
                'success': False,
                'message': str(e),
                'error': e.response['Error']['Code']
            }

def lambda_handler(event: Dict[str, Any], context: Any) -> Dict[str, Any]:
    """
    Lambda handler for DynamoDB operations
    """
    try:
        # Get table name from environment variable
        table_name = os.environ.get('TABLE_NAME')
        if not table_name:
            raise ValueError("TABLE_NAME environment variable not set")
        
        # Initialize DynamoDB operations
        db_ops = DynamoDBOperations(table_name)
        
        # Get operation type and payload from event
        operation = event.get('operation')
        payload = event.get('payload', {})
        
        if not operation:
            raise ValueError("Operation not specified in event")
        
        # Execute requested operation
        if operation == 'create':
            return db_ops.create_item(payload)
        elif operation == 'read':
            return db_ops.get_item(payload)
        elif operation == 'update':
            key = payload.get('key', {})
            updates = payload.get('updates', {})
            return db_ops.update_item(key, updates)
        elif operation == 'delete':
            return db_ops.delete_item(payload)
        elif operation == 'query':
            condition = payload.get('condition')
            values = payload.get('values', {})
            return db_ops.query_items(condition, values)
        elif operation == 'scan':
            filter_expr = payload.get('filter')
            values = payload.get('values')
            return db_ops.scan_table(filter_expr, values)
        elif operation == 'batch_write':
            items = payload.get('items', [])
            return db_ops.batch_write_items(items)
        else:
            raise ValueError(f"Unsupported operation: {operation}")
            
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        return {
            'success': False,
            'message': str(e),
            'error': 'InternalError'
        } 