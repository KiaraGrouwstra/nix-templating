{ writeShellApplication, python3 }:
writeShellApplication {
  name = "nix_templater";
  runtimeInputs = [
    python3
  ];
  text = ''
    python ${./replace.py} "$@"
    '';
}
