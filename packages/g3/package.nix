{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkg-config,
  cmake,
  openssl,
  libx11,
  libxtst,
  llvmPackages,
}:

rustPlatform.buildRustPackage rec {
  pname = "g3";
  version = "0.1.0-unstable-2025-02-22";

  src = fetchFromGitHub {
    owner = "dhanji";
    repo = "g3";
    rev = "f074d2c1f488c770454a54106f1b1466a1a78283";
    hash = "sha256-md59P0t31/2Np7avZRZK7jLhMN6M3LREMdwI3wayZJs=";
  };

  cargoHash = "sha256-NUzzDMsNAGypkFsN/yyVWxb+Dp0OfzX3BTSmMeJt25Q=";

  nativeBuildInputs = [
    pkg-config
    cmake
    llvmPackages.libclang
  ];

  buildInputs = [
    openssl
  ]
  ++ lib.optionals stdenv.isLinux [
    libx11
    libxtst
  ];

  env.LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";

  preBuild = ''
    export BINDGEN_EXTRA_CLANG_ARGS="$(< ${stdenv.cc}/nix-support/libc-crt1-cflags) $(< ${stdenv.cc}/nix-support/libc-cflags) $(< ${stdenv.cc}/nix-support/cc-cflags) $NIX_CFLAGS_COMPILE"
  '';

  cargoBuildFlags = [
    "--package"
    "g3"
    "--package"
    "studio"
  ];

  postInstall = ''
    mv $out/bin/studio $out/bin/g3-studio
  '';

  doCheck = false;
  doInstallCheck = false;

  passthru.category = "AI Coding Agents";

  meta = with lib; {
    description = "AI coding agent with multi-provider LLM support, computer control, and multi-agent workspace management";
    homepage = "https://github.com/dhanji/g3";
    license = licenses.mit;
    sourceProvenance = with sourceTypes; [ fromSource ];
    maintainers = [ ];
    mainProgram = "g3";
    platforms = platforms.unix;
  };
}
