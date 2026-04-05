#!/usr/bin/env bash
# NeuronClaw QA Suite
# Validates project integrity: cross-references, frontmatter, consistency, completeness
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

pass() { ((PASS++)); echo -e "  ${GREEN}PASS${NC} $1"; }
fail() { ((FAIL++)); echo -e "  ${RED}FAIL${NC} $1"; }
warn() { ((WARN++)); echo -e "  ${YELLOW}WARN${NC} $1"; }

cd "$(dirname "$0")/.."

echo "========================================"
echo " NeuronClaw QA Suite"
echo "========================================"
echo ""

# ─────────────────────────────────────────
echo "1. File Structure"
echo "────────────────────────────────────────"

# Required files
for f in SKILL.md README.md LICENSE CONTRIBUTING.md CHANGELOG.md .gitignore; do
  if [ -f "$f" ]; then pass "$f exists"; else fail "$f missing"; fi
done

# Required directories
for d in references assets/templates assets/examples rules examples docs; do
  if [ -d "$d" ]; then pass "$d/ exists"; else fail "$d/ missing"; fi
done

echo ""

# ─────────────────────────────────────────
echo "2. YAML Frontmatter Validation"
echo "────────────────────────────────────────"

for f in SKILL.md references/*.md rules/*.md; do
  first_line=$(head -1 "$f")
  if [ "$first_line" = "---" ]; then
    # Check closing ---
    closing=$(awk 'NR>1 && /^---$/{print NR; exit}' "$f")
    if [ -n "$closing" ]; then
      pass "$f has valid frontmatter delimiters"
    else
      fail "$f has opening --- but no closing ---"
    fi
  else
    fail "$f missing YAML frontmatter"
  fi
done

# Check templates have frontmatter too
for f in assets/templates/draft.md assets/templates/skill.md; do
  first_line=$(head -1 "$f")
  if [ "$first_line" = "---" ]; then
    pass "$f has frontmatter"
  else
    fail "$f missing frontmatter"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "3. Cross-Reference Integrity (SKILL.md)"
echo "────────────────────────────────────────"

# Extract all relative links from SKILL.md (only ./path, not ../path)
grep -oE '\(\./[a-zA-Z/_.-]+\.md\)' SKILL.md | tr -d '()' | sort -u | while read -r link; do
  if [ -f "$link" ]; then
    pass "SKILL.md → $link"
  else
    fail "SKILL.md → $link (broken)"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "4. Cross-Reference Integrity (references/)"
echo "────────────────────────────────────────"

for f in references/*.md; do
  # Links to sibling files (./foo.md) — match only (./...) not (../...)
  grep -oE '\(\./[a-zA-Z/_.-]+\.md\)' "$f" 2>/dev/null | tr -d '()' | while read -r link; do
    target="$(dirname "$f")/$link"
    if [ -f "$target" ]; then
      pass "$f → $link"
    else
      fail "$f → $link (broken)"
    fi
  done
  # Links to parent dirs (../foo/bar.md)
  grep -oE '\(\.\./[a-zA-Z/_.-]+\.(md|yaml)\)' "$f" 2>/dev/null | tr -d '()' | while read -r link; do
    target="$(dirname "$f")/$link"
    if [ -f "$target" ]; then
      pass "$f → $link"
    else
      fail "$f → $link (broken)"
    fi
  done
done

echo ""

# ─────────────────────────────────────────
echo "5. Cross-Reference Integrity (README.md)"
echo "────────────────────────────────────────"

# Extract markdown links that are local files (not http)
grep -oE '\]\([^)h][^)]*\)' README.md | tr -d '()' | sed 's/.*]//' | while read -r link; do
  if [ -f "$link" ]; then
    pass "README.md → $link"
  else
    fail "README.md → $link (broken)"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "6. Frontmatter Field Validation"
echo "────────────────────────────────────────"

# SKILL.md must have name and description
if grep -q '^name:' SKILL.md; then pass "SKILL.md has 'name' field"; else fail "SKILL.md missing 'name'"; fi
if grep -q '^description:' SKILL.md; then pass "SKILL.md has 'description' field"; else fail "SKILL.md missing 'description'"; fi

# Each reference must have name and description in frontmatter
for f in references/*.md; do
  basename=$(basename "$f" .md)
  if head -20 "$f" | grep -q '^name:'; then
    pass "$f has 'name' field"
  else
    fail "$f missing 'name' in frontmatter"
  fi
  if head -20 "$f" | grep -q '^description:'; then
    pass "$f has 'description' field"
  else
    fail "$f missing 'description' in frontmatter"
  fi
done

# Each rule must have name and description
for f in rules/*.md; do
  if head -20 "$f" | grep -q '^name:'; then
    pass "$f has 'name' field"
  else
    fail "$f missing 'name' in frontmatter"
  fi
  if head -20 "$f" | grep -q '^description:'; then
    pass "$f has 'description' field"
  else
    fail "$f missing 'description' in frontmatter"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "7. Naming Consistency"
echo "────────────────────────────────────────"

# All reference files should be lowercase-hyphenated
for f in references/*.md; do
  basename=$(basename "$f")
  if echo "$basename" | grep -qE '^[a-z][a-z0-9-]+\.md$'; then
    pass "$basename follows naming convention"
  else
    fail "$basename doesn't follow lowercase-hyphen convention"
  fi
done

# All rule files should be lowercase-hyphenated
for f in rules/*.md; do
  basename=$(basename "$f")
  if echo "$basename" | grep -qE '^[a-z][a-z0-9-]+\.md$'; then
    pass "$basename follows naming convention"
  else
    fail "$basename doesn't follow lowercase-hyphen convention"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "8. Orphan Detection"
echo "────────────────────────────────────────"

# Check that every reference file is linked from SKILL.md
for f in references/*.md; do
  basename=$(basename "$f")
  if grep -q "$basename" SKILL.md; then
    pass "$basename referenced in SKILL.md"
  else
    warn "$basename NOT referenced in SKILL.md (orphan?)"
  fi
done

# Check that every rule file is linked from somewhere
for f in rules/*.md; do
  basename=$(basename "$f")
  found=false
  for src in SKILL.md references/*.md; do
    if grep -q "$basename" "$src" 2>/dev/null; then
      found=true
      break
    fi
  done
  if $found; then
    pass "$basename referenced from skill or reference"
  else
    warn "$basename NOT referenced from anywhere (orphan?)"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "9. Template Integrity"
echo "────────────────────────────────────────"

# metadata.yaml should have key fields
for field in slug status promoted_on use_count success_count failure_count usage_log avg_duration_seconds avg_tool_count; do
  if grep -q "^${field}:" assets/templates/metadata.yaml; then
    pass "metadata.yaml has '$field'"
  else
    fail "metadata.yaml missing '$field'"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "10. Content Quality Checks"
echo "────────────────────────────────────────"

# No TODO/FIXME/HACK left in published files
todo_count=$(grep -riE '(TODO|FIXME|HACK|XXX):' --include="*.md" --include="*.yaml" . 2>/dev/null | grep -v node_modules | grep -v .git | wc -l | tr -d ' ')
if [ "$todo_count" -eq 0 ]; then
  pass "No TODO/FIXME/HACK markers found"
else
  warn "Found $todo_count TODO/FIXME/HACK markers"
fi

# No real credentials or API keys
secret_count=$(grep -riE '(sk-[a-zA-Z0-9]{20,}|AKIA[A-Z0-9]{16}|ghp_[a-zA-Z0-9]{36})' --include="*.md" --include="*.yaml" . 2>/dev/null | wc -l | tr -d ' ')
if [ "$secret_count" -eq 0 ]; then
  pass "No hardcoded secrets detected"
else
  fail "Found $secret_count potential hardcoded secrets!"
fi

# Check SKILL.md isn't too long (should be dispatcher, <250 lines)
skill_lines=$(wc -l < SKILL.md | tr -d ' ')
if [ "$skill_lines" -le 250 ]; then
  pass "SKILL.md is $skill_lines lines (under 250 limit)"
else
  warn "SKILL.md is $skill_lines lines (ideally under 250)"
fi

# Check README has key sections
for section in "Installation" "Features" "How It Works" "Quick Start" "Security" "Contributing" "License"; do
  if grep -q "## $section" README.md; then
    pass "README has '## $section' section"
  else
    warn "README missing '## $section' section"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "11. Lifecycle Traceability"
echo "────────────────────────────────────────"

# Verify the lifecycle is documented end-to-end
# Each status transition should be mentioned in at least one reference
for transition in "draft.*probation" "probation.*stable" "probation.*deprecated" "stable.*deprecated" "deprecated.*archived"; do
  found=false
  for f in SKILL.md references/*.md; do
    if grep -qiE "$transition" "$f" 2>/dev/null; then
      found=true
      break
    fi
  done
  if $found; then
    pass "Lifecycle transition '$transition' documented"
  else
    fail "Lifecycle transition '$transition' not documented"
  fi
done

echo ""

# ─────────────────────────────────────────
echo "12. Version Consistency"
echo "────────────────────────────────────────"

# SKILL.md version should match CHANGELOG latest version
skill_version=$(grep 'version:' SKILL.md | head -1 | sed 's/.*version: *//' | tr -d ' ')
changelog_version=$(grep -oE '\[[0-9]+\.[0-9]+\.[0-9]+\]' CHANGELOG.md | head -1 | tr -d '[]')
if [ "$skill_version" = "$changelog_version" ]; then
  pass "SKILL.md version ($skill_version) matches CHANGELOG ($changelog_version)"
else
  fail "SKILL.md version ($skill_version) != CHANGELOG ($changelog_version)"
fi

echo ""

# ─────────────────────────────────────────
echo "========================================"
echo " Results"
echo "========================================"
echo -e "  ${GREEN}PASS: $PASS${NC}"
echo -e "  ${RED}FAIL: $FAIL${NC}"
echo -e "  ${YELLOW}WARN: $WARN${NC}"
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}QA FAILED — $FAIL issue(s) to fix${NC}"
  exit 1
else
  echo -e "${GREEN}QA PASSED${NC}"
  exit 0
fi
