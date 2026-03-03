VENDOR_SITE_DIR := vendor_site
VENDOR_PORT     := 8080
INTERNAL_DOCS   := internal_docs

.PHONY: serve lint test reset help

help:
	@echo "Targets:"
	@echo "  serve   Start local HTTP server for vendor_site/ on port $(VENDOR_PORT)"
	@echo "  lint    Lint internal markdown files"
	@echo "  test    Validate runbook contains required sections"
	@echo "  reset   Remove generated artifacts"

serve:
	@echo "Serving $(VENDOR_SITE_DIR)/ at http://127.0.0.1:$(VENDOR_PORT)"
	@echo "Press Ctrl-C to stop."
	python3 tools/serve_vendor_site.py $(VENDOR_PORT)

lint:
	@bash tools/md_lint.sh $(INTERNAL_DOCS)

test:
	@python3 tools/runbook_check.py $(INTERNAL_DOCS)/runbooks/vendorx_integration.md

reset:
	@echo "Cleaning generated artifacts..."
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@rm -f tools/*.log
	@echo "Done."
