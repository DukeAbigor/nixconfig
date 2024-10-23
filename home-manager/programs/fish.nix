{
  inputs,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting
    '';

    plugins = [
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      { name = "z"; src = pkgs.fishPlugins.z.src; }
      { name = "wakatime-fish"; src = pkgs.fishPlugins.wakatime-fish; }
      { name = "transient-fish"; src = pkgs.fishplugin-transient-fish; }
      { name = "hydro"; src = pkgs.fishplugin-hydro-unstable; }
      { name = "sponge"; src = pkgs.fishplugin-sponge; }
      { name = "puffer"; src = pkgs.fishplugin-puffer; }
      { name = "plugin-sudope"; src = fishplugin-plugin-sudope; }
      { name = "plugin-git"; src = fishplugin-plugin-git; }
      { name = "pisces"; src = fishplugin-pisces; }
      { name = "fzf.fish"; src = fishplugin-fzf.fish; }
    ];

    interactiveShellInit = ''
      begin
        set -l prev (string join0 $fish_complete_path | string match --regex "^.*?(?=\x00[^\x00]*generated_completions.*)" | string split0 | string match -er ".")
        set -l post (string join0 $fish_complete_path | string match --regex "[^\x00]*generated_completions.*" | string split0 | string match -er ".")
        set fish_complete_path $prev "/etc/fish/generated_completions" $post
      end
      if not test -d $__fish_user_data_dir/generated_completions
        ${pkgs.coreutils}/bin/mkdir $__fish_user_data_dir/generated_completions
      end
    '';

    functions = {
      haskell = ``
        function haskellEnv
          nix-shell -p "haskellPackages.ghcWithPackages (pkgs: with pkgs; [ $argv ])"
        end
      ``;

      python = ''
        function pythonEnv --description 'start a nix-shell with the given python packages' --argument pythonVersion
          if set -q argv[2]
            set argv $argv[2..-1]
          end

          for el in $argv
            set ppkgs $ppkgs "python"$pythonVersion"Packages.$el"
          end

          nix-shell -p $ppkgs
        end
      ``;

    };
  };
}