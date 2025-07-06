
## Two stage update

The configuration is split into two parts to allow for two stage updates to conserve space
on storage-limited systems.

To run a two stage update do:
```shell
  $ sudo NIX_LIGHTWEIGHT=1 nixos-rebbuild switch
  $ reboot
```
then:
```shell
  $ sudo nix-collect-garbage --delete-old
  $ sudo nixos-rebbuild switch
```


