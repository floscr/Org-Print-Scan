{
  description = "A simple example of managing a project with a flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nimble.url = "github:floscr/flake-nimble";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nimble, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
          nimpkgs = nimble.packages.${system};
          buildInputs = with pkgs; [
            imagemagick
            ocrmypdf
            scantailor
          ];
      in rec {
        packages.org_print_scan = pkgs.stdenv.mkDerivation {
          name = "org_print_scan";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            nimpkgs.nim
            pkgconfig
          ];

          buildInputs = buildInputs;

          buildPhase = with pkgs; ''
            HOME=$TMPDIR
            nim compile \
            -d:release \
            -p:${nimpkgs.argparse}/src \
            -p:${nimpkgs.nimboost}/src \
            -p:${nimpkgs.classy}/src \
            -p:${nimpkgs.nimfp}/src \
            -p:${nimpkgs.tempfile}/src \
            --out:$TMPDIR/org_print_scan \
            ./src/org_print_scan.nim
          '';
          installPhase = ''
            install -Dt \
            $out/bin \
            $TMPDIR/org_print_scan
          '';
        };

        devShell = import ./shell.nix {
          inherit pkgs;
          inherit nimpkgs;
          inherit buildInputs;
        };

        defaultPackage = packages.org_print_scan;

      });
}
