{ pkgs, lib, nix_templater }:
rec {
  # placeholder to be substituted with the content of a secret file
  fileContents = file: {
   outPath = "<${builtins.placeholder "nix_template"}${toString file}${builtins.placeholder "nix_template"}>";
   file = file;
  };

  # make a template with placeholders
  template_text = { name, text, outPath }:
    pkgs.runCommand name {
      textBeforeTemplate = text;
      script = ''
        #!/bin/sh
        ${nix_templater}/bin/nix_templater ${builtins.placeholder "out"}/template ${builtins.placeholder "nix_template"} "${outPath}"
      '';
      passAsFile = [ "script" "textBeforeTemplate" ];
    } ''
      mkdir -p $out/bin
      cp $textBeforeTemplatePath $out/template
      cp $scriptPath $out/bin/${name}
      chmod +x $out/bin/${name}
    '';

  template_generator = generator: { name, value, outPath }: template_text {
    inherit name outPath;
    text = generator value;
  };

  template_json = options: template_generator (lib.generators.toJSON options);
  template_yaml = options: template_generator (lib.generators.toYAML options); # just json
  template_ini = options: template_generator (lib.generators.toINI options);
}
