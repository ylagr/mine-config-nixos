
cd /mnt
mkdir {b,boot,etc,home,var/log,nix,etc/nixos,persistent,root,snapshots,swap,var} -p

mount $2 /mnt/boot

mount $1 -o subvol=@etc /mnt/etc
mkdir /mnt/etc/nixos -p
mount $1 -o subvol=@home /mnt/home
mount $1 -o subvol=@var /mnt/var
mkdir /mnt/var/log -p
mount $1 -o subvol=@log /mnt/var/log
mount $1 -o subvol=@nix /mnt/nix
mount $1 -o subvol=@nixos /mnt/etc/nixos
mount $1 -o subvol=@persistent /mnt/persistent
mount $1 -o subvol=@root /mnt/root
mount $1 -o subvol=@snapshots /mnt/snapshots
mount $1 -o subvol=@swap /mnt/swap
