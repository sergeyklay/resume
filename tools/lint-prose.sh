#!/usr/bin/env bash
#
# lint-prose.sh — reject résumé prose that invites objection.
#
# The document is read by someone looking for a reason to discount the candidate.
# This script encodes the categories of writing that hand them one: self-assessment
# in place of evidence, recruiter cliché, duty names in place of outcomes, and
# nominalised bullet openings.
#
# Usage:  tools/lint-prose.sh [files...]        (defaults to content/*.tex)
# Exit:   0 clean, 1 findings.

set -uo pipefail

files=("$@")
if [ ${#files[@]} -eq 0 ]; then
  shopt -s nullglob
  files=(content/*.tex)
fi

if [ ${#files[@]} -eq 0 ]; then
  echo "lint-prose: no files to check" >&2
  exit 1
fi

findings=0

# Reports one category. $1 = human-readable reason, $2 = extended regex.
report() {
  local reason="$1" pattern="$2" hits
  hits=$(grep -rInEi --color=never "$pattern" "${files[@]}" 2>/dev/null | grep -v '^\s*%' || true)
  if [ -n "$hits" ]; then
    echo "── $reason"
    echo "$hits" | sed 's/^/   /'
    echo
    findings=$((findings + $(echo "$hits" | wc -l)))
  fi
}

echo "lint-prose: checking ${#files[@]} file(s)"
echo

report "Self-assessing adjective — assert it with evidence or drop it" \
  '\b(world[- ]class|cutting[- ]edge|state[- ]of[- ]the[- ]art|best[- ]in[- ]class|passionate|passionately|driven by|laser[- ]sharp|elegant|robust|seamless|innovative|visionary|exceptional|outstanding|stellar|top[- ]notch)\b'

report "Recruiter cliché" \
  '\b(proven track record|results[- ]oriented|results[- ]driven|team player|hands[- ]on|wear(ing)? many hats|leverag(e|ed|ing)|synerg(y|ies)|spearhead(ed|ing)?|champion(ed|ing)?|thought leader|go[- ]getter|self[- ]starter|dynamic|rockstar|ninja|guru|game[- ]chang(er|ing))\b'

report "Duty name in place of an outcome" \
  '\b(responsible for|in charge of|tasked with|duties includ|working on|worked on the area|helped to|assisted with|participat(ed|ing) in)\b'

report "Filler intensifier — the claim must stand without it" \
  '\b(very|really|extremely|highly|greatly|significantly|substantially|dramatically|massively|hugely|incredibly|truly|deeply)\b'

report "Vague quantifier — name the number or cut the claim" \
  '\b(various|numerous|several|multiple|many|a lot of|lots of|countless|myriad)\b'

report "Bullet opening with a nominalisation — start with a verb" \
  '\\item \{?\s*(Development|Implementation|Creation|Design|Management|Maintenance|Support|Optimization|Optimisation|Improvement|Coordination|Delegation|Integration|Migration|Automation) of\b'

report "American spelling — the document is British throughout" \
  '\b(organiz(e|ed|ing|ation|ations)|standardiz(e|ed|ing|ation)|optimiz(e|ed|ing|ation)|centraliz(e|ed|ing|ation)|prioritiz(e|ed|ing)|recogniz(e|ed|ing)|analyz(e|ed|ing)|behavior|favorite|color|catalog)\b'

report "Exclamation mark or rhetorical question" \
  '(!|\?)\s*\}?\s*$'

report "AI-assistant register — this is a résumé, not a chat reply" \
  '\b(delve|delving|underscore(s|d)?|pivotal|crucial|vital|robustly|holistic|tapestry|realm|landscape of|it.s worth noting|notably|furthermore|moreover|in today.s)\b'

# Bullets longer than ~190 characters will not fit two typeset lines at 11pt.
long=$(grep -rInE '\\item' "${files[@]}" 2>/dev/null | awk -F: 'length($0) > 190' || true)
if [ -n "$long" ]; then
  echo "── Bullet too long for two typeset lines (>190 chars)"
  echo "$long" | sed 's/^/   /' | cut -c1-160
  echo
  findings=$((findings + $(echo "$long" | wc -l)))
fi

if [ "$findings" -eq 0 ]; then
  echo "lint-prose: clean"
  exit 0
fi

echo "lint-prose: $findings finding(s)"
exit 1
