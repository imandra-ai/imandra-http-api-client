{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs =
    [ pkgs.czmq pkgs.gmp pkgs.opam pkgs.pkg-config pkgs.postgresql pkgs.zlib pkgs.ocamlformat_0_21_0 ]
    ++ (if pkgs.stdenv.isDarwin then
      (with pkgs.darwin.apple_sdk.frameworks; [ CoreServices Foundation ])
    else
      [ pkgs.inotify-tools ]);
}
