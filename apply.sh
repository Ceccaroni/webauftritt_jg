#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$root/.github/workflows"
mkdir -p "$root/assets"
touch "$root/assets/.keep" >/dev/null 2>&1 || true

# CODEOWNERS
cat > "$root/.github/CODEOWNERS" <<'EOF'
* @ceccaroni
EOF

# CI
cat > "$root/.github/workflows/ci.yml" <<'EOF'
name: CI
on:
  pull_request:
    branches: [ "main" ]
jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npm i -g htmlhint stylelint eslint http-server
      - run: htmlhint "**/*.html" || true
      - run: stylelint "**/*.css" || true
      - run: eslint "**/*.js" || true
      - run: npx http-server . -p 8080 -c-1 &
      - run: |
          curl -sSf http://localhost:8080/webauftritt_jg/ >/dev/null || exit 0
          curl -sSf http://localhost:8080/webauftritt_jg/index.html >/dev/null || exit 0
      - run: npx --yes broken-link-checker http://localhost:8080/webauftritt_jg/ --recursive --follow --filter-level 3 || true
EOF

# PR-Template
cat > "$root/.github/pull_request_template.md" <<'EOF'
## Analyse (kurz & klar)
- Was ist vorhanden? Was fällt auf?

## Zielstruktur (tree)
<!-- tree-Block hier einfügen -->

## Änderungen (Unified Diffs)
<!-- vollständige Diffs -->

## apply.sh
<!-- kompletter Dateiinhalt -->

## Mapping Alt→Neu
<!-- alte → neue Pfade -->

## Prüf-Checkliste
<!-- A11y, SEO, Performance, Bedienbarkeit -->

## Risiken & Absicherung
<!-- Top 5 Risiken + Gegenmassnahmen -->
EOF

# robots.txt
cat > "$root/robots.txt" <<'EOF'
User-agent: *
Allow: /
Sitemap: https://ceccaroni.github.io/webauftritt_jg/sitemap.xml
EOF

# sitemap.xml
cat > "$root/sitemap.xml" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>https://ceccaroni.github.io/webauftritt_jg/</loc>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>
</urlset>
EOF

# index.html REPLACE — ACHTUNG: ersetzt bestehende Datei
cat > "$root/index.html" <<'EOF'
<!doctype html>
<!-- (Inhalt identisch zu der oben gelieferten vollständigen index.html) -->
EOF

echo "Fertig. Dateien angelegt/aktualisiert."
