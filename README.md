# homebrew-jachy-h

Jachy's personal Homebrew tap — one place to install the macOS tools I build and
maintain.

Every package here is developed in its own repository. This tap only holds the
Homebrew definitions (`Formula/`, `Casks/`), installation docs and release
update automation. No application source code lives in this repository.

## Installation

One-time tap setup:

```bash
brew tap jachy-h/jachy-h
brew trust --tap jachy-h/jachy-h
```

Install Umbragate:

```bash
brew install umbragate
```

Install Lan Copy (macOS Apple Silicon; other platforms are not packaged yet).
The formula installs the `lancopy` command:

```bash
brew install lancopy
brew services start lancopy   # run the LAN server in the background
```

Lan Copy serves the web UI on <http://localhost:8080> after startup. Homebrew
only ships the Apple Silicon build: Intel Macs and Linux are rejected by the
formula instead of installing an unverified binary.

macOS GUI applications are distributed as casks. When the first one is
published, it is installed with:

```bash
brew install --cask <app-name>
```

Formula packages are command-line tools and background services. Cask packages
are `.app`, DMG or PKG bundles.

## Upgrade

```bash
brew update
brew upgrade             # every package from this tap
brew upgrade umbragate   # a single package
brew upgrade lancopy    # a single package
```

Use `brew upgrade lancopy` instead of the in-app updater: the app's updater
replaces files inside the Homebrew Cellar, while Homebrew owns those paths.

## Uninstall

Formula:

```bash
brew services stop umbragate   # only if you enabled the background service
brew uninstall umbragate
```

Lan Copy:

```bash
brew services stop lancopy    # only if you started the service
brew uninstall lancopy
```

Cask:

```bash
brew uninstall --cask <app-name>
brew uninstall --zap --cask <app-name>   # also remove app support and settings
```

Some packages keep data outside Homebrew's prefix. For Umbragate, configuration
and the local database live in `~/.umbragate/` and are intentionally left in
place by `brew uninstall`. Delete that directory manually if you want a clean
slate. A Lan Copy service started with `brew services` keeps its shared folder
in `$(brew --prefix)/var/lancopy`, which `brew uninstall` also leaves behind.

## Available Packages

| Package     | Type    | Description                                                 | Install                  | Source                                                      |
| ----------- | ------- | ----------------------------------------------------------- | ------------------------ | ----------------------------------------------------------- |
| `umbragate` | Formula | Local-first LLM gateway with dashboard and provider routing | `brew install umbragate` | [jachy-h/umbra-gate](https://github.com/jachy-h/umbra-gate) |
| `lancopy`   | Formula | Zero-dependency LAN file and text sharing tool              | `brew install lancopy`   | [jachy-h/lan-copy](https://github.com/jachy-h/lan-copy)     |

No casks are published yet. The table only lists packages that actually exist in
this repository.

## Trust and Security

Homebrew loads tap definitions as Ruby code, so current Homebrew versions
require an explicit trust decision before a non-official tap can be used:

```bash
brew trust --tap jachy-h/jachy-h
```

What this does and does not mean:

- It records, in `~/.homebrew/trust.json` (or `$XDG_CONFIG_HOME/homebrew/trust.json`),
  that Homebrew may load formulae and casks from `jachy-h/jachy-h`. The scope is
  this tap only; it does not trust other taps or arbitrary code.
- You can trust a single package instead of the whole tap:
  `brew trust --formula jachy-h/jachy-h/umbragate`.
- It is not a security audit, and it does not mean the software is signed,
  notarized or endorsed by Apple, Homebrew or anyone else. It is your own
  statement of trust in this tap.
- Every download is pinned to a SHA256 checksum in its definition, and release
  artifacts come from the GitHub Releases of the corresponding project.
  Homebrew refuses to install when a downloaded file does not match.
- Run `brew trust --json v1` to review what you currently trust, and
  `brew untrust --tap jachy-h/jachy-h` to revoke this tap.

Because tap definitions are code, upgrades can change what gets installed.
Review the definition diff before running `brew upgrade` if you want to keep a
close eye on it.

## Reporting Issues

- Packaging problems in this tap (wrong checksum, broken install, missing
  service definition): open an issue at
  [jachy-h/homebrew-jachy-h](https://github.com/jachy-h/homebrew-jachy-h/issues).
- Application bugs and feature requests: open an issue in the project's own
  repository (see the Source column above).
