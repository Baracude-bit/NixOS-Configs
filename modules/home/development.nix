{ pkgs, ... }:
{
  programs = {
    gh.enable = true;
    git.enable = true;
  };

  home.packages = with pkgs; [
    # General
    blender

    # C/C++
    gcc
    gdb

    # Rust
    rustc

    # Python
    python315
  ];
}
