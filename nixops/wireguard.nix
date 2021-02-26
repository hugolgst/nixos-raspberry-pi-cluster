{ vpnClientConfiguration, vpnServerConfiguration }:

{ ... }: {
  networking.firewall.allowedUDPPorts = [ vpnServerConfiguration.port ];

  # Enable Wireguard
  networking.wg-quick.interfaces.neutronvpn = {
    address = vpnClientConfiguration.addresses;
    privateKey = vpnClientConfiguration.privateKey;

    peers = [{
      publicKey = vpnServerConfiguration.publicKey;
      allowedIPs = vpnServerConfiguration.allowedIPs;
      endpoint = "${vpnServerConfiguration.ip}:${vpnServerConfiguration.port}";
      persistentKeepalive = 25;
    }];
  };
}
