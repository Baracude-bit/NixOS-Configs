{ inputs, ... }:
{
  imports = with inputs; [ flatpak.homeModules.default ];
}
