# test injecting a secret into a json template
{ legacyPackages, system, nixpkgs }:
let
  hostPkgs = nixpkgs.legacyPackages.${system};
  secret_file = hostPkgs.writeText "secret" "secret\\needing\"escaping";
in (nixpkgs.lib.nixos.runTest {
    inherit hostPkgs;
    name = "nix_templates";

    nodes.machine = {pkgs, ...}: {
      config = {
        systemd.services.testservice = {
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStartPre = "${legacyPackages.${system}.templateJson {
              name = "test";
              value = {
                foo = "text";
                bar = legacyPackages.${system}.fileContents secret_file;
              };
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
      print(machine.succeed("cat /test"))
      print(machine.succeed("cat /test | grep -q secret"))
      print(machine.succeed("cat /test | ${hostPkgs.jq}/bin/jq"))
    '';
  })
