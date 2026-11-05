# Nix Flake · NixOS Configuration

> purr · git-hooks · nixos · darwin · home-manager · nix-flake

Opinionated Nix flake template for NixOS, nix-darwin, and standalone home-manager configurations, powered by [`purr`](https://github.com/nixcafe/purr) and [`cattery-modules`](https://github.com/nixcafe/cattery-modules). Ships with pre-commit hooks (`nixfmt`, `deadnix`, `statix`) and image recipes (ISO, VM, cloud) exposed through purr's `images` output.

Part of the [develop-templates](https://github.com/nixcafe/develop-templates) collection (`nix flake init`-ready).

## Quick Start

### `nix flake init`

```bash
nix flake init -t "github:nixcafe/develop-templates#nix-config" --refresh
```

Register an alias:
```bash
nix registry add beans "github:nixcafe/develop-templates"
nix flake init -t beans#nix-config
```

> **Tip**: With [cattery-modules](https://github.com/nixcafe/cattery-modules), `beans` is pre-registered.

### Create from Template

```bash
gh repo create my-nixos-config --template nixcafe/nix-config --clone
```

### Enter the Dev Shell

```bash
direnv allow       # or: nix develop
nix flake show     # see all discovered systems/homes
```

## What's Inside

| Component | Purpose |
|-----------|---------|
| `nixosConfigurations` | NixOS system builds (incl. WSL) |
| `darwinConfigurations` | macOS system builds via nix-darwin |
| `homeConfigurations` | Standalone home-manager builds |
| `images` | ISO / VM / cloud images declared in host `meta.nix` (`images.<host>.<format>`) |
| `cattery-modules` | Pre-built NixOS, darwin & home modules |
| Home auto-linking | `user@host` homes auto-injected into matching hosts by purr |
| `nixfmt` · `deadnix` · `statix` | Nix code formatting, dead-code removal, linting |
| `git-hooks` | Pre-commit checks (nixfmt, deadnix, statix) |
| Dev shell | `nix develop` drops you into a shell with the full toolchain + hooks |

## Customizing

### Add a System

Create a new system under `systems/<arch>/<hostname>-<role>/default.nix`:

```
systems/
└── x86_64-linux/
    └── mybox-desktop/
        └── default.nix   # nixosSystem config
```

The directory name becomes the configuration key (e.g. `mybox-desktop`). See existing examples in `systems/` for the expected structure. Supported targets:

- `aarch64-darwin` — Apple Silicon macOS
- `x86_64-linux` — NixOS (bare metal, WSL, server, image recipes)

### Add an Image Recipe

Images are normal `x86_64-linux` hosts with a `meta.nix` that declares their
formats:

```nix
# systems/x86_64-linux/installer/meta.nix
{
  images = [ "iso-installer" ];
}
```

An image-only host is exposed as `images.<host>.<format>` and excluded from
`nixosConfigurations` by default:

```bash
nix build .#images.installer.iso-installer
```

Set `deployable = true` in `meta.nix` if the same host should also appear in
`nixosConfigurations`.

### Add a Home

Create a standalone home under `homes/<arch>/<user>@<hostname>/default.nix`:

```
homes/
└── x86_64-linux/
    └── nixos@mybox-desktop/
        └── default.nix   # home-manager config
```

**Purr auto-linking**: when a home directory matches the pattern `<user>@<hostname>`, purr automatically injects it into the matching `nixosConfiguration` or `darwinConfiguration`. No extra wiring needed.

### Enable Pre-commit Hooks

Hooks are defined in `checks/git-hooks/default.nix` and run `nixfmt`, `deadnix`, and `statix` on staged files:

```bash
pre-commit run --all-files   # run hooks manually
git commit                   # hooks run automatically (via git-hooks.nix)
```

When you enter the dev shell (`nix develop`), the hooks are installed into `.git/hooks` automatically.

## Project Structure

```
.
├── flake.nix              # Flake entrypoint — inputs, purr mkFlake, outputsBuilder
├── .envrc                 # direnv: `use flake`
├── .gitignore
├── checks/
│   └── git-hooks/
│       └── default.nix    # Pre-commit hooks (nixfmt, deadnix, statix)
├── shells/
│   └── default/
│       └── default.nix    # Dev shell (nixfmt, deadnix, statix + hooks)
├── systems/               # System configurations per arch / host
│   ├── aarch64-darwin/    #   macOS (nix-darwin)
│   └── x86_64-linux/      #   NixOS (bare metal, WSL, server, image recipes)
│       └── <host>/meta.nix #   Optional host metadata + `images` recipes
├── homes/                 # Standalone home-manager configs (user@host)
│   ├── aarch64-darwin/
│   └── x86_64-linux/
├── modules/               # Custom NixOS / darwin / home-manager modules
│   ├── nixos/
│   ├── darwin/
│   └── home/
├── lib/                   # Shared library code
│   ├── host/              #   Per-user host metadata (name, email, keys, …)
│   ├── module/            #   Module helpers
│   └── secrets/           #   agenix integration (develop-my-secrets)
└── statix.toml            # Statix linter config
```

## Flake Inputs

| Input | Source | Role |
|-------|--------|------|
| `nixpkgs` | FlakeHub / NixOS/nixpkgs | Package set |
| `purr` | FlakeHub / nixcafe/purr | Flake builder (`mkFlake`) |
| `cattery-modules` | FlakeHub / nixcafe/cattery-modules | Pre-built system modules |
| `nixos-hardware` | FlakeHub / NixOS/nixos-hardware | Hardware quirks |
| `darwin` | FlakeHub / nix-darwin/nix-darwin | macOS system management |
| `home-manager` | FlakeHub / nix-community/home-manager | User environment |
| `git-hooks` | FlakeHub / cachix/git-hooks.nix | Pre-commit checks |
| `my-secrets` | github:nixcafe/develop-my-secrets | agenix secret bootstrap |

## License

MIT
