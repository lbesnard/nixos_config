{ lib, stdenv, appimageTools, fetchurl, makeWrapper, _7zz }:

let
  pname = "joplin-desktop";
  version = "3.2.12";

  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  suffix = {
    x86_64-linux = ".AppImage";
    x86_64-darwin = ".dmg";
    aarch64-darwin = "-arm64.dmg";
  }.${system} or throwSystem;

  src = fetchurl {
    url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}${suffix}";
    sha256 = {
      x86_64-linux = "sha256-+2FFQLNT61hmyOkfLKM8VCMBNjImTHMe3DNVmR6Zcvc=";
      # x86_64-darwin = "sha256-s7gZSr/5VOg8bqxGPckK7UxDpvmsNgdhjDg+lxnO/lU=";
      # aarch64-darwin = "sha256-UzAGYIKd5swtl6XNFVTPeg0nqwKKtu0e36+LA0Qiusw=";
    }.${system} or throwSystem;
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };

  meta = with lib; {
    description = "Open source note taking and to-do application with synchronisation capabilities";
    mainProgram = "joplin-desktop";
    longDescription = ''
      Joplin is a free, open source note taking and to-do application, which can
      handle a large number of notes organised into notebooks. The notes are
      searchable, can be copied, tagged and modified either from the
      applications directly or from your own text editor. The notes are in
      Markdown format.
    '';
    homepage = "https://joplinapp.org";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ hugoreeves qjoly ];
    platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };

  linux = appimageTools.wrapType2 rec {
    inherit pname version src meta;
    nativeBuildInputs = [ makeWrapper ];

    profile = ''
      export LC_ALL=C.UTF-8
    '';

    extraInstallCommands = ''
      wrapProgram $out/bin/${pname} \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform=wayland --enable-features=WaylandWindowDecorations}}"
      install -Dm444 ${appimageContents}/joplin.desktop -t $out/share/applications
      install -Dm444 ${appimageContents}/joplin.png -t $out/share/pixmaps
      substituteInPlace $out/share/applications/joplin.desktop \
        --replace 'Exec=AppRun' 'Exec=${pname}' \
        --replace 'Icon=joplin' "Icon=joplin"
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version src meta;

    nativeBuildInputs = [ _7zz ];

    sourceRoot = "Joplin.app";

    installPhase = ''
      mkdir -p $out/Applications/Joplin.app
      cp -R . $out/Applications/Joplin.app
    '';
  };
in
if stdenv.hostPlatform.isDarwin
then darwin
else linux


# {
#   lib,
#   appimageTools,
#   fetchurl,
# }:
#
# let
#   version = "3.2.12";
#   pname = "joplin";
#
#   src = fetchurl {
#     url = "https://github.com/laurent22/joplin/releases/download/v${version}/Joplin-${version}.AppImage";
#     # hash = "sha256-EsTF7W1np5qbQQh3pdqsFe32olvGK3AowGWjqHPEfoM=";
#   };
#
#   appimageContents = appimageTools.extractType1 { inherit name src; };
# in
# appimageTools.wrapType2 rec {
#   inherit pname version src;
#
#   extraInstallCommands = ''
#     substituteInPlace $out/share/applications/${pname}.desktop \
#       --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
#   '';
#
#   meta = {
#     description = "Joplin - An open-source note-taking and to-do application";
#     homepage = "https://joplinapp.org";
#     license = lib.licenses.asl20;
#     sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
#     maintainers = with lib.maintainers; [ onny ];
#     platforms = [ "x86_64-linux" ];
#   };
# }
