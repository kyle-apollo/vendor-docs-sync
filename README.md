# vendor-docs-sync

A workflow repository for keeping internal runbooks up to date with external vendor documentation.

## Overview

Vendor documentation changes. This repo provides a structured process for a developer to:

1. Serve the vendor guide locally (simulating an external URL).
2. Review the vendor guide and extract relevant changes.
3. Update the internal runbook in `internal_docs/runbooks/`.
4. Validate the updated runbook meets internal standards.

## Repository layout

```
internal_docs/
  runbooks/
    vendorx_integration.md       # VendorX integration runbook (the doc you maintain)

vendor_site/
  vendorx_install.html           # Snapshot of vendor's setup guide

sample_project/
  app_config.yaml                # Example application configuration
  .env.example                   # Environment variable template
  scripts/
    diagnostics.sh               # Diagnostic helper referenced in vendor guide

tools/
  serve_vendor_site.py           # Local HTTP server for vendor_site/
  md_lint.sh                     # Markdown style checker
  runbook_check.py               # Validates runbook contains required sections
```

## Quickstart

### 1. Start the vendor guide server

```bash
make serve
```

This starts a local HTTP server at `http://127.0.0.1:8080` serving the contents of `vendor_site/`.

Open the vendor guide in a browser:

```
http://127.0.0.1:8080/vendorx_install.html
```

### 2. Review the vendor guide and update the runbook

Read the vendor guide and update `internal_docs/runbooks/vendorx_integration.md` as needed.
Follow the guidelines in `internal_docs/policies/external_sources_policy.md`.

### 3. Validate the runbook

```bash
make lint    # Check markdown formatting
make test    # Verify required sections are present
```

### 4. Clean up generated artifacts

```bash
make reset
```

## Make targets

| Target | Description |
|--------|-------------|
| `make serve` | Serve `vendor_site/` on port 8080 |
| `make lint` | Lint internal markdown files |
| `make test` | Check runbook for required sections |
| `make reset` | Remove generated artifacts |

## Prerequisites

- Python 3.7+ (for `make serve` and `make test`)
- Bash (for `make lint`)
- No external dependencies required.
