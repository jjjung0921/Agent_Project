#!/usr/bin/env bash
# Start of Work — checkpoint 이후의 변경을 Agent/Developer로 구분해 보여주고, 상황에 맞는 next steps를 안내한다.
#
# 사용법: scripts/ai-start.sh          요약
#         scripts/ai-start.sh --diff   개발자 커밋의 변경 파일 목록까지 표시
# 요구:   git 2.22+, bash 3.2+ (macOS 기본 bash 호환). 항상 종료 코드 0 (정보 제공용).

set -eo pipefail
cd "$(git rev-parse --show-toplevel)"

CURRENT=".ai/CURRENT.md"
HANDOFF=".ai/HANDOFF.md"
INBOX=".ai/INBOX.md"
SEP=$'\x1f'
show_diff=0
[ "${1:-}" = "--diff" ] && show_diff=1

# section <file> <header>: 해당 "## 헤더" 섹션의 본문 (헤더·주석·빈 줄 제외)
section() {
  sed -n "/^## $2/,/^## /p" "$1" | grep -vE '^(## |<!--|-->|$)' || true
}

# --- 1. checkpoint ---
checkpoint=$(section "$CURRENT" "Last Checkpoint" | grep -oE '^`[0-9a-f]{7,40}`$' | head -n1 | tr -d '`' || true)
limit=""
if [ -z "$checkpoint" ]; then
  echo "checkpoint: (없음) — 첫 세션이거나 CURRENT.md의 Last Checkpoint가 비어 있다. 최근 30개 커밋을 표시한다."
  range="HEAD"; limit="-n 30"
elif ! git cat-file -e "${checkpoint}^{commit}" 2>/dev/null; then
  echo "checkpoint: $checkpoint — 이 저장소에 없는 커밋이다 (history rewrite 또는 다른 clone?). 최근 30개 커밋을 표시한다."
  range="HEAD"; limit="-n 30"
else
  echo "checkpoint: $checkpoint  $(git log -1 --format='%as %s' "$checkpoint")"
  range="${checkpoint}..HEAD"
fi

# --- 2. checkpoint 이후 커밋 (Agent trailer 유무로 구분) ---
echo
echo "commits since checkpoint (oldest first):"
count=0; dev_count=0; dev_shas=""
while IFS="$SEP" read -r sha date subject agent task; do
  [ -z "$sha" ] && continue
  count=$((count + 1))
  if [ -n "$agent" ]; then
    printf '  [agent:%s] %s %s %s%s\n' "$agent" "$sha" "$date" "$subject" "${task:+  (Task: $task)}"
  else
    printf '  [DEVELOPER] %s %s %s\n' "$sha" "$date" "$subject"
    dev_count=$((dev_count + 1)); dev_shas="$dev_shas $sha"
  fi
done < <(git log --reverse $limit \
  --format="%h${SEP}%as${SEP}%s${SEP}%(trailers:key=Agent,valueonly,separator=%x2C)${SEP}%(trailers:key=Task,valueonly,separator=%x2C)" \
  "$range" --)
[ "$count" -eq 0 ] && echo "  (없음)"

if [ "$dev_count" -gt 0 ]; then
  echo
  echo "developer commits: ${dev_count}개 — 되돌리지 말 것 (Rule 4)."
  if [ "$show_diff" -eq 1 ]; then
    for sha in $dev_shas; do
      echo "  --- $sha  $(git log -1 --format='%an: %s' "$sha")"
      git show --stat --format= "$sha" | sed 's/^/    /'
    done
  else
    echo "  변경 파일 목록: scripts/ai-start.sh --diff"
  fi
fi

# --- 3. uncommitted 변경 (개발자 변경 또는 중단된 Agent 작업) ---
echo
echo "uncommitted changes:"
status_out=$(git status --porcelain)
if [ -z "$status_out" ]; then
  echo "  (없음)"
else
  printf '%s\n' "$status_out" | sed 's/^/  /'
