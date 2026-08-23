# task-tui: a TUI for Taskwarrior built with Textual
# https://github.com/lbesnard/task-tui
# Update: re-run nix-prefetch-url on the new wheel and update hash/version
{ python3Packages, fetchurl }:

python3Packages.buildPythonPackage {
  pname = "task-tui";
  version = "1.6.0";
  format = "wheel";

  src = fetchurl {
    url = "https://github.com/lbesnard/task-tui/releases/download/v1.6.0/task_tui-1.6.0-py3-none-any.whl";
    hash = "sha256:af1fc3675f3918112744256dd6695df59a43f23762cf6fe3145db241448fb363";
  };

  propagatedBuildInputs = with python3Packages; [ textual ];

  doCheck = false;
}
