{ config, inputs, pkgs, lib, ... }:

{
  imports = with inputs; [
    impermanence.nixosModules.impermanence
    home-manager.nixosModules.home-manager
    lanzaboote.nixosModules.lanzaboote
    nix-index.nixosModules.nix-index
    facter.nixosModules.facter
    disko.nixosModules.disko
  ];

  # ================================================================
  # BOOT & KERNEL
  # ================================================================
  boot = {
    # Use latest Linux kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Kernel parameters for AMD virtualization and IOMMU
    kernelParams = [ "amd_iommu=on" "iommu=pt" ];

    # Kernel tuning
    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.max_map_count" = 2147483642; # Required for some games (e.g. Star Citizen)
    };

    # Emulate ARM architecture (useful for building ARM docker images on x86)
    binfmt.emulatedSystems = [ "aarch64-linux" ];

    loader = {
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };

    # Secure Boot support
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    # --- EPHEMERAL ROOT SETUP ---
    # This script runs in the initial ramdisk after resume.
    # It mounts the Btrfs volume, deletes the 'root' subvolume, and recreates it.
    # This ensures every boot starts with a pristine '/' directory ("Erase Your Darlings").
    initrd.postResumeCommands = lib.mkAfter ''
      delete_subvolume() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume "/temp/$i"
        done
        btrfs subvolume delete "$1"
      }
      mkdir /temp
      mount /dev/disk/by-partlabel/disk-main-system /temp
      [[ -e /temp/root ]] && delete_subvolume "/temp/root"
      btrfs subvolume create /temp/root
      umount /temp
    '';
  };

  # ================================================================
  # STORAGE & FILESYSTEMS (Disko)
  # ================================================================
  disko.devices.disk.main = {
    device = "/dev/diskoTarget";
    imageSize = "24G";
    content = {
      type = "gpt";
      partitions = {
        # EFI System Partition
        esp = {
          size = "5120M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        # Main Encrypted Partition
        system = {
          content = {
            type = "luks";
            name = "system";
            settings.allowDiscards = true; # Allow TRIM on encrypted drive
            content = {
              type = "btrfs";
              # Btrfs Subvolumes
              subvolumes = {
                "root" = { mountpoint = "/"; mountOptions = [ "noatime" ]; };
                "nix"  = { mountpoint = "/nix"; mountOptions = [ "noatime" ]; };
                "data" = { mountpoint = "/data"; mountOptions = [ "noatime" ]; };
                "home" = { mountpoint = "/home"; mountOptions = [ "noatime" ]; };
              };
            };
          };
        };
      };
    };
  };

  # Ensure /data is available before persistence tries to bind mount files
  fileSystems."/data".neededForBoot = true;

  # --- IMPERMANENCE (PERSISTENCE) ---
  # Since root is wiped on boot, we explicitly define what is kept in /data
  environment.persistence."/data" = {
    hideMounts = true;
    files = [ "/etc/machine-id" ];
    directories = [
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
      "/etc/ssh"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/var/lib/nixos"
      "/var/lib/sbctl"
      "/var/cache"
      "/var/log"
    ];
  };

  # ================================================================
  # HARDWARE & SERVICES
  # ================================================================
  networking.networkmanager.enable = true;
  hardware.enableRedistributableFirmware = true;
  zramSwap.enable = true;
  time.timeZone = "Europe/Helsinki";

  services = {
    # System maintenance
    btrfs.autoScrub.enable = true;
    thermald.enable = true;
    bpftune.enable = true;

    # Custom Scheduler (SCX)
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    # Audio (PipeWire)
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;

      # --- AUDIO PROCESSING CHAIN ---
      # This creates a virtual node for Real-time Noise Suppression (RNNoise)
      # It filters microphone input to remove background noise.
      extraConfig.pipewire."99-input-denoising"."context.modules" = [
        {
          "name" = "libpipewire-module-filter-chain";
          "args" = {
            "node.description" = "Noise Canceling Source";
            "media.name" = "Noise Canceling Source";
            "filter.graph" = {
              "nodes" = [
                {
                  "type" = "ladspa";
                  "name" = "rnnoise";
                  "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  "label" = "noise_suppressor_mono";
                  "control" = {
                    "VAD Threshold (%)" = 75.0;
                    "VAD Grace Period (ms)" = 200;
                    "Retroactive VAD Grace (ms)" = 0;
                  };
                }
              ];
            };
            "capture.props" = {
              "node.name" = "capture.rnnoise_source";
              "node.passive" = true;
              "audio.rate" = 48000;
            };
            "playback.props" = {
              "node.name" = "rnnoise_source";
              "media.class" = "Audio/Source";
              "audio.rate" = 48000;
            };
          };
        }
      ];
    };
  };

  # ================================================================
  # DESKTOP & GRAPHICS
  # ================================================================
  services.desktopManager.plasma6.enable = true;
  services.displayManager = {
    autoLogin.user = "victor";
    sddm = {
      enable = true;
      wayland.enable = true;
    };
  };
  # Alternative console renderer
  services.kmscon.enable = true;

  # Remove default KDE packages we don't want
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    kwin-x11
    aurorae
    elisa
    krdp
  ];

  environment.variables.NIXOS_OZONE_WL = 1; # Hint electron apps to use Wayland

  fonts.packages = with pkgs; [
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    liberation_ttf
    vista-fonts
    noto-fonts
    corefonts
  ];

  # ================================================================
  # PROGRAMS & GAMING
  # ================================================================
  services.flatpak.enable = true;

  programs = {
    nix-index-database.comma.enable = true; # Run uninstalled binaries like , cowsay
    partition-manager.enable = true;
    nix-ld.enable = true; # Run unpatched dynamic binaries

    # Gaming Setup
    gamescope.enable = true;
    gamemode.enable = true;
    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    # Nix Helper (Clean up garbage automatically)
    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
      };
    };
  };

  # ================================================================
  # VIRTUALIZATION
  # ================================================================
  virtualisation = {
    docker.enable = true;
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu = {
        swtpm.enable = true; # TPM emulation
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };
  };

  # ================================================================
  # USERS & SECURITY
  # ================================================================
  users = {
    mutableUsers = false;
    users.victor = {
      description = "victor";
      isNormalUser = true;
      extraGroups = [ "libvirtd" "docker" "wheel" ];
      password = "test"; # WARNING: Change this to a hashed password or use file provision
    };
  };

  security.sudo.extraConfig = "Defaults lecture=never,timestamp_type=global,pwfeedback";

  # ================================================================
  # NIX CONFIGURATION
  # ================================================================
  nix = {
    channel.enable = false;
    optimise.automatic = true;
    settings.experimental-features = "nix-command flakes";
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (final: _: {
        unstable = import inputs.nixpkgs-unstable {
          inherit (final.stdenv.hostPlatform) system;
          inherit (final) overlays config;
        };
      })
    ];
  };

  # Home Manager Setup
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    overwriteBackup = true;
    backupFileExtension = "hmBackup";
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [ { home.stateVersion = config.system.stateVersion; } ];
    users.victor.imports = [ ./home.nix ];
  };
}
