🚀 Portfolio Cloud Native & Architecture Serverless (AWS & Terraform)
Bienvenue dans ce dépôt présentant mon projet de portfolio d'ingénieure Cloud & DevOps. Ce projet démontre une infrastructure entièrement automatisée, hautement disponible et sécurisée, suivant les meilleures pratiques d'AWS.

Le concept : Un portfolio statique ultra-rapide couplé à un backend "Serverless" pour la gestion dynamique des contacts, sans aucun serveur à administrer.

🏗️ L'Architecture (Infrastructure as Code)
L'intégralité de l'infrastructure est orchestrée via Terraform, garantissant une reproductibilité totale du cloud.

Frontend : Site statique hébergé sur Amazon S3, distribué mondialement via AWS CloudFront (CDN) pour une latence minimale et une sécurité HTTPS renforcée.

Sécurité S3 : Accès restreint via Origin Access Control (OAC), rendant le bucket S3 totalement privé.

Backend Serverless : Logique pilotée par les événements via Lambda (Python 3.9), exposée par une Lambda Function URL (ou API Gateway) avec configuration CORS.

Base de Données : Persistance des messages dans Amazon DynamoDB (NoSQL), scalable à la demande.

Gestion des Identités : Politiques IAM strictes basées sur le principe du moindre privilège.

⚙️ Pipeline CI/CD & GitOps
Le projet automatise le cycle de vie du logiciel grâce à GitHub Actions :

Infrastructure : Chaque modification des fichiers .tf déclenche une validation et un déploiement automatique de l'infrastructure.

Frontend : Synchronisation automatique des assets (HTML/CSS/Images) vers S3 et invalidation du cache CloudFront.

Backend : Packaging et déploiement automatisé du code Python (lambda_function.zip).

🛠️ Stack Technique
IaC : Terraform (State management, Providers AWS).

Cloud (AWS) : S3, CloudFront, Lambda, DynamoDB, IAM, ACM, Route 53.

DevOps : GitHub Actions, Git, AWS CLI.

Développement : Python (Boto3), JavaScript (Fetch API), HTML5/CSS3.

📊 Monitoring & Maintenance
Health Check : Scripts de vérification de la disponibilité des endpoints.

Logs : Centralisation des logs d'exécution via Amazon CloudWatch.

🚀 Guide de Déploiement Rapide
Pré-requis
Un compte AWS et les credentials configurés (aws configure).

Terraform installé localement.

Étapes de déploiement

# 1. Initialiser le projet et les providers

terraform init

# 2. Vérifier les modifications à venir

terraform plan

# 3. Déployer l'infrastructure

terraform apply -auto-approve

# 4. Upload du contenu frontend vers S3

aws s3 cp ./frontend/ s3://nom-de-votre-bucket/ --recursive

© 2026 - Delphine Rakotondrabe - Cloud DevOps Engineer
