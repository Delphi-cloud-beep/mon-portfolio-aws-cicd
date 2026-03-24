# 🚀 Portfolio Cloud Native & Pipeline CI/CD (AWS & Terraform)

![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?style=for-the-badge&logo=amazon-aws&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232088FF.svg?style=for-the-badge&logo=githubactions&logoColor=white)

Bienvenue sur mon projet de portfolio d'ingénieure DevOps. Ce dépôt démontre une infrastructure entièrement automatisée, sécurisée et scalable.

**Le concept :** Un formulaire de contact "Serverless" qui traite et stocke les messages sans aucun serveur à gérer.

---

## 🏗️ L'Architecture (Infrastructure as Code)

L'intégralité de l'infrastructure est orchestrée via **Terraform**, garantissant une reproductibilité totale et une gestion simplifiée du cycle de vie des ressources.

- **Frontend :** Hébergement sur **AWS S3** avec distribution **CloudFront** (Edge computing & HTTPS).
- **Backend Serverless :** Architecture pilotée par les événements via **API Gateway** → **AWS Lambda (Python)**.
- **Stockage de Données :** Base de données NoSQL **Amazon DynamoDB** pour la persistance des messages de contact.
- **Sécurité :** Gestion fine des accès via des politiques **IAM** (Principe du moindre privilège).

---

## ⚙️ Automatisation & CI/CD

Le projet suit les principes du **GitOps** :

1. **CI/CD :** Chaque `push` sur la branche `main` déclenche un workflow **GitHub Actions** qui synchronise le code source et met à jour l'infrastructure.
2. **Qualité :** Validation de la syntaxe Terraform et déploiement automatisé des assets statiques.

---

## 🛠️ Stack Technique

- **IaC :** Terraform (Modules, State management).
- **Cloud :** AWS (S3, CloudFront, Lambda, DynamoDB, IAM).
- **DevOps :** GitHub Actions, Git, Python (Boto3).
- **Frontend :** HTML5 / CSS3 / JavaScript (Dashboard de contact).

---

## 📊 Monitoring & Santé du Service

Le projet inclut un script de santé hybride :

- **`monitor.py` :** Un script Python de health check pour vérifier la disponibilité de l'API et du frontend en temps réel.
- **`index.py` :** Logique backend optimisée pour le traitement des requêtes JSON.

---

## 🚀 Comment déployer ?

```powershell
# Initialiser le backend Terraform
terraform init

# Planifier et valider les ressources
terraform plan

# Déployer sur AWS
terraform apply -auto-approve

```
