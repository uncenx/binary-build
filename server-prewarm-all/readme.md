# Server Prewarm All

![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Bash](https://img.shields.io/badge/script-bash-blue.svg)

Server Prewarm All installation and management scripts.

> **Note:** Configuration is embedded in the binary. No `.env` file is required.

## 🚀 Quick Start (One-line Install)

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-prewarm-all/install.sh | sudo -E bash -s -- --app
```

## 🗑️ Uninstallation

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-prewarm-all/install.sh | sudo -E bash -s -- --uninstall
```

## ⚙️ Service Management

```bash
systemctl status server-prewarm-all
journalctl -u server-prewarm-all -f

sudo systemctl start server-prewarm-all
sudo systemctl stop server-prewarm-all
sudo systemctl restart server-prewarm-all
```
