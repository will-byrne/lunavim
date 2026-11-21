{
  lib,
  config,
  ...
}:
{
  imports = [
    ./toggleterm.nix
  ];

  options = {
    terminal.enable = lib.mkEnableOption "Enable terminal module";
  };
  config = lib.mkIf config.terminal.enable {
    toggleterm.enable = lib.mkDefault true;
  };
}
