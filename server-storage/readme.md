# Server Storage

![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Bash](https://img.shields.io/badge/script-bash-blue.svg)

Server Storage installation and management scripts. This package provides an automated way to install, configure, and manage the Server Storage application.

## 🚀 Quick Start (One-line Install)

You can install and configure the Server Storage directly from the repository using `curl`.

Customize the parameters as needed:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-storage/install.sh | sudo -E bash -s -- \
    --app \
    --port 8083 \
    --mongodb-uri "mongodb+srv://user:pass@host/dbname" \
    --storage-id "your-storage-id" \
    --storage-path "/home/files"
```

## 🛠️ Manual Installation

If you have downloaded the scripts locally, first ensure the installation script is executable:

```bash
chmod +x install.sh
```

### Standard Install
Installs the Application with default configurations:
```bash
sudo ./install.sh
```

### Custom Configuration
Specify custom settings during installation:
```bash
sudo ./install.sh --port 8083 \
    --mongodb-uri "mongodb+srv://user:pass@host/dbname" \
    --storage-id "your-storage-id" \
    --storage-path "/home/files"
```

### Component Selection
You can choose to install or update only specific components:

**1. Update only the Application (Binary + `.env`)**
```bash
sudo ./install.sh --app
```

## 🗑️ Uninstallation

To completely remove the application, service:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-storage/install.sh | sudo -E bash -s -- --uninstall
```

## ⚙️ Service Management

After installation, the application runs as a `systemd` service named `server-storage`. You can manage it using standard `systemctl` commands.

**Check Service Status:**
```bash
systemctl status server-storage
```

**View Real-time Logs:**
```bash
journalctl -u server-storage -f
```

**Start / Stop / Restart:**
```bash
sudo systemctl start server-storage
sudo systemctl stop server-storage
sudo systemctl restart server-storage
```

**Enable / Disable on Boot:**
```bash
sudo systemctl enable server-storage
sudo systemctl disable server-storage
```
