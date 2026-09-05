{
  description = "Personal user-level Claude Code skills, and the installer that links them into ~/.claude/skills";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      forAllSystems = f: lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});

      # The skill tree, and the only thing the installer links.
      skills = ./.claude/skills;

      scripts = pkgs: {
        install = pkgs.writeShellApplication {
          name = "install-skills";
          runtimeInputs = [ pkgs.git ];
          text = builtins.readFile ./scripts/install.sh;
        };
        uninstall = pkgs.writeShellApplication {
          name = "uninstall-skills";
          runtimeInputs = [ pkgs.git ];
          text = builtins.readFile ./scripts/uninstall.sh;
        };
        check = pkgs.writeShellApplication {
          name = "check-skills";
          text = builtins.readFile ./scripts/check-skills.sh;
        };
      };
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          s = scripts pkgs;
        in
        {
          inherit (s) install uninstall check;
        }
      );

      apps = forAllSystems (
        pkgs:
        let
          s = scripts pkgs;
          app = drv: exe: {
            type = "app";
            program = "${drv}/bin/${exe}";
          };
        in
        rec {
          default = install;
          install = app s.install "install-skills";
          uninstall = app s.uninstall "uninstall-skills";
          # Validates the working tree; `nix flake check` validates the
          # committed tree via checks.skills below.
          check = app s.check "check-skills";
        }
      );

      checks = forAllSystems (
        pkgs:
        let
          s = scripts pkgs;
        in
        {
          skills = pkgs.runCommand "check-skills" { } ''
            ${s.check}/bin/check-skills ${skills}
            touch "$out"
          '';
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}
