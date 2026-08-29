# Handoff

<!-- 60줄 이내. Task 시작 시 Goal·Work In Progress를 먼저 쓰고(handoff-first) 진행하며 갱신, 종료 시 완성. 덮어쓴다(이력은 git log). 모든 항목을 채운다(없으면 "없음"). -->

- From: claude-cowork — 제약 프리셋 세션
- Date: 2026-08-29
- Phase / Task: 01-project-setup / 시작 전 (Task 밖 작업)

## Goal

언어·저장소 구성이 무엇이든 같은 수준의 제약이 걸리도록, 계약은 Phase 01 AC로 고정하고 언어별 프리셋과 Layout 절차를 BOOTSTRAP.md에 둔다.

## Work Completed

- `.ai/BOOTSTRAP.md` Stack Constraints 절(Layout → Preset → AGENTS.md → PLAN T3, 프리셋 10종, Weak types, Polyglot) — 커밋 `d7262c3`
- `AGENTS.md` Rule 8·13 보강, Repository Map의 src/·tests/ 기본값 주석 / Phase 01 PLAN T3·T5·AC2·AC6·AC7 / README / ADR-0004

## Work In Progress

- 없음

## Files Changed

- `d7262c3` 참조 (`git show --stat d7262c3`)

## Decisions Made

- 계약(경고 없이 통과하는 4개 명령, 버전 고정·lockfile·설정 파일, 언어 규칙 ≤ 3줄 + 허용 목록, CI)은 PLAN AC로 고정, 도구·구성은 자유 — ADR-0004
- 루트 src/·tests/는 단일 패키지 기본값. 구성요소가 여럿이면 삭제하고 구성요소 디렉터리 + 루트 Makefile/justfile로 Commands를 묶는다
- 프리셋은 초기화 후 삭제되는 BOOTSTRAP.md에만 둔다 (AGENTS.md 컨텍스트 예산 유지)

## Tests Executed

- 문서 상호 참조·README 트리·Rule/AC 번호 참조 검사, openapi.yaml 파싱, 스크립트 문법 검사

## Test Results

- 문제 없음. 프리셋의 명령·옵션은 문서상 확인만 했고 각 언어 툴체인에서 실제 실행하지는 않았다(초기화 T3에서 검증)

## Known Problems

- 없음

## Unverified Assumptions

- 프로젝트 설명이 아직 없다. 스택·배포 형태·API 유무는 `.ai/BOOTSTRAP.md` 수행 시 결정한다.
- 개발자 git이 `--trailer`(2.32+)를 지원한다고 가정한다.
- 프리셋의 도구 버전·옵션(예: ruff `[tool.ruff.lint]`, Gradle `dependencyLocking`)은 2026-08 기준이며 초기화 시점에 재확인이 필요하다.

## Exact Next Action

`.ai/BOOTSTRAP.md`의 Project Description을 채운 뒤 Agent에게 수행을 지시한다. Agent는 `scripts/ai-start.sh`로 시작한다.
