{
  environment.persistence."/data" = {
    files = [
      "/etc/machine-id"
    ];

    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/var/lib/nixos"
      "/var/lib/sbctl"
      "/etc/wireguard"
      "/var/cache"
      "/etc/nixos"
      "/etc/ssh"
      "/var/log"
    ];
  };
}
