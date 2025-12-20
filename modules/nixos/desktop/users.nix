{
  users = {
    mutableUsers = false;
    users.victor = {
      description = "victor";
      isNormalUser = true;
      extraGroups = [ "wheel", "libvirt" ];
      hashedPassword = "No";
    };
  };

  time.timeZone = "Europe/Helsinki";
  security.sudo.extraConfig = "Defaults lecture=never,timestamp_type=global,pwfeedback";
}
