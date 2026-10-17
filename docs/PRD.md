# PRD — <프로젝트 이름>

<!--
제품 관점의 요구사항 문서. "무엇을, 왜"를 다루고 "어떻게(구현)"는 docs/ARCHITECTURE.md에 둔다.
- 요구사항마다 ID를 붙여 Phase PLAN의 Task 줄 `Refs:`·테스트·ADR에서 참조한다 (FR-1, NFR-1 ...). 어느 Task·스트림이 맡았는지는 여기 쓰지 않는다 — docs/phases/README.md의 추적 표가 PLAN에서 도출한다.
- ID는 `접두어-n`(0 채움 없음). 번호는 다시 매기지 않는다 — 없앤 요구는 행을 남기고 Priority를 Won't, Acceptance에 "폐기(날짜) — 대체 FR-n".
- Requirement 한 칸 = 검증 가능한 동작 하나, "시스템은 …해야 한다", 두 문장 이내. 상세 조건은 Acceptance, 결정 경위는 Change Log·ADR로.
- 모르는 것은 추정으로 채우지 않는다: 답이 없으면 Open Questions(Q-n), 검증 전 가정이면 Assumptions(A-n) + `[hypothesis]`.
- 요구사항이 바뀌면 이 문서를 먼저 고치고 Change Log에 영향 ID를 적은 뒤, 영향을 받는 Phase PLAN을 갱신한다.
- Status: Draft → Approved. Approved 전에 PRD 검증(규칙 검사 · 유즈케이스 · 시퀀스 · 교차 모델)을 거친다. Approved 이후 변경은 Version을 올린다.
- 선택 절(필요할 때만, 정해진 위치에): Glossary(Problem 앞) · Screens SCR-n · Key Flows(FR 앞) · Exceptions ER-n(FR 뒤) · Data Requirements DR-n(NFR 뒤) · ID Index(Change Log 앞). 300줄을 넘으면 맨 앞에 Reading Guide.
- 전체 작성 규칙·검증 절차: prd-writing 스킬 (~/.agents/skills/prd-writing/).
-->

- Status: Draft
- Version: v1
- Last updated: <YYYY-MM-DD>
- Owner: <이름>
- Source of truth: 이 문서 <!-- 원본이 따로 있으면 경로. 충돌 시 우선순위도 적는다 — 예: 디자인 > 이 문서 > 기획서 -->
- Related: [ARCHITECTURE](ARCHITECTURE.md) · [Phases](phases/README.md)
- Trace: [docs/phases/README.md — Traceability](phases/README.md#traceability) (FR/NFR → Task → 스트림, 생성 표)

## Problem

<해결하려는 문제. 누가, 어떤 상황에서, 무엇 때문에 불편한가.>

지금의 대안과 결함:
- <대안>: <결함>

## Goals

- G-1. <측정 가능한 결과 — 숫자 또는 판정 가능한 상태>
- G-2. <...>

## Target Users

- 1차 — <사용자 유형>: <특징·상황·기대>
- 2차 — <사용자 유형>: <...>

## User Stories

- US-1. <사용자>로서 <목적>을 위해 <행동>하고 싶다.
- US-2. <...>

## Scope

| 릴리스 | 포함 | 진입 조건 |
|--------|------|-----------|
| R1     | <FR-1~FR-n> | — |

## Functional Requirements

우선순위 — Must: 이 릴리스 없이는 출시 불가 · Should: 시간 허용 시 · Could: 확장 · Won't: 이번에 제외(사유를 Acceptance에).

| ID   | Requirement             | Priority | Acceptance                 | Related |
|------|-------------------------|----------|----------------------------|---------|
| FR-1 | <시스템은 ...해야 한다> | Must     | <관찰 가능한 합격 조건>    | US-1    |
| FR-2 | <...>                   | Should   | <...>                      | US-2    |

<!-- 영역이 여럿이면 ### 소제목으로 표를 나눈다. 표 머리는 같게. 구현 방식(프레임워크·라이브러리·DB 제품명)은 적지 않는다 — 외부에서 강제된 기술은 Constraints로. -->

## Non-functional Requirements

| ID    | Category | Requirement                          | Target           | Verification |
|-------|----------|--------------------------------------|------------------|--------------|
| NFR-1 | <성능·보안·가용성·접근성·호환성 등> | <...> | <수치 또는 기준> | <측정 방법>  |

## Constraints

- C-1. <기술·법·일정·예산·플랫폼·외부 결정 등 바꿀 수 없는 제약>

## Assumptions

- A-1. <검증 전 사실로 놓는 것> `[hypothesis]` — 검증: <방법>

## Non-goals

- <이번 범위에서 의도적으로 제외하는 것> — <이유 / 관련 ID>

## Success Criteria

- SC-1 (G-1). <출시·완료 판정 기준 — 관련 FR/NFR>

<!-- 모든 G-n에 SC가 하나 이상. -->

## Open Questions

| ID  | 질문  | 막고 있는 것 | 결정 주체 | 필요 시점 | 상태 |
|-----|-------|--------------|-----------|-----------|------|
| Q-1 | <...> | <FR-n>       | <사람>    | <날짜 또는 Phase> | open |

<!-- 닫히면 행을 지우지 않고 상태를 "closed(날짜) → FR-n"으로 바꾼다. -->

## Change Log

| 날짜 | 버전 | 변경 | 영향 ID |
|------|------|------|---------|
| <YYYY-MM-DD> | v1 | 최초 작성 | — |
