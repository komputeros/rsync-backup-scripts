#!/bin/bash

# === WCZYTAJ DANE Z .env ===
ENV_FILE="/etc/backup/.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Brak pliku konfiguracyjnego: $ENV_FILE"
  exit 1
fi

source "$ENV_FILE"

# === SPRAWDŹ WYMAGANE ZMIENNE ===
if [[ -z "$MAILGUN_API_KEY" || -z "$MAILGUN_DOMAIN" || -z "$MAILGUN_TO_EMAIL" ]]; then
  echo "❌ Brakuje zmiennych MAILGUN_API_KEY, MAILGUN_DOMAIN lub MAILGUN_TO_EMAIL"
  exit 1
fi

# === USTAWIENIA ===
FROM_EMAIL="Backup System <backup@${MAILGUN_DOMAIN}>"
SUBJECT="✔️ Backup zakończony pomyślnie z logiem"
LOGFILE="/var/log/backup_rotation.log"
HTML_BODY="<html><body><h2>Backup zakończony pomyślnie</h2><p><strong>Data:</strong> $(date)</p><p><strong>Serwer:</strong> $(hostname)</p></body></html>"

# === WALIDACJA LOGU ===
if [ ! -f "$LOGFILE" ]; then
  echo "❌ Nie znaleziono pliku logu: $LOGFILE"
  exit 1
fi

# === WYSYŁANIE ===
RESPONSE=$(curl -s --fail --user "api:${MAILGUN_API_KEY}" \
  https://api.mailgun.net/v3/${MAILGUN_DOMAIN}/messages \
  -F from="${FROM_EMAIL}" \
  -F to="${MAILGUN_TO_EMAIL}" \
  -F subject="${SUBJECT}" \
  -F html="${HTML_BODY}" \
  -F attachment=@"${LOGFILE}")

# === OBSŁUGA BŁĘDÓW ===
if [ $? -eq 0 ]; then
  echo "📬 Powiadomienie Mailgun zostało wysłane."
else
  echo "❌ Błąd wysyłania maila przez Mailgun!"
  echo "Odpowiedź API: $RESPONSE"
  exit 1
fi

