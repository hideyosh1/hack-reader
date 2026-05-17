{
  description = "hacky development shell";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forEachSupportedSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          }
        );
    in
    {
      overlays.default = final: prev: rec {
        nodejs = prev.nodejs;
        yarn = prev.yarn.override { inherit nodejs; };
      };

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {

            venvDir = ".venv";
            packages =
              with pkgs;
              [
                nodejs
                yarn-berry
                typescript
                typescript-language-server
                pyright
                black
                python39
                libjpeg
                zlib
                openssl
              ]
              ++ (with pkgs.python313Packages; [
                pip
                venvShellHook
              ]);
            /*
              shellHook = ''
                npx update-browserslist-db@latest
              '';
            */
          };
        }
      );
    };
}
