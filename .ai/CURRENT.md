# Current State

<!--
항상 짧게 유지한다. 전체 프로젝트 상태를 복사하지 않는다.
- step이 끝날 때마다 Progress를, 세션 종료 시 나머지를 갱신한다.
- Status 값: TODO | IN_PROGRESS | BLOCKED | REVIEW | DONE — 정상 종료 시 IN_PROGRESS로 남기지 않는다.
  다음 세션이 IN_PROGRESS를 보면 "중단된 세션"으로 판단하고 Resume 절차(AGENTS.md)를 따른다.
-->

## Current Phase

01-project-setup — `docs/phases/01-project-setup/PLAN.md`

## Current Task

T1. `.ai/BOOTSTRAP.md`를 수행해 템플릿을 실제 프로젝트로 초기화

## Status

TODO

## Progress

<!-- 현재 Task의 step 체크리스트. 진행 중인 step 끝에 ← 를 붙인다. Task가 바뀌면 지우고 다시 쓴다. -->

- (Task 시작 전)

## Last Checkpoint

<!-- Agent가 마지막으로 처리한 커밋. scripts/ai-start.sh가 이 값 이후의 변경만 보여준다. close commit 직전에 `scripts/ai-end.sh --set-checkpoint`로 HEAD를 기록한다. -->

`<sha>`

## Relevant Documents

- `.ai/BOOTSTRAP.md`
- `docs/phases/01-project-setup/PLAN.md`
- `docs/phases/README.md`

## Relevant Source Files

- (아직 없음)

## Recent Important Changes

- 2026-08-29 템플릿 초기 생성 (ADR-0001). 아직 프로젝트 설명이 반영되지 않았다.

## Next Action

`.ai/BOOTSTRAP.md`의 Project Description이 채워져 있는지 확인한다. 채워져 있으면 BOOTSTRAP 절차를 수행한다. 비어 있으면 사용자에게 프로젝트 설명을 요청하고 멈춘다.
