{ writeShellApplication, python3 }:
writeShellApplication {
  name = "text_templater";
  runtimeInputs = [
    python3
  ];
  text = ''
    python ${./replace.py} "$@"
    '';
}
