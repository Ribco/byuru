import os
import urllib.request

BASE = "https://raw.githubusercontent.com/Ribco/byuru/main"

files = {
    "bin/byuru": f"{BASE}/bin/byuru",
    "bin/byuructl": f"{BASE}/bin/byuructl",
    "install.sh": f"{BASE}/install.sh",
    "README.md": f"{BASE}/README.md",
    "LICENSE": f"{BASE}/LICENSE",
    ".gitignore": f"{BASE}/.gitignore",
    "examples/basic.conf": f"{BASE}/examples/basic.conf",
    "examples/reverse-proxy.conf": f"{BASE}/examples/reverse-proxy.conf",
    "examples/virtual-hosts.conf": f"{BASE}/examples/virtual-hosts.conf",
    "systemd/byuru.service": f"{BASE}/systemd/byuru.service",
    "termux/byuru-service": f"{BASE}/termux/byuru-service",
}

for path, url in files.items():
    print(f"Downloading {path}...")
    try:
        urllib.request.urlretrieve(url, path)
        print(f"  OK")
    except Exception as e:
        print(f"  FAILED: {e}")

# Make executables
os.chmod("bin/byuru", 0o755)
os.chmod("bin/byuructl", 0o755)
os.chmod("install.sh", 0o755)
os.chmod("termux/byuru-service", 0o755)

print("\nDone! Run: git init && git add . && git commit -m 'v1.0.0'")

