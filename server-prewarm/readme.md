# Server Prewarm

![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Bash](https://img.shields.io/badge/script-bash-blue.svg)

Server Prewarm installation and management scripts. This package provides an automated way to install, configure, and manage the Server Prewarm application along with its Nginx reverse proxy.

## 🚀 Quick Start (One-line Install)

You can install and configure the Server Prewarm directly from the repository using `curl`.

Customize the parameters as needed:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-prewarm/install.sh | sudo -E bash -s -- \
    --app \
    --storage-id 3b5a7630-479f-4877-b907-489fe0ff75c5 \
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
sudo ./install.sh --port 8886 --domain v2.ibucket.org \
    --storage-id "your-storage-id" \
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
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-prewarm/install.sh | sudo -E bash -s -- \
    --uninstall
```

## ⚙️ Service Management

After installation, the application runs as a `systemd` service named `server-prewarm`. You can manage it using standard `systemctl` commands.

**Check Service Status:**
```bash
systemctl status server-prewarm
```

**View Real-time Logs:**
```bash
journalctl -u server-prewarm -f
```

**Start / Stop / Restart:**
```bash
sudo systemctl start server-prewarm
sudo systemctl stop server-prewarm
sudo systemctl restart server-prewarm
```

**Enable / Disable on Boot:**
```bash
sudo systemctl enable server-prewarm
sudo systemctl disable server-prewarm
```
