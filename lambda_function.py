import json
import boto3
import uuid
import os
import base64

# Initialisation du client DynamoDB
dynamodb = boto3.resource('dynamodb')
# On utilise la variable d'environnement définie dans Terraform
TABLE_NAME = os.environ.get('DYNAMO_TABLE', 'PortfolioContacts')
table = dynamodb.Table(TABLE_NAME)

def lambda_handler(event, context):
    # Extraction de la méthode HTTP (compatible Lambda Function URL)
    method = event.get('requestContext', {}).get('http', {}).get('method')
    
    # 1. Gérer la pré-vérification CORS (OPTIONS)
    if method == 'OPTIONS':
        return {
            'statusCode': 200,
            'body': ''
        }

    # 2. Traitement du message (POST)
    try:
        # Récupération du corps de la requête
        raw_body = event.get('body', '{}')
        
        # Correction cruciale : Décodage si le navigateur envoie du Base64
        if event.get('isBase64Encoded', False):
            raw_body = base64.b64decode(raw_body).decode('utf-8')
            
        body = json.loads(raw_body)
        
        # Validation des données[cite: 6]
        email = body.get('email')
        message = body.get('message')
        
        if not email or not message:
            return {
                'statusCode': 400,
                'body': json.dumps({'status': 'error', 'message': "Email et message sont obligatoires."})
            }

        # Enregistrement dans DynamoDB[cite: 6]
        table.put_item(
            Item={
                'MessageId': str(uuid.uuid4()),
                'name': body.get('name', 'Anonyme'),
                'email': email,
                'message': message
            }
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({'status': 'success', 'message': 'Message enregistré !'})
        }

    except Exception as e:
        # Log de l'erreur précise dans CloudWatch pour le débogage[cite: 6]
        print(f"Erreur détaillée : {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'status': 'error', 'message': "Erreur interne au serveur."})
        }