# test injecting a secret into a text template
{ legacyPackages, system, nixpkgs }:
let
  # this file would usually be outside of the store
  # but in this test it isn't, because setting it up in other ways is hard :)
  secret_file = (nixpkgs.legacyPackages.${system}.writeText "secret" "secret");
in (nixpkgs.lib.nixos.runTest {
    hostPkgs = nixpkgs.legacyPackages.${system};
    name = "nix_templates";

    nodes.machine = {pkgs, ...}: {
      config = {
        systemd.services.testservice = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStartPre = "${legacyPackages.${system}.templateText {
              name = "test";
              text = ''
              public text
              ${legacyPackages.${system}.fileContents secret_file}
              '';
              outPath = "./test";
            }}/bin/test";
            ExecStart = pkgs.writeScript "test_file_got_templates" ''
              #!/bin/sh
              cat ./test | grep -q 'secret'
            '';
          };
        };
      };
    };

    testScript = ''
      start_all()
      print(machine.execute("uname -a"))
      machine.wait_for_unit("multi-user.target")
      print(machine.succeed("cat /test | grep -q secret"))
    '';
  })
