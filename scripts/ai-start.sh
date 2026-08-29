#!/usr/bin/env bash
# Start of Work 점검 — checkpoint 이후의 변경을 Agent/Developer로 구분해 보여준다.
#
# 사용법: scripts/ai-start.sh          요약
#         scripts/ai-start.sh --diff   개발자 커밋의 변경 파일 목록까지 표시
# 요구:   git 2.22+, bash 3.2+ (macOS 기본 bash 호환). 항상 종료 코드 0 (정보 제공용).

set -eo pipefail
cd "$(git rev-parse --show-toplevel)"

CURRENT=".ai/CURRENT.md"
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
  echo "developer commits: ${dev_count}개 — 되돌리지 말 것. diff를 읽고 spec·PLAN·HANDOFF에 반영하고 LOG의 Developer changes에 기록한다."
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
if [ -f "$INBOX" ]; then
  open_items=$(grep -c '^- \[ \]' "$INBOX" || true)
  if [ "${open_items:-0}" -gt 0 ]; then
    echo "INBOX: 처리할 항목 ${open_items}개 — $INBOX 를 읽고 반영한다 (Source of Truth 1순위)"
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
task=$(section "$CURRENT" "Current Task" | head -n1)
status=$(section "$CURRENT" "Status" | head -n1 | tr -d '[:space:]')
next=$(section "$CURRENT" "Next Action" | head -n1)
echo "CURRENT: phase  = ${phase:-?}"
echo "         task   = ${task:-?}"
echo "         status = ${status:-?}"
echo "         next   = ${next:-?}"
if [ "$status" = "IN_PROGRESS" ]; then
  echo
  echo "  → 직전 세션이 정상 종료되지 않았다(중단 가능성). AGENTS.md > Start of Work > Resume 절차를 따른다."
  echo "    progress:"
  section "$CURRENT" "Progress" | sed 's/^/      /'
fi
