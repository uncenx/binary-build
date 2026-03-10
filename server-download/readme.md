# Server Download

![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Bash](https://img.shields.io/badge/script-bash-blue.svg)

Server Download installation and management scripts. This package provides an automated way to install, configure, and manage multiple worker instances of the Server Download application as systemd services.

## 🚀 Installation & Usage

You can install and configure the Server Download directly from the repository using `curl`.

### Basic Installation
Installs with the default configuration (1 worker instance):
```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-download/install.sh | sudo -E bash
```

### Custom Installation (Arguments)

You can pass arguments to the installer script to customize the configuration.

**Options:**
- `--app`: Install the application component.
- `-n, --count NUM`: Number of worker instances to configure and start (default: `1`).
- `--mongodb-uri URI`: MongoDB connection string.
- `--storage-id ID`: Storage ID for the download server.
- `--storage-path DIR`: Storage path (default: `/home/files`).
- `--uninstall`: Uninstall Server Download completely.
- `-h, --help`: Show help message.

**Examples:**

Install with 2 workers:
```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-download/install.sh | sudo -E bash -s -- -n 2
```

Install with custom storage and database:
```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-download/install.sh | sudo -E bash -s -- \
    --app \
    -n 5 \
    --storage-path /home/files \
    --storage-id "your-storage-id" \
    --mongodb-uri "mongodb+srv://user:pass@cluster.mongodb.net/dbname"
```

## ⚙️ Service Management

After installation, each worker runs as an independent `systemd` service named `server-download@<id>` (e.g., `server-download@1`, `server-download@2`). 

### View Status & Logs

**View running workers:**
```bash
systemctl list-units "server-download@*" --all
```

**View Real-time Logs:**
```bash
journalctl -u "server-download@*" -f          # All workers combined
journalctl -u "server-download@1" -f          # Worker 1 only
```

### Start / Stop / Restart

**Stop specific worker:**
```bash
sudo systemctl stop server-download@5
```

**Stop ALL workers:**
```bash
sudo systemctl stop "server-download@*"
```

**Restart ALL workers:**
*(Adjust the range `{1..5}` based on how many workers you have running)*
```bash
for i in {1..5}; do sudo systemctl restart server-download@$i; done
```

### Enable / Disable Workers

**Disable ALL workers from starting on boot:**
```bash
sudo systemctl disable "server-download@*"
```

**Disable & stop specific worker:**
```bash
sudo systemctl disable server-download@3
sudo systemctl stop server-download@3
```

**Add more workers (e.g., adding workers 6 to 10):**
```bash
for i in {6..10}; do sudo systemctl enable server-download@$i && sudo systemctl start server-download@$i; done
```

## 🔄 Updating Binary

To update the application binary to the latest version, just re-run the installation script with your desired configuration arguments and the service will update accordingly:
```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-download/install.sh | sudo -E bash -s -- -n 5
```

## 🗑️ Uninstallation

To completely remove all workers, the application directory, and the systemd service template:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-download/install.sh | sudo -E bash -s -- --uninstall
```

To cleanup all files:
```bash
cd /opt/server-download && ./server-download --cleanup
```