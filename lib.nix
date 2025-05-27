{ pkgs, nix_templater }:
rec {
  fileContents = file: {
   outPath = "<${builtins.placeholder "nix_template"}${toString file}${builtins.placeholder "nix_template"}>";
   file = file;
  };

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
}
