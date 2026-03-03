#!/usr/bin/env python3
"""
runbook_check.py — validates that a VendorX integration runbook contains
all required sections.

Usage:
    python3 tools/runbook_check.py <path-to-runbook.md>

Exits 0 if all required sections are present, 1 otherwise.
"""
import sys
import re

REQUIRED_SECTIONS = [
    "Overview",
    "Prerequisites",
    "Installation",
    "Configuration",
    "Credential management",
    "Verification",
    "Troubleshooting",
    "Rollback",
    "Sources",
]

def normalize(text: str) -> str:
    """Lowercase and strip punctuation for fuzzy matching."""
    return re.sub(r"[^a-z0-9 ]", "", text.lower()).strip()

def extract_headings(lines: list[str]) -> list[str]:
    headings = []
    for line in lines:
        m = re.match(r"^#{1,4}\s+(.+)", line)
        if m:
            headings.append(m.group(1).strip())
    return headings

def main() -> int:
    if len(sys.argv) < 2:
        print("Usage: runbook_check.py <runbook.md>", file=sys.stderr)
        return 1

    path = sys.argv[1]
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.readlines()
    except FileNotFoundError:
        print(f"ERROR: file not found: {path}", file=sys.stderr)
        return 1

    print(f"Checking runbook: {path}")
    print()

    headings = extract_headings(lines)
    normalized_headings = [normalize(h) for h in headings]

    errors = 0
    for section in REQUIRED_SECTIONS:
        norm_section = normalize(section)
        found = any(norm_section in nh for nh in normalized_headings)
        status = "PASS" if found else "FAIL"
        if not found:
            errors += 1
        print(f"  [{status}]  Required section: '{section}'")

    print()
    if errors == 0:
        print(f"All {len(REQUIRED_SECTIONS)} required sections present.")
        return 0
    else:
        print(f"{errors} required section(s) missing. Update the runbook and re-run.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
