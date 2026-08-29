# AI-Agent Project Template

여러 AI Agent(Claude Code, Codex, Gemini CLI, ChatGPT 등)가 교대로 작업해도 문맥이 끊기지 않도록 설계된 프로젝트 템플릿이다.
특정 Agent의 대화 기억에 의존하지 않고, **저장소 자체**가 현재 상태·설계 의도·개발 계획·작업 규칙을 설명한다.

<!-- 새 프로젝트로 초기화한 뒤에는 이 README를 프로젝트 소개(무엇을, 왜, 어떻게 실행하는지)로 교체한다. 절차는 .ai/BOOTSTRAP.md 참고. -->

## Design Goals

1. 모든 Agent가 같은 규칙을 공유한다 → 규칙은 `AGENTS.md` 한 곳에만 둔다.
2. 새 Agent는 최소 context만 읽고 작업을 이어간다 → `AGENTS.md` → `.ai/CURRENT.md` → checkpoint 이후 변경 → 지정된 문서만.
3. 장기 지식(`docs/`)과 단기 작업 상태(`.ai/`)를 분리한다.
4. 개발은 Phase 단위로 계획하고 검증한다 → `docs/phases/`.
5. Agent 간 handoff는 파일로 한다 → `.ai/HANDOFF.md`.
6. 개발자의 직접 수정·결정이 Agent의 판단보다 우선한다 → git checkpoint로 자동 감지, `.ai/INBOX.md`로 지시.
7. Spec(PRD · ARCHITECTURE · API)이 대화보다 높은 source of truth다.
8. 프로젝트가 커져도 progressive context loading으로 읽는 양을 제한한다.
9. 세션이 언제 끊겨도 저장소만으로 재개한다 → Progress 체크리스트, WIP 커밋, handoff-first.
10. 개발자는 `.ai/LOG.md` 맨 위만 읽으면 현황을 안다.

## How to Use This Template

1. 이 저장소를 복제(또는 GitHub의 "Use this template")해 새 프로젝트 저장소를 만든다.
2. `.ai/BOOTSTRAP.md`의 **Project Description**에 프로젝트 설명을 적는다.
3. 사용하는 AI Agent에게 `.ai/BOOTSTRAP.md`를 수행하라고 지시한다.
   Agent가 저장소 구성(단일 패키지 / 구성요소별)과 언어별 제약 층(프리셋 기반)을 정하고, placeholder를 채우고, 스택·구조 결정을 ADR로 남기고, Phase 계획을 세운 뒤 `BOOTSTRAP.md`를 삭제한다.
4. 이후 모든 세션은 `AGENTS.md`의 Rules와 Session Procedure를 따른다.

## Repository Layout

```text
/
├── AGENTS.md                  # 모든 Agent 공통 규칙 (프로세스의 source of truth)
├── CLAUDE.md                  # Claude Code 진입점 → @AGENTS.md
├── GEMINI.md                  # Gemini CLI 진입점 → @./AGENTS.md
├── README.md
├── docs/
│   ├── PRD.md                 # 제품 요구사항 (무엇을, 왜)
│   ├── ARCHITECTURE.md        # 현재 architecture (과거 구조·이유는 ADR로)
│   ├── api/
│   │   └── openapi.yaml       # REST API spec (machine-readable, API 없으면 삭제)
│   ├── phases/
│   │   ├── README.md          # Phase 목록·순서·상태
│   │   ├── _template/         # 새 Phase용 PLAN.md / RESULT.md 양식
│   │   └── 01-project-setup/
│   │       └── PLAN.md
│   └── decisions/
│       ├── _template.md       # ADR 양식
│       ├── ADR-0001-repository-as-shared-memory.md
│       ├── ADR-0002-git-checkpoint-and-session-safety.md
│       ├── ADR-0003-rules-vs-procedure-and-context-budget.md
│       └── ADR-0004-executable-constraints-over-prose.md
├── .ai/
│   ├── CURRENT.md             # 현재 Phase·Task·Status·Progress·Last Checkpoint (항상 짧게)
│   ├── HANDOFF.md             # Agent → 다음 Agent 인수인계 (덮어쓰기)
│   ├── LOG.md                 # Agent → 개발자 보고 (세션별, 최신순)
│   ├── INBOX.md               # 개발자 → Agent 지시 (처리 후 삭제)
│   ├── BOOTSTRAP.md           # 템플릿 → 프로젝트 초기화 절차 + 언어별 제약 프리셋 (초기화 후 삭제)
│   └── notes/                 # 임시 조사 메모 (source of truth 아님)
├── scripts/
│   ├── ai-start.sh            # 세션 시작: checkpoint 이후 변경(Agent/개발자 구분), INBOX, 중단 여부, next steps 안내
│   └── ai-end.sh              # 세션 종료: 커밋·Status·checkpoint·HANDOFF·LOG 점검, 크기 상한 경고
├── src/                       # 구현  (단일 패키지 기본값 — 구성요소가 여럿이면 초기화 시
└── tests/                     # 테스트  backend/ frontend/ db/ infra/ 같은 디렉터리로 교체)
```

