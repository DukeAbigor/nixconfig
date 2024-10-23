{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
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
  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      nix-path = config.nix.nixPath;
    };
    channel.enable = false;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  networking = {
    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "10.10.10.10";
            prefixLength = 24;
          }
        ];
      };
    };

    defaultGateway = {
      address = "10.10.10.1";
    };

    nameservers = [ "1.1.1.1" "1.0.0.1" ];
    hostName = "devVM";
    networkmanager.enable = true;
    useDHCP = false;
    enableIPv6 = false;
  };

  boot.loader.systemd-boot.enable = true;

  console = {
    keyMap = "us";
  };

  users.users = {
    eligos = {
      initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPDRt7oUaN0DUPxM493KIDp31OGPfZxCuTGNvJVymCGP android@mobile"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHJ676mgwe53bWey3qhP4TiKdc8b0fb/luQ6BqkjiRa1 crour@Argon"
      ];
      extraGroups = [ "wheel" ];
      sudoPasswordless = true;
      packages = with pkgs; [];
    };
  };

  security.sudo.wheelNeedsPassword = false;
  
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "24.05";
}
