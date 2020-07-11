## Systems

These subfolders contain system-specific definitions. To use one of them,
simply import it like below, using a correct, existing path:

```nix
{ ... }:

{
  imports = [
    /home/user/Path/To/nixos-configuration/systems/foo/bar.nix
  ];
}
```
