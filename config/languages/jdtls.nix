{
  lib,
  config,
  pkgs,
  ...
}:
{
  options = {
    jdtls.enable = lib.mkEnableOption "Enable jdtls module";
  };
  config = lib.mkIf config.jdtls.enable {
    plugins.jdtls = {
      enable = true;
      settings = {
        # The nixpkgs jdtls wrapper already picks a per-project workspace
        # (-data) under $XDG_CACHE_HOME, so no data dir is passed here.
        cmd = [ "${pkgs.jdt-language-server}/bin/jdtls" ];
        settings = {
          java = {
            signatureHelp = true;
            completion = true;
          };
        };
      };
    };
  };
}
