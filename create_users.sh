#!/bin/bash
# Script som skapar nya användare med hemkatalog, mappar och välkomstfil
# Används av systemadministratörer för att onboarda nya användare

# Kontrollera att scriptet körs som root (administratör)
if [ "$EUID" -ne 0 ]; then
  echo "Fel: Scriptet måste köras som root. Använd sudo."
  exit 1
fi

# Loop 1: Skapa alla användare och mappar först
for username in "$@"; do

  # Skapa användarkontot med en hemkatalog
  useradd -m "$username"

  HOME_DIR="/home/$username"

  # Skapa standardmapparna i hemkatalogen
  mkdir -p "$HOME_DIR/Documents" "$HOME_DIR/Downloads" "$HOME_DIR/Work"

  # Sätt ägare och begränsa rättigheter (700 = bara ägaren kan läsa/skriva)
  chown -R "$username":"$username" "$HOME_DIR"
  chmod 700 "$HOME_DIR/Documents" "$HOME_DIR/Downloads" "$HOME_DIR/Work"

done

# Loop 2: Skapa välkomstfiler när alla användare finns i systemet
for username in "$@"; do

  HOME_DIR="/home/$username"

  # Skapa välkomstfilen med en hälsning och lista på övriga användare
  echo "Välkommen $username" > "$HOME_DIR/welcome.txt"
  cut -d: -f1 /etc/passwd | grep -v "^$username$" >> "$HOME_DIR/welcome.txt"

  # Sätt rätt ägare på välkomstfilen
  chown "$username":"$username" "$HOME_DIR/welcome.txt"

done

