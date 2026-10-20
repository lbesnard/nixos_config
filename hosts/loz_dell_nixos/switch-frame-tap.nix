# switch-frame-tap: Linux viewer for streaming/recording a Nintendo Switch over USB
# https://github.com/TomasUribe/switch-frame-tap
# Update: bump version/url below and re-run nix-prefetch-url on the new tarball
{
  lib,
  stdenv,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  libusb1,
  SDL2,
  alsa-lib,
  libGL,
  libglvnd,
  mesa,
  libpulseaudio,
  wayland,
  libxkbcommon,
  libdecor,
  libdrm,
  libva,
  dbus,
  xorg,
}:

stdenv.mkDerivation rec {
  pname = "switch-frame-tap";
  version = "0.7.13.1";

  src = fetchzip {
    url = "https://github.com/TomasUribe/switch-frame-tap/releases/download/v${version}/switch-frame-tap-${version}-linux.tar.gz";
    hash = "sha256-4H5KbzQ0c0zm4AyCzk3+puhC5IvwnQ+AokhQqwKzkXM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  # Most of SDL2's backends (X11, Wayland, OpenGL/EGL, audio) and libva are
  # dlopen()'d at runtime rather than linked, so autoPatchelfHook (which only
  # patches DT_NEEDED entries) can't find them. runtimeLibs below is injected
  # into LD_LIBRARY_PATH so those dlopen() calls succeed.
  runtimeLibs = [
    SDL2
    alsa-lib
    libGL
    libglvnd
    mesa
    libpulseaudio
    wayland
    libxkbcommon
    libdecor
    libdrm
    libva
    dbus
    xorg.libX11
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXi
    xorg.libXext
    xorg.libXfixes
    xorg.libXScrnSaver
  ];

  buildInputs = [
    libusb1
    stdenv.cc.cc.lib
  ] ++ runtimeLibs;

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 switch-frame-tap-viewer $out/bin/switch-frame-tap-viewer
    install -Dm644 switch-frame-tap.svg $out/share/icons/hicolor/scalable/apps/switch-frame-tap.svg
    install -Dm644 99-switch-frame-tap.rules $out/lib/udev/rules.d/99-switch-frame-tap.rules
    install -Dm644 licenses/*.txt -t $out/share/licenses/switch-frame-tap

    wrapProgram $out/bin/switch-frame-tap-viewer \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibs}"

    mkdir -p $out/share/applications
    cat > $out/share/applications/switch-frame-tap.desktop <<DESK
    [Desktop Entry]
    Type=Application
    Name=Switch Frame Tap
    Comment=Watch and record your Switch, streamed over USB or the network
    Exec=$out/bin/switch-frame-tap-viewer --app
    PrefersNonDefaultGPU=true
    Icon=switch-frame-tap
    Terminal=false
    Categories=Game;AudioVideo;
    DESK

    runHook postInstall
  '';

  meta = with lib; {
    description = "Watch and record your Nintendo Switch, streamed over USB or the network";
    homepage = "https://github.com/TomasUribe/switch-frame-tap";
    license = licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "switch-frame-tap-viewer";
  };
}
