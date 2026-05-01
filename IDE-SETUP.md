# IDE Setup

Sets up extensions and settings for your IDE. Supports **VSCode**, **Antigravity**, and **Cursor**.

---

## Run

### Option A — Remote (no clone needed)

```bash
curl -sL https://raw.githubusercontent.com/wrteam-sagar/php-code-quality-setup/main/setup-ide.sh | bash
```

### Option B — Local (after cloning this repo)

```bash
chmod +x setup-ide.sh
./setup-ide.sh
```

You will be prompted to choose which IDE to configure:

```
1) VSCode
2) Antigravity
3) Cursor
4) All
```

The script installs extensions and writes settings for the selected IDE(s).

---

## Extensions Installed

### PHP Core

| Extension | Purpose |
|-----------|---------|
| `bmewburn.vscode-intelephense-client` | PHP intellisense, go-to-definition, refactoring |
| `mehedidracula.php-namespace-resolver` | Auto-import and expand namespaces |
| `neilbrayfield.php-docblocker` | Auto-generate PHPDoc blocks (`@param`, `@return`) |
| `xdebug.php-debug` | Step debugging via Xdebug |

### Code Quality

| Extension | Purpose |
|-----------|---------|
| `valeryanm.vscode-phpsab` | phpcs sniffer — inline PSR12 warnings |
| `junstyle.php-cs-fixer` | php-cs-fixer — format on save |
| `ecodes.vscode-phpmd` | PHPMD mess detector |
| `sanderronde.phpstan-vscode` | PHPStan static analysis |

### Laravel

| Extension | Purpose |
|-----------|---------|
| `amiralizadeh9480.laravel-extra-intellisense` | Route, view, config, env intellisense |
| `onecentlin.laravel-blade` | Blade syntax highlighting and snippets |
| `onecentlin.laravel5-snippets` | `Route::`, `Auth::`, `View::` snippets |
| `shufo.vscode-blade-formatter` | Blade template formatter |
| `ryannaddy.laravel-artisan` | Run artisan commands from the command palette |
| `codingyu.laravel-goto-view` | Ctrl+click a view name to jump to the blade file |

### Editor Utilities

| Extension | Purpose |
|-----------|---------|
| `editorconfig.editorconfig` | Respect `.editorconfig` files |
| `formulahendry.auto-rename-tag` | Sync rename paired HTML/Blade tags |
| `oderwat.indent-rainbow` | Colorize indentation levels |

---

## Settings Applied

| Setting | Value |
|---------|-------|
| Default PHP formatter | `junstyle.php-cs-fixer` |
| Format on save | enabled |
| php-cs-fixer executable | `${workspaceFolder}/vendor/bin/php-cs-fixer` |
| phpcs executable | `${workspaceFolder}/vendor/bin/phpcs` |
| phpcbf executable | `${workspaceFolder}/vendor/bin/phpcbf` |
| phpmd executable | `${workspaceFolder}/vendor/bin/phpmd` |
| phpstan executable | `${workspaceFolder}/vendor/bin/phpstan` |
| phpcs standard | PSR12 |
| phpcs fixer (phpsab) | disabled (php-cs-fixer handles formatting) |
| Intelephense brace style | K&R |

> Tool paths point to `vendor/bin/` because packages are installed per project via `setup-project.sh`.

---

## Notes

- If an IDE is not detected, its step is skipped automatically.
- Settings are written to the global IDE settings file (not per-workspace).
- Composer is installed if not already present.
- Restart your IDE after the script completes.
