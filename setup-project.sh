#!/usr/bin/env bash

# =============================================================================
# PHP Code Quality Setup — Project Installer
# =============================================================================
# Usage (local):
#   chmod +x setup-project.sh
#   ./setup-project.sh <framework> [target-dir] [--force]
#
# Usage (remote via curl):
#   curl -sL https://raw.githubusercontent.com/wrteam-sagar/php-code-quality-setup/main/setup-project.sh | bash -s -- <framework> [target-dir] [--force]
#
# Frameworks: laravel | ci3
# target-dir: defaults to current directory
# --force: overwrite existing files
# =============================================================================

set -e

# ---------------------
# Config
# ---------------------
GITHUB_REPO="wrteam-sagar/php-code-quality-setup"
GITHUB_BRANCH="main"
RAW_BASE="https://raw.githubusercontent.com/${GITHUB_REPO}/${GITHUB_BRANCH}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------
# Parse args
# ---------------------
FRAMEWORK=""
TARGET_DIR="."
FORCE=false

for arg in "$@"; do
    case "$arg" in
        --force) FORCE=true ;;
        laravel|ci3|ci4) FRAMEWORK="$arg" ;;
        *) TARGET_DIR="$arg" ;;
    esac
done

# ---------------------
# Validate
# ---------------------
if [ -z "$FRAMEWORK" ]; then
    echo -e "${RED}Error: framework required.${RESET}"
    echo ""
    echo "Usage: $0 <framework> [target-dir] [--force]"
    echo ""
    echo "Frameworks:"
    echo "  laravel   Laravel project"
    echo "  ci3       CodeIgniter 3 project"
    echo "  ci4       CodeIgniter 4 (coming soon)"
    echo ""
    echo "Examples:"
    echo "  ./setup-project.sh laravel"
    echo "  ./setup-project.sh ci3 /var/www/myproject"
    echo "  ./setup-project.sh laravel . --force"
    exit 1
fi

if [ "$FRAMEWORK" = "ci4" ]; then
    echo -e "${YELLOW}CodeIgniter 4 support coming soon.${RESET}"
    exit 0
fi

# Resolve target dir
TARGET_DIR="$(cd "$TARGET_DIR" 2>/dev/null && pwd || { echo -e "${RED}Error: target dir '$TARGET_DIR' not found.${RESET}"; exit 1; })"

# ---------------------
# Detect local vs remote
# ---------------------
# When piped through curl, $0 = "bash" and BASH_SOURCE[0] = "" or "bash"
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
LOCAL_MODE=false
SCRIPT_DIR=""

if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
    LOCAL_MODE=true
fi

# ---------------------
# Helper functions
# ---------------------
copy_file() {
    local src_rel="$1"          # relative path inside repo (e.g. "Laravel/phpmd.xml")
    local dest_rel="$2"         # relative path in target project (e.g. "phpmd.xml")
    local dest="$TARGET_DIR/$dest_rel"

    # Create destination directory if needed
    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    if [ -f "$dest" ] && [ "$FORCE" = false ]; then
        echo -e "  ${YELLOW}SKIP${RESET}   $dest_rel (exists — use --force to overwrite)"
        return
    fi

    if [ "$LOCAL_MODE" = true ]; then
        # Copy from local clone
        local src="$SCRIPT_DIR/$src_rel"
        if [ ! -f "$src" ]; then
            echo -e "  ${RED}MISS${RESET}   $src_rel (source file not found)"
            return
        fi
        cp "$src" "$dest"
    else
        # Download from GitHub
        local url="$RAW_BASE/$src_rel"
        if ! curl -fsSL "$url" -o "$dest" 2>/dev/null; then
            echo -e "  ${RED}FAIL${RESET}   $dest_rel (download failed: $url)"
            return
        fi
    fi

    echo -e "  ${GREEN}OK${RESET}     $dest_rel"
}

