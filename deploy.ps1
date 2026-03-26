# -------------------------------
# Variables à adapter
# -------------------------------
$repoUrl   = "https://github.com/Delphi-cloud-beep/mon-portfolio-aws-cicd.git"
$localPath = "E:\Local Data 1\D\Delphine\AWS\mon-portfolio-aws-cicd"
$lambdaFile = "lambda_function.py"
$zipFile    = "lambda_function.zip"

# -------------------------------
# 1️⃣ Cloner ou mettre à jour le repo
# -------------------------------
if (!(Test-Path $localPath)) {
    Write-Host "Clonage du repo depuis GitHub..."
    git clone $repoUrl $localPath
} else {
    Write-Host "Mise à jour du repo existant..."
    cd $localPath
    git pull origin main
}

cd $localPath

# -------------------------------
# 2️⃣ Créer le ZIP de la Lambda
# -------------------------------
if (!(Test-Path $lambdaFile)) {
    Write-Error "❌ Le fichier $lambdaFile est introuvable. Crée le avant de continuer !"
    exit
}

if (Test-Path $zipFile) { Remove-Item $zipFile }
Write-Host "Création du fichier ZIP pour Lambda..."
Compress-Archive -Path $lambdaFile -DestinationPath $zipFile -Force

# -------------------------------
# 3️⃣ Initialiser Terraform
# -------------------------------
Write-Host "Initialisation de Terraform..."
.\terraform.exe init

# -------------------------------
# 4️⃣ Appliquer Terraform
# -------------------------------
$confirm = Read-Host "Tape 'yes' pour appliquer les changements Terraform"
if ($confirm -eq "yes") {
    .\terraform.exe apply -auto-approve
    Write-Host "✅ Déploiement Terraform terminé !"
} else {
    Write-Host "Déploiement annulé."
}

# -------------------------------
# 5️⃣ Afficher l'URL publique de la Lambda
# -------------------------------
Write-Host "`n📌 URL publique de la Lambda (à mettre dans ton HTML) :"
terraform output -raw form_action_url








Ouvre PowerShell et exécute le script :
cd "E:\Local Data 1\D\Delphine\AWS\mon-portfolio-aws-cicd"
.\deploy.ps1