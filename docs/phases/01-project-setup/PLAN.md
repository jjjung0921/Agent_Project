# Phase 01 — project-setup

<!-- 템플릿에 포함된 첫 Phase다. 초기화(.ai/BOOTSTRAP.md) 시 프로젝트에 맞게 Scope·Tasks를 조정한다. -->

- Status: PLANNED
- Start: <YYYY-MM-DD> · End: <YYYY-MM-DD>

## Goal

템플릿이 실제 프로젝트가 되어, 어떤 Agent든 `AGENTS.md`의 Commands로 test/typecheck/lint를 실행할 수 있고 첫 기능 Phase를 시작할 준비가 끝난 상태.

## Motivation

이후 모든 Phase가 같은 규칙·spec·검증 명령 위에서 진행되려면 그 기반이 먼저 있어야 한다. 이 Phase가 끝나기 전에는 기능 구현을 시작하지 않는다.

## Scope

- 템플릿 placeholder를 프로젝트 내용으로 교체 (`AGENTS.md`, `README.md`, `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/api/`)
- 기술 스택·핵심 도구 결정과 ADR 기록
- 저장소 구성 확정(단일 패키지 또는 구성요소별 디렉터리)과 제약 층 구성: 패키지 매니저, 포맷터·린터·타입체커·테스트 러너 설정, 버전 고정, lockfile
- 최소 실행 가능한 스켈레톤과 테스트 1개 이상
- 전체 개발 계획을 Phase 목록으로 정리

## Out of Scope

- 실제 기능(비즈니스 로직) 구현
- 배포 인프라·운영 환경 구성 (필요하면 별도 Phase)
- 성능 최적화

## Dependencies

- 개발자가 제공하는 프로젝트 설명 (`.ai/BOOTSTRAP.md`의 Project Description)
- 스택 선택에 대한 개발자 승인

## Tasks

<!-- 완료 시 [x]로 바꾸고 완료 커밋 SHA를 끝에 적는다: (commit abc1234) -->

- [ ] T1. `.ai/BOOTSTRAP.md` 수행 — Done when: BOOTSTRAP의 Output Checklist 전부 충족
- [ ] T2. 스택·핵심 도구 결정 후 ADR(다음 번호) 작성 — Done when: ADR Status가 Accepted
- [ ] T3. 제약 층 구성 (T1에서 적은 설정 파일·버전 고정·lockfile·`.gitignore` 목록대로) — Done when: `AGENTS.md` Commands의 install/test/typecheck/lint가 경고 없이 성공하고 설정 파일이 커밋됨
- [ ] T4. 최소 실행 스켈레톤 + 테스트 — Done when: Run 명령이 동작하고 테스트 1개 이상이 통과
- [ ] T5. (권장) CI에서 install/test/typecheck/lint 실행 — Done when: 기본 브랜치 push 시 자동 실행. `ai-end.sh`는 테스트를 대신 돌리지 않으므로 CI가 최종 관문
- [ ] T6. Phase 02 PLAN 초안 작성 — Done when: `docs/phases/README.md`에 등록되고 `.ai/CURRENT.md`가 Phase 02를 가리킴

## Relevant Specifications

- `docs/PRD.md` — 전체 (초안 작성 대상)
- `docs/ARCHITECTURE.md` — 전체 (초안 작성 대상)
- `docs/decisions/_template.md`
- `.ai/BOOTSTRAP.md`

## Acceptance Criteria

- [ ] AC1. `AGENTS.md`, `README.md`, `docs/PRD.md`, `docs/ARCHITECTURE.md`에 placeholder(`<...>`)와 작성 지침 주석이 남아 있지 않다
- [ ] AC2. `AGENTS.md` Commands의 모든 명령이 클린 체크아웃에서 경고 없이 성공한다 (typecheck·lint는 경고=실패 옵션으로 실행)
- [ ] AC3. 스택 결정 ADR이 존재하고 `docs/ARCHITECTURE.md`가 이를 참조한다
- [ ] AC4. `docs/phases/README.md`에 전체 Phase 목록이 있고 Phase 02 PLAN이 존재한다
- [ ] AC5. `.ai/BOOTSTRAP.md`가 삭제되었다
- [ ] AC6. 툴체인 버전 고정 파일, lockfile, 도구 설정 파일이 커밋되어 있고 `.gitignore`에 언어 항목이 있다. 구성요소가 여럿이면 각 디렉터리에 있고 루트 Makefile/justfile이 Commands를 묶는다
- [ ] AC7. `AGENTS.md` Rule 13 뒤에 언어별 규칙이 3줄 이내로 있고 마지막 줄이 허용 언어 목록이며, 스택 ADR에 도구 선택 이유가 있다

## Validation Plan

- AC1: `grep -n "<" AGENTS.md README.md docs/PRD.md docs/ARCHITECTURE.md`의 출력에 placeholder·주석이 없는지 눈으로 확인
- AC2: 새로 클론한 디렉터리에서 Commands를 Install → Test → Typecheck → Lint 순으로 실행
- AC3–AC7: 해당 파일의 존재·내용 확인. AC6은 새 클론에서 Install만으로 같은 도구 버전이 잡히는지로 확인
