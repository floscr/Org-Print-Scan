{ pkgs ? import <nixpkgs> }:
pkgs.mkShell {
  shellHook = ''
    export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
    export NIMBLE_DIR="$PWD/.nimble"
  '';
  buildInputs = [ pkgs.nim ];
}
