# In order to boot NixOS on a Raspberry Pi 3B+ you'll have to build this image.
#
# First of all, if your main computer is *not* ARM-based, you have to emulate ARM on your system.
# Add the following parameter to your NixOS configuration:
# `boot.binfmt.emulatedSystems = [ "aarch64-linux" ];`
# Then make sure to rebuild your system via `nixos-rebuild switch`
#
# You can now build the image via this command (which might take a while depending on your computer)
# `nix-build '<nixpkgs/nixos>' -A config.system.build.sdImage --argstr system aarch64-linux -I nixos-config=sd-image.nix`
#
# The image created will be compressed with the zst format, to decompress it use:
# `nix-shell -p zstd --run "unzstd nixos-sd-image-20.09pre242769.61525137fd1-aarch64-linux.img.zst`
#
# You can now flash the image to your SD card!
# Example with `dd`:
# `sudo dd bs=4M if=nixos-sd-image-21.03pre262561.581232454fd-aarch64-linux.img of=/dev/mmcblk0 conv=fsync`

{ lib, pkgs, config, ... }: {
  imports = [ <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix> ];

  # Since the latest kernel can't boot on RPI 3B+
  boot.kernelPackages = pkgs.linuxPackages_rpi3;

  # Authorized SSH keys to access the root user at boot
  users.extraUsers.root.openssh.authorizedKeys.keys =
    [ "ssh-rsa .... user@host" ];
}
