{
  pkgs,
  nix_templater,
  lib ? pkgs.lib,
}:
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

  # make a template with placeholders from a text
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

  # make a template with placeholders from a file
  templateFromFile = { name, templateFile, outPath, translations ? {} }:
    pkgs.runCommand name {
      inherit templateFile;
      script = ''
        #!/bin/sh
        ${nix_templater}/bin/nix_templater ${builtins.placeholder "out"}/template ${builtins.placeholder "nix_template"} "${outPath}" '${lib.strings.toJSON translations}'
      '';
      passAsFile = [ "script" ];
    } ''
      mkdir -p $out/bin
      cp $templateFile $out/template
      cp $scriptPath $out/bin/${name}
      chmod +x $out/bin/${name}
    '';

  translateFile = translations: generator: { name, value, outPath }: templateFromFile {
    inherit name outPath translations;
    templateFile = generator value;
  };

  translateText = translations: generator: { name, value, outPath }: templateText {
    inherit name outPath translations;
    text = generator value;
  };

  # escaping: https://www.json.org/json-en.html
  templateJson = translateFile escapeJson (pkgs.writers.writeJSON "template.json");
  # just json
  templateYaml = translateFile escapeJson (pkgs.writers.writeYAML "template.yaml");
  # escaping: technically also control characters (U+0000 to U+001F): https://toml.io/en/v0.3.0#string
  templateToml = translateFile escapeJson (pkgs.writers.writeTOML "template.toml");

  # escaping: https://git.kernel.org/pub/scm/git/git.git/tree/Documentation/config.txt?id=a54a84b333adbecf7bc4483c0e36ed5878cac17b#n47
  templateIniWith = options: translateText escapeJson (lib.generators.toINI options);

  templateIni = templateIniWith { };
}
