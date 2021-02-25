# nixos-raspberry-pi-cluster
A user-guide to create a Raspberry Pi (3B+, 4) cluster under NixOS managed by NixOps

## Installation
### Booting the Raspberry Pis
#### 4

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

3. The image created will be compressed with the zst format, to decompress it use:
  ```bash
  nix-shell -p zstd --run "unzstd nixos-sd-image-20.09pre242769.61525137fd1-aarch64-linux.img.zst
  ```

4. You can now flash the image to your SD card!
  Example with `dd`:
  ```bash
  dd bs=4M if=nixos-sd-image-21.03pre262561.581232454fd-aarch64-linux.img of=/dev/mmcblk0 conv=fsync
  ```
  
You might find useful information on [this wiki post](https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_3).

### First viable configuration
#### 4

#### 3B+
After successfully booting your RPI3B+, you have to pull the default configuration file in `/etc/nixos/configuration.nix`
```bash
curl https://raw.githubusercontent.com/hugolgst/nixos-raspberry-pi-cluster/master/rpi3B%2B/default-configuration.nix > /etc/nixos/configuration.nix
```

Then tweak the configuration file as you want and rebuild/reboot the system
```bash
nixos-rebuild switch
reboot
```
