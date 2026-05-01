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

# -------------------
# IDE Selection
# -------------------
echo "Which IDE would you like to set up?"
echo ""
echo "  1) VSCode"
echo "  2) Antigravity"
echo "  3) Cursor"
echo "  4) All"
echo ""
read -rp "Enter choice [1-4]: " IDE_CHOICE </dev/tty
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
# Framework Selection
# -------------------
echo "Which framework profile would you like to set up?"
echo ""
echo "  1) Laravel  (Pint formatter, Blade tools)"
echo "  2) CI3      (php-cs-fixer, PSR12)"
echo "  3) All      (both profiles)"
echo ""
read -rp "Enter choice [1-3]: " FRAMEWORK_CHOICE </dev/tty
echo ""

SETUP_LARAVEL=false
SETUP_CI3=false

case "$FRAMEWORK_CHOICE" in
    1) SETUP_LARAVEL=true ;;
    2) SETUP_CI3=true ;;
    3) SETUP_LARAVEL=true; SETUP_CI3=true ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${RESET}"
        exit 1
        ;;
esac

# -------------------
# Extension Lists
# -------------------
COMMON_EXTENSIONS=(
    # --- PHP Core ---
    "bmewburn.vscode-intelephense-client"   # PHP intellisense, go-to-def, refactor
    "mehedidracula.php-namespace-resolver"  # auto-import & expand namespaces
    "neilbrayfield.php-docblocker"          # auto-generate PHPDoc blocks
    "xdebug.php-debug"                      # step debugging via Xdebug

    # --- Code Quality ---
    "ecodes.vscode-phpmd"                   # PHPMD mess detector
    "sanderronde.phpstan-vscode"            # PHPStan static analysis

    # --- Editor Utilities ---
    "editorconfig.editorconfig"             # respect .editorconfig files
    "formulahendry.auto-rename-tag"         # sync rename paired HTML/Blade tags
)

LARAVEL_EXTENSIONS=(
    "open-southeners.laravel-pint"                 # Laravel Pint formatter
    "amiralizadeh9480.laravel-extra-intellisense"  # route/view/config/env intellisense
    "onecentlin.laravel-blade"                     # Blade syntax highlighting & snippets
    "onecentlin.laravel5-snippets"                 # Route::, Auth::, View:: etc. snippets
    "shufo.vscode-blade-formatter"                 # Blade template formatter
    "codingyu.laravel-goto-view"                   # Ctrl+click view name → jump to blade file
)

CI3_EXTENSIONS=(
    "junstyle.php-cs-fixer"                # php-cs-fixer formatter on save
    "valeryanm.vscode-phpsab"              # phpcs sniffer (PSR12 inline warnings)
)

# -------------------
# Detect OS & Settings Paths
# -------------------
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            OS="mac"
            VSCODE_BASE="$HOME/Library/Application Support/Code/User"
            ANTIGRAVITY_BASE="$HOME/Library/Application Support/Antigravity/User"
            CURSOR_BASE="$HOME/Library/Application Support/Cursor/User"
            ;;
        Linux*)
            OS="linux"
            VSCODE_BASE="$HOME/.config/Code/User"
            ANTIGRAVITY_BASE="$HOME/.config/Antigravity/User"
            CURSOR_BASE="$HOME/.config/Cursor/User"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            OS="windows"
            if [ -n "$APPDATA" ]; then
                VSCODE_BASE="$APPDATA/Code/User"
                ANTIGRAVITY_BASE="$APPDATA/Antigravity/User"
                CURSOR_BASE="$APPDATA/Cursor/User"
            else
                VSCODE_BASE="$HOME/AppData/Roaming/Code/User"
                ANTIGRAVITY_BASE="$HOME/AppData/Roaming/Antigravity/User"
                CURSOR_BASE="$HOME/AppData/Roaming/Cursor/User"
            fi
            ;;
        *)
            OS="unknown"
            VSCODE_BASE="$HOME/.config/Code/User"
            ANTIGRAVITY_BASE="$HOME/.config/Antigravity/User"
            CURSOR_BASE="$HOME/.config/Cursor/User"
            echo "Warning: Unknown OS. Using Linux paths as fallback."
            ;;
    esac
}

detect_os

# -------------------
# Register Profile
# -------------------
# Registers a named profile in the IDE's storage.json so --profile flag works.
# VSCode uses random hex IDs as locations; Antigravity uses the name directly.
register_profile() {
    local storage_json=$1
    local profile_name=$2
    local ide_name=$3
    local profiles_base=$4

    if [ ! -f "$storage_json" ]; then
        return
    fi

    python3 - "$storage_json" "$profile_name" "$ide_name" "$profiles_base" << 'PYEOF'
import json, sys, os, hashlib

storage_json, profile_name, ide_name, profiles_base = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

with open(storage_json) as f:
    data = json.load(f)

profiles = data.get('userDataProfiles', [])

# check if already registered by name
if any(p.get('name') == profile_name for p in profiles):
    sys.exit(0)

# determine location: Antigravity uses name directly, VSCode uses hex ID
if ide_name == 'Antigravity':
    location = profile_name
else:
    # deterministic 8-char hex from name, matching VSCode convention
    location = hashlib.md5(profile_name.encode()).hexdigest()[:8]
    # ensure profile dir exists at that location
    profile_dir = os.path.join(profiles_base, location)
    os.makedirs(profile_dir, exist_ok=True)

profiles.append({'location': location, 'name': profile_name})
data['userDataProfiles'] = profiles

with open(storage_json, 'w') as f:
    json.dump(data, f, indent=2)
PYEOF
}

