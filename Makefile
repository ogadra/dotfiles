HOST := $(shell hostname)

.PHONY: build switch

build:
	nixos-rebuild build --flake .#$(HOST)

switch:
	sudo nixos-rebuild switch --flake .#$(HOST)
