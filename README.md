<img src="https://user-images.githubusercontent.com/15371828/109402799-1cf80a80-7959-11eb-8ba3-5b9b83c03dfd.jpg" align="right" width="225" />

# nixos-raspberry-pi-cluster
A user-guide to create a Raspberry Pi (3B+, 4) cluster under **NixOS** and managed by **NixOps**.

In this guide, the nodes are all connected to a VPN server using Wireguard.

## Table of contents
<ol>
  <li><a href="#installation"><strong>Installation</strong></a>
    <ol>
      <li><a href="#booting-the-raspberry-pis">Booting the Raspberry Pis</a></li>
      <li><a href="#first-viable-configuration">First viable configuration</a></li>
    </ol>
  </li>
  
  <li><a href="#nixops-deployment"><strong>NixOps deployment</strong></a>
    <ol>
      <li><a href="#install-nixops">Install NixOps</a></li>
      <li><a href="#create-the-deployment">Create the deployment</a></li>
      <li><a href="#deploy-the-configurations">Deploy the configurations</a></li>
    </ol>
  </li>
</ol>

## Installation
### Booting the Raspberry Pis
#### 4
For the Raspberry Pi 4, a Hydra job build a SD Image for it.
You can find the job [here](https://hydra.nixos.org/job/nixos/trunk-combined/nixos.sd_image_raspberrypi4.aarch64-linux/all?page=1), just pick the latest successful job and download the image.

#### 3B+
In order to boot NixOS on a Raspberry Pi 3B+ you'll have to build your own image.
Find its Nix expression at [`rpi3B+/sd-image.nix`](https://github.com/hugolgst/nixos-raspberry-pi-cluster/blob/master/rpi3B%2B/sd-image.nix)


First of all, if your main computer is *not* ARM-based, you have to emulate ARM on your system.
1. Add the following parameter to your NixOS configuration:
  ```nix
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  ```
  Then make sure to rebuild your system via `nixos-rebuild switch`


2. You can now build the image via this command (which might take a while depending on your computer)
  ```bash
  nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage --argstr system aarch64-linux -I nixos-config=sd-image.nix
  ```
  
You might find useful information on [this wiki post](https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3).

#### Uncompress the image and flash it
1. The image created will be compressed with the zst format, to decompress it use:
  ```bash
  nix-shell -p zstd --run "unzstd nixos-sd-image-20.09pre242769.61525137fd1-aarch64-linux.img.zst
  ```

2. You can now flash the image to your SD card!
  Example with `dd`:
  ```bash
  dd bs=4M if=nixos-sd-image-21.03pre262561.581232454fd-aarch64-linux.img of=/dev/mmcblk0 conv=fsync
  ```

#### Booting
Then, plug a keyboard and a screen via the HDMI/micro-HDMI ports.

To connect it to internet, either plug a Ethernet cable or connect to the wifi with:
```bash
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase 'SSID' 'password')
```

### First viable configuration
After booting on the Raspberry Pi, generate the configuration via:
```bash
nixos-generate-configuration
```

#### 4
Then, you can pull the default configuration
```bash
curl https://raw.githubusercontent.com/hugolgst/nixos-raspberry-pi-cluster/master/rpi4/default-configuration.nix > /etc/nixos/configuration.nix
```

#### 3B+
After successfully booting your RPI3B+, you have to pull the default configuration file in `/etc/nixos/configuration.nix`
```bash
curl https://raw.githubusercontent.com/hugolgst/nixos-raspberry-pi-cluster/master/rpi3B%2B/default-configuration.nix > /etc/nixos/configuration.nix
```

#### Rebuild
Then tweak the configuration file as you want and rebuild/reboot the system
```bash
nixos-rebuild switch
reboot
```

## NixOps deployment
To manage the Raspberry Pi cluster, we can use [NixOps](https://github.com/NixOS/nixops).

### Install NixOps
First of all make sure to have it installed on your system:
```bash
nix-env -iA nixos.nixops
```
or 
```bash
nix-shell -p nixops
```
or add it to your system packages in `/etc/nixos/configuration.nix`.

### Create the deployment
Create the deployment using this command
```bash
nixops create nixops/cluster.nix -d <your-deployment-name>
```

Then you can list all your deployments and check if yours is present with:
```bash
nixops list
```
*To have more information about the commands available and the tool in general, check [the manual](https://hydra.nixos.org/build/115931128/download/1/manual/manual.html).*

**Make sure to have your ssh public key in the root authorized keys!**
```nix
users.extraUsers.root.openssh.authorizedKeys.keys = [
  "ssh-rsa ... host"
];
```

### Deploy the configurations
You can tweak the configuration(s) in [`nixops/cluster.nix`](https://github.com/hugolgst/nixos-raspberry-pi-cluster/blob/master/nixops/cluster.nix) and the `nixops/` files as you want.

In order to deploy the configuration you can use the `deploy` tag.
```bash
nixops deploy -d <your-deployment-name>
```
