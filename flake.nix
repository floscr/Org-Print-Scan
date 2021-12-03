{
  description = "A simple example of managing a project with a flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.nimble.url = "github:floscr/flake-nimble";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, nimble, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        nimpkgs = nimble.packages.${system};
        buildInputs = with pkgs; [
          imagemagick
          ocrmypdf
          scantailor
          poppler_utils
          qpdf
        ];
      in
      rec {
        packages.org_print_scan = pkgs.stdenv.mkDerivation {
          name = "org_print_scan";
          src = ./.;

          nativeBuildInputs = with pkgs; [
            nim
            pkgconfig
          ];

          buildInputs = buildInputs;

          buildPhase = with pkgs; let
            fusion = pkgs.fetchFromGitHub
              ({
                owner = "nim-lang";
                repo = "fusion";
                rev = "v1.1";
                sha256 = "9tn0NTXHhlpoefmlsSkoNZlCjGE8JB3eXtYcm/9Mr0I=";
              });
            nimfp = pkgs.fetchFromGitHub
              ({
                owner = "floscr";
                repo = "nimfp";
                rev = "master";
                sha256 = "sha256-gEs4qovho5qTXCquEG+fZOsL3rGB+Ql/r0IeLhnHjFk=";
              });
          in
          ''
            HOME=$TMPDIR
            # Pass paths of needed buildInputs
            # and nim packages fetched from nix
            nim compile \
                --threads \
                -d:release \
                --verbosity:0 \
                --hint[Processing]:off \
                --excessiveStackTrace:on \
                -p:${fusion}/src \
                -p:${nimfp}/src \
                -p:${nimpkgs.cascade}/src \
                -p:${nimpkgs.classy}/src \
                -p:${nimpkgs.cligen}/src \
                -p:${nimpkgs.nimboost}/src \
                -p:${nimpkgs.print}/src \
                -p:${nimpkgs.regex}/src \
                -p:${nimpkgs.unicodedb}/src \
                -p:${nimpkgs.unpack}/src \
                -p:${nimpkgs.zero_functional}/src \
                --out:$TMPDIR/${name} \
                ./src/lib/scan.nim
          '';
          installPhase = ''
            install -Dt $out/bin $TMPDIR/org_print_scan
          '';
        };

        devShell = import ./shell.nix {
          inherit pkgs;
          inherit nimpkgs;
          inherit buildInputs;
        };

        defaultApp = {
          program = "${packages.org_print_scan}/bin/org_print_scan";
          type = "app";
        };

        defaultPackage = packages.org_print_scan;

      });
}
