import json
import boto3
import uuid
import os

# Initialisation du client DynamoDB
dynamodb = boto3.resource('dynamodb')
TABLE_NAME = os.environ.get('DYNAMO_TABLE', 'PortfolioContacts')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    # Terraform gère déjà les headers CORS, on ne les définit plus ici
    
    method = event.get('requestContext', {}).get('http', {}).get('method')
    
    # Gérer la requête OPTIONS (pré-vérification du navigateur)
    if method == 'OPTIONS':
        return {
            'statusCode': 200,
            'body': ''
        }

    # Traitement du message (POST)
    try:
        body = json.loads(event.get('body', '{}'))
        
        if not body.get('email') or not body.get('message'):
            raise ValueError("Email et message sont obligatoires.")

        # Enregistrement dans DynamoDB
        table.put_item(
            Item={
                'MessageId': str(uuid.uuid4()),
                'name': body.get('name', 'Anonyme'),
                'email': body.get('email'),
                'message': body.get('message')
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'status': 'success'})
        }

    except Exception as e:
        print(f"Erreur : {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'status': 'error', 'message': "Erreur lors de l'enregistrement."})
        }