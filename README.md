# shdft

Shell-Standards für Bash, Zsh und Git Bash — einmal ausführen, auf allen Rechnern gleiches Verhalten.

## Was wird eingerichtet?

| Einstellung | Datei | Wirkung |
|-------------|-------|---------|
| `cls`, `ll`, `la`, `l` | `~/.bashrc`, `~/.zshrc` | Nützliche Aliase für Terminal und `ls` |
| Vollständiger Prompt-Pfad | `~/.bashrc`, `~/.zshrc` | Anzeige des kompletten Pfads statt gekürztem Verzeichnisnamen |
| TAB-Completion ohne Groß-/Kleinschreibung | `~/.inputrc` | Dateinamen-Vervollständigung ignoriert die Schreibweise |
| Git Bash | `~/.bash_profile` | Lädt `~/.bashrc`, falls noch nicht vorhanden |
| oh-my-zsh | interaktiv | Optional installieren, wenn zsh vorhanden ist (Abfrage `[j/N]`) |

Alle Einstellungen liegen in markierten Blöcken (`# BEGIN shdft` … `# END shdft`) und lassen sich gezielt entfernen.

## Schnellstart (One-Liner)

```bash
curl -fsSL https://raw.githubusercontent.com/dtrywets/shdft/main/setup-shell-defaults.sh | bash
```

Status prüfen:

```bash
curl -fsSL https://raw.githubusercontent.com/dtrywets/shdft/main/setup-shell-defaults.sh | bash -s -- --status
```

Deinstallieren:

```bash
curl -fsSL https://raw.githubusercontent.com/dtrywets/shdft/main/setup-shell-defaults.sh | bash -s -- --uninstall
```

## Installation (Clone)

```bash
git clone https://github.com/dtrywets/shdft.git
cd shdft
chmod +x setup-shell-defaults.sh
./setup-shell-defaults.sh
```

Änderungen aktivieren:

```bash
source ~/.bashrc
# oder
source ~/.zshrc
```

Alternativ neu anmelden.

## Befehle

| Befehl | Beschreibung |
|--------|--------------|
| `./setup-shell-defaults.sh` | Einstellungen anwenden (idempotent) |
| `./setup-shell-defaults.sh --status` | Aktuellen Stand anzeigen |
| `./setup-shell-defaults.sh --uninstall` | Alle shdft-Blöcke entfernen |
| `./setup-shell-defaults.sh --help` | Hilfe anzeigen |

## Zsh und oh-my-zsh

Bei der Installation wird geprüft, ob oh-my-zsh bereits vorhanden ist. Falls nicht und `zsh` verfügbar ist, erscheint die Abfrage:

```
oh-my-zsh installieren? [j/N]
```

Auf Arch/EndeavourOS wird bei fehlendem `zsh` optional `pacman -S zsh` angeboten (ebenfalls mit `[j/N]`).

Nach der oh-my-zsh-Installation werden die shdft-Einstellungen am Ende der `~/.zshrc` ergänzt und überschreiben damit das Theme-Prompt für den vollen Pfad.

## Prompt-Beispiel

Vorher (gekürzt):

```
[ladwein@prodesk shdft]$
```

Nachher (vollständiger Pfad):

```
[ladwein@prodesk ~/Workspaces/shdft]$
```

## Hinweise

- Betrifft nur die Shell-Konfiguration des ausführenden Benutzers (`$HOME`).
- Bestehende manuelle Anpassungen außerhalb der shdft-Blöcke bleiben erhalten.
- Alte Einträge aus früheren Versionen (`FULL_PATH_PROMPT_ENABLED`, lose `cls`-Aliase) werden bei der Installation automatisch bereinigt.

## Lizenz

MIT — siehe [LICENSE](LICENSE).
