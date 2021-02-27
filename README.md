# nixos-raspberry-pi-cluster
A user-guide to create a Raspberry Pi (3B+, 4) cluster under NixOS and managed by NixOps

## Summary
<ol>
  <li><a href="#installation"><strong>Installation</strong></a></li>
  <ol>
    <li><a href="#booting-the-raspberry-pis">Booting the Raspberry Pis</a></li>
    <li><a href="#first-viable-configuration">First viable configuration</a></li>
  </ol>
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
