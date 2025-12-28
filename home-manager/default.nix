{
  profile,
  username,
  ...
}:
{
  home-manager = {
    useGlobalPkgs     = true;
    useUserPackages   = true;
    users.${username} = import ./profiles/${profile};
    extraSpecialArgs  = {
      inherit username;
    };
  };
}
