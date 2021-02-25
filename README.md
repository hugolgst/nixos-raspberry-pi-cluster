# nixos-raspberry-pi-cluster
A user-guide to create a Raspberry Pi (3B+, 4) cluster under NixOS managed by NixOps

## Installation
### Booting the Raspberry Pis
#### 4 (2Go, 4Go)

#### 3B+
In order to boot NixOS on a Raspberry Pi 3B+ you'll have to build your own image.

First of all, if your main computer is *not* ARM-based, you have to emulate ARM on your system.
1. Add the following parameter to your NixOS configuration:
  ```nix
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  ```
  Then make sure to rebuild your system via `nixos-rebuild switch`


2. You can now build the image via this command (which might take a while depending on your computer)
  ```nix
  nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage --argstr system aarch64-linux -I nixos-config=sd-image.nix
  ```

3. The image created will be compressed with the zst format, to decompress it use:
  ```bash
  nix-shell -p zstd --run "unzstd nixos-sd-image-20.09pre242769.61525137fd1-aarch64-linux.img.zst
  ```

4. You can now flash the image to your SD card!
  Example with `dd`:
  ```
  dd bs=4M if=nixos-sd-image-21.03pre262561.581232454fd-aarch64-linux.img of=/dev/mmcblk0 conv=fsync
  ```
