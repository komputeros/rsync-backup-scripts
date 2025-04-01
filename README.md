# Rsync Backup System – Pełna Instrukcja

Kompletny zestaw skryptów do backupu przy użyciu `rsync` + `--link-dest` z rotacją i powiadomieniem przez Mailgun.

## 📁 Struktura katalogów

```
/backup/
├── backup_YYYY-MM-DD/   # snapshot backupu
├── latest → backup_YYYY-MM-DD  # symlink do najnowszego
└── ... inne katalogi
```

## ✅ Wymagania

- Linux (serwer i klient)
- `rsync`, `cron`, `ssh`
- (opcjonalnie) konto Mailgun

## 🔧 Instalacja

1. Utwórz użytkownika do backupu:
```bash
sudo useradd -m -s /bin/bash backup_client
sudo passwd backup_client
```

2. Utwórz katalogi:
```bash
sudo mkdir -p /backup/latest /etc/backup
sudo touch /var/log/backup_rotation.log
```

3. Uprawnienia:
```bash
sudo chown -R root:root /backup
sudo chmod 755 /backup
sudo chown backup_client:backup_client /backup/latest
sudo chmod 755 /backup/latest
sudo chmod 644 /var/log/backup_rotation.log
```

4. Skopiuj wszystkie skrypty do `/etc/backup/`:
```bash
sudo mv *.sh /etc/backup/
sudo chmod +x /etc/backup/*.sh
```

5. Ustaw cron (jako `root`):
```bash
sudo crontab -e
# codzienny watcher
* * * * * /etc/backup/watch_and_rotate.sh
# lub backup pull raz w tygodniu (niedziela 2:30)
30 2 * * 0 /etc/backup/pull_backup_server.sh
```

## 🔐 Uwierzytelnianie SSH

Wygeneruj klucz:
```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_backup
```

Skopiuj na klienta:
```bash
ssh-copy-id -i ~/.ssh/id_backup.pub backup@client
```

Dodaj do `~/.ssh/config`:
```text
Host backup-klient
    HostName client
    User backup
    IdentityFile ~/.ssh/id_backup
```

## ✉️ Powiadomienia Mailgun

1. Utwórz `.env` w `/etc/backup/`:
```bash
MAILGUN_API_KEY=key-xxx
MAILGUN_DOMAIN=sandbox123.mailgun.org
MAILGUN_TO_EMAIL=you@example.com
```

2. Skrypt `/etc/backup/post_backup_notify_mailgun_html.sh` pobierze dane z `.env`

## 🧪 Testowanie

Zobacz plik `test_backup_procedure.txt` – opisuje jak przetestować backup bez dużych danych, z uwzględnieniem awarii.

## 📦 Skrypty

- `pull_backup_server.sh` – backup z klienta
- `rotate.sh` – rotacja wersji
- `watch_and_rotate.sh` – reaguje na `done.flag`
- `post_backup.sh` – działania końcowe + rotacja logu
- `post_backup_notify_mailgun_html.sh` – wysyła maila z logiem
- `rsync_backup_client.sh` – klient typu push (opcjonalnie)

Gotowe do produkcji!
