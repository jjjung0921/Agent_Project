# Phases

<!--
전체 개발 계획의 Phase 목록. 순서·목표·상태만 적고, 상세는 각 디렉터리의 PLAN.md / RESULT.md에 둔다.
- Status: PLANNED | IN_PROGRESS | DONE | CANCELLED — Phase 시작·종료 시에만 갱신한다. 지금 진행 중인 Task는 .ai/CURRENT.md가 기준이다.
- 새 Phase 추가: `_template/`를 `NN-<phase-name>/`으로 복사하고 표에 한 줄 추가한다. 번호는 두 자리, 이름은 kebab-case.
-->

| #  | Phase                                        | Goal                                                              | Status  | Result |
|----|----------------------------------------------|-------------------------------------------------------------------|---------|--------|
| 01 | [project-setup](01-project-setup/PLAN.md)    | 템플릿을 실제 프로젝트로 초기화하고 검증 명령·개발 환경을 갖춘다 | PLANNED | —      |

## Phase Rules

- 한 Phase는 독립적으로 검증 가능한 하나의 결과를 낸다. 결과를 한 문장으로 말할 수 없으면 나눈다.
- Phase 종료 조건: PLAN의 Acceptance Criteria 전부 충족 + Validation Plan 수행 + RESULT.md 작성 + `phase/NN` 태그 (`git tag -a phase/01 -m "..."`).
- 진행 중인 Phase는 하나만 둔다. 순서를 바꿔야 하면 PLAN의 Dependencies를 먼저 확인한다.
