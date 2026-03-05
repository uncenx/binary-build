#!/bin/bash

# Server Storage Installation Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default values
HTTP_PORT="8888"
MONGODB_URI=""
STORAGE_ID=""
STORAGE_PATH="/home/files"
INSTALL_APP=false
UNINSTALL=false

URL_BASE="https://raw.githubusercontent.com/uncenx/binary-build/refs/heads/master/server-storage"

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
        -p|--port)
            HTTP_PORT="$2"
            shift 2
            ;;
        --mongodb-uri)
            MONGODB_URI="$2"
            shift 2
            ;;
        --storage-id)
            STORAGE_ID="$2"
            shift 2
            ;;
        --storage-path)
            STORAGE_PATH="$2"
            shift 2
            ;;
        -h|--help)
            echo "Server Storage Installer"
            echo ""
            echo "Usage: sudo ./install.sh [OPTIONS]"
            echo ""
            echo "Components (if none specified, both are installed):"
            echo "  --app              Install/Update Application only"
            echo "  --uninstall        Uninstall Server Storage completely"
            echo ""
            echo "Configuration:"
            echo "  -p, --port PORT          HTTP port (default: 8888)"
            echo "  --mongodb-uri URI        MongoDB connection URI"
            echo "  --storage-id ID          Storage ID"
            echo "  --storage-path DIR       Storage path (default: /home/files)"
            echo "  -h, --help               Show this help message"
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
    print_warning "⚠️  Starting Uninstallation..."
    
    APP_NAME="server-storage"
    
    # Stop and disable service
    print_status "Stopping and disabling service..."
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

# If no specific component flag is set, install everything
if [ "$INSTALL_APP" = false ]; then
    INSTALL_APP=true
fi

print_status "🚀 Starting Installation..."
print_status "Components: App=$INSTALL_APP"
print_status "Configuration: Port=$HTTP_PORT"

# Update and install dependencies
print_status "Updating system packages..."
if command -v apt-get &> /dev/null; then
    apt-get update
    print_status "Installing dependencies (curl, jq)..."
    apt-get install -y curl jq
fi

# ==========================================
# Application Installation
# ==========================================
if [ "$INSTALL_APP" = true ]; then
    print_status "📦 Installing Application..."

    APP_NAME="server-storage"
    APP_DIR="/opt/$APP_NAME"
    SERVICE_USER="root"

    # Stop service if running
    print_status "Stopping existing service..."
    systemctl stop $APP_NAME 2>/dev/null || true

    # Create directory structure
    print_status "Creating directory structure..."
    mkdir -p "$APP_DIR"
    mkdir -p "$APP_DIR/uploads"

    # Determine architecture
    ARCH=$(uname -m)
    if [ "$ARCH" = "x86_64" ]; then
        BINARY="server-storage-linux"
    elif [ "$ARCH" = "aarch64" ]; then
        BINARY="server-storage-linux-arm64"
    else
        print_error "Unsupported architecture: $ARCH"
        exit 1
    fi

    # Download binary
    print_status "Downloading binary ($BINARY)..."
    curl -fsSL "$URL_BASE/$BINARY" -o "$APP_DIR/$APP_NAME"
    chmod +x "$APP_DIR/$APP_NAME"

    # Create .env file (only if not exists, to preserve existing config)
    if [ ! -f "$APP_DIR/.env" ]; then
        print_status "Creating configuration..."
        cat > "$APP_DIR/.env" << EOF
# Server Storage Configuration
MONGODB_URI=$MONGODB_URI
HTTP_PORT=$HTTP_PORT
STORAGE_ID=$STORAGE_ID
STORAGE_PATH=$STORAGE_PATH
EOF
        if [ -z "$MONGODB_URI" ] || [ -z "$STORAGE_ID" ]; then
            print_warning "⚠️  Please edit $APP_DIR/.env and set MONGODB_URI, STORAGE_ID"
        fi
    else
        print_status "Configuration file already exists, skipping..."
    fi

    # Create systemd service
    print_status "Creating systemd service..."
    cat > /etc/systemd/system/$APP_NAME.service << EOF
[Unit]
Description=Server Storage
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
fi

print_status "🎉 Installation completed successfully!"
