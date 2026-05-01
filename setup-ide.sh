#!/usr/bin/env bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}=========================================="
echo -e "  PHP Code Quality — IDE Setup"
echo -e "==========================================${RESET}"
echo ""
echo "Which IDE would you like to set up?"
echo ""
echo "  1) VSCode"
echo "  2) Antigravity"
echo "  3) Cursor"
echo "  4) All"
echo ""
read -rp "Enter choice [1-4]: " IDE_CHOICE
echo ""

SETUP_VSCODE=false
SETUP_ANTIGRAVITY=false
SETUP_CURSOR=false

case "$IDE_CHOICE" in
    1) SETUP_VSCODE=true ;;
    2) SETUP_ANTIGRAVITY=true ;;
    3) SETUP_CURSOR=true ;;
    4) SETUP_VSCODE=true; SETUP_ANTIGRAVITY=true; SETUP_CURSOR=true ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${RESET}"
        exit 1
        ;;
esac

# -------------------
# IDE Extension Installations
# -------------------
ACTIVE_PROFILE="Default"

EXTENSIONS=(
    # --- PHP Core ---
    "bmewburn.vscode-intelephense-client"   # PHP intellisense, go-to-def, refactor
    "mehedidracula.php-namespace-resolver"  # auto-import & expand namespaces
    "neilbrayfield.php-docblocker"          # auto-generate PHPDoc blocks
    "xdebug.php-debug"                      # step debugging via Xdebug

    # --- Code Quality ---
    "valeryanm.vscode-phpsab"               # phpcs sniffer (PSR12 inline warnings)
    "junstyle.php-cs-fixer"                 # php-cs-fixer formatter on save
    "ecodes.vscode-phpmd"                   # PHPMD mess detector
    "sanderronde.phpstan-vscode"            # PHPStan static analysis

    # --- Laravel ---
    "amiralizadeh9480.laravel-extra-intellisense"  # route/view/config/env intellisense
    "onecentlin.laravel-blade"              # Blade syntax highlighting & snippets
    "onecentlin.laravel5-snippets"          # Route::, Auth::, View:: etc. snippets
    "shufo.vscode-blade-formatter"          # Blade template formatter
    "ryannaddy.laravel-artisan"             # run artisan commands from command palette
    "codingyu.laravel-goto-view"            # Ctrl+click view name → jump to blade file

    # --- Editor Utilities ---
    "editorconfig.editorconfig"             # respect .editorconfig files
    "formulahendry.auto-rename-tag"         # sync rename paired HTML/Blade tags
    "oderwat.indent-rainbow"                # colorize indentation levels
)

install_extensions() {
    local ide_cmd=$1
    local ide_name=$2

    echo ""
    echo -e "${BOLD}Installing $ide_name Extensions...${RESET}"

    if ! command -v "$ide_cmd" &>/dev/null; then
        echo -e "  ${YELLOW}SKIP${RESET}   $ide_name not detected."
        return
    fi

    local success_count=0
    local failed_count=0
    local skipped_count=0

    for extension in "${EXTENSIONS[@]}"; do
        if [[ "$extension" =~ ^[[:space:]]*# ]]; then
            skipped_count=$((skipped_count + 1))
            continue
        fi

        # Strip inline comments and surrounding whitespace
        extension=$(echo "$extension" | sed 's/#.*//' | xargs)

        if [ -z "$extension" ]; then
            skipped_count=$((skipped_count + 1))
            continue
        fi

        set +e
        if $ide_cmd --profile "$ACTIVE_PROFILE" --force --install-extension "$extension" >/dev/null 2>&1; then
            success_count=$((success_count + 1))
            echo -e "  ${GREEN}OK${RESET}     $extension"
        else
            failed_count=$((failed_count + 1))
            echo -e "  ${RED}FAIL${RESET}   $extension (not available in $ide_name marketplace)"
        fi
        set -e
    done

    echo ""
    echo "  Summary — Success: $success_count | Failed: $failed_count | Skipped: $skipped_count"
    echo ""
}

# -------------------
# Detect OS & Settings Paths
# -------------------
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="mac"
            VSCODE_SETTINGS_PATH="$HOME/Library/Application Support/Code/User/settings.json"
            ANTIGRAVITY_SETTINGS_PATH="$HOME/Library/Application Support/Antigravity/User/settings.json"
            CURSOR_SETTINGS_PATH="$HOME/Library/Application Support/Cursor/User/settings.json"
            ;;
        Linux*)
            OS="linux"
            VSCODE_SETTINGS_PATH="$HOME/.config/Code/User/settings.json"
            ANTIGRAVITY_SETTINGS_PATH="$HOME/.config/Antigravity/User/settings.json"
            CURSOR_SETTINGS_PATH="$HOME/.config/Cursor/User/settings.json"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            OS="windows"
            if [ -n "$APPDATA" ]; then
                VSCODE_SETTINGS_PATH="$APPDATA/Code/User/settings.json"
                ANTIGRAVITY_SETTINGS_PATH="$APPDATA/Antigravity/User/settings.json"
                CURSOR_SETTINGS_PATH="$APPDATA/Cursor/User/settings.json"
            else
                VSCODE_SETTINGS_PATH="$HOME/AppData/Roaming/Code/User/settings.json"
                ANTIGRAVITY_SETTINGS_PATH="$HOME/AppData/Roaming/Antigravity/User/settings.json"
                CURSOR_SETTINGS_PATH="$HOME/AppData/Roaming/Cursor/User/settings.json"
            fi
            ;;
        *)
            OS="unknown"
            VSCODE_SETTINGS_PATH="$HOME/.config/Code/User/settings.json"
            ANTIGRAVITY_SETTINGS_PATH="$HOME/.config/Antigravity/User/settings.json"
            CURSOR_SETTINGS_PATH="$HOME/.config/Cursor/User/settings.json"
            echo "Warning: Unknown OS. Using Linux paths as fallback."
            ;;
    esac
}

