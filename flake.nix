{
  description = "akir-zimfw zsh configuration flake";

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
          cfg = config.programs.azimfw;
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
          options.programs.azimfw = {
            enable = lib.mkEnableOption "akir-zimfw zsh configuration";

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
              defaultText = lib.literalExpression "inputs.azimfw.packages.\${pkgs.stdenv.hostPlatform.system}.default";
              description = "The akir-zimfw package to link into the Home Manager configuration directory.";
            };

            configDir = lib.mkOption {
              type = lib.types.str;
              default = ".config/azimfw";
              example = ".config/azimfw";
              description = "Path relative to the user's home directory where akir-zimfw is linked.";
            };

            extraPackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
              example = lib.literalExpression "with pkgs; [ lsd jq ]";
              description = "Additional optional packages for akir-zimfw integrations.";
            };

            grepExcludeFolders = lib.mkOption {
              type = lib.types.str;
              default = "{.bzr,CVS,.git,.hg,.svn,.idea,.tox}";
              example = "{.git,.hg,.svn,.idea,.tox,node_modules,target}";
              description = "Directories to exclude from grep searches (sets EXC_FOLDERS).";
            };

            zshCacheDir = lib.mkOption {
              type = lib.types.str;
              default = "$HOME/.cache/azim";
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
              description = "Whether to automatically enter the last working directory on shell start (sets AZIM_IN_LASTDIR).";
            };

            historyShow = lib.mkOption {
              type = lib.types.bool;
              default = true;
              example = false;
              description = "Whether to bind Ctrl+R to fzf-powered history search (sets AZIM_HISTORY_SHOW).";
            };

            promptStyle = lib.mkOption {
              type = lib.types.enum [
                "compact"
                "segments"
              ];
              default = "compact";
              example = "segments";
              description = "Prompt display style (sets AZIM_PROMPT_STYLE).";
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
              export AZIM_IN_LASTDIR="${if cfg.autoInLastDir then "true" else "false"}"
              export AZIM_HISTORY_SHOW="${if cfg.historyShow then "true" else "false"}"
              export AZIM_PROMPT_STYLE="${cfg.promptStyle}"
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

          azimfwPackage = pkgs.stdenvNoCC.mkDerivation {
            pname = "akir-zimfw";
            version = "2026.06.27";
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
          packages.default = azimfwPackage;

          devShells.default = pkgs.mkShell {
            packages = defaultPackages ++ [ pkgs.nix ];
          };

          checks.package-build = pkgs.runCommand "akir-zimfw-package-build-check" { } ''
            test -f ${azimfwPackage}/init.zsh
            test -f ${azimfwPackage}/zimrc
            test -d ${azimfwPackage}/modules/azim
            touch $out
          '';
        };
    };
}
