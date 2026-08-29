# Current State

<!-- 50줄 이내. Status: TODO | IN_PROGRESS | BLOCKED | REVIEW | DONE (정상 종료 시 IN_PROGRESS 금지). Progress는 step마다, 나머지는 세션 종료 시 갱신. -->

## Current Phase

01-project-setup — `docs/phases/01-project-setup/PLAN.md`

## Current Task

T1. `.ai/BOOTSTRAP.md`를 수행해 템플릿을 실제 프로젝트로 초기화

## Status

TODO

## Progress

<!-- 현재 Task의 step ≤ 10개. 진행 중인 step 끝에 ← -->
- (Task 시작 전)

## Last Checkpoint

<!-- close commit 직전의 HEAD. `scripts/ai-end.sh --set-checkpoint`가 기록한다. -->
`b3db569`

## Relevant Documents

- `.ai/BOOTSTRAP.md`
- `docs/phases/01-project-setup/PLAN.md`
- `docs/phases/README.md`

## Relevant Source Files

<!-- 디렉터리가 아니라 파일·심볼 단위로: `src/api/users.py:create_user` -->
- (아직 없음)

## Recent Important Changes

<!-- 최근 5개만 -->
- 2026-08-29 템플릿 초기 생성 (ADR-0001). 아직 프로젝트 설명이 반영되지 않았다.
- 2026-08-29 변경 추적·중단 대비·보고 워크플로 추가 (ADR-0002, `scripts/`, `.ai/LOG.md`, `.ai/INBOX.md`)

## Next Action

`.ai/BOOTSTRAP.md`의 Project Description이 채워져 있는지 확인한다. 채워져 있으면 BOOTSTRAP 절차를 수행한다. 비어 있으면 사용자에게 프로젝트 설명을 요청하고 멈춘다.
