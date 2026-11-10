# task-tui: a TUI for Taskwarrior built with Textual
# https://github.com/lbesnard/task-tui
# Update: re-run nix-prefetch-url on the new wheel and update hash/version
{ python3Packages, fetchurl }:

python3Packages.buildPythonPackage {
  pname = "task-tui";
  version = "2.4.0";
  format = "wheel";

  src = fetchurl {
    url = "https://github.com/lbesnard/task-tui/releases/download/v2.4.0/task_tui-2.4.0-py3-none-any.whl";
    hash = "sha256-BcXIUbdpKMq3/fql4857S19OUdXttxwK0n2fNg8S+60=";
  };

  propagatedBuildInputs = with python3Packages; [ textual ];

  doCheck = false;
}
