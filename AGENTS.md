# AGENTS.md

모든 AI Agent(Claude Code, Codex, Gemini CLI, ChatGPT 등)와 개발자가 공유하는 최소 공통 규칙이다.
이 파일은 짧게 유지한다. 상세 설계는 `docs/`에, 현재 작업 상태는 `.ai/`에 있으며 여기에 복사하지 않는다.

## Project

- Name: <프로젝트 이름>
- Summary: <누구를 위한 무엇인지 한 줄>
- Stack: <언어 / 프레임워크 / 런타임 / 패키지 매니저>

<!-- 템플릿 초기화(.ai/BOOTSTRAP.md) 시 채운다. 상세 설명은 README.md, 요구사항은 docs/PRD.md에 둔다. -->

## Repository Map

- `docs/PRD.md` 요구사항 · `docs/ARCHITECTURE.md` 현재 구조 · `docs/api/` API spec · `docs/decisions/` ADR · `docs/phases/` Phase 계획/결과
- `.ai/CURRENT.md` 현재 상태 · `.ai/HANDOFF.md` 인수인계 · `.ai/notes/` 임시 메모 (source of truth 아님)
- `src/` 구현 · `tests/` 테스트

## Core Principles

1. 저장소가 기억이다. 대화 기억에 의존하지 않고 상태·의도·계획·규칙을 파일에 남긴다.
2. Spec이 대화보다 우선한다. 요구사항·architecture·API는 `docs/`가 source of truth다.
3. 현재 Phase의 Scope 안에서만 작업한다.
4. 작게, 검증 가능하게 끝낸다. 한 Task는 test/typecheck/lint를 통과하는 단위다.
5. 개발자의 직접 변경이 AI의 판단보다 우선한다.

## Coding Convention

- 포맷·린트는 도구 설정(`.editorconfig`, <linter/formatter 설정 파일>)을 따른다. 도구가 정하지 않은 스타일은 주변 코드를 따른다.
- 모듈 경계와 의존성 방향은 `docs/ARCHITECTURE.md`를 따른다. 위반이 필요하면 먼저 ADR을 제안한다.
- 공개 인터페이스(API, 스키마, CLI)를 바꾸면 해당 spec을 같은 변경에서 갱신한다.
- 새 기능·버그 수정에는 대응하는 테스트를 `tests/`에 같은 변경으로 추가한다.
- 커밋 메시지: `<type>(<scope>): <summary>` — type은 feat, fix, refactor, docs, test, chore. 본문에 Phase/Task를 적는다.
- 비밀값(.env, 키, 토큰)과 생성물(빌드 산출물, 캐시)은 커밋하지 않는다.

<!-- 스택 확정 후 언어별 규칙(타입 명시, 예외 처리, 로깅 등)을 5줄 이내로 추가한다. -->

## Commands

| Purpose   | Command                |
|-----------|------------------------|
| Install   | `<install command>`    |
| Test      | `<test command>`       |
| Typecheck | `<typecheck command>`  |
| Lint      | `<lint command>`       |
| Run       | `<run command>`        |

<!-- 템플릿 초기화 시 채운다. 해당 없는 항목은 N/A로 명시한다. -->

## Source of Truth Priority

정보가 충돌하면 위에 있는 것이 우선한다.

1. 사용자가 지금 직접 내린 명시적 지시
2. Executable specification — tests, type system, schemas, `docs/api/`
3. 현재 source code
4. `docs/decisions/` (ADR)
5. `docs/ARCHITECTURE.md`
6. `docs/PRD.md`
7. 현재 Phase의 `PLAN.md`
8. `.ai/CURRENT.md`
9. `.ai/HANDOFF.md`
10. 과거 AI 대화

코드가 spec을 위반하는 것으로 보이면 코드를 정답으로 간주하지 않는다. inconsistency로 보고하고 사용자의 판단을 기다린다.

## Context Loading

모든 문서를 읽지 않는다. 아래 순서로, 필요한 만큼만 읽는다.

1. `AGENTS.md` (이 파일)
2. `.ai/CURRENT.md` — 현재 Phase·Task·Next Action
3. `.ai/CURRENT.md`가 지정한 Relevant Documents와 Relevant Source Files
4. 현재 Phase의 `PLAN.md`
5. 필요할 때만 `docs/ARCHITECTURE.md`, 관련 ADR, `docs/api/`, `docs/PRD.md`

과거 Phase 문서, 무관한 ADR, `.ai/notes/`는 이유가 있을 때만 읽는다.

## Developer Changes

- 작업 시작 시 `git status`, `git diff`, `git log --oneline -10`을 확인한다.
- AI가 만들지 않은 변경(uncommitted 또는 최근 commit)은 의도된 developer modification으로 취급한다.
- 되돌리지 않는다. 의도가 불분명하면 그대로 두고 `.ai/HANDOFF.md`의 Unverified Assumptions에 적은 뒤 사용자에게 확인한다.
- 개발자의 결정이 구조·계획에 영향을 주면 ADR 또는 Phase `PLAN.md`에 반영한다.

## Start of Work

1. `AGENTS.md`, `.ai/CURRENT.md` 확인
2. `git status` / `git diff` / 최근 log 확인 (Developer Changes)
3. 현재 Phase `PLAN.md`에서 Task·Acceptance Criteria 확인
4. 필요한 spec과 관련 코드 확인
5. 이번 세션의 작업 범위를 정하고 `.ai/CURRENT.md`의 Status 갱신
6. 그 후에 구현을 시작한다

## End of Work

1. Commands의 test → typecheck → lint 실행. 실패 상태로 끝내지 않는다. 불가피하면 HANDOFF에 명시한다.
2. `.ai/CURRENT.md` 갱신 (Status, Recent Important Changes, Next Action)
3. `.ai/HANDOFF.md` 갱신 (모든 항목, 이전 내용은 덮어쓴다)
4. 현재 Phase `PLAN.md`의 Task 체크박스 갱신
5. 장기 영향이 있는 결정이 있었다면 `docs/decisions/`에 ADR 추가
6. Phase가 끝났다면 `RESULT.md` 작성, `docs/phases/README.md` 상태 갱신, `.ai/CURRENT.md`를 다음 Phase로 이동

## Verification

- 코드 변경은 test/typecheck/lint를 통과해야 완료다.
- 실행하지 않은 검증을 완료로 적지 않는다. 검증하지 못한 것은 "미검증"으로 HANDOFF에 적는다.
- 재현 가능한 검증 절차(명령, 입력, 기대 결과)를 Phase `PLAN.md`의 Validation Plan과 `RESULT.md`에 남긴다.

## Scope Discipline

- 현재 Phase `PLAN.md`의 Scope / Out of Scope를 따른다. Scope 밖 문제는 고치지 말고 HANDOFF의 Known Problems에 적는다.
- 요청받지 않은 리팩터링, 의존성 추가, 파일 구조 변경, spec 변경을 하지 않는다. 필요하면 먼저 제안한다.
- Spec(PRD, ARCHITECTURE, API)을 바꿔야 하는 작업은 사용자 승인 후 spec을 먼저 갱신하고 구현한다.
