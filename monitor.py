import urllib.request
import sys

# Remplace par l'URL finale de ton site AWS (S3 ou CloudFront)
URL_SITE = "http://ton-site.s3-website.eu-west-3.amazonaws.com"

def check_health():
    print(f"Vérification de la santé du site : {URL_SITE}...")
    try:
        response = urllib.request.urlopen(URL_SITE)
        status = response.getcode()
        if status == 200:
            print("✅ SUCCÈS : Le site répond parfaitement (Code 200).")
        else:
            print(f"⚠️ ALERTE : Le site répond avec un code {status}.")
    except Exception as e:
        print(f"❌ ERREUR : Impossible de joindre le site. Détails : {e}")
        sys.exit(1)

if __name__ == "__main__":
    check_health()