## Agent Entry Points

| Agent | 읽는 파일 | 비고 |
|-------|-----------|------|
| Codex (CLI / ChatGPT) | `AGENTS.md` | 기본 지원 |
| Claude Code | `CLAUDE.md` → `AGENTS.md` | `@AGENTS.md` import |
| Gemini CLI | `GEMINI.md` → `AGENTS.md` | `@./AGENTS.md` import |
| 웹 채팅(ChatGPT, Claude 등) | `AGENTS.md` + `.ai/CURRENT.md` + `scripts/ai-start.sh` 출력을 첫 메시지로 전달 | 결과는 사람이 저장소에 반영하고 trailer를 붙여 커밋 |
| 기타 도구(Cursor, Copilot 등) | 도구별 설정에서 `AGENTS.md` 참조 | 규칙을 복사하지 않는다 |

## Workflow at a Glance

- **세션 시작**: `AGENTS.md`(자동 로드되면 생략) → `.ai/CURRENT.md` → `.ai/HANDOFF.md` → `scripts/ai-start.sh`의 next steps를 따른다 (Resume 여부, 개발자 변경·INBOX 반영, 현재 PLAN, HANDOFF 초안) → 구현
- **작업 중**: step마다 `CURRENT.md` Progress 갱신, 긴 Task는 WIP 커밋
- **세션 종료**: test → typecheck → lint → 작업 커밋 → `CURRENT.md`·`HANDOFF.md`·`LOG.md` → `scripts/ai-end.sh --set-checkpoint` → close commit
- 판단 규칙은 `AGENTS.md`의 Rules 14개가 유일한 기준이고, 절차의 세부 단계는 스크립트 출력이 안내한다. 상태 파일에는 크기 상한이 있다(ADR-0003).

## For Developers

- **현황 확인**: `.ai/LOG.md` 맨 위 항목(커밋, 한 일, 확인 요청)을 본다. 더 필요하면 `.ai/HANDOFF.md`, `git log --oneline`.
- **직접 수정**: 평소처럼 커밋한다(trailer 없이). 다음 Agent가 checkpoint 이후의 커밋과 uncommitted 변경을 개발자 변경으로 감지해 되돌리지 않고 반영한다.
- **지시 남기기**: `.ai/INBOX.md`에 한 줄 추가한다. Agent가 시작 시 읽고 처리한 뒤 지운다.
- **특정 작업만 보기**: `git log --grep='Task: 01/T3'`, Phase 단위는 `git tag -l 'phase/*'`.
- **중단된 세션**: `.ai/CURRENT.md`의 Status가 `IN_PROGRESS`면 세션이 끊긴 것이다. 다음 Agent에게 그대로 시작을 지시하면 Resume 절차를 따른다.
