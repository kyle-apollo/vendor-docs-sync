#!/usr/bin/env bash
# diagnostics.sh — collects system and VendorX connector information
# for inclusion in support tickets.
#
# Usage:
#   bash sample_project/scripts/diagnostics.sh
#   bash sample_project/scripts/diagnostics.sh > /tmp/vendorx_diag.txt
#
# IMPORTANT: Review output before sharing. Redact any secret values
# (API keys, passwords) in accordance with the External Sources Policy.

set -euo pipefail

SEP="────────────────────────────────────────────────────────────────"

print_section() {
  echo ""
  echo "$SEP"
  echo "  $1"
  echo "$SEP"
}

# ── Header ──────────────────────────────────────────────────────────────────
echo "VendorX Diagnostics Report"
echo "Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# ── OS and runtime ───────────────────────────────────────────────────────────
print_section "System information"
echo "OS:           $(uname -s) $(uname -r) $(uname -m)"
echo "Hostname:     $(hostname)"
if command -v python3 &>/dev/null; then
  echo "Python:       $(python3 --version 2>&1)"
else
  echo "Python:       not found"
fi

# ── VendorX agent ────────────────────────────────────────────────────────────
print_section "VendorX agent"
if command -v vendorx-agent &>/dev/null; then
  echo "Binary:       $(command -v vendorx-agent)"
  echo "Version:      $(vendorx-agent --version 2>&1 || echo 'could not determine')"
else
  echo "vendorx-agent not found in PATH"
fi

# ── Python SDK ───────────────────────────────────────────────────────────────
print_section "Python SDK"
if command -v pip &>/dev/null || command -v pip3 &>/dev/null; then
  PIP_CMD=$(command -v pip3 2>/dev/null || command -v pip)
  SDK_VER=$("$PIP_CMD" show vendorx-sdk 2>/dev/null | grep Version || echo "not installed")
  echo "vendorx-sdk:  $SDK_VER"
else
  echo "pip not found — cannot determine SDK installation status"
fi

# ── Config file ──────────────────────────────────────────────────────────────
print_section "Configuration file"
CONFIG_CANDIDATES=(
  "sample_project/app_config.yaml"
  "app_config.yaml"
  "${VENDORX_CONFIG_PATH:-}"
)
CONFIG_FOUND=false
for cfg in "${CONFIG_CANDIDATES[@]}"; do
  if [[ -n "$cfg" && -f "$cfg" ]]; then
    echo "Found:        $cfg"
    echo ""
    # Print config, masking the api_key value if present
    sed 's/\(api_key:\s*\).*/\1<REDACTED>/' "$cfg"
    CONFIG_FOUND=true
    break
  fi
done
if [[ "$CONFIG_FOUND" == false ]]; then
  echo "No config file found in default locations."
fi

# ── Environment variables ────────────────────────────────────────────────────
print_section "Relevant environment variables"
echo "# Only VENDORX_* and APP_* variables are shown."
echo "# Values for keys that look like secrets are masked."
echo ""

env | sort | grep -E '^(VENDORX_|APP_|LOG_LEVEL)' | \
  sed 's/\(VENDORX_API_KEY=\).*/\1<REDACTED>/' || \
  echo "(none found)"

# ── .env file (if present) ───────────────────────────────────────────────────
print_section ".env file"
ENV_FILE=".env"
if [[ -f "$ENV_FILE" ]]; then
  echo "Found: $ENV_FILE"
  echo ""
  # Print .env with secret-looking values masked
  sed 's/\(VENDORX_API_KEY=\).*/\1<REDACTED>/' "$ENV_FILE"
else
  echo "No .env file found at: $ENV_FILE"
fi

# ── Network reachability ─────────────────────────────────────────────────────
print_section "Network reachability"
ENDPOINT="https://ingest.vendorx.example.com/health"
echo "Checking: $ENDPOINT"
if command -v curl &>/dev/null; then
  curl -sS --max-time 10 -o /dev/null -w "HTTP status: %{http_code}  Time: %{time_total}s\n" \
    "$ENDPOINT" 2>&1 || echo "curl failed — host may be unreachable (expected in local/offline environments)"
else
  echo "curl not found — skipping reachability check"
fi

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "$SEP"
echo "  End of diagnostics report"
echo "$SEP"
echo ""
echo "Review the output above before sharing."
