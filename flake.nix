{
  description = "akiron-zsh zsh configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      flake.homeManagerModules.default =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.akiron-zsh;
          defaultPackages = with pkgs; [
            zsh
            curl
            git
            fd
            fzf
            file
            lua
            bat
            eza
          ];
          hasLsd = builtins.elem pkgs.lsd cfg.extraPackages;
        in
        {
          options.programs.akiron-zsh = {
            enable = lib.mkEnableOption "akiron-zsh zsh configuration";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              defaultText = lib.literalExpression "inputs.akiron-zsh.packages.\${pkgs.stdenv.hostPlatform.system}.default";
              description = "The akiron-zsh package to link into the Home Manager configuration directory.";
            };

            configDir = lib.mkOption {
              type = lib.types.str;
              default = ".config/akiron-zsh";
              example = ".config/akiron-zsh";
              description = "Path relative to the user's home directory where akiron-zsh is linked.";
            };

            extraPackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
              example = lib.literalExpression "with pkgs; [ lsd jq ]";
              description = "Additional optional packages for akiron-zsh integrations.";
            };

            grepExcludeFolders = lib.mkOption {
              type = lib.types.str;
              default = "{.bzr,CVS,.git,.hg,.svn,.idea,.tox}";
              example = "{.git,.hg,.svn,.idea,.tox,node_modules,target}";
              description = "Directories to exclude from grep searches (sets EXC_FOLDERS).";
            };

            zshCacheDir = lib.mkOption {
              type = lib.types.str;
              default = "$HOME/.cache/akiron-zsh";
              example = "$HOME/.cache/my-zsh";
              description = "Directory for zsh cache files (sets ZSH_CACHE_DIR).";
            };

            caseSensitive = lib.mkOption {
              type = lib.types.bool;
              default = false;
              example = true;
              description = "Whether tab completion should be case-sensitive (sets CASE_SENSITIVE).";
            };

            autoInLastDir = lib.mkOption {
              type = lib.types.bool;
              default = false;
              example = true;
              description = "Whether to automatically enter the last working directory on shell start (sets AKIRON_ZSH_IN_LASTDIR).";
            };

            historyShow = lib.mkOption {
              type = lib.types.bool;
              default = true;
              example = false;
              description = "Whether to bind Ctrl+R to fzf-powered history search (sets AKIRON_ZSH_HISTORY_SHOW).";
            };

            promptStyle = lib.mkOption {
              type = lib.types.enum [
                "compact"
                "segments"
              ];
              default = "compact";
              example = "segments";
              description = "Prompt display style (sets AKIRON_ZSH_PROMPT_STYLE).";
            };
          };

          config = lib.mkIf cfg.enable {
            home.file.${cfg.configDir}.source = cfg.package;

            home.packages = defaultPackages ++ cfg.extraPackages;

            programs.zsh.enable = lib.mkDefault true;
            programs.zsh.initContent = lib.mkAfter ''
              export EXC_FOLDERS="${cfg.grepExcludeFolders}"
              export ZSH_CACHE_DIR="${cfg.zshCacheDir}"
              export CASE_SENSITIVE="${if cfg.caseSensitive then "true" else "false"}"
              export AKIRON_ZSH_IN_LASTDIR="${if cfg.autoInLastDir then "true" else "false"}"
              export AKIRON_ZSH_HISTORY_SHOW="${if cfg.historyShow then "true" else "false"}"
              export AKIRON_ZSH_PROMPT_STYLE="${cfg.promptStyle}"
              source ${config.home.homeDirectory}/${cfg.configDir}/init.zsh
            '';

            programs.lsd = lib.mkIf hasLsd {
              enable = lib.mkDefault true;
              settings.date = lib.mkDefault "+%Y-%m-%d %H:%M:%S";
            };
          };
        };

      perSystem =
        { pkgs, ... }:
        let
          defaultPackages = with pkgs; [
            zsh
            curl
            git
            fd
            fzf
            file
            lua
            bat
            eza
          ];

          akironZshPackage = pkgs.stdenvNoCC.mkDerivation {
            pname = "akiron-zsh";
            version = "2026.08.09";
            src = self;

            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              runHook preInstall

              mkdir -p $out
              cp -R init.zsh zimrc modules $out/

              runHook postInstall
            '';
          };
        in
        {
          packages.default = akironZshPackage;

          devShells.default = pkgs.mkShell {
            packages = defaultPackages ++ [ pkgs.nix ];
          };

          checks.package-build = pkgs.runCommand "akiron-zsh-package-build-check" { } ''
            test -f ${akironZshPackage}/init.zsh
            test -f ${akironZshPackage}/zimrc
            test -d ${akironZshPackage}/modules/akiron-zsh
            touch $out
          '';
        };
    };
}
