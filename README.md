# NixOS configuration template

This flake is a starting point for NixOS, nix-darwin, and standalone home-manager configurations. It uses [purr](https://github.com/nixcafe/purr) to discover systems and homes, and [cattery-modules](https://github.com/nixcafe/cattery-modules) for the system and user modules. The repository also defines pre-commit hooks and image recipes.

It is part of the [develop-templates](https://github.com/nixcafe/develop-templates) collection and can be copied with `nix flake init` or used as a GitHub template.

## Quick start

### Create from the flake template

```bash
nix flake init -t "github:nixcafe/develop-templates#nix-config" --refresh
```

If you use the templates often, register the collection once:

```bash
nix registry add beans "github:nixcafe/develop-templates"
nix flake init -t beans#nix-config
```

On systems that import cattery-modules, the `beans` registry entry is already configured.

### Create a GitHub repository from the template

```bash
gh repo create my-nixos-config --template nixcafe-develop/nix-config --clone
```

### Enter the development shell

```bash
direnv allow   # or: nix develop
nix flake show # list the discovered systems and homes
```

## What's included

| Output or component | Purpose |
|---------------------|---------|
| `nixosConfigurations` | NixOS hosts from `systems/x86_64-linux`. The template includes a WSL host. |
| `darwinConfigurations` | macOS hosts from `systems/aarch64-darwin`. |
| `homeConfigurations` | Standalone home-manager configurations from `homes/`. |
| `images` | Images for hosts that list formats in `meta.nix`, such as `images.graphical.iso-installer`. |
| `devShells.default` | Shell with nixfmt, deadnix, statix, and the git hooks. |
| `formatter` | `nixfmt`, also available through `nix fmt`. |
| `checks.git-hooks` | Pre-commit checks for nixfmt, deadnix, and statix. |
| `modules/` | Local modules for the user account, secrets, and Homebrew. |
| `cattery-modules` | Input that provides the `cattery` option namespace. |
| Home linking | A home named `<user>@<host>` is added to the system with the same host name. |

## Configuration

### Host identity

Edit `lib/host/default.nix`. The values are used by the user modules and can be overridden per host.

```nix
{
  name = "nixos";
  realName = "NixOS";
  email.address = "nixos@example.com";
  timeZone = "America/New_York";
  authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
}
```

The starship prompt configuration is read from `lib/host/config/starship.toml`.

### Add a system

Create `systems/<arch-format>/<name>/default.nix`. For NixOS, use a directory such as `systems/x86_64-linux/desktop`. For nix-darwin, use a directory such as `systems/aarch64-darwin/laptop`. The directory name becomes the key in `nixosConfigurations` or `darwinConfigurations`.

```nix
{
  cattery.room.desktop.dev.enable = true;
  system.stateVersion = "25.11";
}
```

purr sets `networking.hostName` to the directory name by default. Add an optional `meta.nix` next to `default.nix` for host metadata.

### Add a home

Create `homes/<arch-format>/<user>@<host>/default.nix`. purr links the home to the system with the same host name and sets `home.username` and `home.homeDirectory`. The same file is also exposed as a standalone entry in `homeConfigurations`.

```nix
{
  home.stateVersion = "25.11";
  cattery.room.desktop.dev.enable = true;
}
```

### Add an image recipe

Image hosts are normal NixOS hosts with a `meta.nix` that lists formats. The repository has three image hosts under `systems/x86_64-linux`: `graphical`, `minimal`, and `minimal-no-zfs`.

```nix
# systems/x86_64-linux/graphical/meta.nix
{
  images = [ "iso-installer" ];
}
```

Build one with:

```bash
nix build .#images.graphical.iso-installer
```

Image-only hosts are not added to `nixosConfigurations` by default. Set `deployable = true` in `meta.nix` to include the host as a system as well.

### Enable secrets

`my-secrets` is a flake input for the [nixcafe-develop/nix-secrets](https://github.com/nixcafe-develop/nix-secrets) repository. Secret support in `lib/secrets/default.nix` is disabled by default:

```nix
{
  enable = false;
  secretsPath = "${inputs.my-secrets}";
}
```

Set `enable = true` to pass the secrets path to the cattery secrets module. The input uses `flake = false`, so `secretsPath` points at the repository contents.

### Git hooks

Hooks are defined in `checks/git-hooks/default.nix` and run `nixfmt`, `deadnix`, and `statix`. The `statix.toml` file ignores `repeated_keys` and `.direnv`.

```bash
pre-commit run --all-files   # run the hooks manually
git commit                   # hooks run on the staged files
```

Entering the development shell installs the hooks in `.git/hooks`.

## Project structure

```
.
├── flake.nix                  # inputs and the purr mkFlake call
├── .envrc                     # direnv: use flake
├── .gitignore
├── checks/
│   └── git-hooks/
│       └── default.nix        # pre-commit hooks
├── shells/
│   └── default/
│       └── default.nix        # development shell
├── systems/
│   ├── aarch64-darwin/
│   │   └── hostname-mbp/
│   └── x86_64-linux/
│       ├── graphical/         # meta.nix declares an ISO image
│       ├── hostname-nixos/
│       ├── hostname-server/
│       ├── hostname-wsl/
│       ├── minimal/           # meta.nix declares an ISO image
│       └── minimal-no-zfs/    # meta.nix declares an ISO image
├── homes/
│   ├── aarch64-darwin/
│   │   └── nixos@hostname-mbp/
│   └── x86_64-linux/
│       ├── nixos@graphical/
│       ├── nixos@hostname-nixos/
│       ├── nixos@minimal/
│       ├── nixos@minimal-no-zfs/
│       ├── root@hostname-server/
│       └── root@hostname-wsl/
├── modules/
│   ├── nixos/
│   │   ├── secrets/
│   │   └── user/
│   ├── darwin/
│   │   ├── brew/
│   │   ├── secrets/
│   │   └── user/
│   └── home/
│       ├── home/
│       ├── secrets/
│       └── user/
├── lib/
│   ├── host/
│   │   ├── config/starship.toml
│   │   └── default.nix        # host identity defaults
│   ├── module/
│   │   └── default.nix        # module helpers
│   └── secrets/
│       └── default.nix        # secrets settings
└── statix.toml
```

## Flake inputs

| Input | Source | Role |
|-------|--------|------|
| `nixpkgs` | `flakehub.com/f/NixOS/nixpkgs` | Package set |
| `purr` | `flakehub.com/f/nixcafe/purr` | Provides `mkFlake` |
| `git-hooks` | `flakehub.com/f/cachix/git-hooks.nix` | Pre-commit hook runner |
| `nixos-hardware` | `flakehub.com/f/nixos/nixos-hardware` | Hardware modules |
| `darwin` | `flakehub.com/f/nix-darwin/nix-darwin` | nix-darwin input |
| `home-manager` | `flakehub.com/f/nix-community/home-manager` | User environments |
| `cattery-modules` | `flakehub.com/f/nixcafe/cattery-modules` | cattery modules |
| `my-secrets` | `github:nixcafe-develop/nix-secrets` | Secrets repository, `flake = false` |

## Useful commands

```bash
nix develop
nix flake show
nix flake check
nix fmt
nix build .#nixosConfigurations.hostname-nixos.config.system.build.toplevel
nix build .#images.graphical.iso-installer
sudo nixos-rebuild switch --flake .#hostname-nixos
```

## License

MIT
