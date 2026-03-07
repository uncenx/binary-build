# Server Content

![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Bash](https://img.shields.io/badge/script-bash-blue.svg)

Server Content installation and management scripts. This package provides an automated way to install, configure, and manage the Server Content application along with its Nginx reverse proxy.

## 🚀 Quick Start (One-line Install)

You can install and configure the Server Content directly from the repository using `curl`.

Customize the parameters as needed:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-content/install.sh | sudo -E bash -s -- \
    --app \
    --nginx \
    --domain v.uncenxcdn.com \
    --port 8082 \
    --mongodb-uri "mongodb+srv://user:pass@host/dbname"
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
sudo ./install.sh --port 8082 --domain content.uncenxcdn.com \
    --mongodb-uri "mongodb+srv://user:pass@host/dbname"
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
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-content/install.sh | sudo -E bash -s -- \
    --uninstall
```

## ⚙️ Service Management

After installation, the application runs as a `systemd` service named `server-content`. You can manage it using standard `systemctl` commands.

**Check Service Status:**
```bash
systemctl status server-content
```

**View Real-time Logs:**
```bash
journalctl -u server-content -f
```

**Start / Stop / Restart:**
```bash
sudo systemctl start server-content
sudo systemctl stop server-content
sudo systemctl restart server-content
```

**Enable / Disable on Boot:**
```bash
sudo systemctl enable server-content
sudo systemctl disable server-content
```
