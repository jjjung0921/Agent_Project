# AGENTS.md

모든 AI Agent(Claude Code, Codex, Gemini CLI, ChatGPT 등)와 개발자가 공유하는 공통 규칙이다. 짧게 유지한다.
장기 지식은 `docs/`, 작업 상태는 `.ai/`에 있으며 여기에 복사하지 않는다. 도구가 이 파일을 이미 로드했다면(CLAUDE.md·GEMINI.md import) 다시 읽지 않는다.

## Project

- Name: <프로젝트 이름>
- Summary: <누구를 위한 무엇인지 한 줄>
- Stack: <언어 / 프레임워크 / 런타임 / 패키지 매니저>

<!-- 템플릿 초기화(.ai/BOOTSTRAP.md) 시 채운다. 상세 설명은 README.md, 요구사항은 docs/PRD.md에 둔다. -->

## Repository Map

- `docs/PRD.md` 요구사항 · `docs/ARCHITECTURE.md` 현재 구조 · `docs/api/` API spec · `docs/decisions/` ADR · `docs/phases/` Phase 계획/결과
- `.ai/CURRENT.md` 현재 상태·checkpoint · `.ai/HANDOFF.md` Agent 간 인수인계 · `.ai/LOG.md` 개발자 보고 · `.ai/INBOX.md` 개발자 지시 · `.ai/notes/` 임시 메모 (source of truth 아님)
- `scripts/ai-start.sh` 시작 절차 안내 · `scripts/ai-end.sh` 종료 점검 · `src/` 구현 · `tests/` 테스트

<!-- src/·tests/는 단일 패키지 기본값이다. backend/frontend/db/infra처럼 구성요소가 여럿이면 초기화 시 이 줄을 구성요소 목록으로 바꾼다 (.ai/BOOTSTRAP.md의 Layout). -->

## Rules

1. **Memory** — 저장소가 기억이다. 상태·의도·계획·규칙은 파일과 커밋에 남기고, 대화 기억에 의존하지 않는다.
2. **Truth** — 정보가 충돌하면 이 순서로 우선한다: ① 사용자의 직접 지시(대화·`.ai/INBOX.md`) ② tests·type system·schemas·`docs/api/` ③ 현재 코드 ④ ADR ⑤ `docs/ARCHITECTURE.md` ⑥ `docs/PRD.md` ⑦ 현재 Phase `PLAN.md` ⑧ `.ai/CURRENT.md` ⑨ `.ai/HANDOFF.md` ⑩ 과거 대화. 코드가 spec을 위반해 보이면 코드를 정답으로 보지 말고 inconsistency로 보고한다.
3. **Loading** — 필요한 것만 읽는다: 이 파일 → `.ai/CURRENT.md` → `.ai/HANDOFF.md` → `scripts/ai-start.sh` 출력 → CURRENT가 지정한 문서·파일 → 현재 `PLAN.md`. ARCHITECTURE·ADR·PRD·과거 Phase·`.ai/notes/`·LOG의 이전 항목·checkpoint 이전 커밋은 이유가 있을 때만 본다.
4. **Developer changes** — `Agent:` trailer가 없는 커밋과 uncommitted 변경은 개발자 변경이다. 되돌리지 않는다. diff를 읽고 spec·PLAN·HANDOFF에 반영하며 `.ai/LOG.md`의 Developer changes에 기록한다. 의도가 불분명하면 그대로 두고 HANDOFF의 Unverified Assumptions에 적은 뒤 묻는다.
5. **Inbox** — `.ai/INBOX.md`의 항목은 사용자의 직접 지시다. 처리한 항목은 삭제하고 결과를 LOG에 적는다. 처리하지 못한 항목은 남기고 이유를 LOG에 적는다.
6. **Scope** — 현재 Phase `PLAN.md`의 Scope 안에서만 작업한다. Scope 밖 문제는 고치지 말고 HANDOFF의 Known Problems에 적는다. 요청받지 않은 리팩터링·의존성 추가·구조 변경은 먼저 제안한다.
7. **Spec first** — Spec(PRD·ARCHITECTURE·API)을 바꿔야 하는 작업은 승인 후 spec을 먼저 갱신하고 구현한다. 공개 인터페이스(API·스키마·CLI) 변경은 같은 커밋에서 spec을 갱신한다.
8. **Verification** — 코드 변경은 test/typecheck/lint를 경고 없이 통과해야 완료다(경고는 실패로 설정한다). 새 기능·버그 수정에는 테스트를 같은 커밋에 넣는다. 실행하지 않은 검증을 완료로 적지 않고, 검증 절차는 PLAN의 Validation Plan과 RESULT에 남긴다.
9. **Commits** — Task 완료마다 1커밋, 긴 Task는 step마다 WIP 커밋. Agent 커밋에는 `Agent:`·`Task:` trailer(아래 Commit Format). 세션의 마지막은 `.ai/`·`docs/phases/`·`docs/decisions/`만 담은 close commit이며, 커밋하지 않은 변경을 남긴 채 세션을 끝내지 않는다. push된 커밋은 rewrite하지 않는다.
10. **Interruption** — 중단(토큰·시간 소진, 오류)은 언제든 일어난다고 가정한다. Task 시작 시 HANDOFF의 Goal·Work In Progress를 먼저 쓰고(handoff-first), step마다 CURRENT의 Progress를 갱신하며, 큰 변경 전에는 HANDOFF를 먼저 갱신한다. 세션 안에 끝나지 않을 것 같으면 억지로 끝내지 말고 종료 절차로 간다.
11. **Resume** — 정상 종료 시 CURRENT의 Status를 IN_PROGRESS로 남기지 않는다. 시작 시 IN_PROGRESS를 보면 중단된 세션이다: uncommitted diff가 HANDOFF의 Work In Progress·CURRENT의 Progress와 일치하면 그 step부터 잇고, 아니면 개발자 변경으로 취급한다. 어느 쪽이든 test를 먼저 실행한다.
12. **Context budget** — 파일은 필요한 부분만 읽고 긴 출력은 요약해서 남긴다. Relevant Source Files는 디렉터리가 아니라 파일·심볼 단위(`src/api/users.py:create_user`)로 적는다. 상한: CURRENT.md 50줄, HANDOFF.md 60줄, LOG 항목 8줄, Progress 10 step, Recent Important Changes 5개.
13. **Conventions** — 포맷·린트는 도구 설정(`.editorconfig`, <linter/formatter 설정 파일>)을 따르고, 모듈 경계·의존성 방향은 `docs/ARCHITECTURE.md`를 따른다. 정해진 Stack 밖의 언어·런타임 도입은 ADR이 필요하다. 비밀값과 생성물은 커밋하지 않는다. <!-- 스택 확정 후 언어별 규칙을 3줄 이내로 추가한다. 마지막 줄은 허용 언어 목록 (.ai/BOOTSTRAP.md의 Stack Constraints) -->
14. **Decisions** — 장기 영향이 있는 결정은 `docs/decisions/`에 ADR로 남긴다. `docs/ARCHITECTURE.md`는 현재 구조만 기술하고, 과거 구조와 이유는 ADR에 둔다.

