#!/bin/bash

# Server Scraper Deployment Script
# Usage: curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-scraper/install.sh | sudo -E bash -s -- [OPTIONS]
# Options:
#   -n, --count NUM    Number of worker instances (default: 1)
#   -h, --help         Show this help message

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
WORKER_COUNT=1
UNINSTALL=false

APP_NAME="server-scraper"
APP_DIR="/opt/server-scraper"
SERVICE_NAME="server-scraper"

# Environment Variables Configuration
ENV_DATABASE_URL="mongodb+srv://admin:[password]/dbname"
URL_BASE="https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-scraper"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        -n|--count)
            WORKER_COUNT="$2"
            shift 2
            ;;
        -db|--database)
            DATABASE_URL="$2"
            shift 2
            ;;
        -h|--help)
            echo "Server Scraper Installer"
            echo ""
            echo "Usage: curl -fsSL https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-scraper/install.sh | sudo -E bash -s -- [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --uninstall        Uninstall Server Scraper completely"
            echo "  -n, --count NUM    Number of worker instances (default: 1)"
            echo "  -db, --database    MongoDB connection string (default: $ENV_DATABASE_URL)"
            echo "  -h, --help         Show this help message"
            echo ""
            echo "Examples:"
            echo "  # Install with 1 worker (default)"
            echo "  curl -fsSL .../install.sh | sudo -E bash"
            echo ""
            echo "  # Install with 5 workers"
            echo "  curl -fsSL .../install.sh | sudo -E bash -s -- -n 5"
            echo ""
            echo "  # Uninstall entirely"
            echo "  curl -fsSL .../install.sh | sudo -E bash -s -- --uninstall"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# ==========================================
# Uninstallation
# ==========================================
if [ "$UNINSTALL" = true ]; then
    print_warning "⚠️  Starting Uninstallation..."
    
    # Stop and disable all worker services
    print_status "Stopping and disabling worker services..."
    systemctl stop "${APP_NAME}@*" 2>/dev/null || true
    systemctl disable "${APP_NAME}@*" 2>/dev/null || true
    systemctl stop $APP_NAME 2>/dev/null || true
    
    # Remove systemd service file
    if [ -f "/etc/systemd/system/${APP_NAME}@.service" ]; then
        print_status "Removing systemd service template file..."
        rm "/etc/systemd/system/${APP_NAME}@.service"
        systemctl daemon-reload
    fi
    
    # Remove application directory
    if [ -d "$APP_DIR" ]; then
        print_status "Removing application directory ($APP_DIR)..."
        rm -rf "$APP_DIR"
    fi
    
    print_status "✅ Uninstallation completed successfully!"
    exit 0
fi

# Functions
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    print_error "This script must be run as root"
    exit 1
fi

print_status "Installing with $WORKER_COUNT worker(s)..."

# Update and install dependencies
print_status "Updating system packages..."
if command -v apt-get &> /dev/null; then
    apt-get update
    print_status "Installing dependencies (curl, jq)..."
    apt-get install -y curl jq
fi

# Check if required commands exist
print_status "Checking required commands..."
for cmd in curl jq; do
    if ! command -v $cmd &> /dev/null; then
        print_error "$cmd is not installed. Please install it and try again."
        exit 1
    fi
done
print_status "All required commands are installed."

# Create application directory
print_status "Creating application directory: $APP_DIR"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Stop all existing services
print_status "Stopping existing services (if running)..."
systemctl stop ${SERVICE_NAME}@* 2>/dev/null || true
systemctl stop ${SERVICE_NAME} 2>/dev/null || true

# Determine architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    BINARY="server-scraper-linux"
elif [ "$ARCH" = "aarch64" ]; then
    BINARY="server-scraper-linux-arm64"
else
    print_error "Unsupported architecture: $ARCH"
    exit 1
fi

# Download application files
print_status "Downloading application files ($BINARY)..."
curl -fsSL "$URL_BASE/$BINARY" -o "$APP_DIR/$APP_NAME"
chmod +x "$APP_DIR/$APP_NAME"
print_status "Application files downloaded successfully."
print_status "Execution permissions set."

# Create .env file
print_status "Creating .env file..."
cat <<EOF > .env
MONGODB_URI=$ENV_DATABASE_URL
EOF
print_status ".env file created successfully."

# Create systemd service template (for multiple instances)
print_status "Creating systemd service template..."
cat <<EOF > /etc/systemd/system/${SERVICE_NAME}@.service
[Unit]
Description=Server Scraper Service - Worker %i
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/$APP_NAME
Restart=always
RestartSec=5
EnvironmentFile=$APP_DIR/.env
Environment="WORKER_ID=scraper-worker-%i"

[Install]
WantedBy=multi-user.target
EOF
print_status "Systemd service template created successfully."

# Reload systemd
print_status "Reloading systemd daemon..."
systemctl daemon-reload

# Enable and start workers
print_status "Starting $WORKER_COUNT worker(s)..."
for i in $(seq 1 $WORKER_COUNT); do
    systemctl enable ${SERVICE_NAME}@$i
    systemctl start ${SERVICE_NAME}@$i
    sleep 0.3 # Small delay to prevent CPU spike
done
print_status "All workers started successfully."

# Verify service status
print_status "Verifying services..."
RUNNING=0
for i in $(seq 1 $WORKER_COUNT); do
    if systemctl is-active --quiet ${SERVICE_NAME}@$i; then
        RUNNING=$((RUNNING + 1))
    fi
done

if [ $RUNNING -eq $WORKER_COUNT ]; then
    print_status "All $WORKER_COUNT workers are running!"
else
    print_warning "$RUNNING of $WORKER_COUNT workers are running. Checking logs..."
    journalctl -u "${SERVICE_NAME}@1" -n 10 --no-pager
fi

# Display service information
print_status "Service Information:"
cat <<EOF

Service: ${SERVICE_NAME}@{1..$WORKER_COUNT}
Running: $RUNNING of $WORKER_COUNT workers
Directory: $APP_DIR
Main File: $APP_DIR/$APP_NAME

Commands:
  View logs:     journalctl -u "${SERVICE_NAME}@*" -f
  View worker 1: journalctl -u "${SERVICE_NAME}@1" -f
  Stop all:      systemctl stop "${SERVICE_NAME}@*"
  Restart all:   for i in \$(seq 1 $WORKER_COUNT); do systemctl restart ${SERVICE_NAME}@\$i; done

EOF

print_status "Installation completed successfully!"