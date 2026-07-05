#!/bin/bash
# byuru Installer
# Works on Linux, macOS, Termux, WSL, and other Unix-like systems
# Usage: curl -fsSL https://raw.githubusercontent.com/Ribco/byuru/main/install.sh | bash

set -e

REPO_URL="https://raw.githubusercontent.com/Ribco/byuru/main"
BYURU_VERSION="1.0.0"

log_info() { echo "[INFO] $1"; }
log_ok() { echo "[OK] $1"; }
log_error() { echo "[ERROR] $1"; }

print_banner() {
    echo "    ___.                                 "
    echo "    \_ |__    ___.__.  __ __  _______   __ __ "
    echo "     | __ \  <   |  | |  |  \ \_  __ \ |  |  \ "
    echo "     | \_\ \  \___  | |  |  /  |  | \/ |  |  / "
    echo "     |___  /  / ____| |____/   |__|    |____/  "
    echo "         \/   \/                              "
    echo "byuru v${BYURU_VERSION} Installer"
    echo ""
}

detect_platform() {
    if [[ -n "$TERMUX_VERSION" ]] || [[ "$PREFIX" == */com.termux* ]] || [[ -d "$PREFIX" && "$PREFIX" == */termux* ]]; then
        echo "termux"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

download_file() {
    local url="$1"
    local dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$url" -O "$dest"
    else
        log_error "Neither curl nor wget found"
        exit 1
    fi
}

main() {
    print_banner
    local platform=$(detect_platform)
    log_info "Detected platform: $platform"
    
    local install_dir
    if [[ "$platform" == "termux" ]]; then
        install_dir="$PREFIX/bin"
    elif [[ -w "/usr/local/bin" ]]; then
        install_dir="/usr/local/bin"
    else
        install_dir="$HOME/.local/bin"
        mkdir -p "$install_dir"
    fi
    
    log_info "Installing to: $install_dir"
    
    log_info "Downloading byuru..."
    download_file "${REPO_URL}/bin/byuru" "${install_dir}/byuru"
    chmod +x "${install_dir}/byuru"
    log_ok "byuru installed"
    
    log_info "Downloading byuructl..."
    download_file "${REPO_URL}/bin/byuructl" "${install_dir}/byuructl"
    chmod +x "${install_dir}/byuructl"
    log_ok "byuructl installed"
    
    for cmd in start stop restart reload status; do
        ln -sf "${install_dir}/byuructl" "${install_dir}/byuru-$cmd" 2>/dev/null || true
    done
    
    local config_dir
    if [[ "$platform" == "termux" ]]; then
        config_dir="$PREFIX/etc/byuru"
    else
        config_dir="/etc/byuru"
    fi
    if ! mkdir -p "$config_dir" 2>/dev/null; then
        config_dir="$HOME/.byuru/etc"
        mkdir -p "$config_dir"
    fi
    
    local log_dir
    if [[ "$platform" == "termux" ]]; then
        log_dir="$PREFIX/var/log/byuru"
    else
        log_dir="/var/log/byuru"
    fi
    if ! mkdir -p "$log_dir" 2>/dev/null; then
        log_dir="$HOME/.byuru/log"
        mkdir -p "$log_dir"
    fi
    
    local doc_root
    if [[ "$platform" == "termux" ]]; then
        doc_root="$HOME/.byuru/www"
    else
        doc_root="/var/www/html"
    fi
    mkdir -p "$doc_root"
    
    local config_file="${config_dir}/byuru.conf"
    if [[ ! -f "$config_file" ]]; then
        log_info "Creating default configuration..."
        cat > "$config_file" <<EOF
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    access_log ${log_dir}/access.log;
    error_log ${log_dir}/error.log;
    
    server {
        listen 8080;
        server_name localhost;
        root ${doc_root};
        index index.html;
        
        location / {
            try_files \$uri \$uri/ =404;
        }
    }
}
EOF
        log_ok "Config created at $config_file"
    fi
    
    if [[ ! -f "${doc_root}/index.html" ]]; then
        log_info "Creating landing page..."
        cat > "${doc_root}/index.html" <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>byuru - Welcome</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;background:linear-gradient(135deg,#1a1a2e 0%,#16213e 100%);color:#fff;min-height:100vh;display:flex;align-items:center;justify-content:center;text-align:center}
.container{padding:2rem}
h1{font-size:4rem;margin-bottom:1rem;letter-spacing:-2px}
h1 span{color:#00d4aa}
p{font-size:1.2rem;color:#8892b0;margin-bottom:2rem}
.badge{display:inline-block;background:rgba(0,212,170,0.1);border:1px solid #00d4aa;color:#00d4aa;padding:0.5rem 1rem;border-radius:20px;font-size:0.9rem;font-family:monospace}
.footer{position:fixed;bottom:2rem;left:0;right:0;color:#555;font-size:0.85rem}
</style>
</head>
<body>
<div class="container">
<h1>Welcome to<span>byuru!</span></h1>
<h1>by<span>uru</span></h1>
<p>Your lightweight HTTP server is running successfully! However, further configurations are still needed.</p>
<span class="badge">byuru/1.0.0</span>
</div>
<div class="footer">Powered by byuru · Built for everyone, everywhere</div>
</body>
</html>
EOF
    fi
    
    echo ""
    log_ok "Installation complete!"
    echo "  Binary: ${install_dir}/byuru"
    echo "  Control: ${install_dir}/byuructl"
    echo "  Config: ${config_file}"
    echo "  Root: ${doc_root}"
    echo ""
    echo "Quick start:"
    echo "  byuructl start"
    echo "  byuructl status"
    echo "  byuructl stop"
}

main "$@"
