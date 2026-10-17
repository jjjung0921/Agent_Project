#!/usr/bin/env python3
"""prd_trace.py — PRD ID를 원본으로 파생 문서(usecases.md · Phase PLAN · ADR)의 인용 정합성을 검사한다.

사용법:
  prd_trace.py PRD [DOC ...]            인용 수집 결과 요약
  prd_trace.py PRD [DOC ...] --check    검사. 종료 코드 0 통과 · 1 FAIL 있음 · 2 FAIL 없이 stale만
  prd_trace.py PRD [DOC ...] --write    usecases.md의 FR×UC 행렬 재생성 + usecases.lock.json 갱신

PRD는 파일 하나 또는 분할 폴더(docs/prd/). DOC를 안 주면 PRD 옆에서 찾는다:
  usecases.md · phases/[0-9][0-9]-*/PLAN.md · decisions/ADR-*.md (_template 제외)

검사:
  FAIL  PRD 안 ID 중복 · FR Related가 없는 ID · 파생 문서가 PRD에 없는 ID 인용
        · PLAN Task 줄에 Refs: 없음 · 마커 사이 FR×UC 행렬이 UC 단계 인용과 다름
  warn  Won't ID 인용 · Must FR이 어느 UC 단계에도 없음 · Must FR이 어느 PLAN Refs에도 없음(PLAN이 있을 때)
  STALE usecases.lock.json의 행 해시(Requirement+Acceptance, NFR은 Requirement+Target)와 현재 PRD가 다른 ID
        → 그 ID를 인용한 UC 목록. 이 목록이 prd-modeler 재호출 scope다.
옛 양식 PRD(머리 Version 줄과 Change Log 절이 둘 다 없음)는 lock·stale을 건너뛴다.
표준 라이브러리만 쓴다.

원본: ~/.agents/skills/prd-writing/scripts/prd_trace.py (prd-writing 스킬). 템플릿 레포의 scripts/prd_trace.py는
복사본이다 — 고칠 때는 원본을 고치고 다시 복사한다.
"""
import glob
import hashlib
import json
import os
import re
import sys

ID_RE = re.compile(r"(?<![A-Za-z0-9-])([A-Z]+)-(\d+)(?![0-9])")
ROW_RE = re.compile(r"^\|\s*([A-Z]+-\d+)\s*\|")
LIST_DEF_RE = re.compile(r"^\s*[-*]\s+\**([A-Z]+-\d+)\b")
UC_HEAD_RE = re.compile(r"^###\s+(UC-\d+)\b")
TASK_RE = re.compile(r"^- \[[ x]\] T\d+\. ")
BEGIN, END = "<!-- trace:fr-uc:begin -->", "<!-- trace:fr-uc:end -->"
MATRIX_HEAD_RE = re.compile(r"^##\s+FR\s*×\s*UC")


def strip_comments(text):
    """HTML 주석을 같은 줄 수의 빈칸으로 바꾼다(템플릿 예시 ID 무시, 줄 번호 유지)."""
    return re.sub(r"<!--.*?-->", lambda m: re.sub(r"[^\n]", " ", m.group(0)), text, flags=re.S)


def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def norm(s):
    return re.sub(r"\s+", " ", s).strip()


# ---------- PRD ----------

