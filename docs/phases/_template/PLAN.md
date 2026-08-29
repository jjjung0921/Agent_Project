# Phase NN — <phase-name>

<!--
새 Phase 시작 시 작성한다. Scope가 곧 AI의 작업 허용 범위이므로 구체적으로 적는다.
Task는 한 세션(또는 한 PR) 안에 끝나고 독립적으로 검증 가능한 크기로 나눈다.
-->

- Status: PLANNED | IN_PROGRESS | DONE
- Start: <YYYY-MM-DD> · End: <YYYY-MM-DD>

## Goal

<이 Phase가 끝났을 때 참이 되어야 하는 한 문장.>

## Motivation

<왜 지금 이 Phase인가. 어떤 요구사항(FR/NFR)·문제를 해결하는가.>

## Scope

- <포함되는 작업·컴포넌트·기능>

## Out of Scope

- <이번 Phase에서 하지 않는 것. 하고 싶어지기 쉬운 것일수록 명시한다>

## Dependencies

- <선행 Phase, 외부 서비스, 개발자 결정 대기 항목>

## Tasks

<!-- 상태는 체크박스로 관리한다. 진행 중인 Task는 .ai/CURRENT.md의 Current Task와 일치해야 한다. -->

- [ ] T1. <작업> — Done when: <검증 가능한 완료 조건>
- [ ] T2. <...>

## Relevant Specifications

- `docs/PRD.md` — <FR-x, NFR-y>
- `docs/ARCHITECTURE.md` — <해당 섹션>
- `docs/api/openapi.yaml` — <해당 경로>
- `docs/decisions/ADR-xxxx-*.md`

## Acceptance Criteria

- [ ] AC1. <외부에서 관찰 가능한 조건>
- [ ] AC2. <...>

## Validation Plan

- <자동 테스트: 어떤 테스트가 어떤 AC를 덮는가>
- <수동 확인: 절차와 기대 결과>
- <NFR 검증: 성능·보안 등의 측정 방법>
