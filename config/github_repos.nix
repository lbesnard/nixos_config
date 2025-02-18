{ config, pkgs, ... }:

let
  lingoankiRepo = builtins.fetchGit {
        url = "ssh://git@github.com/lbesnard/LingoAnki.git";
        rev = "5b9ab42231890babfec858275f6dc9abf20377fa";
  };

  Koreader2ankiRepo = builtins.fetchGit {
        url = "ssh://git@github.com/lbesnard/Koreader_Highlights_2_Anki.git";
        rev = "f16e711aa091d521104958a5b2482d3dde98aeb1";
  };
in {
  home.file."./repos/LingoAnki" = {
    source = lingoankiRepo;
    recursive = true;
  };

  home.file."./repos/Koreader_Highlights_2_Anki" = {
    source = Koreader2ankiRepo;
    recursive = true;
  };
}

