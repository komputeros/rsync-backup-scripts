#!/bin/bash

# === KONFIGURACJA ===
MAILGUN_API_KEY="YOUR_API_KEY_HERE"
MAILGUN_DOMAIN="YOUR_DOMAIN_HERE"
FROM_EMAIL="Backup System <backup@${MAILGUN_DOMAIN}>"
TO_EMAIL="you@example.com"
SUBJECT="✔️ Backup zakończony pomyślnie z logiem"
LOGFILE="/var/log/backup_rotation.log"
HTML_BODY="<html><body><h2>Backup zakończony pomyślnie</h2><p><strong>Data:</strong> $(date)</p><p><strong>Serwer:</strong> $(hostname)</p></body></html>"

# === WALIDACJA LOGU ===
if [ ! -f "$LOGFILE" ]; then
  echo "Błąd: nie znaleziono pliku logu: $LOGFILE"
  exit 1
fi

# === WYSYŁANIE ===
RESPONSE=$(curl -s --fail --user "api:${MAILGUN_API_KEY}" \
  https://api.mailgun.net/v3/${MAILGUN_DOMAIN}/messages \
  -F from="${FROM_EMAIL}" \
  -F to="${TO_EMAIL}" \
  -F subject="${SUBJECT}" \
  -F html="${HTML_BODY}" \
  -F attachment=@"${LOGFILE}")

# === OBSŁUGA BŁĘDÓW ===
if [ $? -eq 0 ]; then
  echo "Mail z raportem backupu został wysłany pomyślnie."
else
  echo "❌ Błąd podczas wysyłania maila przez Mailgun!"
  echo "Odpowiedź API: $RESPONSE"
  exit 1
fi

