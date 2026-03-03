# VendorX Integration Runbook

**Service:** VendorX Data Pipeline Connector
**Team:** Platform Engineering
**Last updated:** 2025-10-14
**Review cycle:** Quarterly or after any VendorX major release
**Source:** [VendorX Setup Guide](http://127.0.0.1:8000/vendorx_install.html) — accessed 2025-10-14

---

## Troubleshooting

### Connection refused / timeout

- Confirm network access: `curl -v https://ingest.vendorx.example.com/health`
- Check that `VENDORX_ENDPOINT` is set correctly.
- Verify firewall rules permit outbound HTTPS from the host.

### Authentication errors (401 / 403)

- Confirm `VENDORX_API_KEY` is set and not expired.
- Check the key has the `ingest:write` permission in the VendorX portal.

### Collecting diagnostic information

When opening a support ticket with VendorX, use the `diagnostics.sh` script to collect safe, non-sensitive system information:

```bash
bash sample_project/scripts/diagnostics.sh > /tmp/vendorx_diag.txt
```

Review `/tmp/vendorx_diag.txt` before sharing. Remove or redact any secrets, internal hostnames, or PII. 

---


## Overview

VendorX is a third-party data pipeline service that ingests structured event streams from internal applications and delivers them to downstream analytics systems. This runbook covers installation, configuration, credential management, verification, and common troubleshooting steps for the VendorX connector used by the `sample_project` application.

---

## Prerequisites

- Python 3.9 or later
- Network access to `ingest.vendorx.example.com` (port 443)
- A VendorX API key provisioned via the vendor portal (see [Credential management](#credential-management))
- The application configuration file at `sample_project/app_config.yaml`

---

## Required sections

> **Note for tooling:** The automated runbook check (`make test`) requires the headings below to be present verbatim.

---

## Installation

### 1. Install the VendorX agent

Download the agent package from the VendorX portal and place the binary in `/usr/local/bin/vendorx-agent`. Verify the SHA-256 checksum against the value published in the vendor release notes before executing.

```bash
# Example — replace <VERSION> and <CHECKSUM> with values from the vendor release page
curl -fsSL https://packages.vendorx.example.com/agent/<VERSION>/vendorx-agent-linux-amd64 \
  -o /tmp/vendorx-agent

echo "<CHECKSUM>  /tmp/vendorx-agent" | sha256sum -c -
chmod +x /tmp/vendorx-agent
sudo mv /tmp/vendorx-agent /usr/local/bin/vendorx-agent
```

### 2. Install the Python SDK

```bash
pip install vendorx-sdk==2.4.1
```

Confirm the package version:

```bash
pip show vendorx-sdk | grep Version
```

---

## Configuration

### Application config

The connector reads its runtime configuration from `sample_project/app_config.yaml`. Key fields:

| Field | Description |
|---|---|
| `vendorx.endpoint` | Ingest endpoint URL |
| `vendorx.batch_size` | Number of events per batch |
| `vendorx.flush_interval_seconds` | Maximum time between flushes |
| `vendorx.tls.verify` | Whether to verify the server TLS certificate |

Do not set `tls.verify: false` in production environments.

### Environment variables

Credentials and environment-specific overrides are supplied via environment variables. Copy `.env.example` to `.env` and fill in the values:

```bash
cp sample_project/.env.example sample_project/.env
# Edit .env — do not commit this file
```

Required variables:

| Variable | Description |
|---|---|
| `VENDORX_API_KEY` | API key from the VendorX portal |
| `VENDORX_ENDPOINT` | Ingest endpoint (overrides config file if set) |
| `APP_ENV` | `development`, `staging`, or `production` |
| `LOG_LEVEL` | `DEBUG`, `INFO`, `WARN`, or `ERROR` |

---

## Credential management

API keys are provisioned per environment through the VendorX portal at `portal.vendorx.example.com`. Store the key in the team secrets manager under the path `platform/vendorx/<environment>/api_key`. Never commit the key to version control or paste it into a runbook or issue tracker.

Rotate keys quarterly or immediately if a key is suspected to have been exposed.

---

## Verification

After installation and configuration, verify the connector is operational:

```bash
# 1. Check the agent version
vendorx-agent --version

# 2. Send a test event (returns the server-assigned event ID on success)
vendorx-agent verify --config sample_project/app_config.yaml
```

If the verify command fails, consult the [Troubleshooting](#troubleshooting) section.

---


## Rollback

To revert to a previous agent version:

```bash
sudo vendorx-agent install --version <PREVIOUS_VERSION>
```

Confirm the previous version is running:

```bash
vendorx-agent --version
```

---

## Runbook maintenance

| Section | Update trigger |
|---|---|
| Installation | VendorX agent major/minor release |
| Configuration | Changes to `app_config.yaml` schema |
| Credential management | Policy updates or key rotation procedure changes |
| Troubleshooting | New error patterns observed in production |

---

## Sources

- VendorX Setup Guide — `http://127.0.0.1:8000/vendorx_install.html` (accessed 2025-10-14)
- VendorX SDK changelog — `https://docs.vendorx.example.com/sdk/changelog` (accessed 2025-10-14)
