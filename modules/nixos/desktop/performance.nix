{
  zramSwap.enable = true;

  services = {
    scx = {
      enable = true;
      scheduler = "scx_lavd";
    };

    bpftune.enable = true;
    thermald.enable = true;
  };
}