## Commands

| Purpose   | Command                |
|-----------|------------------------|
| Install   | `<install command>`    |
| Test      | `<test command>`       |
| Typecheck | `<typecheck command>`  |
| Lint      | `<lint command>`       |
| Run       | `<run command>`        |

<!-- 템플릿 초기화 시 채운다. 해당 없는 항목은 N/A로 명시한다. -->

## Session Procedure

- **시작**: `scripts/ai-start.sh`를 실행하고 출력의 next steps를 따른다 — Resume 판단 → 개발자 변경·INBOX 반영 → PLAN의 Task·Acceptance Criteria 확인 → CURRENT의 Status=IN_PROGRESS·Progress 작성과 HANDOFF 초안 → 구현.
- **종료**: test → typecheck → lint → 작업 커밋과 PLAN의 Task SHA 갱신 → CURRENT(Status≠IN_PROGRESS)·HANDOFF·LOG 갱신 → 필요 시 ADR, Phase 완료 시 `RESULT.md`·`docs/phases/README.md`·`phase/NN` 태그 → `scripts/ai-end.sh --set-checkpoint` → close commit.

## Commit Format

- `<type>(<scope>): <summary>` — type: feat, fix, refactor, docs, test, chore, wip. 본문에 무엇을·왜. WIP는 미완료 사항과 테스트 상태.
- trailer: `git commit --trailer "Agent: claude-code" --trailer "Task: 01/T3"` — Agent 이름은 소문자 kebab-case, Task 밖 작업은 `01/-`.
- Task 완료 커밋의 SHA를 PLAN에 적는다: `- [x] T3. ... (commit abc1234)`. 특정 Task 조회: `git log --grep='Task: 01/T3'`.
- close commit: `docs(ai): close session — <요약>` (`.ai/`·`docs/phases/`·`docs/decisions/`만 포함).
- 브랜치를 쓸 때: `.ai/LOG.md`는 union merge(`.gitattributes`), `CURRENT.md`·`HANDOFF.md` 충돌은 최신 세션 쪽을 택하고 병합 후 `scripts/ai-end.sh --set-checkpoint`로 checkpoint를 다시 잡는다.
