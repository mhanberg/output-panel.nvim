{
  description = "A panel to view the logs from your LSP servers.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" "x86_64-windows" "aarch64-windows"];

      perSystem = {
        pkgs,
        system,
        ...
      }: {
        packages.default = pkgs.vimUtils.buildVimPlugin {
          pname = "output-panel-nvim";
          version = "unstable";
          src = self;
          # dependencies = with pkgs.vimPlugins; [
          #   nui-nvim
          #   nvim-dap
          #   nvim-nio
          #   nvim-dap-virtual-text
          #   noice-nvim
          # ];
          nvimSkipModule = [
          ];
        };
      };
    };
}
