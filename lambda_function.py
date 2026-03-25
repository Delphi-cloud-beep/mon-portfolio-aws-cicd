import json
import boto3
import os
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ.get('DYNAMO_TABLE', 'PortfolioContacts'))

def lambda_handler(event, context):
    body = json.loads(event.get('body', '{}'))
    item = {
        'MessageId': str(uuid.uuid4()),
        'Name': body.get('name', ''),
        'Email': body.get('email', ''),
        'Message': body.get('message', ''),
        'Timestamp': datetime.utcnow().isoformat()
    }
    table.put_item(Item=item)
    return {
        'statusCode': 200,
        'headers': { "Content-Type": "application/json" },
        'body': json.dumps({ "message": "Message reçu !" })
    }