def read_prd(path):
    files = sorted(glob.glob(os.path.join(path, "*.md"))) if os.path.isdir(path) else [path]
    prd = {"ids": {}, "rows": {}, "order": [], "version": None, "changelog": False, "fails": []}
    for f in files:
        lines = strip_comments(open(f, encoding="utf-8").read()).splitlines()
        header = None
        for n, line in enumerate(lines, 1):
            if prd["version"] is None:
                m = re.match(r"^\s*-\s*Version:\s*(\S+)", line)
                if m:
                    prd["version"] = m.group(1)
            if re.match(r"^#+\s*(\d+\.\s*)?Change Log\b", line):
                prd["changelog"] = True
            if not line.startswith("|"):
                header = None
                m = LIST_DEF_RE.match(line)
                if m:
                    define(prd, m.group(1), f, n)
                continue
            c = cells(line)
            m = ROW_RE.match(line)
            if not m:
                if c and c[0] == "ID":
                    header = c
                continue
            if header is None:  # 머리 없는 표(파생 행렬 등)는 정의가 아니다
                continue
            rid = m.group(1)
            row = dict(zip(header, c))
            define(prd, rid, f, n)
            acc = row.get("Acceptance", row.get("Target", ""))
            prd["rows"][rid] = {
                "priority": row.get("Priority", ""),
                "related": row.get("Related", ""),
                "hash": hashlib.sha256((norm(row.get("Requirement", "")) + "\x1f" + norm(acc)).encode()).hexdigest()[:16],
                "where": (f, n),
            }
            if "Priority" in row:
                prd["order"].append(rid)
    prd["legacy"] = prd["version"] is None and not prd["changelog"]
    prd["prefixes"] = {i.split("-")[0] for i in prd["ids"]}
    for rid, r in prd["rows"].items():
        for ref in ID_RE.finditer(r["related"]):
            ref = ref.group(0)
            if ref.split("-")[0] in prd["prefixes"] and ref not in prd["ids"]:
                prd["fails"].append((r["where"], f"{rid} Related={ref} — PRD에 없는 ID"))
    return prd


def define(prd, rid, f, n):
    if rid in prd["ids"]:
        pf, pn = prd["ids"][rid]
        prd["fails"].append(((f, n), f"{rid} 중복 정의 (먼저 {rel(pf)}:{pn})"))
    else:
        prd["ids"][rid] = (f, n)


def wont(prd, rid):
    return prd["rows"].get(rid, {}).get("priority", "").lower().startswith("won")


def must(prd, rid):
    return prd["rows"].get(rid, {}).get("priority", "").lower() == "must"


# ---------- 파생 문서 ----------

def discover(prd_path):
    base = os.path.dirname(os.path.normpath(prd_path)) or "."
    out = glob.glob(os.path.join(base, "usecases.md"))
    out += sorted(glob.glob(os.path.join(base, "phases", "[0-9][0-9]-*", "PLAN.md")))
    out += sorted(p for p in glob.glob(os.path.join(base, "decisions", "ADR-*.md")) if "_template" not in p)
    return out


def scan(path):
    """인용 (id, 줄, 줄 텍스트) 전부 + usecases면 UC별 단계 인용·전체 인용, PLAN이면 Refs."""
    raw = open(path, encoding="utf-8").read()
    lines, raw_lines = strip_comments(raw).splitlines(), raw.splitlines()
    doc = {"path": path, "cites": [], "uc_order": [], "uc_step": {}, "uc_any": {}, "refs": set(), "no_refs": []}
    is_uc = os.path.basename(path).startswith("usecases")
    is_plan = os.path.basename(path) == "PLAN.md"
    uc = None
    in_block = False
    for n, line in enumerate(lines, 1):
        if BEGIN in raw_lines[n - 1]:
            in_block = True
        if END in raw_lines[n - 1]:
            in_block = False
        if in_block:  # 생성 구간은 인용으로 세지 않는다
            continue
        for m in ID_RE.finditer(line):
            doc["cites"].append((m.group(0), n))
        if is_uc:
            m = UC_HEAD_RE.match(line)
            if m:
                uc = m.group(1)
                doc["uc_order"].append(uc)
                doc["uc_step"][uc], doc["uc_any"][uc] = set(), set()
                continue
            if line.startswith("#"):
                uc = None
                continue
            if uc:
                doc["uc_any"][uc].update(m.group(0) for m in ID_RE.finditer(line))
                if line[:1].isspace() and " — " in line:  # 주 흐름·대안 흐름 단계
                    tail = re.sub(r"\([^)]*\)", "", line.rsplit(" — ", 1)[1])
                    doc["uc_step"][uc].update(m.group(0) for m in ID_RE.finditer(tail))
        if is_plan and TASK_RE.match(line):
            m = re.search(r"Refs:\s*(.*)", line)
            if not m:
                doc["no_refs"].append(n)
            else:
                refs = re.split(r" · |\(commit", m.group(1))[0]
                doc["refs"].update(x.group(0) for x in ID_RE.finditer(refs))
    return doc


