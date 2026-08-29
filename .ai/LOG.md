# Work Log

<!-- 개발자 보고. 세션마다 맨 위에 추가(최신순), 항목당 8줄 이내. Phase 종료 시 그 Phase의 항목은 삭제(이력은 git log). 상세는 .ai/HANDOFF.md. -->

## 2026-08-29 · claude-cowork · 01/-

- Commits: `d7262c3` 언어별 제약 프리셋과 유연한 저장소 구성 (BOOTSTRAP Stack Constraints, ADR-0004)
- Done: 프리셋 10종(언어 8 + DB·Infra 구성요소), Layout 절차(루트 src/·tests/는 단일 패키지 기본값, 구성요소가 여럿이면 교체), Weak types·Polyglot 지침, 계약을 Phase 01 AC2·AC6·AC7로 고정, Rule 8 "경고 없이"·Rule 13 "Stack 밖 도입은 ADR"
- Not done: 없음
- Developer changes: 없음
- Needs your attention: 프리셋의 도구 버전·옵션은 초기화 시점에 최신인지 확인 필요. push 미실행
- Verification: 문서 상호 참조·Rule/AC 번호 참조 검사, 스크립트 문법 검사

## 2026-08-29 · claude-cowork · 01/-

- Commits: `21d707d` 규칙·절차 분리와 컨텍스트 예산 (AGENTS.md 59줄, 스크립트 next steps·상한 경고, ADR-0003)
- Done: AGENTS.md Rules 14개로 압축, ai-start.sh 상황별 안내·시작 컨텍스트 크기(18KB→14KB), ai-end.sh 상한 경고, .ai 주석 축소, Source Files 파일·심볼 단위
- Not done: 없음
- Developer changes: 없음
- Needs your attention: macOS 기본 bash에서 `scripts/ai-start.sh` 실행 확인 권장. push 미실행 (`git push -u origin main`)
- Verification: 임시 clone에서 IN_PROGRESS·개발자 커밋·상한 초과 시나리오로 스크립트 출력 확인, 문서 상호 참조·Rule 번호 참조 검사

## 2026-08-29 · claude-cowork · 01/-

- Commits: `b3db569` 변경 추적·중단 대비·보고 워크플로 추가 (AGENTS.md, `.ai/LOG.md`·`INBOX.md`, `scripts/`, ADR-0002)
- Done: checkpoint 기반 개발자 변경 감지, Task 단위 + WIP 커밋과 trailer 규칙, Progress·handoff-first·Resume 절차, LOG/INBOX 채널, `ai-start.sh`·`ai-end.sh`
- Not done: 없음
- Developer changes: 없음 (checkpoint 없음 → 전체 이력 확인, 개발자 커밋 없음)
- Needs your attention: 새 프로젝트를 시작하려면 `.ai/BOOTSTRAP.md`의 Project Description을 채운 뒤 Agent에게 수행을 지시. 원격 push는 아직 안 됨 (`git push -u origin main`)
- Verification: 스크립트 시나리오 테스트(개발자/Agent 커밋 구분, INBOX, IN_PROGRESS 감지, ai-end FAIL→통과), 문서 상호 참조·openapi.yaml 파싱 확인

## 2026-08-29 · claude-cowork · 01/-

- Commits: `a0afdc5` 템플릿 초기 생성
- Done: 저장소 구조, AGENTS/CLAUDE/GEMINI/README, docs 양식, ADR-0001, Phase 01 PLAN, .ai 상태 파일
- Not done: 없음
- Developer changes: 없음
- Needs your attention: 없음
- Verification: 문서 상호 참조·openapi.yaml 파싱 확인
