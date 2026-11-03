{ ... }:
let
  # Open WebUI listens here on every interface, for phones and other PCs on the LAN
  webuiPort = 8793;
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
}
