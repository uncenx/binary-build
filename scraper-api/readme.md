# Scraper API

![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Bash](https://img.shields.io/badge/script-bash-blue.svg)

Scraper API installation and management scripts. This package provides an automated way to install, configure, and manage the Scraper API application along with its Nginx reverse proxy.

## 🚀 Quick Start (One-line Install)

You can install and configure the Scraper API directly from the repository using `curl`. 

Customize the `--domain` and `--port` parameters as needed:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/scraper-api/install.sh | sudo -E bash -s -- \
    --app \
    --nginx \
    --domain ibucket.org \
    --port 8084
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
Specify a custom port and domain during installation:
```bash
sudo ./install.sh --port 8081 --domain mydomain.com
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
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/scraper-api/install.sh | sudo -E bash -s -- \
    --uninstall
```

## ⚙️ Service Management

After installation, the application runs as a `systemd` service named `scraper-api`. You can manage it using standard `systemctl` commands.

**Check Service Status:**
```bash
systemctl status scraper-api
```

**View Real-time Logs:**
```bash
journalctl -u scraper-api -f
```

**Start / Stop / Restart:**
```bash
sudo systemctl start scraper-api
sudo systemctl stop scraper-api
sudo systemctl restart scraper-api
```

**Enable / Disable on Boot:**
```bash
sudo systemctl enable scraper-api
sudo systemctl disable scraper-api
```
