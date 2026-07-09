#!/usr/bin/env bash
set -euo pipefail

SHDFT_BEGIN="# BEGIN shdft"
SHDFT_END="# END shdft"
REPO_URL="https://github.com/dtrywets/shdft"

usage() {
    cat <<EOF
Verwendung: $(basename "$0") [OPTION]

Shell-Standards für Bash, Zsh und Git Bash einrichten.

Optionen:
  (ohne)        Einstellungen anwenden (idempotent)
  --status      Aktuellen Stand anzeigen
  --check       Wie --status
  --uninstall   Alle von shdft verwalteten Blöcke entfernen
  -h, --help    Diese Hilfe

Nach der Installation: source ~/.bashrc  bzw.  source ~/.zshrc
EOF
}

confirm() {
    local prompt="$1"
    local answer=""
    read -r -p "$prompt [j/N] " answer
    case "$answer" in
        j|J|ja|Ja|y|Y|yes|Yes) return 0 ;;
        *) return 1 ;;
    esac
}

managed_shell_files() {
    local files=("$HOME/.bashrc")

    if [[ -f "$HOME/.zshrc" ]] || command -v zsh >/dev/null 2>&1; then
        files+=("$HOME/.zshrc")
    fi

    if [[ -n "${MSYSTEM:-}" ]]; then
        files+=("$HOME/.bash_profile")
    fi

    printf '%s\n' "${files[@]}" | awk '!seen[$0]++'
}

has_block() {
    local file="$1"
    [[ -f "$file" ]] && grep -qF "$SHDFT_BEGIN" "$file"
}

remove_block() {
    local file="$1"
    [[ -f "$file" ]] || return 0

    local tmp
    tmp="$(mktemp)"
    awk -v begin="$SHDFT_BEGIN" -v end="$SHDFT_END" '
        $0 == begin { skip = 1; next }
        $0 == end   { skip = 0; next }
        !skip       { print }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
}

remove_legacy_entries() {
    local file="$1"
    [[ -f "$file" ]] || return 0

    local tmp
    tmp="$(mktemp)"
    awk '
        /FULL_PATH_PROMPT_ENABLED/ { skip = 1; next }
        skip && /^$/ { skip = 0; next }
        skip { next }
        /^[[:space:]]*alias[[:space:]]+cls=/ { next }
        { print }
    ' "$file" > "$tmp"
    mv "$tmp" "$file"
}

remove_legacy_inputrc() {
    local file="$HOME/.inputrc"
    [[ -f "$file" ]] || return 0
    if has_block "$file"; then
        return 0
    fi
    local tmp
    tmp="$(mktemp)"
    grep -vxF "set completion-ignore-case on" "$file" > "$tmp" || true
    mv "$tmp" "$file"
}

write_block() {
    local file="$1"
    local shell_type="$2"

    touch "$file"
    remove_legacy_entries "$file"
    remove_block "$file"

    {
        echo ""
        echo "$SHDFT_BEGIN"
        echo "# Shell-Standards ($REPO_URL)"
        echo "alias cls='clear'"
        echo "alias ll='ls -lah'"
        echo "alias la='ls -A'"
        echo "alias l='ls -CF'"

        if [[ "$shell_type" == "bash" ]]; then
            echo "export PROMPT_DIRTRIM=0"
            echo "PS1='[\\u@\\h \${PWD/#\$HOME/\\~}]\$ '"
        else
            echo "export PROMPT_DIRTRIM=0"
            echo "PROMPT='[%n@%m \${PWD/#\$HOME/\\~}]%# '"
        fi

        echo "$SHDFT_END"
    } >> "$file"
}

write_inputrc_block() {
    local file="$HOME/.inputrc"
    touch "$file"
    remove_legacy_inputrc
    remove_block "$file"

    {
        echo ""
        echo "$SHDFT_BEGIN"
        echo "# Shell-Standards ($REPO_URL)"
        echo "set completion-ignore-case on"
        echo "$SHDFT_END"
    } >> "$file"
}

