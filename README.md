# wsl-arch

Currently, installing Arch Linux in WSL2 just gives you a barebones environment and then drops you into it as root.

This script does the following for you:
- Sets up the locale
- Prompts you to set a root password
- Prompts you to set up a non-root user
- Adds the new non-root user to the `wheel` group
- Prompts you to set a password for the new non-root user
- Sets the new non-root user you created as the default user in `/etc/wsl.conf`
- Installs `sudo` package and sets up sudo access for the wheel group in `/etc/sudoers`
- Final step shuts down the virtual environment so that the changes to `/etc/wsl.conf` take effect when you reattach to it via `wsl -d archlinux`

## Instructions

```bash
git clone https://github.com/chriscorbell/wsl-arch
./wsl-arch/wsl-arch.sh
```
Or alternatively (don't forget to always read and verify the source before doing this):
```
curl https://raw.githubusercontent.com/chriscorbell/wsl-arch/main/wsl-arch.sh >> wsl-arch.sh && chmod +x wsl-arch.sh && ./wsl-arch.sh
```
