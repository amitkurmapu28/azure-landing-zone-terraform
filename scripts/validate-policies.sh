#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "=== Terraform formatting ==="
terraform -chdir="$ROOT" fmt -check -recursive

echo "=== Landing Zone validation ==="
terraform -chdir="$ROOT" init \
  -backend=false \
  -input=false \
  -lockfile=readonly

terraform -chdir="$ROOT" validate

echo "=== Azure Monitor Agent validation ==="
terraform -chdir="$ROOT/ama-windows-lab" init \
  -backend=false \
  -input=false \
  -lockfile=readonly

terraform -chdir="$ROOT/ama-windows-lab" validate

echo "=== Azure Policy JSON syntax ==="
python3 - "$ROOT/policies" <<'PY'
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
files = sorted(root.rglob("*.json"))

for path in files:
    with path.open(encoding="utf-8") as handle:
        json.load(handle)
    print(f"Valid JSON: {path.relative_to(root)}")

print(f"Checked {len(files)} JSON file(s).")
PY

echo "=== All validation checks passed ==="
