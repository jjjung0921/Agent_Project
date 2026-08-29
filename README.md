# AI-Agent Project Template

여러 AI Agent(Claude Code, Codex, Gemini CLI, ChatGPT 등)가 교대로 작업해도 문맥이 끊기지 않도록 설계된 프로젝트 템플릿이다.
특정 Agent의 대화 기억에 의존하지 않고, **저장소 자체**가 현재 상태·설계 의도·개발 계획·작업 규칙을 설명한다.

<!-- 새 프로젝트로 초기화한 뒤에는 이 README를 프로젝트 소개(무엇을, 왜, 어떻게 실행하는지)로 교체한다. 절차는 .ai/BOOTSTRAP.md 참고. -->

## Design Goals

1. 모든 Agent가 같은 규칙을 공유한다 → 규칙은 `AGENTS.md` 한 곳에만 둔다.
2. 새 Agent는 최소 context만 읽고 작업을 이어간다 → `AGENTS.md` → `.ai/CURRENT.md` → 지정된 문서만.
3. 장기 지식(`docs/`)과 단기 작업 상태(`.ai/`)를 분리한다.
4. 개발은 Phase 단위로 계획하고 검증한다 → `docs/phases/`.
5. Agent 간 handoff는 파일로 한다 → `.ai/HANDOFF.md`.
6. 개발자의 직접 수정·결정이 Agent의 판단보다 우선한다.
7. Spec(PRD · ARCHITECTURE · API)이 대화보다 높은 source of truth다.
8. 프로젝트가 커져도 progressive context loading으로 읽는 양을 제한한다.

## How to Use This Template

1. 이 저장소를 복제(또는 GitHub의 "Use this template")해 새 프로젝트 저장소를 만든다.
2. `.ai/BOOTSTRAP.md`의 **Project Description**에 프로젝트 설명을 적는다.
3. 사용하는 AI Agent에게 `.ai/BOOTSTRAP.md`를 수행하라고 지시한다.
   Agent가 placeholder를 채우고, 스택·구조 결정을 ADR로 남기고, Phase 계획을 세운 뒤 `BOOTSTRAP.md`를 삭제한다.
4. 이후 모든 세션은 `AGENTS.md`의 Start of Work / End of Work 절차를 따른다.

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
│       └── ADR-0001-repository-as-shared-memory.md
├── .ai/
│   ├── CURRENT.md             # 현재 Phase·Task·상태·다음 행동 (항상 짧게)
│   ├── HANDOFF.md             # 세션 종료 시 인수인계 (덮어쓰기)
│   ├── BOOTSTRAP.md           # 템플릿 → 프로젝트 초기화 절차 (초기화 후 삭제)
│   └── notes/                 # 임시 조사 메모 (source of truth 아님)
├── src/                       # 구현
└── tests/                     # 테스트
```

## Agent Entry Points

| Agent | 읽는 파일 | 비고 |
|-------|-----------|------|
| Codex (CLI / ChatGPT) | `AGENTS.md` | 기본 지원 |
| Claude Code | `CLAUDE.md` → `AGENTS.md` | `@AGENTS.md` import |
| Gemini CLI | `GEMINI.md` → `AGENTS.md` | `@./AGENTS.md` import |
| 웹 채팅(ChatGPT, Claude 등) | `AGENTS.md` + `.ai/CURRENT.md`를 첫 메시지로 전달 | 결과는 사람이 저장소에 반영 |
| 기타 도구(Cursor, Copilot 등) | 도구별 설정에서 `AGENTS.md` 참조 | 규칙을 복사하지 않는다 |

## Workflow at a Glance

- **세션 시작**: `AGENTS.md` → `.ai/CURRENT.md` → `git status` / `git diff` / 최근 log → 현재 Phase `PLAN.md` → 필요한 spec·코드
- **세션 종료**: test → typecheck → lint → `.ai/CURRENT.md` → `.ai/HANDOFF.md` → Phase Task 갱신 → (필요 시) ADR, `RESULT.md`
- 상세 규칙, 정보 우선순위, 예외 처리는 `AGENTS.md`가 유일한 기준이다.
