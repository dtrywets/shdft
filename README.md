# shdft

Shell-Standards für Bash und Zsh — einmal ausführen, auf allen Rechnern gleiches Verhalten.

## Was wird eingerichtet?

| Einstellung | Datei | Wirkung |
|-------------|-------|---------|
| `cls`-Alias | `~/.bashrc`, `~/.zshrc` | `cls` löscht den Bildschirm wie `clear` |
| Vollständiger Prompt-Pfad | `~/.bashrc`, `~/.zshrc` | Anzeige des kompletten Pfads statt gekürztem Verzeichnisnamen |
| TAB-Completion ohne Groß-/Kleinschreibung | `~/.inputrc` | Dateinamen-Vervollständigung ignoriert die Schreibweise |

Das Skript ist idempotent: Bereits vorhandene Einträge werden nicht doppelt angelegt.

## Installation

Repository klonen und Skript ausführen:

```bash
git clone git@github.com:dtrywets/shdft.git
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
- Bestehende manuelle Anpassungen in `~/.bashrc` oder `~/.zshrc` bleiben erhalten; neue Blöcke werden angehängt.
