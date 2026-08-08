{ config, pkgs, inputs, ... }:

{

services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video $sys$devpath/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w $sys$devpath/brightness"
  '';

# Enable experimental Flakes features natively so we don't need flags anymore
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader setup (Systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network configuration
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Set your time zone
  time.timeZone = "Europe/Brussels";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure keymap in X11 and console (Belgian Layout)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  console.keyMap = "us";

  # Enable the GNOME Desktop Environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable PipeWire for Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  # Hardware video acceleration (VA-API) for Intel CPUs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  # Define your user account
  users.users.ruki = {
    isNormalUser = true;
    description = "ruki";
    extraGroups = [ "networkmanager" "wheel" "video" ];
    packages = with pkgs; [];
  };

  # Your custom desktop pipeline packages
  environment.systemPackages = with pkgs; [
(pkgs.catppuccin-gtk.override {
  accents = [ "mauve" ];
  size = "standard";
  variant = "mocha";
})

    brightnessctl
    git
    neovim
    kitty
    niri
    wget
    curl
    brave
    ani-cli
    mpv
    libva-utils
    anki-bin
    noctalia-shell

    #your new terminal utilities
    fastfetch
    btop
    tty-clock
    cava
  ];

environment.shellAliases = {
  rbd = "cd ~/nixos-config && sudo nix-shell -p git --run \"nixos-rebuild switch --flake .#myMachine --option extra-experimental-features 'nix-command flakes'\"";
};  

  # Allow unfree packages natively
  nixpkgs.config.allowUnfree = true;

  # --- YOUR REQUESTED CUSTOMIZATIONS ---

  # 1. Spicetify with Adblocker Setup via inputs
  imports = [
    inputs.spicetify-nix.nixosModules.default
  ];

  programs.spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
    in
    {
      enable = true;
      theme = spicePkgs.themes.catppuccin;
      colorScheme = "mocha";
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        shuffle
      ];
    };

  # 2. Kitty Terminal Transparent Configuration Hint
  # (This installs kitty system-wide; we will drop the opacity config into ~/.config/kitty/kitty.conf next)
  
  # 3. Niri Window Manager Keybindings/Media Keys Layer
  # (Niri is installed in environment.systemPackages above; its media keys config will live in ~/.config/niri/config.kdl)

  # DO NOT CHANGE THIS NUMBER. It matches your exact installation target.
  system.stateVersion = "26.05";
  # Enable the Niri scrollable-tiling window manager
  programs.niri.enable = true;
  # Automatic Garbage Collection to save SSD space
# Automatically check for updates and update system packages daily
  system.autoUpgrade = {
    enable = true;
    dates = "daily";
    flake = "/home/ruki/nixos-config#myMachine";
    flags = [
      "--update-input" "nixpkgs" # Tells Nix to specifically check for newer app versions
      "--print-build-logs"
    ];
  };
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 14d";
};
}
