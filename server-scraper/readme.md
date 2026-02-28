# Server Scraper

![Platform](https://img.shields.io/badge/platform-linux-lightgrey.svg)
![Bash](https://img.shields.io/badge/script-bash-blue.svg)

Server Scraper installation and management scripts. This package provides an automated way to install, configure, and manage multiple worker instances of the Server Scraper application as systemd services.

## 🚀 Installation & Usage

You can install and configure the Server Scraper directly from the repository using `curl`.

### Basic Installation
Installs with the default configuration (1 worker instance):
```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-scraper/install.sh | sudo -E bash
```

### Custom Installation (Arguments)

You can pass arguments to the installer script to customize the number of workers and the database connection string.

**Options:**
- `-n, --count NUM`: Number of worker instances to configure and start (default: `1`).
- `-db, --database URL`: MongoDB connection string.
- `-h, --help`: Show help message.

**Examples:**

Install with 2 workers:
```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-scraper/install.sh | sudo -E bash -s -- -n 2
```

Install with 15 workers and a custom database string:
```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-scraper/install.sh | sudo -E bash -s -- -n 15 -db "mongodb+srv://user:pass@cluster.mongodb.net/dbname"
```

## ⚙️ Service Management

After installation, each worker runs as an independent `systemd` service named `server-scraper@<id>` (e.g., `server-scraper@1`, `server-scraper@2`). 

### View Status & Logs

**View running workers:**
```bash
systemctl list-units "server-scraper@*" --all
```

**View Real-time Logs:**
```bash
journalctl -u "server-scraper@*" -f          # All workers combined
journalctl -u "server-scraper@1" -f          # Worker 1 only
```

### Start / Stop / Restart

**Stop specific worker:**
```bash
sudo systemctl stop server-scraper@5
```

**Stop ALL workers:**
```bash
sudo systemctl stop "server-scraper@*"
```

**Restart ALL workers:**
*(Adjust the range `{1..5}` based on how many workers you have running)*
```bash
for i in {1..5}; do sudo systemctl restart server-scraper@$i; done
```

### Enable / Disable Workers

**Disable ALL workers from starting on boot:**
```bash
sudo systemctl disable "server-scraper@*"
```

**Disable & stop specific worker:**
```bash
sudo systemctl disable server-scraper@3
sudo systemctl stop server-scraper@3
```

**Add more workers (e.g., adding workers 6 to 10):**
```bash
for i in {6..10}; do sudo systemctl enable server-scraper@$i && sudo systemctl start server-scraper@$i; done
```

## 🔄 Updating Binary

To update the application binary to the latest version, just re-run the installation script with your desired configuration arguments and the service will update accordingly:
```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-scraper/install.sh | sudo -E bash -s -- -n 5
```

## 🗑️ Uninstallation

To completely remove all workers, the application directory, and the systemd service template:

```bash
curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-scraper/install.sh | sudo -E bash -s -- --uninstall
```
