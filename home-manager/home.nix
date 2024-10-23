{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    # inputs.nix-colors.homeManagerModules.default
    # ./nvim.nix
    ./programs/fish.nix
  ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "eligos";
    homeDirectory = "/home/eligos";
  };

  programs.neovim.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
    plugins = [
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }

    ];
  };

  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git.enable = true;

  programs.bash = {
  interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
    fi
  '';
};

  systemd.user.startServices = "sd-switch";

  system.stateVersion = "24.05";
}
