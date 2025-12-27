{ config, pkgs, ... }:
let
  sleepmute-bin = pkgs.fetchurl {
    url = "https://github.com/FinlayTheBerry/sleepmute/releases/download/v0.2.0/sleepmute_static";
    hash = "sha256-Y2zO6YO2PUE3bm/m6lV7hpJGBQadB3USV5YdJPCSu1E=";
    executable = true;
  };
in
{
  systemd.services.sleepmute-service = {
    description = "Runs sleepmute on sleep/hibernate.";
    wantedBy = [ 
      "sleep.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    before = [
      "sleep.target"
      "suspend.target"
      "hibernate.target"
      "hybrid-sleep.target"
      "suspend-then-hibernate.target"
    ];
    unitConfig = {
      StopWhenUnneeded = "yes";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${sleepmute-bin} pre";
      ExecStop = "${sleepmute-bin} post";
      User = "root";
    };
  };
}