setup_git_hook() {
    local src_rel="$1"          # relative path inside repo
    local hook_name="$2"        # e.g. "pre-commit"
    local hook_dest="$TARGET_DIR/.git/hooks/$hook_name"

    if [ ! -d "$TARGET_DIR/.git" ]; then
        echo -e "  ${YELLOW}SKIP${RESET}   .git/hooks/$hook_name (not a git repo — run 'git init' first)"
        return
    fi

    if [ -f "$hook_dest" ] && [ "$FORCE" = false ]; then
        echo -e "  ${YELLOW}SKIP${RESET}   .git/hooks/$hook_name (exists — use --force to overwrite)"
        return
    fi

    mkdir -p "$TARGET_DIR/.git/hooks"

    if [ "$LOCAL_MODE" = true ]; then
        local src="$SCRIPT_DIR/$src_rel"
        if [ ! -f "$src" ]; then
            echo -e "  ${RED}MISS${RESET}   .git/hooks/$hook_name (source file not found)"
            return
        fi
        cp "$src" "$hook_dest"
    else
        local url="$RAW_BASE/$src_rel"
        if ! curl -fsSL "$url" -o "$hook_dest" 2>/dev/null; then
            echo -e "  ${RED}FAIL${RESET}   .git/hooks/$hook_name (download failed)"
            return
        fi
    fi

    chmod +x "$hook_dest"
    echo -e "  ${GREEN}OK${RESET}     .git/hooks/$hook_name (executable)"
}

# ---------------------
# Banner
# ---------------------
echo ""
echo -e "${BOLD}============================================${RESET}"
echo -e "${BOLD}  PHP Code Quality Setup — Project Install${RESET}"
echo -e "${BOLD}============================================${RESET}"
echo ""
echo -e "  Framework : ${CYAN}${FRAMEWORK}${RESET}"
echo -e "  Target    : ${CYAN}${TARGET_DIR}${RESET}"
echo -e "  Mode      : ${CYAN}$([ "$LOCAL_MODE" = true ] && echo "local" || echo "remote (GitHub)")${RESET}"
echo -e "  Force     : ${CYAN}${FORCE}${RESET}"
echo ""

# ---------------------
# Framework file maps
# ---------------------
case "$FRAMEWORK" in

    laravel)
        echo -e "${BOLD}Copying Laravel config files...${RESET}"
        copy_file "Laravel/phpmd.xml"                "phpmd.xml"
        copy_file "Laravel/phpstan.neon"             "phpstan.neon"
        copy_file "Laravel/pint.json"                "pint.json"
        copy_file "Laravel/.php-cs-fixer.dist.php"   ".php-cs-fixer.dist.php"

        echo ""
        echo -e "${BOLD}Setting up Git hooks...${RESET}"
        setup_git_hook "Laravel/.git-hooks/pre-commit" "pre-commit"
        ;;

    ci3)
        echo -e "${BOLD}Copying CodeIgniter 3 config files...${RESET}"
        copy_file "Codeigniter 3/phpmd.xml"               "phpmd.xml"
        copy_file "Codeigniter 3/phpstan.neon"             "phpstan.neon"
        copy_file "Codeigniter 3/phpstan-bootstrap.php"    "phpstan-bootstrap.php"
        copy_file "Codeigniter 3/ci-stubs.php"             "ci-stubs.php"
        copy_file "Codeigniter 3/.php-cs-fixer.dist.php"   ".php-cs-fixer.dist.php"

        echo ""
        echo -e "${BOLD}Optional (PhpStorm users)...${RESET}"
        copy_file "Codeigniter 3/CI_PHPSTORM.php"          "CI_PHPSTORM.php"
        ;;

esac

# ---------------------
# Done
# ---------------------
echo ""
echo -e "${GREEN}${BOLD}Done!${RESET}"
echo ""
echo -e "Next steps:"

case "$FRAMEWORK" in
    laravel)
        echo "  1. composer require --dev laravel/pint phpstan/phpstan larastan/larastan phpmd/phpmd"
        echo "  2. Review phpstan.neon and phpmd.xml — adjust rules to your project"
        echo "  3. Pre-commit hook installed — will run on every 'git commit'"
        ;;
    ci3)
        echo "  1. composer require --dev phpstan/phpstan phpmd/phpmd squizlabs/php_codesniffer friendsofphp/php-cs-fixer"
        echo "  2. Review phpstan.neon — update 'bootstrapFiles' path if phpstan-bootstrap.php moved"
        echo "  3. Set up pre-commit hook manually (see CodeIgniter 3 README)"
        ;;
esac

echo ""
