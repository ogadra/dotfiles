HOST := $(shell hostname -s | tr '[:upper:]' '[:lower:]')
UNAME := $(shell uname)
FLAKE_SUFFIX := $(if $(filter isucon,$(MAKECMDGOALS)),-isucon,)
FLAKE := .#$(HOST)$(FLAKE_SUFFIX)

.PHONY: ensure-nix build switch update clean

ensure-nix:
	@command -v nix >/dev/null 2>&1 || { \
		echo "Nix not found. Installing..."; \
		curl -L https://nixos.org/nix/install | sh; \
		echo "Restarting shell and running make..."; \
		exec fish -c "cd $(PWD) && make"; \
	}
	@command -v darwin-rebuild >/dev/null 2>&1 || { \
		echo "darwin-rebuild not found. Bootstrapping nix-darwin..."; \
		sudo nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake $(FLAKE); \
	}

ifeq ($(UNAME), Darwin)
build: ensure-nix
	darwin-rebuild build --flake $(FLAKE)
switch: ensure-nix
	sudo darwin-rebuild switch --flake $(FLAKE)
else
build:
	nixos-rebuild build --flake $(FLAKE)

switch:
	sudo nixos-rebuild switch --flake $(FLAKE)
endif

clean:
	bash scripts/clean.sh

update:
	nix flake update --access-tokens "github.com=$$(gh auth token)" $(filter-out $@,$(MAKECMDGOALS))

%:
	@:
