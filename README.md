# PHP Code Quality Tools Setup

This script automatically installs and configures essential PHP code quality tools for your development environment. It sets up IDE extensions, installs PHP tools via Composer, and configures your editor settings.

---

## 🔧 One-Time Setup (Run Once)

### Step 1: Run the Setup Script

**Note:** This setup requires the `run.sh` file. Make sure to download it first.

1. Make the script executable:

   ```bash
   chmod +x run.sh
   ```

2. Run the script:

   ```bash
   ./run.sh
   ```

3. Restart your terminal and IDE after installation completes.

### Step 2: Install PHPMD Extension in Cursor (Manual)

Since Cursor's extension marketplace doesn't list the PHPMD extension, you need to install it manually:

1. Open Cursor
2. Open the Extensions menu from the sidebar (or press `Cmd+Shift+X` / `Ctrl+Shift+X`)
3. Drag and drop the [`ecodes.vscode-phpmd-1.3.0.vsix`](./ecodes.vscode-phpmd-1.3.0.vsix) file into the Extensions view
4. The extension will be installed automatically

**Note:** This is a one-time setup. After installation, the extension will be available for all your projects.

---

## 📁 Project-Wise Setup

Each project needs its own quality config files (`phpmd.xml`, `phpstan.neon`, etc.) and git hooks. Use the setup script below to copy the right files automatically.

---

## 🚀 Project Setup Script

`setup-project.sh` copies all required config files and git hooks into your project for the chosen framework.

### Supported Frameworks

| Framework | Arg | Status |
|-----------|-----|--------|
| Laravel | `laravel` | ✅ Ready |
| CodeIgniter 3 | `ci3` | ✅ Ready |
| CodeIgniter 4 | `ci4` | 🔜 Coming soon |

---

### Option A — Remote (no clone needed)

Run directly from GitHub. No need to download this repo first.

**Laravel:**
```bash
curl -sL https://raw.githubusercontent.com/wrteam-sagar/php-code-quality-setup/main/setup-project.sh | bash -s -- laravel
```

**CodeIgniter 3:**
```bash
curl -sL https://raw.githubusercontent.com/wrteam-sagar/php-code-quality-setup/main/setup-project.sh | bash -s -- ci3
```

> Run from inside your project directory, or pass the path as a second argument:
> ```bash
> curl -sL https://raw.githubusercontent.com/wrteam-sagar/php-code-quality-setup/main/setup-project.sh | bash -s -- laravel /path/to/your-project
> ```

---

### Option B — Local (after cloning this repo)

```bash
# 1. Clone this repo (once)
git clone https://github.com/wrteam-sagar/php-code-quality-setup.git

# 2. Make script executable (once)
chmod +x php-code-quality-setup/setup-project.sh

# 3. Run inside your project
cd /path/to/your-project
/path/to/php-code-quality-setup/setup-project.sh laravel

# Or pass target path explicitly
/path/to/php-code-quality-setup/setup-project.sh ci3 /path/to/your-project
```

---

### Arguments