ensure_git_bash_sources_bashrc() {
    local profile="$HOME/.bash_profile"
    [[ -n "${MSYSTEM:-}" ]] || return 0
    [[ -f "$profile" ]] || touch "$profile"

    if grep -qE '(\.|source)[[:space:]]+~?/?\.bashrc' "$profile"; then
        return 0
    fi

    if has_block "$profile"; then
        return 0
    fi

    {
        echo ""
        echo "$SHDFT_BEGIN"
        echo "# Git Bash: ~/.bashrc laden"
        echo 'if [[ -f "$HOME/.bashrc" ]]; then'
        echo '    . "$HOME/.bashrc"'
        echo 'fi'
        echo "$SHDFT_END"
    } >> "$profile"
}

ohmyzsh_installed() {
    [[ -d "$HOME/.oh-my-zsh" ]]
}

zsh_available() {
    command -v zsh >/dev/null 2>&1
}

maybe_install_zsh() {
    zsh_available && return 0

    echo "zsh ist nicht installiert."
    if command -v pacman >/dev/null 2>&1; then
        confirm "zsh per pacman installieren (sudo)?" || return 1
        sudo pacman -S --needed --noconfirm zsh
        return 0
    fi

    echo "Automatische zsh-Installation auf diesem System nicht vorgesehen."
    return 1
}

maybe_install_ohmyzsh() {
    if ohmyzsh_installed; then
        echo "oh-my-zsh: bereits installiert."
        return 0
    fi

    if ! zsh_available; then
        maybe_install_zsh || return 0
    fi

    if ! zsh_available; then
        echo "oh-my-zsh: übersprungen (zsh fehlt)."
        return 0
    fi

    confirm "oh-my-zsh installieren?" || {
        echo "oh-my-zsh: übersprungen."
        return 0
    }

    echo "oh-my-zsh wird installiert …"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
    echo "oh-my-zsh: Installation abgeschlossen."
}

status_item() {
    local label="$1"
    local ok="$2"
    if [[ "$ok" == "yes" ]]; then
        printf "  [ok]   %s\n" "$label"
    else
        printf "  [ -- ] %s\n" "$label"
    fi
}

cmd_status() {
    echo "shdft — Status"
    echo

    local file shell_type
    while IFS= read -r file; do
        if has_block "$file"; then
            status_item "$file (shdft-Block)" "yes"
        else
            status_item "$file (shdft-Block)" "no"
        fi
    done < <(managed_shell_files)

    if has_block "$HOME/.inputrc"; then
        status_item "$HOME/.inputrc (TAB-Completion)" "yes"
    else
        status_item "$HOME/.inputrc (TAB-Completion)" "no"
    fi

    echo
    if zsh_available; then
        status_item "zsh verfügbar" "yes"
    else
        status_item "zsh verfügbar" "no"
    fi

    if ohmyzsh_installed; then
        status_item "oh-my-zsh installiert" "yes"
    else
        status_item "oh-my-zsh installiert" "no"
    fi

    if [[ -n "${MSYSTEM:-}" ]]; then
        status_item "Git Bash erkannt ($MSYSTEM)" "yes"
    fi

    echo
}

cmd_uninstall() {
    echo "shdft — Deinstallation"
    echo

    local file
    while IFS= read -r file; do
        if has_block "$file"; then
            remove_block "$file"
            echo "  entfernt: $file"
        fi
    done < <(managed_shell_files)

    if has_block "$HOME/.inputrc"; then
        remove_block "$HOME/.inputrc"
        echo "  entfernt: ~/.inputrc"
    fi

    echo
    echo "shdft-Blöcke entfernt. Shell neu laden oder neu anmelden."
    echo
}

cmd_install() {
    echo "shdft — Einrichtung"
    echo

    maybe_install_ohmyzsh
    echo

    local file
    while IFS= read -r file; do
        case "$file" in
            *".zshrc")
                write_block "$file" "zsh"
                ;;
            *".bash_profile")
                ensure_git_bash_sources_bashrc
                ;;
            *)
                write_block "$file" "bash"
                ;;
        esac
        echo "  eingerichtet: $file"
    done < <(managed_shell_files)

    write_inputrc_block
    echo "  eingerichtet: ~/.inputrc"

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
    echo
}

main() {
    case "${1:-}" in
        --status|--check)
            cmd_status
            ;;
        --uninstall)
            cmd_uninstall
            ;;
        -h|--help)
            usage
            ;;
        "")
            cmd_install
            ;;
        *)
            echo "Unbekannte Option: $1" >&2
            echo
            usage >&2
            exit 1
            ;;
    esac
}

main "$@"
