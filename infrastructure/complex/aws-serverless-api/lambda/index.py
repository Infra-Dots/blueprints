import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('DYNAMODB_TABLE_NAME')
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Simple Counter Logic for demo
        response = table.update_item(
            Key={'id': 'visit_counter'},
            UpdateExpression='ADD visits :inc',
            ExpressionAttributeValues={':inc': 1},
            ReturnValues="UPDATED_NEW"
        )
        
        visits = int(response['Attributes']['visits'])
        
        return {
            'statusCode': 200,
            'body': json.dumps(f'Hello from Serverless! Visitor count: {visits}'),
            'headers': {
                'Content-Type': 'application/json'
            }
        }
    except Exception as e:
        print(e)
        return {
            'statusCode': 500,
            'body': json.dumps('Internal Server Error')
        }
