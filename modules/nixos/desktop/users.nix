{
  users = {
    mutableUsers = false;
    users.victor = {
      description = "victor";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      password = "test";
    };
  };

  time.timeZone = "Europe/Helsinki";
  security.sudo.extraConfig = "Defaults lecture=never,timestamp_type=global,pwfeedback";
}
