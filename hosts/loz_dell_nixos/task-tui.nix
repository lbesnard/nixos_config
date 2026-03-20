# task-tui: a TUI for Taskwarrior built with Textual
# https://github.com/lbesnard/task-tui
# Update: re-run nix-prefetch-url on the new wheel and update hash/version
{ python3Packages, fetchurl }:

python3Packages.buildPythonPackage {
  pname = "task-tui";
  version = "1.2.0";
  format = "wheel";

  src = fetchurl {
    url = "https://github.com/lbesnard/task-tui/releases/download/v1.2.0/task_tui-1.2.0-py3-none-any.whl";
    hash = "sha256-2jjhZhYq/tEbhmWHQV2dYqL6a+XPJtJOJtV0432SOS0=";
  };

  propagatedBuildInputs = with python3Packages; [ textual ];

  doCheck = false;
}
