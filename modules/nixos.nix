{
  config,
  inputs,
  pkgs,
  lib,
  ...
}:
{
  services = {
    desktopManager.plasma6.enable = true;
    btrfs.autoScrub.enable = true;
    thermald.enable = true;
    flatpak.enable = true;
    bpftune.enable = true;
    kmscon.enable = true;

    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    displayManager = {
      autoLogin.user = "victor";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
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

  environment = {
    variables.NIXOS_OZONE_WL = 1;

    systemPackages = with pkgs; [
      nvtopPackages.full
      docker-compose
      neovim
      sbctl
    ];

    plasma6.excludePackages = with pkgs.kdePackages; [
      plasma-browser-integration
      kwin-x11
      aurorae
      elisa
      krdp
    ];

    persistence."/data" = {
      files = [ "/etc/machine-id" ];
      hideMounts = true;

      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/timers"
        "/var/lib/nixos"
        "/var/lib/sbctl"
        "/var/cache"
        "/etc/nixos"
        "/etc/ssh"
        "/var/log"
      ];
    };
  };

  networking.networkmanager.enable = true;
  zramSwap.enable = true;

  users = {
    mutableUsers = false;
    users.victor = {
      description = "victor";
      isNormalUser = true;
      extraGroups = [
        "libvirtd"
        "docker"
        "wheel"
      ];
      password = "test";
    };
  };

  programs = {
    nix-index-database.comma.enable = true;
    partition-manager.enable = true;
    virt-manager.enable = true;
    gamescope.enable = true;
    gamemode.enable = true;
    nix-ld.enable = true;

    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };

    nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 7d --keep 3";
      };
    };
  };

  virtualisation = {
    docker.enable = true;

    libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };
  };

  boot = {
    loader = {
      timeout = 0;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    kernel.sysctl = {
      "vm.swappiness" = 10;
      "vm.max_map_count" = 2147483642;
    };

    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
    ];

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

    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  disko.devices.disk.main = {
    device = "/dev/diskoTarget";
    imageSize = "24G";
    content = {
      type = "gpt";
      partitions = {
        esp = {
          size = "5120M";
          type = "EF00";
          content = {
            format = "vfat";
            type = "filesystem";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        system.content = {
          type = "luks";
          name = "system";
          settings.allowDiscards = true;
          content = {
            type = "btrfs";
            subvolumes = {
              "root" = {
                mountOptions = [ "noatime" ];
                mountpoint = "/";
              };
              "nix" = {
                mountOptions = [ "noatime" ];
                mountpoint = "/nix";
              };
              "data" = {
                mountOptions = [ "noatime" ];
                mountpoint = "/data";
              };
              "home" = {
                mountOptions = [ "noatime" ];
                mountpoint = "/home";
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/data".neededForBoot = true;

  fonts.packages = with pkgs; [
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    liberation_ttf
    vista-fonts
    noto-fonts
    corefonts
  ];

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

  imports = with inputs; [
    impermanence.nixosModules.impermanence
    home-manager.nixosModules.home-manager
    lanzaboote.nixosModules.lanzaboote
    nix-index.nixosModules.nix-index
    facter.nixosModules.facter
    disko.nixosModules.disko
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    overwriteBackup = true;
    backupFileExtension = "hmBackup";
    users.victor.imports = [ ./home.nix ];
    extraSpecialArgs = { inherit inputs; };
    sharedModules = [ { home.stateVersion = config.system.stateVersion; } ];
  };

  time.timeZone = "Europe/Helsinki";
  security.sudo.extraConfig = "Defaults lecture=never,timestamp_type=global,pwfeedback";
}
