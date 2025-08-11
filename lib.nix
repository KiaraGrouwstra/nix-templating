{ pkgs, nix_templater }:
{
  # placeholder to be substituted with the content of a secret file
  fileContents = file: {
   outPath = "<${builtins.placeholder "nix_template"}${toString file}${builtins.placeholder "nix_template"}>";
   file = file;
  };

  # make a template with placeholders
  template_text = {
    name,
    text,
    outPath,
    owner ? "root",
    group ? "",
    mode ? "0400",
  }:
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
      chown ${owner}:${group} $out/bin/${name}
      chmod ${mode} $out/bin/${name}
    '';
}
