# terminal-browser: a graphical browser rendered inside the terminal via the
# Kitty graphics protocol. https://github.com/zenbu-labs/terminal-browser
#
# Upstream ships no source build, only a prebuilt Electron bundle fetched by
# their installer (https://terminal-browser.sh/install) straight from GitHub
# releases, so this just unpacks that same tarball and autoPatchelfHook's the
# bundled Electron ("pixel") binary, its native addon, and the agent-browser
# CLI against nixpkgs' copies of their shared libs (list taken from `readelf
# -d electron/pixel`, the standard Electron/Chromium dependency set).
#
# The bundle also ships its own setuid chrome-sandbox helper, which the Nix
# store can't make setuid-root. ELECTRON_DISABLE_SANDBOX=1 tells Electron to
# skip it at startup instead of refusing to launch — this drops the
# renderer sandbox, which is an acceptable trade for a personal, single-user
# machine but worth knowing about.
#
# Update: bump `version` below, then refetch the hash with
#   nix-prefetch-url --unpack --type sha256 \
#     https://github.com/zenbu-labs/terminal-browser/releases/download/v<ver>/terminal-browser-linux-x64.tar.gz
# (fetchzip hashes the *extracted* contents, not the raw archive) and convert
# with `nix hash to-sri --type sha256 <result>`.
{
  stdenv,
  lib,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  glib,
  nspr,
  nss,
  atk,
  at-spi2-atk,
  at-spi2-core,
  cups,
  dbus,
  cairo,
  gtk3,
  pango,
  mesa,
  expat,
  libxkbcommon,
  systemd,
  alsa-lib,
  libx11,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxrandr,
  libxcb,
}:

stdenv.mkDerivation rec {
  pname = "terminal-browser";
  version = "0.15.4";

  src = fetchzip {
    url = "https://github.com/zenbu-labs/terminal-browser/releases/download/v${version}/terminal-browser-linux-x64.tar.gz";
    hash = "sha256-ozF4lAUfMfIWu7He0YULnyNCRERBii7j5g7S7TU+Yd8=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # electron/pixel's direct NEEDED entries (minus libc/libm/libdl/libpthread/
  # libgcc_s/libstdc++, which autoPatchelfHook already resolves via stdenv).
  buildInputs = [
    stdenv.cc.cc.lib
    glib
    nspr
    nss
    atk
    at-spi2-atk
    at-spi2-core
    cups
    dbus
    cairo
    gtk3
    pango
    mesa
    expat
    libxkbcommon
    systemd
    alsa-lib
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
  ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/terminal-browser
    cp -r . $out/opt/terminal-browser/

    mkdir -p $out/bin
    makeWrapper $out/opt/terminal-browser/bin/terminal-browser $out/bin/terminal-browser \
      --set ELECTRON_DISABLE_SANDBOX 1
    makeWrapper $out/opt/terminal-browser/agent-browser/bin/agent-browser $out/bin/agent-browser

    runHook postInstall
  '';

  meta = {
    description = "Graphical browser that renders inside the terminal over the Kitty graphics protocol";
    homepage = "https://github.com/zenbu-labs/terminal-browser";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "terminal-browser";
  };
}
