let 
  pkgs = import <nixpkgs> { };
  vpnConfiguration = import ./vpn-configuration.nix;
in {
  a = { ... }: {
    imports = [ 
      # Import the Wireguard configuration with its credentials (server/client)
      ./wireguard.nix {
        vpnClientConfiguration = vpnConfiguration.clients.a;
        vpnServerConfiguration = vpnConfiguration.server;
      } 
    ];

    environment.systemPackages = with pkgs; [ gotop ];
    deployment.targetHost = "10.0.0.3";
  };
}
