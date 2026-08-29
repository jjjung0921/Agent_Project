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
- `.ai/CURRENT.md` 현재 상태·checkpoint · `.ai/HANDOFF.md` Agent 간 인수인계 · `.ai/LOG.md` 개발자 보고 · `.ai/INBOX.md` 개발자 지시 · `.ai/notes/` 임시 메모 (source of truth 아님)
- `scripts/ai-start.sh` 시작 점검 · `scripts/ai-end.sh` 종료 점검 · `src/` 구현 · `tests/` 테스트

## Core Principles

1. 저장소가 기억이다. 대화 기억에 의존하지 않고 상태·의도·계획·규칙을 파일과 커밋에 남긴다.
2. Spec이 대화보다 우선한다. 요구사항·architecture·API는 `docs/`가 source of truth다.
3. 현재 Phase의 Scope 안에서만 작업한다.
4. 작게, 검증 가능하게, 자주 커밋한다. 세션이 언제 끊겨도 저장소만으로 재개할 수 있어야 한다.
5. 개발자의 직접 변경이 AI의 판단보다 우선한다.

## Coding Convention

- 포맷·린트는 도구 설정(`.editorconfig`, <linter/formatter 설정 파일>)을 따른다. 도구가 정하지 않은 스타일은 주변 코드를 따른다.
- 모듈 경계와 의존성 방향은 `docs/ARCHITECTURE.md`를 따른다. 위반이 필요하면 먼저 ADR을 제안한다.
- 공개 인터페이스(API, 스키마, CLI)를 바꾸면 해당 spec을 같은 커밋에서 갱신한다.
- 새 기능·버그 수정에는 대응하는 테스트를 `tests/`에 같은 커밋으로 추가한다.
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

1. 사용자가 직접 내린 명시적 지시 (대화 또는 `.ai/INBOX.md`)
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
2. `.ai/CURRENT.md` — 현재 Phase·Task·Status·Progress·Next Action·Last Checkpoint
3. `.ai/HANDOFF.md` — 직전 세션의 상태와 가정
4. `scripts/ai-start.sh` 출력 — checkpoint 이후의 커밋, uncommitted 변경, INBOX
5. `.ai/CURRENT.md`가 지정한 Relevant Documents와 Relevant Source Files
6. 현재 Phase의 `PLAN.md`
7. 필요할 때만 `docs/ARCHITECTURE.md`, 관련 ADR, `docs/api/`, `docs/PRD.md`

과거 Phase 문서, 무관한 ADR, `.ai/notes/`, `.ai/LOG.md`의 이전 항목, checkpoint 이전의 커밋은 이유가 있을 때만 본다.

## Change Tracking

- `.ai/CURRENT.md`의 Last Checkpoint는 Agent가 마지막으로 처리한 커밋이다. 그 이후만 확인한다: `scripts/ai-start.sh` (= `git log <checkpoint>..HEAD` + `git status` + INBOX).
- `Agent:` trailer가 없는 커밋과 uncommitted 변경은 개발자 변경이다. 되돌리지 않는다. diff를 읽고 영향을 받는 spec·PLAN·HANDOFF에 반영하며, 무엇을 어떻게 반영했는지 `.ai/LOG.md`의 Developer changes에 적는다.
- 의도가 불분명하면 그대로 두고 HANDOFF의 Unverified Assumptions에 적은 뒤 사용자에게 확인한다. 구조·계획에 영향을 주는 개발자 결정은 ADR 또는 PLAN에 반영한다.
- `.ai/INBOX.md`의 항목은 사용자의 직접 지시다. 처리한 항목은 삭제하고 반영처와 결과를 LOG에 적는다. 처리하지 못한 항목은 남기고 이유를 LOG에 적는다.

## Commit Policy

- 단위: Task 완료마다 1커밋. 한 세션에 끝나지 않는 Task는 step마다 WIP 커밋. 커밋하지 않은 변경을 남긴 채 세션을 끝내지 않는다.
- 메시지: `<type>(<scope>): <summary>` — type은 feat, fix, refactor, docs, test, chore, wip. 본문에 무엇을·왜. WIP는 미완료 사항과 테스트 상태를 본문에 적는다.
- Agent 커밋에는 trailer를 붙인다 (`git commit --trailer "Agent: ..." --trailer "Task: ..."`):
  - `Agent: <이름>` — claude-code, codex, gemini-cli, chatgpt 등 소문자 kebab-case
  - `Task: <phase>/<task>` — 예: `01/T3`. Task 밖 작업은 `01/-`
