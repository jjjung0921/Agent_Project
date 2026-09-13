#!/usr/bin/env bash
# ai-trace.sh — docs/phases/README.md 의 추적 표(PRD FR/NFR → Task → commit)를 PLAN Task 줄의 `Refs:` 에서 생성한다.
#
# 사용법: scripts/ai-trace.sh            표 생성 (<!-- trace:begin --> / <!-- trace:end --> 사이를 바꾼다)
#         scripts/ai-trace.sh --check    생성 결과와 현재 표가 같으면 0, 다르면 diff 출력 후 1 (ai-end.sh 가 호출)
# 요구:   bash 3.2+, awk (macOS 기본 awk 호환)

set -eo pipefail
cd "$(git rev-parse --show-toplevel)"
f="docs/phases/README.md"
grep -q '<!-- trace:begin -->' "$f" || { echo "error: $f 에 <!-- trace:begin --> / <!-- trace:end --> 마커가 없다" >&2; exit 1; }

gen() {
  local plans; plans=$(ls docs/phases/[0-9][0-9]-*/PLAN.md 2>/dev/null || true)
  # shellcheck disable=SC2086
  awk '
    FNR == 1 { fidx++ }
    fidx == 1 { if ($0 ~ /^\| *N?FR-[0-9]+ *\|/) { id = $0; sub(/^\| */, "", id); sub(/ *\|.*/, "", id); if (!(id in prd)) { prd[id] = 1; order[++n] = id } }; next }
    /^- \[[ x]\] T[0-9]+\. / {
      phase = FILENAME; sub(/^docs\/phases\//, "", phase); sub(/\/PLAN\.md$/, "", phase); nn = substr(phase, 1, 2)
      state = (substr($0, 4, 1) == "x") ? "done" : "open"
      line = $0; sub(/^- \[[ x]\] /, "", line); tk = line; sub(/\..*/, "", tk)
      title = line; sub(/^T[0-9]+\. /, "", title); sub(/ — Done when:.*/, "", title); gsub(/\|/, "\\|", title)
      refs = ""; if (match($0, /· Refs: */)) { refs = substr($0, RSTART + RLENGTH); sub(/ · .*/, "", refs); sub(/ *\(commit .*/, "", refs); gsub(/`/, "", refs); sub(/ *$/, "", refs) }
      pr = ""; if (match($0, /\(commit [^)]*\)/)) pr = substr($0, RSTART + 8, RLENGTH - 9)
      task = nn "/" tk; cell = "[" task "](" phase "/PLAN.md) — " title
      if (refs == "") refs = "—"
      nr = split(refs, rs, /, */)
      for (i = 1; i <= nr; i++) { r = rs[i]; if (r == "") continue
        rows[r] = rows[r] "\n| " r " | " cell " | " state " | " pr " |"
        if (!(r in prd) && !(r in seen)) { seen[r] = 1; extra[++m] = r } }
      next
    }
    function rank(r) { return (r == "—") ? "~2" : (r == "none") ? "~1" : r }
    function emit(r) { if (r in rows) print substr(rows[r], 2); else print "| " r " | — 미배정 | | |" }
    END {
      print "| Ref | Phase/Task | 상태 | commit |"; print "|-----|------------|------|--------|"
      for (i = 1; i <= n; i++) emit(order[i])
      for (i = 1; i <= m; i++) for (j = i + 1; j <= m; j++) if (rank(extra[j]) < rank(extra[i])) { t = extra[i]; extra[i] = extra[j]; extra[j] = t }
      for (i = 1; i <= m; i++) emit(extra[i])
    }' docs/PRD.md $plans
}

new=$(mktemp -t ai-trace.XXXXXX); gen > "$new"
if [ "${1:-}" = "--check" ]; then
  cur=$(mktemp -t ai-trace-cur.XXXXXX)
  sed -n '/<!-- trace:begin -->/,/<!-- trace:end -->/p' "$f" | grep -v -e '<!-- trace:begin -->' -e '<!-- trace:end -->' > "$cur" || true
  if diff -q "$cur" "$new" >/dev/null; then rc=0; else diff "$cur" "$new" || true; rc=1; fi
  rm -f "$cur" "$new"; exit $rc
fi
tmp=$(mktemp -t ai-trace-out.XXXXXX)
awk -v nf="$new" '
  index($0, "<!-- trace:begin -->") { print; while ((getline line < nf) > 0) print line; skip = 1; next }
  index($0, "<!-- trace:end -->")   { skip = 0 }
  !skip { print }' "$f" > "$tmp" && mv "$tmp" "$f"
rm -f "$new"
echo "$f 추적 표를 갱신했다"
