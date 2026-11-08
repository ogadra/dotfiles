{ pkgs, ... }:
let
  # Open WebUI listens here on every interface, for phones and other PCs on the LAN
  webuiPort = 8793;

  # Loopback only: codex on this PC is the one client
  codexGatewayPort = 8794;
in
{
  # A phone-friendly chat UI for Strata, because Strata's own UI refuses host controls from any origin but localhost
  # The upstream image instead of services.open-webui: nixpkgs' package is unfree, so it is never cached, and posthog in it is broken with mcp >= 2
  virtualisation.oci-containers = {
    backend = "docker";
    containers.open-webui = {
      # v0.13.0 was released less than 3 days ago; the digest pins the multi-arch index of v0.12.5
      image = "ghcr.io/open-webui/open-webui:v0.12.5@sha256:03443b8de6b617da9d900edd09b4bf1cb0ddbfdcba6afb42c548336a0b821ded";
      # Host networking so the container reaches Strata on the host's loopback, which a bridge network cannot
      extraOptions = [ "--network=host" ];
      volumes = [ "open-webui:/app/backend/data" ];
      environment = {
        PORT = toString webuiPort;
        ANONYMIZED_TELEMETRY = "False";
        DO_NOT_TRACK = "True";
        SCARF_NO_ANALYTICS = "True";
        # The strata user unit in home-manager/common/cli/strata serves here on loopback only
        OPENAI_API_BASE_URL = "http://127.0.0.1:8792/v1";
        ENABLE_OLLAMA_API = "False";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ webuiPort ];

  # Lists Strata among codex's OpenAI models, so /model switches to it within a thread
  systemd.services.strata-codex-gateway = {
    description = "Route codex's strata model to Strata and the rest to OpenAI";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    environment = {
      GATEWAY_PORT = toString codexGatewayPort;
      # The strata user unit in home-manager/common/cli/strata serves here on loopback only
      STRATA_URL = "http://127.0.0.1:8792/v1";
      # The model name strata serve reports
      STRATA_MODEL = "strata";
      # Tokens; the --context that strata-serve in home-manager/common/cli/strata installs with
      STRATA_CONTEXT_TOKENS = "65536";
    };
    serviceConfig = {
      ExecStart = "${
        pkgs.python3.withPackages (p: [ p.aiohttp ])
      }/bin/python3 ${./strata/codex_gateway.py}";
      DynamicUser = true;
      # Every codex request passes through here, so a crash must not leave codex without OpenAI
      Restart = "always";
      RestartSec = 1;
    };
  };

  # The system layer, so only this PC's codex goes through the gateway; the path suffix keeps codex's ChatGPT routes
  environment.etc."codex/config.toml".text = ''
    openai_base_url = "http://127.0.0.1:${toString codexGatewayPort}/backend-api/codex"
  '';
}
