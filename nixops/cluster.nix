let
  pkgs = import <nixpkgs> { };
  vpnConfiguration = import ./vpn-configuration.nix;
in {
  network.description = "A Raspberry Pi (4, 3B+) cluster.";

  # Default configuration applicable to all machines
  defaults = {
    # Setup Gnome display manager
    services.xserver.enable = true;
    services.xserver.layout = "us";
    services.xserver.xkbVariant = "intl";
    services.xserver.desktopManager.gnome3.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.videoDrivers = [ "fbdev" ];

    # Enable captive-browser
    programs.captive-browser.enable = true;
    programs.captive-browser.interface = "wlan0";

    # Networking configuration
    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;
    networking.interfaces.wlan0.useDHCP = true;
    networking.networkmanager.enable = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [ wget vim git gotop ];

    users.users.hl = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    # Enable openssh and add the ssh key to the root user
    services.openssh.enable = true;
    users.extraUsers.root.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDE/WRAH45Vb65I5OkQaS/Oa/LZgJmI5VCE9TmkZov/svLPjNp7VFJJJXCx+IDIZeVeMG8yv8lNncrU9QLnouPr4lTy3AF1Ajjk7FXy+wfyjpwfn9STO3ToTWd1j1nVNtCHQrzA930u/yikygQaaE3Zp1QqVq1dC0Po6MTT+aQ15SL4PWG/pqaOR4SjPJZhSWoEUYecsvj/Xs1tBx8GR3uJyHeLZkZMUljRQo/yQdKWJnIy16syh1W5edTYcj9/RD1ZD/h+kFh5cmjWBtGeeT37TTCpNdZzJhQAd1IwigQKdIBb4BR/MTmRYyDLMDgXX3Uxhg/0IYADhuDZMkKQSxddxOC1AXbAUTOksXhJZ4C1izbZtdQiSkV8rvk9VDEgf8Qg2OMl6HHi825FEUW7ehhgnjbOwXr3p4SWLLxVSw702XjiTuc9gljEJfm0sXouwJ6tVmi0PKWN6qgnhATw9b9VqEaX3UrU22jhnxLWRNlLRYJggaBdaZJq9TiQxrXPJF8= hl@nixos"
    ];
  };

  a = { ... }:
    let
      wireguard = import ./wireguard.nix {
        vpnClientConfiguration = vpnConfiguration.clients.a;
        vpnServerConfiguration = vpnConfiguration.server;
      };
    in {
      imports = [ ./hardware/rpi4.nix ];

      nixpkgs.localSystem = {
        system = "aarch64-linux";
        config = "aarch64-unknown-linux-gnu";
      };
      deployment.targetHost = "10.0.0.3";
    } // wireguard;
}