fi

# --- 4. INBOX ---
echo
open_items=0
if [ -f "$INBOX" ]; then
  open_items=$(grep -c '^- \[ \]' "$INBOX" || true)
  open_items=${open_items:-0}
  if [ "$open_items" -gt 0 ]; then
    echo "INBOX: 처리할 항목 ${open_items}개 — 사용자의 직접 지시 (Rule 5)"
    grep '^- \[ \]' "$INBOX" | sed 's/^/  /'
  else
    echo "INBOX: 비어 있음"
  fi
else
  echo "INBOX: 파일 없음 ($INBOX)"
fi

# --- 5. CURRENT 상태와 중단 여부 ---
echo
phase=$(section "$CURRENT" "Current Phase" | head -n1)
plan=$(printf '%s' "$phase" | grep -oE '`[^`]+`' | head -n1 | tr -d '`' || true)
task=$(section "$CURRENT" "Current Task" | head -n1)
status=$(section "$CURRENT" "Status" | head -n1 | tr -d '[:space:]')
next=$(section "$CURRENT" "Next Action" | head -n1)
echo "CURRENT: phase  = ${phase:-?}"
echo "         task   = ${task:-?}"
echo "         status = ${status:-?}"
echo "         next   = ${next:-?}"
if [ "$status" = "IN_PROGRESS" ]; then
  echo "  → 직전 세션이 정상 종료되지 않았다(중단 가능성). progress:"
  section "$CURRENT" "Progress" | sed 's/^/      /'
fi

# --- 6. 시작 컨텍스트 크기 (Rule 12) ---
echo
files="AGENTS.md $CURRENT $HANDOFF"
[ -n "$plan" ] && [ -f "$plan" ] && files="$files $plan"
total=0
for f in $files; do
  size=$(wc -c < "$f" | tr -d ' '); total=$((total + size))
done
echo "startup context: $(( (total + 512) / 1024 ))KB — $files"
[ "$total" -gt 25600 ] && echo "  → 25KB 초과. CURRENT/HANDOFF/PLAN을 줄인다 (Rule 12)."
cur_lines=$(wc -l < "$CURRENT" | tr -d ' ')
ho_lines=$(wc -l < "$HANDOFF" | tr -d ' ')
[ "$cur_lines" -gt 50 ] && echo "  → CURRENT.md ${cur_lines}줄 (상한 50)"
[ "$ho_lines" -gt 60 ] && echo "  → HANDOFF.md ${ho_lines}줄 (상한 60)"

# --- 7. next steps (상황에 따라 달라짐) ---
echo
echo "next steps:"
n=1
if [ "$status" = "IN_PROGRESS" ]; then
  echo "  $n. Resume (Rule 11) — uncommitted diff를 HANDOFF의 Work In Progress·위 progress와 대조: 일치하면 그 step부터 잇고, 아니면 개발자 변경으로 취급. 먼저 test 실행."
  n=$((n + 1))
fi
if [ "$dev_count" -gt 0 ] || [ "$open_items" -gt 0 ] || [ -n "$status_out" ]; then
  echo "  $n. 개발자 변경·INBOX 반영 (Rule 4·5) — 되돌리지 말고 spec·PLAN·HANDOFF에 반영, LOG의 Developer changes에 기록."
  n=$((n + 1))
fi
echo "  $n. ${plan:-현재 Phase PLAN.md}에서 Task·Acceptance Criteria 확인. CURRENT의 Relevant Documents·Source Files만 읽는다."
n=$((n + 1))
echo "  $n. CURRENT.md: Status=IN_PROGRESS, Progress에 step 목록(≤10). HANDOFF.md: Goal·Work In Progress 초안 (handoff-first, Rule 10)."
n=$((n + 1))
echo "  $n. 구현 — step마다 Progress 갱신, 긴 Task는 WIP 커밋. 끝나면 scripts/ai-end.sh."
exit 0
