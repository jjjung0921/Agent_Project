#!/usr/bin/env bash
# End of Work — close commit 전에 종료 절차와 크기 상한이 지켜졌는지 확인한다.
#
# 사용법: scripts/ai-end.sh                   점검만
#         scripts/ai-end.sh --set-checkpoint  CURRENT.md의 Last Checkpoint를 현재 HEAD로 기록한 뒤 점검
# 종료 코드: 0 = 통과, 1 = FAIL 항목 있음 (warn은 통과)
# 요구:   git 2.22+, bash 3.2+ (macOS 기본 bash 호환)

set -eo pipefail
cd "$(git rev-parse --show-toplevel)"

CURRENT=".ai/CURRENT.md"
HANDOFF=".ai/HANDOFF.md"
LOG=".ai/LOG.md"
INBOX=".ai/INBOX.md"
today=$(date +%F)
head_short=$(git rev-parse --short HEAD)
head_full=$(git rev-parse HEAD)
fail=0

ok()   { printf '  [ok]   %s\n' "$1"; }
bad()  { printf '  [FAIL] %s\n' "$1"; fail=1; }
warn() { printf '  [warn] %s\n' "$1"; }
section() { sed -n "/^## $2/,/^## /p" "$1" | grep -vE '^(## |<!--|-->|$)' || true; }
strip_comments() { awk '/<!--/ { c = 1 } !c { print } /-->/ { c = 0 }' "$1"; }
lines() { wc -l < "$1" | tr -d ' '; }
count_bullets() { section "$1" "$2" | grep -c '^- ' || true; }
# cap <label> <value> <max>
cap() { if [ "${2:-0}" -le "$3" ]; then ok "$1 = $2 (≤ $3)"; else warn "$1 = $2 — 상한 $3 (Rule 12)"; fi; }

if [ "${1:-}" = "--set-checkpoint" ]; then
  awk -v sha="$head_short" '
    /^## Last Checkpoint/            { insec = 1; print; next }
    insec && /^## /                  { insec = 0 }
    insec && !done && /^`[^`]*`$/    { print "`" sha "`"; done = 1; next }
    { print }
  ' "$CURRENT" > "$CURRENT.tmp" && mv "$CURRENT.tmp" "$CURRENT"
  echo "Last Checkpoint → $head_short"
fi

echo "end-of-work check (HEAD $head_short, $today)"

# 1. 작업 커밋: .ai/, docs/ 밖의 uncommitted 변경은 close commit에 섞이면 안 된다
other=$(git status --porcelain | cut -c4- | sed 's/.* -> //' | grep -vE '^(\.ai/|docs/)' || true)
if [ -z "$other" ]; then
  ok "코드 변경이 모두 커밋되어 있다"
else
  bad "작업 커밋이 안 된 변경이 있다 (close commit 전에 Rule 9대로 커밋):"
  printf '%s\n' "$other" | sed 's/^/           /'
fi

# 2. Status
status=$(section "$CURRENT" "Status" | head -n1 | tr -d '[:space:]')
case "$status" in
  IN_PROGRESS)              bad "CURRENT.md Status가 IN_PROGRESS다 → TODO / REVIEW / BLOCKED / DONE 중 하나로 바꾼다 (Rule 11)" ;;
  TODO|REVIEW|BLOCKED|DONE) ok  "CURRENT.md Status = $status" ;;
  *)                        bad "CURRENT.md Status를 읽을 수 없다: '${status:-}'" ;;
esac

# 3. Last Checkpoint == HEAD
checkpoint=$(section "$CURRENT" "Last Checkpoint" | grep -oE '^`[0-9a-f]{7,40}`$' | head -n1 | tr -d '`' || true)
if [ -n "$checkpoint" ] && [ "${head_full#$checkpoint}" != "$head_full" ]; then
  ok "Last Checkpoint = HEAD ($checkpoint)"
else
  bad "Last Checkpoint(${checkpoint:-없음})가 HEAD($head_short)와 다르다 → scripts/ai-end.sh --set-checkpoint"
fi

# 4. HANDOFF: 오늘 날짜, placeholder 없음
if grep -q "^- Date: $today" "$HANDOFF"; then
  ok "HANDOFF.md Date = $today"
else
  warn "HANDOFF.md의 Date가 오늘($today)이 아니다 — 갱신했는지 확인"
fi
if strip_comments "$HANDOFF" | grep -qE '<[^>]+>'; then
  warn "HANDOFF.md에 placeholder(<...>)가 남아 있다"
else
  ok "HANDOFF.md에 placeholder 없음"
fi

# 5. LOG: 맨 위 항목이 오늘 세션
top=$(grep -m1 '^## ' "$LOG" || true)
case "$top" in
  "## $today"*) ok "LOG.md 맨 위 항목 = 오늘 세션" ;;
  *)            warn "LOG.md 맨 위 항목이 오늘($today)이 아니다 — 세션 보고를 추가했는지 확인 (${top:-항목 없음})" ;;
esac

# 6. HEAD 커밋 trailer
if git log -1 --format='%(trailers:key=Agent,valueonly)' | grep -q .; then
  ok "HEAD 커밋에 Agent trailer 있음"
else
  warn "HEAD 커밋($head_short)에 Agent trailer가 없다 — 개발자 커밋이거나 trailer 누락"
fi

# 7. INBOX 미처리 항목
open_items=$(grep -c '^- \[ \]' "$INBOX" 2>/dev/null || true)
if [ "${open_items:-0}" -gt 0 ]; then
  warn "INBOX에 미처리 항목 ${open_items}개 — 처리하지 못했다면 LOG에 이유를 적는다"
else
  ok "INBOX 비어 있음"
fi

# 8. 크기 상한 (Rule 12)
cap "CURRENT.md 줄 수" "$(lines "$CURRENT")" 50
cap "HANDOFF.md 줄 수" "$(lines "$HANDOFF")" 60
top_lines=$(awk '/^## /{ n++ } n == 1 && NF' "$LOG" | grep -vc '^## ' || true)
cap "LOG 맨 위 항목 줄 수" "${top_lines:-0}" 8
cap "Progress step 수" "$(count_bullets "$CURRENT" Progress)" 10
cap "Recent Important Changes 수" "$(count_bullets "$CURRENT" 'Recent Important Changes')" 5

echo
if [ "$fail" -eq 0 ]; then
  echo "통과. 남은 단계: close commit"
  echo "  git add .ai docs && git commit -m 'docs(ai): close session — <요약>' --trailer 'Agent: <이름>' --trailer 'Task: <phase>/<task>'"
else
  echo "FAIL 항목을 해결한 뒤 다시 실행한다."
  exit 1
fi
