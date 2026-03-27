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

# Configuration des headers CORS pour la réutilisation
CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*', # À restreindre à votre domaine en prod
    'Access-Control-Allow-Methods': 'OPTIONS,POST',
    'Access-Control-Allow-Headers': 'Content-Type',
}

def lambda_handler(event, context):
    # Extraction de la méthode HTTP (compatible Lambda Function URL)
    request_context = event.get('requestContext', {})
    method = request_context.get('http', {}).get('method')
    
    # 1. Gérer la pré-vérification CORS (OPTIONS)
    if method == 'OPTIONS':
        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': ''
        }

    # 2. Traitement du message (POST)
    try:
        # Récupération du corps de la requête
        raw_body = event.get('body', '{}')
        
        # Décodage si le navigateur envoie du Base64 (courant avec CloudFront/API Gateway)
        if event.get('isBase64Encoded', False):
            raw_body = base64.b64decode(raw_body).decode('utf-8')
            
        body = json.loads(raw_body)
        
        # Validation des données
        email = body.get('email')
        message = body.get('message')
        name = body.get('name', 'Anonyme')
        
        if not email or not message:
            return {
                'statusCode': 400,
                'headers': CORS_HEADERS,
                'body': json.dumps({'status': 'error', 'message': "Email et message sont obligatoires."})
            }

        # Enregistrement dans DynamoDB
        table.put_item(
            Item={
                'MessageId': str(uuid.uuid4()),
                'name': name,
                'email': email,
                'message': message,
                'timestamp': str(boto3.resource('dynamodb').meta.client.generate_presigned_url) # Optionnel: ajout date
            }
        )
        
        return {
            'statusCode': 200,
            'headers': CORS_HEADERS,
            'body': json.dumps({'status': 'success', 'message': 'Message enregistré !'})
        }

    except Exception as e:
        # Log de l'erreur précise dans CloudWatch pour le débogage
        print(f"Erreur détaillée : {str(e)}")
        return {
            'statusCode': 500,
            'headers': CORS_HEADERS,
            'body': json.dumps({'status': 'error', 'message': "Erreur interne au serveur."})
        }