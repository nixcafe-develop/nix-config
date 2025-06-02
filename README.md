# NixOS Configuration Template

This template provides a streamlined way to set up and manage your NixOS configuration using the `cattery-modules` from NixCafe. It includes support for agenix secret management and various system configurations.

## Features

- Quick deployment of NixOS configurations using `cattery-modules`
- Integrated agenix secret management
- Support for multiple system types (NixOS, Darwin, WSL)
- Pre-configured development environments
- Modular and maintainable configuration structure

## Getting Started

### 1. Use Template Repository

[Create a new repository from this template](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)

### 2. Basic Configuration

The main configuration file is located at `./lib/host/default.nix`:

```nix
{
  # default vars
  host = {
    # Your name
    name = "example";
    # Your nickname (currently used as git name)
    nickname = "example";
    # Your email
    email = "demo@example.com";
    # If you want git to use gpg, you can fill in the key id here
    signKey = "";
    # Fill in the key that all your hosts trust. 
    # Note that they have large permissions and need to be saved offline.
    authorizedKeys.keys = [ ];
    # starship config, see: https://starship.rs/config/
    starship.settings = builtins.fromTOML (builtins.readFile ./config/starship.toml);
  };
}
```

### 3. Directory Structure

```
.
├── flake.nix              # Main flake configuration
├── lib/                   # Library functions and host configurations
│   └── host/             # Host-specific configurations
├── modules/              # Custom modules
│   ├── darwin/          # macOS specific modules
│   ├── home/            # Home Manager modules
│   └── nixos/           # NixOS specific modules
├── systems/             # System configurations
│   ├── aarch64-darwin/  # macOS configurations
│   └── x86_64-linux/    # Linux configurations
└── homes/               # Home Manager configurations
    ├── aarch64-darwin/  # macOS home configurations
    └── x86_64-linux/    # Linux home configurations
```

### 4. Using cattery-modules

The template integrates `cattery-modules` for easy system configuration. Example usage:

```nix
{
  cattery = {
    room.desktop.dev.enable = true;  # Enable development environment
    desktop.plasma.enable = true;    # Enable KDE Plasma
  };
}
```

### 5. Secret Management with agenix

For detailed information about secret management using agenix, please refer to the [develop-my-secrets](https://github.com/nixcafe/develop-my-secrets) repository. The template is pre-configured to work with agenix for secure secret management.

## Available Modules

- **Desktop Environments**: KDE Plasma, GNOME, etc.
- **Development Tools**: VSCode, development environments
- **System Configurations**: Server, WSL, macOS
- **Secret Management**: agenix integration

## Contributing

Feel free to submit issues and enhancement requests!
