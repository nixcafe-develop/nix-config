{
  inputs,
  pkgs,
  system,
  ...
}:
pkgs.mkShell {
  packages = with pkgs; [
    nixfmt
    deadnix
    statix
  ];

  inherit (inputs.self.checks.${system}.git-hooks) shellHook;
  buildInputs = inputs.self.checks.${system}.git-hooks.enabledPackages;
}