def matrix(prd, uc):
    ucs = uc["uc_order"]
    row = lambda cs: "|" + "|".join(f" {c} " if c else " " for c in cs) + "|"
    out = [row(["FR", "Priority"] + ucs + ["걸린 UC 수"]), "|" + "---|" * (len(ucs) + 3)]
    for rid in prd["order"]:
        hit = [u for u in ucs if rid in uc["uc_step"][u]]
        out.append(row([rid, prd["rows"][rid]["priority"]] + ["●" if u in hit else "" for u in ucs] + [str(len(hit))]))
    return out


def current_matrix(path):
    """(마커 유무, 현재 표 줄들, 시작 줄 번호) — 마커가 없으면 '## FR × UC' 절의 첫 표."""
    lines = open(path, encoding="utf-8").read().splitlines()
    if any(BEGIN in l for l in lines):
        b = next(i for i, l in enumerate(lines) if BEGIN in l)
        e = next(i for i, l in enumerate(lines) if END in l)
        return True, [l for l in lines[b + 1:e] if l.strip()], b + 2
    for i, l in enumerate(lines):
        if MATRIX_HEAD_RE.match(l):
            j = i + 1
            while j < len(lines) and not lines[j].startswith("|"):
                j += 1
            k = j
            while k < len(lines) and lines[k].startswith("|"):
                k += 1
            return False, lines[j:k], j + 1
    return False, [], None


def same_table(a, b):
    return [cells(x) for x in a] == [cells(x) for x in b]


def lock_path(uc_path):
    return os.path.join(os.path.dirname(uc_path) or ".", "usecases.lock.json")


# ---------- main ----------

def rel(p):
    r = os.path.relpath(p)
    return r if not r.startswith("..") else os.path.abspath(p).replace(os.path.expanduser("~"), "~", 1)


