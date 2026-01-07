HOST := $(shell hostname -s | tr '[:upper:]' '[:lower:]')
UNAME := $(shell uname)

.PHONY: build switch ensure-nix

ensure-nix:
	@command -v nix >/dev/null 2>&1 || { \
		echo "Nix not found. Installing..."; \
		curl -L https://nixos.org/nix/install | sh; \
		echo "Please restart your shell and run make again."; \
		exit 1; \
	}
	@command -v darwin-rebuild >/dev/null 2>&1 || { \
		echo "darwin-rebuild not found. Bootstrapping nix-darwin..."; \
		nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake .#$(HOST); \
	}

ifeq ($(UNAME), Darwin)
build: ensure-nix
	darwin-rebuild build --flake .#$(HOST)

switch: ensure-nix
	sudo darwin-rebuild switch --flake .#$(HOST)
else
build:
	nixos-rebuild build --flake .#$(HOST)

switch:
	sudo nixos-rebuild switch --flake .#$(HOST)
endif