```
setup-project.sh <framework> [target-dir] [--force]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `framework` | Yes | `laravel` or `ci3` |
| `target-dir` | No | Path to target project. Defaults to current directory |
| `--force` | No | Overwrite files that already exist |

---

### What Gets Copied

#### Laravel

| File | Purpose |
|------|---------|
| `phpmd.xml` | PHPMD mess detector rules |
| `phpstan.neon` | PHPStan static analysis config |
| `pint.json` | Laravel Pint code style config |
| `.php-cs-fixer.dist.php` | PHP-CS-Fixer formatting rules |
| `.git/hooks/pre-commit` | Pre-commit hook (auto `chmod +x`) |

After copying, install dev dependencies:
```bash
composer require --dev laravel/pint phpstan/phpstan larastan/larastan phpmd/phpmd
```

#### CodeIgniter 3

| File | Purpose |
|------|---------|
| `phpmd.xml` | PHPMD mess detector rules |
| `phpstan.neon` | PHPStan static analysis config |
| `phpstan-bootstrap.php` | PHPStan bootstrap for CI3 globals |
| `ci-stubs.php` | CI3 type stubs for static analysis |
| `.php-cs-fixer.dist.php` | PHP-CS-Fixer formatting rules |
| `CI_PHPSTORM.php` | PhpStorm helper stubs (optional) |

After copying, install dev dependencies:
```bash
composer require --dev phpstan/phpstan phpmd/phpmd squizlabs/php_codesniffer friendsofphp/php-cs-fixer
```

---

### Behavior

- **Existing files are skipped** by default — your customizations are safe
- Use `--force` to overwrite with fresh defaults
- Git hook is skipped with a warning if the target is not a git repo

---

### Manual Setup (Framework-Specific Guides)

Prefer to copy files manually or need pre-commit hook setup instructions?

#### [Laravel](./Laravel/README.md)

#### [CodeIgniter 3](./Codeigniter%203/README.md)

#### CodeIgniter 4 (Coming soon)

---

<details>
<summary><strong>📖 View Technical Details</strong></summary>

## What Gets Installed

### IDE Extensions

The script installs the following VSCode/Cursor extensions:

- **Intelephense** - PHP language support
- **PHP Namespace Resolver** - Namespace management
- **Xdebug** - PHP debugging support
- **EditorConfig** - Editor configuration support
- **PHPTools** - Advanced PHP development tools
- **Laravel Extra IntelliSense** - Laravel-specific IntelliSense
- **Laravel Blade** - Blade template support
- **Blade Formatter** - Blade template formatting
- **Auto Rename Tag** - HTML/XML tag management
- **Indent Rainbow** - Visual indentation guide
- **PHP CodeSniffer** - CodeSniffer integration
- **PHP CS Fixer** - Code formatting
- **PHPMD** - Mess detector integration
- **PHPStan** - Static analysis tool

### Global PHP Tools

The following tools are installed globally via Composer:

- **PHP_CodeSniffer** (`phpcs`) - Detects violations of coding standards
- **PHP-CS-Fixer** (`php-cs-fixer`) - Automatically fixes coding standards violations
- **PHPStan** (`phpstan`) - Static analysis tool for finding bugs
- **Laravel Pint** (`pint`) - Laravel's opinionated PHP code style fixer
- **PHPMD** (`phpmd`) - Mess detector that finds potential problems
- **Larastan** - PHPStan rules for Laravel
- **Laravel IDE Helper** - Helper files for Laravel projects

## IDE Settings Configuration

The script configures your IDE with the following settings:

- **Format on Save** - Automatically formats code when saving
- **PSR-12 Standard** - Uses PSR-12 coding standard
- **PHPStan Enabled** - Enables static analysis
- **PHP CS Fixer** - Configured as default PHP formatter
- **PHPMD** - Configured for code quality checks
- **Editor Settings** - Optimized for PHP development

Settings are applied to:

- VSCode: `~/.config/Code/User/settings.json` (Linux) or `~/Library/Application Support/Code/User/settings.json` (macOS)
- Cursor: `~/.config/Cursor/User/settings.json` (Linux) or `~/Library/Application Support/Cursor/User/settings.json` (macOS)

## Post-Installation Steps

After running the script:

1. **Restart your terminal** - This ensures the PATH changes take effect
2. **Restart your IDE** - Close and reopen VSCode/Cursor to load new extensions and settings
3. **Verify installation** - Check that tools are available:

   ```bash
   phpcs --version
   php-cs-fixer --version
   phpstan --version
   phpmd --version
   ```

## Usage

### PHP_CodeSniffer

PHP_CodeSniffer detects violations of coding standards in your PHP code. It checks your code against predefined rules (like PSR-12) and reports any violations.

**Example:**

```bash
phpcs app/Models/User.php
```

### PHP-CS-Fixer

PHP-CS-Fixer automatically fixes coding standard violations in your PHP code. It can format your code according to PSR-12 or other coding standards without manual intervention.

**Example:**

```bash
php-cs-fixer fix app/Controllers/HomeController.php
```

### PHPStan

PHPStan performs static analysis on your PHP code to find bugs before they reach production. It analyzes your code without running it and detects type errors, undefined variables, and other potential issues.

**Example:**

```bash
phpstan analyse app/
```

### PHPMD

PHPMD (PHP Mess Detector) finds potential problems in your code such as unused code, overly complex methods, or naming issues. It helps maintain clean and maintainable code.

**Example:**

```bash
phpmd app/Models/Product.php text codesize,unusedcode,naming
```

### Laravel Pint

Laravel Pint is Laravel's opinionated PHP code style fixer built on PHP-CS-Fixer. It automatically formats your Laravel project code according to Laravel's coding standards.

**Example:**

```bash
pint app/
```

## Troubleshooting

### Composer Not Found After Installation

If Composer commands don't work after installation:

1. Check if Composer is in your PATH:

   ```bash
   echo $PATH | grep composer
   ```

2. Manually add to your shell configuration:

   ```bash
   # For bash
   echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc
   source ~/.bashrc

   # For zsh
   echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

### IDE Extensions Not Installing

- Ensure VSCode/Cursor is installed and accessible via command line
- Check if the IDE is running (some installations require the IDE to be closed)
- Verify you have internet connection
- Some extensions may not be available in all IDE marketplaces

### Permission Errors

If you encounter permission errors:

- On macOS/Linux, you may need to use `sudo` for Composer installation
- Ensure you have write permissions to your home directory
- Check that the IDE settings directory is writable

### Tools Not Found After Installation

1. Verify tools are installed:

   ```bash
   composer global show
   ```

2. Check Composer's global bin directory:

   ```bash
   composer global config bin-dir --absolute
   ```

3. Ensure the bin directory is in your PATH (see Composer troubleshooting above)

## Customization

### Adding More Extensions

Edit the `EXTENSIONS` array in `run.sh` to add more IDE extensions:

```bash
EXTENSIONS=(
    "bmewburn.vscode-intelephense-client"
    # Add your extension here
    "your.extension-id"
)
```

### Modifying IDE Settings

Edit the settings JSON block in the `apply_settings` function to customize IDE behavior.

### Adding More PHP Tools

Add additional tools to the Composer global require command:

```bash
composer global require \
    squizlabs/php_codesniffer \
    # Add your tool here
    vendor/package-name
```

## Supported Operating Systems

- **macOS** - Fully supported
- **Linux** - Fully supported
- **Windows** - Supported via Git Bash, WSL, or PowerShell

## Notes

- The script uses `set -e` which stops execution on any error
- Settings are overwritten - backup your existing settings if needed
- Extensions are installed for the "Default" profile
- The script automatically detects your operating system and adjusts paths accordingly

</details>
