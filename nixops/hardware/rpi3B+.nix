{ pkgs, ... }: {
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Make sure not to use the latest kernel because it is not supported on NixOS RPI
  boot.kernelPackages = pkgs.linuxPackages_rpi3;

  # A bunch of boot parameters needed for optimal runtime on RPi 3b+
  boot.kernelParams = [ "cma=256M" ];
  boot.loader.raspberryPi.enable = true;
  boot.loader.raspberryPi.version = 3;
  boot.loader.raspberryPi.uboot.enable = true;
  boot.loader.raspberryPi.firmwareConfig = ''
    gpu_mem=256
  '';

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
      options = [ "nofail" ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  # Use 1GB of additional swap memory in order to not run out of memory
  # when installing lots of things while running other things at the same time.
  swapDevices = [{
    device = "/swapfile";
    size = 1024;
  }];
}
