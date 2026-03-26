terraform {
  backend "s3" {
    bucket         = "delphine-terraform-state-2026" # Le nom du bucket créé à l'étape 1
    key            = "portfolio/terraform.tfstate"   # Chemin du fichier dans le bucket
    region         = "eu-west-3"
  }
}