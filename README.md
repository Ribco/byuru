 byuru

[![Version](https://img.shields.io/badge/version-1.2.0-00d4aa)](https://github.com/Ribco/byuru)
[![License](https://img.shields.io/badge/license-MIT-00d4aa)](LICENSE)
[![npm](https://img.shields.io/npm/v/byuru-server?color=00d4aa)](https://www.npmjs.com/package/byuru-server)

> A lightweight HTTP server and reverse proxy, inspired by nginx. Built for everyone, everywhere.

[![byuru](https://i.imgur.com/GpZtUxx.png)](https://byuru.qd.je)

## Features

- ⚡ **Static file serving** with MIME types, autoindex, ETag caching
- 🔒 **Reverse proxy** with header forwarding
- ⚖️ **Load balancing** (round-robin, least connections, IP hash)
- 🛡️ **Rate limiting**
- 📝 **nginx-style config parser**
- 🔄 **Graceful reload**
- 👷 **Multi-worker model**
- 📊 **Access and error logging**
- 📦 **Gzip compression ready**
- 🐍 **Python & Node.js** — Choose your runtime
- 📱 **Termux Ready** — Run from your Android phone
- 🚀 **Express Compatible** — Static + dynamic in one server
- 🌍 **Everywhere** — Linux, macOS, Windows, Termux, WSL

## Quick Start

One-line install:
    `curl -fsSL https://raw.githubusercontent.com/Ribco/byuru/main/install.sh | bash`
    
Or with npm:
`npm install -g byuru-server`

Start the server:

    byuructl start

Visit http://localhost:8080

## Installation

Linux/macOS:

    git clone https://github.com/Ribco/byuru.git
    cd byuru
    chmod +x bin/byuru bin/byuructl
    sudo cp bin/byuru bin/byuructl /usr/local/bin/

Termux:

    pkg install python git
    git clone https://github.com/Ribco/byuru.git
    cd byuru
    chmod +x bin/byuru bin/byuructl
    cp bin/byuru bin/byuructl $PREFIX/bin/
    byuructl start

## Usage

    byuructl start      # Start server
    byuructl stop       # Stop server
    byuructl reload     # Reload config
    byuructl restart    # Restart server
    byuructl status     # Show status
    byuructl test       # Test config
    byuructl logs       # Tail access logs
    byuructl logs error # Tail error logs
    byuructl config     # Show config
    byuructl edit       # Edit config
    byuructl log-web    # Shows your error logs using web browser
    byuructl start --tls   # Starts byuru With TLS - Using our byuru Limited Certificate.

## Configuration

Default config locations:
- Linux/macOS: /etc/byuru/byuru.conf
- Termux: $PREFIX/etc/byuru/byuru.conf

Example config:

    worker_processes auto;
    
    events {
        worker_connections 1024;
    }
    
    http {
        access_log /var/log/byuru/access.log;
        error_log /var/log/byuru/error.log;
        
        server {
            listen 8080;
            server_name localhost;
            root /var/www/html;
            index index.html;
            
            location / {
                try_files $uri $uri/ =404;
            }
            
            location /api/ {
                proxy_pass http://127.0.0.1:3000;
            }
        }
    }

## Environment Variables

- BYURU_BIN: Path to byuru binary
- BYURU_CONFIG: Path to config file
- BYURU_PIDFILE: Path to PID file
- BYURU_LOGDIR: Path to log directory
- BYURU_PORT: Default port (8080)
- BYURU_ROOT: Document root (/var/www/html)

## License

MIT License
