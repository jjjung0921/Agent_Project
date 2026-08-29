# Handoff

<!-- 60줄 이내. Task 시작 시 Goal·Work In Progress를 먼저 쓰고(handoff-first) 진행하며 갱신, 종료 시 완성. 덮어쓴다(이력은 git log). 모든 항목을 채운다(없으면 "없음"). -->

- From: claude-cowork — 컨텍스트 예산 세션
- Date: 2026-08-29
- Phase / Task: 01-project-setup / 시작 전 (Task 밖 작업)

## Goal

Agent가 읽는 컨텍스트가 희석되지 않도록 AGENTS.md를 규칙 중심으로 압축하고, 절차는 스크립트가 안내하며, 상태 파일에 크기 상한을 둔다.

## Work Completed

- `AGENTS.md` 139줄 → 59줄 (Rules 14개, Session Procedure, Commit Format) — 커밋 `21d707d`
- `scripts/ai-start.sh`: 상황별 next steps, startup context 크기·상한 경고 / `scripts/ai-end.sh`: 상한 경고 5종
- `.ai/` 주석 축소, CURRENT.md에 Source Files 파일·심볼 단위 지침, ADR-0003 작성

## Work In Progress

- 없음

## Files Changed

- `21d707d` 참조 (`git show --stat 21d707d`)

## Decisions Made

- 규칙(AGENTS.md)과 절차(스크립트 출력)를 분리. AGENTS.md 분할이나 요약 파일은 만들지 않는다 — ADR-0003
- 상한: CURRENT 50줄, HANDOFF 60줄, LOG 항목 8줄, Progress 10 step, Recent Changes 5개, 시작 컨텍스트 25KB 경고
- ADR 번호 참조는 "다음 번호"로 일반화해 템플릿 수정 시 번호 churn을 없앤다

## Tests Executed

- 임시 clone에서 `scripts/ai-start.sh`(정상·IN_PROGRESS·개발자 커밋), `scripts/ai-end.sh`(상한 초과 경고, FAIL 검출)
- 문서 상호 참조·README 트리·Rule 번호 참조 검사, openapi.yaml 파싱

## Test Results

- 모두 기대대로 동작. 시작 컨텍스트 18KB → 14KB
- 스크립트는 Linux bash 5에서만 실행 (bash 3.2 호환 문법 사용, macOS 미검증)

## Known Problems

- 없음

## Unverified Assumptions

- 프로젝트 설명이 아직 없다. 스택·배포 형태·API 유무는 `.ai/BOOTSTRAP.md` 수행 시 결정한다.
- 개발자 git이 `--trailer`(2.32+)를 지원한다고 가정한다.

## Exact Next Action

`.ai/BOOTSTRAP.md`의 Project Description을 채운 뒤 Agent에게 수행을 지시한다. Agent는 `scripts/ai-start.sh`로 시작한다.