- Task를 끝낸 커밋의 SHA를 PLAN.md의 Task 줄에 적는다: `- [x] T3. ... (commit abc1234)`
- 세션의 마지막 커밋은 close commit — `docs(ai): close session — <요약>` — 으로 `.ai/`와 docs 갱신만 담는다.
- Phase 완료 시 `phase/NN` 태그를 만든다 (`git tag -a phase/01 -m "..."`). push된 커밋은 rewrite하지 않는다.
- 특정 Task의 커밋만 보기: `git log --grep='Task: 01/T3'`

## Start of Work

1. `AGENTS.md`, `.ai/CURRENT.md`, `.ai/HANDOFF.md` 확인
2. `scripts/ai-start.sh` 실행 — checkpoint 이후 커밋(Agent/Developer 구분), uncommitted 변경, INBOX, 중단 여부
3. Resume: CURRENT.md의 Status가 `IN_PROGRESS`면 직전 세션이 비정상 종료된 것이다. uncommitted diff가 HANDOFF의 Work In Progress·CURRENT의 Progress와 일치하면 그 step부터 이어서 하고, 아니면 개발자 변경으로 취급한다. 어느 쪽이든 test를 먼저 실행해 현재 상태를 확인한다.
4. 개발자 변경과 INBOX 반영 (Change Tracking)
5. 현재 Phase `PLAN.md`에서 Task·Acceptance Criteria 확인, 필요한 spec·코드 확인
6. 이번 세션의 범위를 정한다. CURRENT.md의 Status를 `IN_PROGRESS`로, Progress에 step 목록을 쓰고, HANDOFF의 Goal·Work In Progress를 초안으로 갱신한다 (handoff-first)
7. 그 후에 구현을 시작한다

## During Work

중단(토큰·시간 소진, 오류)은 언제든 일어난다고 가정한다.

- step이 끝날 때마다 CURRENT.md의 Progress를 갱신한다. 긴 Task는 step마다 WIP 커밋한다.
- 대규모 리팩터링·마이그레이션 같은 큰 변경 전에 HANDOFF를 먼저 갱신한다.
- 파일은 필요한 부분만 읽고 긴 출력은 요약해 문서에 남긴다. context가 길어졌다고 판단되면 즉시 WIP 커밋과 HANDOFF 갱신을 하고 계속한다.
- Task가 이번 세션에 끝나지 않을 것 같으면 억지로 끝내지 말고 End of Work로 넘어간다.

## End of Work

1. Commands의 test → typecheck → lint 실행. 실패 상태로 끝내지 않는다. 불가피하면 HANDOFF와 LOG에 명시한다.
2. 작업 커밋 (Commit Policy). PLAN.md의 Task 체크박스와 commit SHA 갱신.
3. `.ai/CURRENT.md` 갱신 — Status(`IN_PROGRESS`로 남기지 않는다: TODO / REVIEW / BLOCKED / DONE), Progress, Recent Important Changes, Next Action, Last Checkpoint = 현재 HEAD (`scripts/ai-end.sh --set-checkpoint`)
4. `.ai/HANDOFF.md` 갱신 (모든 항목, 덮어쓰기)
5. `.ai/LOG.md` 맨 위에 이번 세션 항목 추가 (개발자 보고)
6. 장기 영향이 있는 결정이 있었다면 ADR 추가. Phase가 끝났다면 `RESULT.md` 작성, `docs/phases/README.md` 갱신, `phase/NN` 태그, CURRENT.md를 다음 Phase로 이동
7. `scripts/ai-end.sh`로 점검한 뒤 close commit

## Verification

- 코드 변경은 test/typecheck/lint를 통과해야 완료다.
- 실행하지 않은 검증을 완료로 적지 않는다. 검증하지 못한 것은 "미검증"으로 HANDOFF와 LOG에 적는다.
- 재현 가능한 검증 절차(명령, 입력, 기대 결과)를 Phase `PLAN.md`의 Validation Plan과 `RESULT.md`에 남긴다.

## Scope Discipline

- 현재 Phase `PLAN.md`의 Scope / Out of Scope를 따른다. Scope 밖 문제는 고치지 말고 HANDOFF의 Known Problems에 적는다.
- 요청받지 않은 리팩터링, 의존성 추가, 파일 구조 변경, spec 변경을 하지 않는다. 필요하면 먼저 제안한다.
- Spec(PRD, ARCHITECTURE, API)을 바꿔야 하는 작업은 사용자 승인 후 spec을 먼저 갱신하고 구현한다.
