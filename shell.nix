let
  # commit revison of nixpkgs repository
  nixpkgsRev = "nixos-unstable";

  # a nix function to fetch a tar ball from github
  githubTarball = owner: repo: rev:
    builtins.fetchTarball { url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz"; };

  # import set of packages from nixpkgs github repo at a particular revision with the config specified below
  pkgs = import (githubTarball "nixos" "nixpkgs" nixpkgsRev) { };

  os = if pkgs.stdenv.isDarwin then "macos" else "linux";
  arch = if pkgs.stdenv.isAarch64 then "arm64" else "x86_64";
  hashes =
    {
      "x86_64-linux" = "443a763487366fa960120bfe193441e6bbe86fdb31baeed7dbb17d410dee0522";
      "aarch64-linux" = "f11bec3b094df0c0958a8f1e07af5570199e671a882ad5fe979f1e7e482e986d";
      "x86_64-darwin" = "d05a88d13e240fdbc1bf64bd1a4a9ec4d3d53c95961bb9e338449b856df91853";
      "aarch64-darwin" = "bb105e7aebae3c637b761017c6fb49d9696eba1022f27ec594aac9c2dbffd907";
    };

  lamdera = pkgs.stdenv.mkDerivation rec {
    name = "lamdera-${version}";

    version = "1.1.0";

    src = pkgs.fetchurl {
      url = "https://static.lamdera.com/bin/lamdera-${version}-${os}-${arch}";
      sha256 = hashes.${pkgs.stdenv.system};
    };

    unpackPhase = ":";

    sourceRoot = ".";

    installPhase = ''
      install -m755 -D $src $out/bin/lamdera
    '';

    meta = with pkgs.lib; {
      homepage = "https://lamdera.com/";
      # license = licenses.unfree;
      description = "Lamdera";
      platforms = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
    };
  };
in
{
  inherit pkgs;
  shell = pkgs.mkShell {
    name = "elm pages invoices app";
    buildInputs = [
      lamdera
      pkgs.nodejs_20
      pkgs.openssl
      pkgs.nodePackages_latest.prisma
      pkgs.elmPackages.elm-json
    ];
    shellHook = ''
      echo "elm pages starter"
      PATH="$PWD/node_modules/.bin:$PATH"
    '';
    PRISMA_MIGRATION_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/migration-engine";
    PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
    PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
    PRISMA_INTROSPECTION_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/introspection-engine";
    PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
  };
}
