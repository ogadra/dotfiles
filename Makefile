HOST := $(shell hostname)

.PHONY: build switch update

build:
	nixos-rebuild build --flake .#$(HOST)

switch:
	sudo nixos-rebuild switch --flake .#$(HOST)

update:
	nix flake update $(filter-out $@,$(MAKECMDGOALS))
