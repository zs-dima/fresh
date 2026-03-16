# core-flake + Nix + devenv + Podman

### Windows Terminal 1.25

`settings.json` (в Windows Terminal: Settings → Open JSON file)

```json
{
  "profiles": {
    "list": [
      {
        "guid": "{755159a3-6c97-5fe8-b7ec-1fe51b7eeee3}",
        "hidden": false,
        "name": "Ubuntu",
        "source": "Microsoft.WSL",
        "startingDirectory": "~"
      }
    ]
  }
}
```

### Ubuntu-24.04 & WSL2 & systemd

1) PowerShell **admin**:

```powershell
wsl --install --distribution Ubuntu-24.04
```

2) Ubuntu (WSL) systemd:

```bash
systemctl status
```

```bash
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true
EOF
```

```powershell
wsl --shutdown
```

```bash
systemctl status
```


### Nix (multi-user daemon) & flakes

systemd On > multi-user setup `--daemon`

1) Ubuntu-WSL:

```bash
sudo apt-get update
sudo apt-get install -y curl xz-utils ca-certificates git
```

2) Nix (daemon):

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

3) New shell:

```bash
nix --version
```

4) On flakes & `nix-command` in `/etc/nix/nix.conf`:

```bash
sudo tee -a /etc/nix/nix.conf >/dev/null <<'EOF'

experimental-features = nix-command flakes
EOF

sudo systemctl restart nix-daemon
```


### devenv via nix profile

```bash
nix profile add nixpkgs#devenv
devenv version
```

### Home Manager (standalone flake) & direnv + nix-direnv

1) Home Manager `release-25.11`:

```bash
nix run home-manager/release-25.11 -- init --switch
```

## Summary

```bash
git clone https://github.com/zs-dima/fresh.git ~/fresh
cd ~/fresh/nix
echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf && sudo systemctl restart nix-daemon
home-manager switch --flake . --impure
```

### WSL
```bash
sudo apt-get install -y curl xz-utils ca-certificates git

curl -L https://nixos.org/nix/install | sh -s -- --daemon

sudo tee -a /etc/nix/nix.conf >/dev/null <<'EOF'

experimental-features = nix-command flakes
EOF
sudo systemctl restart nix-daemon

nix profile add nixpkgs#devenv

nix run home-manager/release-25.11 -- init --switch

wsl --shutdown
```