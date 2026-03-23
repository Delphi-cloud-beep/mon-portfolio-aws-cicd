import urllib.request
import sys

# Utilise ton domaine final avec HTTPS
URL_SITE = "https://www.delphine.cloud"

def check_health():
    print(f"🔍 Vérification de la santé du site : {URL_SITE}...")
    
    # On ajoute un 'User-Agent' pour simuler un vrai navigateur (évite d'être bloqué par certains pare-feu)
    req = urllib.request.Request(
        URL_SITE, 
        headers={'User-Agent': 'Mozilla/5.0 (AWS HealthCheck Script)'}
    )
    
    try:
        response = urllib.request.urlopen(req)
        status = response.getcode()
        if status == 200:
            print("✅ SUCCÈS : Le site est en ligne (Code 200).")
        else:
            print(f"⚠️ ALERTE : Réponse inhabituelle (Code {status}).")
            sys.exit(1)
    except Exception as e:
        print(f"❌ ERREUR : Le site est injoignable. Détails : {e}")
        sys.exit(1)

if __name__ == "__main__":
    check_health()