detect_os

# -------------------
# Apply Settings
# -------------------
apply_settings() {
    local settings_path=$1
    local ide_name=$2
    local ide_cmd=$3

    if ! command -v "$ide_cmd" &>/dev/null && [ ! -d "$(dirname "$settings_path")" ]; then
        echo -e "  ${YELLOW}SKIP${RESET}   $ide_name not detected. Skipping settings."
        return
    fi

    mkdir -p "$(dirname "$settings_path")"

    cat > "$settings_path" << 'EOF'
{
    "editor.formatOnSave": true,

    "[php]": {
        "editor.defaultFormatter": "junstyle.php-cs-fixer"
    },

    "intelephense.format.braces": "k&r",
    "php.format.rules.indentBraces": false,

    "php-cs-fixer.onsave": true,
    "php-cs-fixer.executablePath": "${workspaceFolder}/vendor/bin/php-cs-fixer",
    "php-cs-fixer.executablePathWindows": "${workspaceFolder}/vendor/bin/php-cs-fixer",
    "php-cs-fixer.config": ".php-cs-fixer.php;.php-cs-fixer.dist.php;.php_cs;.php_cs.dist",
    "php-cs-fixer.rules": {
        "@PSR12": true,
        "braces_position": {
            "classes_opening_brace": "same_line",
            "functions_opening_brace": "same_line"
        }
    },
    "php-cs-fixer.pathMode": "override",
    "php-cs-fixer.exclude": [],
    "php-cs-fixer.autoFixByBracket": true,
    "php-cs-fixer.autoFixBySemicolon": false,
    "php-cs-fixer.formatHtml": false,
    "php-cs-fixer.documentFormattingProvider": true,
    "php-cs-fixer.ignorePHPVersion": false,

    "phpsab.standard": "PSR12",
    "phpsab.debug": false,
    "phpsab.fixerEnable": false,
    "phpsab.executablePathCS": "${workspaceFolder}/vendor/bin/phpcs",
    "phpsab.executablePathCBF": "${workspaceFolder}/vendor/bin/phpcbf",
    "phpsab.snifferArguments": [],

    "phpmd.verbose": true,
    "phpmd.command": "${workspaceFolder}/vendor/bin/phpmd",
    "phpmd.rules": "phpmd.xml",

    "phpstan.enabled": true,
    "phpstan.phpstanPath": "${workspaceFolder}/vendor/bin/phpstan",
    "phpstan.checkValidity": true,
    "phpstan.showProgress": true,

    "diffEditor.ignoreTrimWhitespace": false,
    "diffEditor.hideUnchangedRegions.enabled": true,
    "git.enableSmartCommit": true,
    "prettier.bracketSameLine": true
}
EOF

    echo -e "  ${GREEN}OK${RESET}     $ide_name settings → $settings_path"
}

# -------------------
# Run for selected IDEs
# -------------------
if [ "$SETUP_VSCODE" = true ]; then
    echo -e "${BOLD}--- VSCode ---${RESET}"
    install_extensions "code" "VSCode"
    echo -e "${BOLD}Applying VSCode settings...${RESET}"
    apply_settings "$VSCODE_SETTINGS_PATH" "VSCode" "code"
fi

if [ "$SETUP_ANTIGRAVITY" = true ]; then
    echo -e "${BOLD}--- Antigravity ---${RESET}"
    install_extensions "antigravity" "Antigravity"
    echo -e "${BOLD}Applying Antigravity settings...${RESET}"
    apply_settings "$ANTIGRAVITY_SETTINGS_PATH" "Antigravity" "antigravity"
fi

if [ "$SETUP_CURSOR" = true ]; then
    echo -e "${BOLD}--- Cursor ---${RESET}"
    install_extensions "cursor" "Cursor"
    echo -e "${BOLD}Applying Cursor settings...${RESET}"
    apply_settings "$CURSOR_SETTINGS_PATH" "Cursor" "cursor"
fi

# -------------------
# Composer Installation
# -------------------
echo ""
if ! command -v composer &>/dev/null; then
    echo "Composer not found. Installing..."
    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    php -r "copy('https://getcomposer.org/installer','composer-setup.php');"
    php -r "if (hash_file('sha384','composer-setup.php') !== '$EXPECTED_SIGNATURE') { echo 'Installer corrupt'; unlink('composer-setup.php'); exit(1); }"
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    rm composer-setup.php
else
    echo "Composer already installed."
fi

echo ""
echo -e "${GREEN}${BOLD}Setup complete. Restart your IDE(s).${RESET}"
echo ""
