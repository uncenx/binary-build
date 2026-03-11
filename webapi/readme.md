# WebAPI

![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Bash](https://img.shields.io/badge/script-bash-blue.svg)

WebAPI installation and management scripts. This package provides an automated way to install, configure, and manage the WebAPI application along with its Nginx reverse proxy.

## 🚀 Quick Start (One-line Install)

You can install and configure the WebAPI directly from the repository using `curl`.

Customize the parameters as needed:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/webapi/install.sh | sudo -E bash -s -- \
    --app \
    --nginx \
    --domain api.uncenx.com \
    --port 8080 \
    --mongo-uri "mongodb+srv://user:pass@host/dbname" \
    --player-domain "https://ibucket.org"
```

## 🛠️ Manual Installation

If you have downloaded the scripts locally, first ensure the installation script is executable:

```bash
chmod +x install.sh
```

### Standard Install
Installs the Application and Nginx with default configurations:
```bash
sudo ./install.sh
```

### Custom Configuration
Specify custom settings during installation:
```bash
sudo ./install.sh --port 8080 --domain api.uncenx.com \
    --mongo-uri "mongodb+srv://user:pass@host/dbname" \
    --player-domain "https://ibucket.org"
```

### Component Selection
You can choose to install or update only specific components:

**1. Update only the Application (Binary + `.env`)**
```bash
sudo ./install.sh --app
```

**2. Update only Nginx configuration**
```bash
sudo ./install.sh --nginx --domain newdomain.com
```

## 🗑️ Uninstallation

To completely remove the application, service, and Nginx configurations:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/webapi/install.sh | sudo -E bash -s -- \
    --uninstall
```

## ⚙️ Service Management

After installation, the application runs as a `systemd` service named `webapi`. You can manage it using standard `systemctl` commands.

**Check Service Status:**
```bash
systemctl status webapi
```

**View Real-time Logs:**
```bash
journalctl -u webapi -f
```

**Start / Stop / Restart:**
```bash
sudo systemctl start webapi
sudo systemctl stop webapi
sudo systemctl restart webapi
```

**Enable / Disable on Boot:**
```bash
sudo systemctl enable webapi
sudo systemctl disable webapi
```
