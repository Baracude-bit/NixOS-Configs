{ ... }:
{
  programs.ghostty = {
    enable = true;
    settings = {
      clipboard-read = "allow";
      clipboard-write = "allow";
      copy-on-select = false;
      window-subtitle = "working-directory";
      background-opacity = 0.95;
      theme = "TokyoNight";
      background = "#140E21";
      foreground = "#42C34C";
      selection-background = "#33467c";
      selection-foreground = "#c0caf5";
      cursor-color = "#FF0101";
      cursor-text = "#15161e";
      cursor-style = "block_hollow";
      font-size = 10;

      palette = [
        "0=#15161e"
        "1=#f7768e"
        "2=#9ece6a"
        "3=#e0af68"
        "4=#7aa2f7"
        "5=#bb9af7"
        "6=#7dcfff"
        "7=#a9b1d6"
        "8=#414868"
        "9=#f7768e"
        "10=#9ece6a"
        "11=#e0af68"
        "12=#7aa2f7"
        "13=#bb9af7"
        "14=#4242C3"
        "15=#c0caf5"
      ];
    };
  };
}
