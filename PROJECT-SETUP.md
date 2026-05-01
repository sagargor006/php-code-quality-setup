# Project Setup

Copies code quality config files into your project and installs the required Composer dev dependencies. Run this once per project.

---

## Supported Frameworks

| Framework | Argument | Status |
|-----------|----------|--------|
| Laravel | `laravel` | Ready |
| CodeIgniter 3 | `ci3` | Ready |
| CodeIgniter 4 | `ci4` | Coming soon |

---

## Usage

### Option A — Remote (no clone needed)

Run directly from GitHub inside your project directory.

**Laravel:**
```bash
curl -sL https://raw.githubusercontent.com/wrteam-sagar/php-code-quality-setup/main/setup-project.sh | bash -s -- laravel
```

**CodeIgniter 3:**
```bash
curl -sL https://raw.githubusercontent.com/wrteam-sagar/php-code-quality-setup/main/setup-project.sh | bash -s -- ci3
```

Pass a target path if not running from inside the project:
```bash
curl -sL https://raw.githubusercontent.com/wrteam-sagar/php-code-quality-setup/main/setup-project.sh | bash -s -- laravel /path/to/your-project
```

---

### Option B — Local (after cloning this repo)

```bash
# Clone once
git clone https://github.com/wrteam-sagar/php-code-quality-setup.git
chmod +x php-code-quality-setup/setup-project.sh

# Run inside your project
cd /path/to/your-project
/path/to/php-code-quality-setup/setup-project.sh laravel

# Or pass path explicitly
/path/to/php-code-quality-setup/setup-project.sh ci3 /path/to/your-project
```

---

## Arguments

```
setup-project.sh <framework> [target-dir] [--force]
```

| Argument | Required | Description |
|----------|----------|-------------|
| `framework` | Yes | `laravel` or `ci3` |
| `target-dir` | No | Target project path. Defaults to current directory |
| `--force` | No | Overwrite files that already exist |

---

## What Gets Installed

### Laravel

**Config files copied to project root:**

| File | Purpose |
|------|---------|
| `phpmd.xml` | PHPMD mess detector rules |
| `phpstan.neon` | PHPStan static analysis config |
| `pint.json` | Laravel Pint code style config |
| `.php-cs-fixer.dist.php` | PHP CS Fixer formatting rules |

**Git hook installed:**

| Hook | Trigger |
|------|---------|
| `.git/hooks/pre-commit` | Runs on every `git commit` |

The pre-commit hook runs:
- `php-cs-fixer fix` — auto-fix formatting
- `phpmd ... text phpmd.xml` — detect code mess
- `phpstan analyse` — static analysis
- `pint --config pint.json` — Laravel code style

**Composer dev packages installed:**

```
laravel/pint
phpstan/phpstan
larastan/larastan
phpmd/phpmd
friendsofphp/php-cs-fixer
```

---

### CodeIgniter 3

**Config files copied to project root:**

| File | Purpose |
|------|---------|
| `phpmd.xml` | PHPMD mess detector rules |
| `phpstan.neon` | PHPStan static analysis config |
| `phpstan-bootstrap.php` | PHPStan bootstrap for CI3 globals |
| `ci-stubs.php` | CI3 type stubs for static analysis |
| `.php-cs-fixer.dist.php` | PHP CS Fixer formatting rules |
| `CI_PHPSTORM.php` | PhpStorm helper stubs (optional) |

**Composer dev packages installed:**

```
phpstan/phpstan
phpmd/phpmd
squizlabs/php_codesniffer
friendsofphp/php-cs-fixer
```

---

## Behavior

- Existing files are **skipped by default** — your customizations are safe.
- Use `--force` to overwrite with fresh defaults.
- Git hook is skipped with a warning if the target is not a git repo.
- Composer install is skipped with a warning if `composer` is not found.
