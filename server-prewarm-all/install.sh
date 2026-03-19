#!/bin/bash

# Server Prewarm All Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

APP_NAME="server-prewarm-all"
INSTALL_APP=false
UNINSTALL=false

URL_BASE="https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-prewarm-all"

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

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        --app)
            INSTALL_APP=true
            shift
            ;;
        -h|--help)
            echo "Server Prewarm All Installer"
            echo ""
            echo "Usage: sudo ./install.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --app              Install/Update Application"
            echo "  --uninstall        Uninstall Server Prewarm All completely"
            echo "  -h, --help         Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ==========================================
# Uninstallation
# ==========================================
if [ "$UNINSTALL" = true ]; then
    print_warning "⚠️  Starting Uninstallation of $APP_NAME..."

    # Stop and disable service
    print_status "Stopping and disabling $APP_NAME service..."
    systemctl stop $APP_NAME 2>/dev/null || true
    systemctl disable $APP_NAME 2>/dev/null || true

    # Remove systemd service file
    if [ -f "/etc/systemd/system/$APP_NAME.service" ]; then
        print_status "Removing systemd service file..."
        rm "/etc/systemd/system/$APP_NAME.service"
        systemctl daemon-reload
    fi

    # Remove application directory
    if [ -d "/opt/$APP_NAME" ]; then
        print_status "Removing application directory..."
        rm -rf "/opt/$APP_NAME"
    fi

    print_status "✅ Uninstallation completed successfully!"
    exit 0
fi

# If --app not specified, default to install
if [ "$INSTALL_APP" = false ]; then
    INSTALL_APP=true
fi

# ==========================================
# Application Installation
# ==========================================
print_status "🚀 Installing $APP_NAME..."

APP_DIR="/opt/$APP_NAME"
SERVICE_USER="root"

# Stop service if running
print_status "Stopping existing service..."
systemctl stop $APP_NAME 2>/dev/null || true

# Create directory structure
print_status "Creating directory structure..."
mkdir -p "$APP_DIR"

# Determine architecture
ARCH=$(uname -m)
if [ "$ARCH" = "x86_64" ]; then
    BINARY="server-prewarm-all-linux"
elif [ "$ARCH" = "aarch64" ]; then
    BINARY="server-prewarm-all-linux-arm64"
else
    print_error "Unsupported architecture: $ARCH"
    exit 1
fi

# Download binary
print_status "Downloading binary ($BINARY)..."
curl -fsSL "$URL_BASE/$BINARY" -o "$APP_DIR/$APP_NAME"
chmod +x "$APP_DIR/$APP_NAME"

# Create systemd service
print_status "Creating systemd service..."
cat > /etc/systemd/system/$APP_NAME.service << EOF
[Unit]
Description=Server Prewarm All
After=network.target

[Service]
Type=simple
User=$SERVICE_USER
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/$APP_NAME
Restart=always
RestartSec=5
Environment=PATH=/usr/bin:/bin

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
print_status "Configuring systemd..."
systemctl daemon-reload
systemctl enable $APP_NAME

# Start service
print_status "Starting service..."
systemctl start $APP_NAME

# Verify service
sleep 2
if systemctl is-active --quiet $APP_NAME; then
    print_status "✅ Application installed and running!"
else
    print_error "❌ Application failed to start. Check logs: journalctl -u $APP_NAME -e"
    exit 1
fi

print_status "🎉 Installation completed successfully!"