def main(argv):
    mode = "list"
    args = []
    for a in argv:
        if a in ("--check", "--write"):
            mode = a[2:]
        elif a in ("-h", "--help"):
            print(__doc__)
            return 0
        else:
            args.append(a)
    if not args:
        print(__doc__, file=sys.stderr)
        return 1
    prd_path, docs = args[0], args[1:] or discover(args[0])
    prd = read_prd(prd_path)
    scanned = [scan(d) for d in docs]
    ucs = [d for d in scanned if d["uc_order"]]
    plans = [d for d in scanned if os.path.basename(d["path"]) == "PLAN.md"]
    form = "옛 양식(ID 확인만, stale 생략)" if prd["legacy"] else f"Version {prd['version'] or '없음'}"
    print(f"prd_trace — {rel(prd_path)} · {form} · ID {len(prd['ids'])}개 · 파생 문서 {len(scanned)}개")

    if mode == "write":
        for uc in ucs:
            write_matrix(prd, uc)
            if not prd["legacy"]:
                lk = {"prd": os.path.relpath(prd_path, os.path.dirname(uc["path"]) or "."),
                      "version": prd["version"],
                      "hashes": {rid: r["hash"] for rid, r in prd["rows"].items()}}
                with open(lock_path(uc["path"]), "w", encoding="utf-8") as f:
                    json.dump(lk, f, ensure_ascii=False, indent=2)
                    f.write("\n")
                print(f"{rel(lock_path(uc['path']))} 갱신 (기준 {prd['version']})")
        return 0

    fails, warns, stale = [], [], []
    for (f, n), msg in prd["fails"]:
        fails.append(f"{rel(f)}:{n}  {msg}")
    for d in scanned:
        wonts = {}
        for rid, n in d["cites"]:
            if rid.split("-")[0] not in prd["prefixes"]:
                continue  # UC-n·ADR-n처럼 PRD가 정의하지 않는 접두어
            if rid not in prd["ids"]:
                fails.append(f"{rel(d['path'])}:{n}  {rid} — PRD에 없는 ID 인용")
            elif wont(prd, rid):
                wonts.setdefault(rid, []).append(str(n))
        for rid, ns in wonts.items():
            warns.append(f"{rel(d['path'])}:{ns[0]}  {rid} — Won't(폐기) ID 인용 (줄 {', '.join(ns)})")
        for n in d["no_refs"]:
            fails.append(f"{rel(d['path'])}:{n}  Task 줄에 Refs: 없음 (요구 없는 Task는 Refs: none)")
    musts = [r for r in prd["order"] if must(prd, r)]
    for uc in ucs:
        for rid in musts:
            if not any(rid in s for s in uc["uc_step"].values()):
                warns.append(f"{rel(uc['path'])}  Must {rid} — 어느 UC 단계에도 없음")
        marked, cur, start = current_matrix(uc["path"])
        gen = matrix(prd, uc)
        if not marked:
            warns.append(f"{rel(uc['path'])}  FR×UC 행렬 마커 없음 — --write로 생성 구간을 만든다")
        if cur and not same_table(cur, gen) or marked and not cur:
            fails.append(f"{rel(uc['path'])}:{start}  FR×UC 행렬이 UC 단계 인용과 다르다 — --write로 재생성")
            for l in diff(cur, gen):
                fails.append("    " + l)
        if prd["legacy"]:
            continue
        lp = lock_path(uc["path"])
        if not os.path.exists(lp):
            warns.append(f"{rel(lp)} 없음 — prd-modeler 결과를 확인한 뒤 --write로 기준을 만든다")
            continue
        lk = json.load(open(lp, encoding="utf-8"))
        old, new = lk.get("hashes", {}), {rid: r["hash"] for rid, r in prd["rows"].items()}
        changed = sorted((set(old) | set(new)) - {k for k in old if old.get(k) == new.get(k)}, key=idkey)
        if changed and lk.get("version") != prd["version"]:
            warns.append(f"{rel(lp)}  기준 Version {lk.get('version')} → 현재 {prd['version']}")
        for rid in changed:
            hit = [u for u in uc["uc_order"] if rid in uc["uc_any"][u]]
            tag = "추가" if rid not in old else "삭제" if rid not in new else "변경"
            stale.append(f"{rid} ({tag}) → {', '.join(hit) if hit else 'UC 없음'}")
    if plans:
        refs = set().union(*(p["refs"] for p in plans))
        for rid in musts:
            if rid not in refs:
                warns.append(f"Must {rid} — 어느 PLAN Task Refs에도 없음 (미배정)")

    for l in fails:
        print(("FAIL  " if not l.startswith("    ") else "") + l)
    for l in warns:
        print("warn  " + l)
    for l in stale:
        print("STALE " + l)
    if mode == "list":
        for uc in ucs:
            print(f"UC 단계 인용 ({rel(uc['path'])}):")
            for u in uc["uc_order"]:
                ids = sorted((i for i in uc["uc_step"][u] if i in prd["ids"]), key=idkey)
                print(f"  {u}: {', '.join(ids) or '—'}")
    nf = sum(1 for l in fails if not l.startswith("    "))
    print(f"결론: FAIL {nf} · warn {len(warns)} · stale {len(stale)}")
    if mode == "check":
        return 1 if nf else 2 if stale else 0
    return 0


def idkey(rid):
    p, n = rid.rsplit("-", 1)
    return (p, int(n))


def diff(cur, gen):
    import difflib
    return [l for l in difflib.unified_diff(cur, gen, "현재", "생성", lineterm="", n=0) if not l.startswith("@@")]


def write_matrix(prd, uc):
    path = uc["path"]
    lines = open(path, encoding="utf-8").read().splitlines()
    gen = matrix(prd, uc)
    marked, cur, start = current_matrix(path)
    if marked:
        b = next(i for i, l in enumerate(lines) if BEGIN in l)
        e = next(i for i, l in enumerate(lines) if END in l)
        lines[b + 1:e] = gen
    elif start:  # '## FR × UC' 절의 손 표를 생성 구간으로 바꾼다
        lines[start - 1:start - 1 + len(cur)] = [BEGIN] + gen + [END]
    else:
        lines += ["", "## FR × UC Matrix", "", BEGIN] + gen + [END]
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"{rel(path)} FR×UC 행렬을 갱신했다")


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
