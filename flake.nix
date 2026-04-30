{
  description = "Development environment for Elixir.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        beamPkgs = pkgs.beam.packages.erlang_28;
      in
      {
        devShells.default = pkgs.mkShell {
          name = "Elixir Shell";
          nativeBuildInputs = [
            beamPkgs.erlang
            beamPkgs.elixir_1_20
            beamPkgs.elixir-ls
            beamPkgs.elixir-ls
            pkgs.git
            pkgs.fish
          ];

          shellHook = ''
            export LANG=en_US.UTF-8
            export ELIXIR_ERL_OPTIONS="+fnu"
            export PROJECT_ROOT=$(pwd)
            export MIX_HOME=$PROJECT_ROOT/.nix-mix
            export HEX_HOME=$PROJECT_ROOT/.nix-hex
            mkdir -p $MIX_HOME $HEX_HOME

            mix local.hex --if-missing --force
            mix local.rebar --if-missing --force

            echo "Elixir Development Shell"
            echo "------------------------"
            elixir --version
            echo "------------------------"
          '';

        };
      });
}