# -------------------
# Install Extensions
# -------------------
install_extensions() {
    local ide_cmd=$1
    local ide_name=$2
    local profile=$3
    shift 3
    local extensions=("$@")

    echo ""
    echo -e "${BOLD}Installing $ide_name extensions → profile: $profile${RESET}"

    if ! command -v "$ide_cmd" &>/dev/null; then
        echo -e "  ${YELLOW}SKIP${RESET}   $ide_name not detected."
        return
    fi

    local success_count=0
    local failed_count=0
    local skipped_count=0

    for extension in "${extensions[@]}"; do
        if [[ "$extension" =~ ^[[:space:]]*# ]]; then
            skipped_count=$((skipped_count + 1))
            continue
        fi

        extension=$(echo "$extension" | sed 's/#.*//' | xargs)

        if [ -z "$extension" ]; then
            skipped_count=$((skipped_count + 1))
            continue
        fi

        set +e
        if $ide_cmd --profile "$profile" --force --install-extension "$extension" >/dev/null 2>&1; then
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
# Apply Settings
# -------------------
apply_laravel_settings() {
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
        "editor.defaultFormatter": "open-southeners.laravel-pint"
    },

    "intelephense.format.braces": "k&r",
    "php.format.rules.indentBraces": false,

    "laravel-pint.enable": true,
    "laravel-pint.executablePath": "${workspaceFolder}/vendor/bin/pint",

    "phpmd.verbose": true,
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

    echo -e "  ${GREEN}OK${RESET}     $ide_name Laravel settings → $settings_path"
}

apply_ci3_settings() {
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

    echo -e "  ${GREEN}OK${RESET}     $ide_name CI3 settings → $settings_path"
}

# -------------------
# Setup per IDE + Framework
# -------------------
# Returns the profile location string for a given IDE + profile name.
# VSCode/Cursor/etc. use an 8-char hex (MD5 prefix); Antigravity uses name directly.
get_profile_location() {
    local ide_name=$1
    local profile_name=$2
    if [ "$ide_name" = "Antigravity" ]; then
        echo "$profile_name"
    else
        python3 -c "import hashlib,sys; print(hashlib.md5(sys.argv[1].encode()).hexdigest()[:8])" "$profile_name"
    fi
}

setup_ide() {
    local ide_cmd=$1
    local ide_name=$2
    local base_path=$3

    echo ""
    echo -e "${BOLD}========== $ide_name ==========${RESET}"

    local storage_json="$base_path/globalStorage/storage.json"

    if [ "$SETUP_LARAVEL" = true ]; then
        local laravel_loc
        laravel_loc=$(get_profile_location "$ide_name" "Laravel")
        echo -e "${BOLD}Applying Laravel settings...${RESET}"
        register_profile "$storage_json" "Laravel" "$ide_name" "$base_path/profiles"
        apply_laravel_settings "$base_path/profiles/$laravel_loc/settings.json" "$ide_name" "$ide_cmd"
        local all_extensions=("${COMMON_EXTENSIONS[@]}" "${LARAVEL_EXTENSIONS[@]}")
        install_extensions "$ide_cmd" "$ide_name" "Laravel" "${all_extensions[@]}"
    fi

    if [ "$SETUP_CI3" = true ]; then
        local ci3_loc
        ci3_loc=$(get_profile_location "$ide_name" "CI3")
        echo -e "${BOLD}Applying CI3 settings...${RESET}"
        register_profile "$storage_json" "CI3" "$ide_name" "$base_path/profiles"
        apply_ci3_settings "$base_path/profiles/$ci3_loc/settings.json" "$ide_name" "$ide_cmd"
        local all_extensions=("${COMMON_EXTENSIONS[@]}" "${CI3_EXTENSIONS[@]}")
        install_extensions "$ide_cmd" "$ide_name" "CI3" "${all_extensions[@]}"
    fi
}

if [ "$SETUP_VSCODE" = true ]; then
    setup_ide "code" "VSCode" "$VSCODE_BASE"
fi

if [ "$SETUP_ANTIGRAVITY" = true ]; then
    setup_ide "antigravity" "Antigravity" "$ANTIGRAVITY_BASE"
fi

if [ "$SETUP_CURSOR" = true ]; then
    setup_ide "cursor" "Cursor" "$CURSOR_BASE"
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
echo -e "${GREEN}${BOLD}Setup complete.${RESET}"
echo ""
echo -e "Switch profiles in your IDE:"
echo -e "  ${CYAN}Command Palette → 'Profiles: Switch Profile'${RESET}"
echo ""
