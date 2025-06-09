{ pkgs, lib, nix_templater }:
let
  escapeJson = {
    "\"" = ''\"'';
    "\\" = ''\\'';
  };
in
rec {
  # placeholder to be substituted with the content of a secret file
  fileContents = file: {
   outPath = "<${builtins.placeholder "nix_template"}${toString file}${builtins.placeholder "nix_template"}>";
   file = file;
  };

  # make a template with placeholders
  templateText = { name, text, outPath, translations ? {} }:
    pkgs.runCommand name {
      textBeforeTemplate = text;
      script = ''
        #!/bin/sh
        ${nix_templater}/bin/nix_templater ${builtins.placeholder "out"}/template ${builtins.placeholder "nix_template"} "${outPath}" '${lib.strings.toJSON translations}'
      '';
      passAsFile = [ "script" "textBeforeTemplate" ];
    } ''
      mkdir -p $out/bin
      cp $textBeforeTemplatePath $out/template
      cp $scriptPath $out/bin/${name}
      chmod +x $out/bin/${name}
    '';

  templateGenerator = translations: generator: { name, value, outPath }: templateText {
    inherit name outPath translations;
    text = generator value;
  };

  templateJsonWith = options: templateGenerator escapeJson (lib.generators.toJSON options);
  templateYamlWith = options: templateGenerator escapeJson (lib.generators.toYAML options); # just json
  templateIniWith = options: templateGenerator escapeJson (lib.generators.toINI options);
  templateJson = templateJsonWith { };
  templateYaml = templateYamlWith { };
  templateIni = templateIniWith { };
}
