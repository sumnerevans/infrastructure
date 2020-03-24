{ pkgs, ... }: {
  services.matrix-synapse = {
    enable = true;
    enable_metrics = true;
    enable_registration = true;
    server_name = "sumnerevans.com";
  };
}
