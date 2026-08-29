# Bootstrap — 템플릿을 실제 프로젝트로 초기화

<!-- 새 프로젝트를 시작할 때 한 번 수행하는 절차다. 초기화가 끝나면 이 파일을 삭제한다. -->

너는 이 프로젝트의 초기 구조를 설계하는 Software Architect이자 AI Agent Workflow Designer다.

이 저장소는 여러 AI Agent가 교대로 작업하기 위한 템플릿에서 생성되었다. 작업 규칙은 `AGENTS.md`에 있고, 각 문서의 작성 지침은 문서 안의 `<!-- -->` 주석에 있다. 아래 Project Description을 바탕으로 템플릿을 실제 프로젝트로 바꿔라.

## Project Description

<여기에 프로젝트 설명을 입력한다: 무엇을 만드는지, 누구를 위한 것인지, 핵심 기능, 기술 스택(정해졌다면), 제약, 일정, 이미 결정된 사항.>

## Procedure

1. `AGENTS.md`를 읽는다. 그 규칙은 이 절차에도 적용된다 (특히 Developer Changes, Scope Discipline).
2. Project Description을 읽는다. 부족한 정보는 **합리적인 최소 가정**으로 채우되, 모든 가정을 `.ai/HANDOFF.md`의 Unverified Assumptions에 기록한다. 스택·배포 형태처럼 프로젝트 방향을 좌우하는 가정은 사용자에게 먼저 묻는다.
3. 다음 파일의 placeholder(`<...>`)와 작성 지침 주석을 프로젝트 내용으로 교체한다.
   - `AGENTS.md` — Project, Commands, (필요 시) Coding Convention의 언어별 규칙
   - `README.md` — 템플릿 소개를 프로젝트 소개(무엇을·왜·실행 방법)로 교체
   - `docs/PRD.md` — 요구사항 (ID 부여)
   - `docs/ARCHITECTURE.md` — 초기 구조 (미확정 부분은 "TBD (ADR-xxxx 예정)")
   - `docs/api/openapi.yaml` — REST API가 있으면 초기 계약, 없으면 `docs/api/` 삭제 후 참조 제거
4. 스택·핵심 구조 결정을 `docs/decisions/ADR-0002-*.md`부터 기록한다 (`_template.md` 사용). 사소한 결정은 ADR로 만들지 않는다.
5. `docs/phases/01-project-setup/PLAN.md`를 프로젝트에 맞게 조정하고, 전체 개발 계획을 Phase로 나눠 `docs/phases/README.md`에 등록한다. 처음 2~3개 Phase만 상세 PLAN을 쓰고 나머지는 목록만 둔다.
6. 프로젝트 성격상 불필요한 파일은 삭제한다. 필요한 spec(DB 스키마, 이벤트 스키마, UI 스펙 등)이 있으면 `docs/` 아래에 추가하고 `AGENTS.md`의 Repository Map·Source of Truth Priority에 반영한다. 중복된 정보원을 만들지 않는다.
7. `.ai/CURRENT.md`를 갱신한다 (Phase 01, 다음 Task, Status, Relevant Documents).
8. `.ai/HANDOFF.md`를 작성한다 (가정 포함).
9. 이 파일(`.ai/BOOTSTRAP.md`)을 삭제하고, `README.md`·`.ai/CURRENT.md`·Phase 01 PLAN에서 BOOTSTRAP 참조를 제거한다.
10. 변경 전체를 하나의 커밋으로 남긴다: `chore: bootstrap project from template`.

## Output Checklist

- [ ] `AGENTS.md`에 placeholder와 작성 지침 주석이 없다
- [ ] `docs/PRD.md`, `docs/ARCHITECTURE.md`가 Project Description과 모순되지 않는다
- [ ] 모든 가정이 `.ai/HANDOFF.md`의 Unverified Assumptions에 있다
- [ ] Phase 목록이 `docs/phases/README.md`에 있고 `.ai/CURRENT.md`가 다음 Task를 가리킨다
- [ ] `.ai/BOOTSTRAP.md`가 삭제되었고 남은 참조가 없다
