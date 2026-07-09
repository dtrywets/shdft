#!/usr/bin/env bash
set -e

# -----------------------------------------------------------------------------
# Shell-Standards einrichten:
#  - cls -> clear
#  - vollständigen Pfad im Prompt anzeigen
#    (/home/ladwein/Workspaces/projekt statt ~/Wor... oder nur projekt)
#  - Groß-/Kleinschreibung bei TAB-Completion ignorieren
# -----------------------------------------------------------------------------

SHELL_FILES=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
)

# ---------------------------------------------------------------------
# Readline-Konfiguration (Bash und viele andere Programme)
# ---------------------------------------------------------------------

touch "$HOME/.inputrc"

grep -qxF "set completion-ignore-case on" "$HOME/.inputrc" || \
    echo "set completion-ignore-case on" >> "$HOME/.inputrc"

# ---------------------------------------------------------------------
# Shell-Konfigurationen
# ---------------------------------------------------------------------

for FILE in "${SHELL_FILES[@]}"; do
    touch "$FILE"

    # cls Alias
    grep -Eq '^[[:space:]]*alias[[:space:]]+cls=' "$FILE" || \
        echo "alias cls='clear'" >> "$FILE"

    # Vollständigen Pfad im Prompt anzeigen
    if [[ "$FILE" == *".bashrc" ]]; then
        grep -q "FULL_PATH_PROMPT_ENABLED" "$FILE" || cat >> "$FILE" <<'EOF'

# FULL_PATH_PROMPT_ENABLED
export PROMPT_DIRTRIM=0
PS1='[\u@\h ${PWD/#$HOME/\~}]$ '
EOF
    fi

    if [[ "$FILE" == *".zshrc" ]]; then
        grep -q "FULL_PATH_PROMPT_ENABLED" "$FILE" || cat >> "$FILE" <<'EOF'

# FULL_PATH_PROMPT_ENABLED
PROMPT='[%n@%m ${PWD/#$HOME/\~}]%# '
EOF
    fi
done

echo
echo "Konfiguration erfolgreich eingerichtet."
echo
echo "Änderungen aktivieren mit:"
echo
echo "    source ~/.bashrc"
echo "oder"
echo "    source ~/.zshrc"
echo
echo "oder einfach neu anmelden."
