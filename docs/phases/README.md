# Phases

<!--
전체 개발 계획의 Phase 목록. 순서·목표·상태만 적고, 상세는 각 디렉터리의 PLAN.md / RESULT.md에 둔다.
- Status: PLANNED | IN_PROGRESS | DONE | CANCELLED — Phase 시작·종료 시에만 갱신한다. 지금 진행 중인 Task는 .ai/CURRENT.md가 기준이다.
- 새 Phase 추가: `_template/`를 `NN-<phase-name>/`으로 복사하고 표에 한 줄 추가한다. 번호는 두 자리, 이름은 kebab-case.
-->

| #  | Phase                                        | Goal                                                              | Status  | Result |
|----|----------------------------------------------|-------------------------------------------------------------------|---------|--------|
| 01 | [project-setup](01-project-setup/PLAN.md)    | 템플릿을 실제 프로젝트로 초기화하고 검증 명령·개발 환경을 갖춘다 | PLANNED | —      |

## Traceability

<!--
요구사항 → Task 추적 표. 각 PLAN 의 Task 줄 `Refs:` 에서 `scripts/ai-trace.sh` 가 생성한다 — 손으로 고치지 않는다 (`ai-end.sh` 가 어긋나면 FAIL).
- Ref 열: PRD 의 FR/NFR(PRD 표 순서) → 그 외 참조(ADR 등) → `none`(요구사항 없는 Task) → `—`(Refs 가 없는 Task — PLAN 에 적어야 한다). `— 미배정` = 아직 어떤 Task 도 맡지 않은 요구사항.
- PRD 는 이 표를 링크만 한다. 상태(Task·commit)는 spec 에 쓰지 않는다 — PLAN 에서 도출한다.
-->

<!-- trace:begin -->
| Ref | Phase/Task | 상태 | commit |
|-----|------------|------|--------|
| FR-1 | — 미배정 | | |
| FR-2 | — 미배정 | | |
| NFR-1 | — 미배정 | | |
| none | [01/T1](01-project-setup/PLAN.md) — `.ai/BOOTSTRAP.md` 수행 | open |  |
| none | [01/T2](01-project-setup/PLAN.md) — 스택·핵심 도구 결정 후 ADR(다음 번호) 작성 | open |  |
| none | [01/T3](01-project-setup/PLAN.md) — 제약 층 구성 (T1에서 적은 설정 파일·버전 고정·lockfile·`.gitignore` 목록대로) | open |  |
| none | [01/T4](01-project-setup/PLAN.md) — 최소 실행 스켈레톤 + 테스트 | open |  |
| none | [01/T5](01-project-setup/PLAN.md) — (권장) CI에서 install/test/typecheck/lint 실행 | open |  |
| none | [01/T6](01-project-setup/PLAN.md) — Phase 02 PLAN 초안 작성 | open |  |
<!-- trace:end -->

## Phase Rules

- 한 Phase는 독립적으로 검증 가능한 하나의 결과를 낸다. 결과를 한 문장으로 말할 수 없으면 나눈다.
- Phase 종료 조건: PLAN의 Acceptance Criteria 전부 충족 + Validation Plan 수행 + RESULT.md 작성 + `phase/NN` 태그 (`git tag -a phase/01 -m "..."`).
- 진행 중인 Phase는 하나만 둔다. 순서를 바꿔야 하면 PLAN의 Dependencies를 먼저 확인한다.
