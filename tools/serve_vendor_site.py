#!/usr/bin/env python3
"""
serve_vendor_site.py — serves the vendor_site/ directory over HTTP.

Usage:
    python3 tools/serve_vendor_site.py [PORT]

Default port: 8000
"""
import http.server
import os
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000

# Resolve the vendor_site directory relative to the repo root.
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.dirname(SCRIPT_DIR)
SERVE_DIR = os.path.join(REPO_ROOT, "vendor_site")

if not os.path.isdir(SERVE_DIR):
    print(f"ERROR: vendor_site/ directory not found at {SERVE_DIR}", file=sys.stderr)
    sys.exit(1)

os.chdir(SERVE_DIR)

Handler = http.server.SimpleHTTPRequestHandler
Handler.extensions_map = {
    ".html": "text/html",
    ".css": "text/css",
    ".js": "application/javascript",
    ".png": "image/png",
    ".jpg": "image/jpeg",
    "": "application/octet-stream",
}

print(f"Serving {SERVE_DIR}")
print(f"URL:     http://127.0.0.1:{PORT}/vendorx_install.html")
print("Press Ctrl-C to stop.")
print()

with http.server.HTTPServer(("127.0.0.1", PORT), Handler) as httpd:
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped.")
