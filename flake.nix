{
  description = "Development environment for Elixir.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        erlangVersion = pkgs.erlang_26;
        erlangPackages = pkgs.beam.packagesWith erlangVersion;
        elixir = erlangPackages.elixir_1_15;
        elixir-ls = erlangPackages.elixir-ls;

      in
      {
        devShell = pkgs.mkShell {
          packages = [
            elixir
            elixir-ls
            erlangVersion
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

            echo "Elixir Development Shell"
            echo "------------------------"
            elixir --version
            echo "------------------------"
          '';

          nativeBuildInputs = [];
        };
      });
}
