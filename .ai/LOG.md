# Work Log

<!--
개발자가 읽는 보고서다. 세션마다 맨 위에 항목을 추가한다(최신순). 항목은 8줄 이내, 사실만 적는다.
- 제목: `## YYYY-MM-DD · <agent> · <phase>/<task>`
- Commits: 이 세션의 작업 커밋 SHA와 한 줄 요약 (close commit 제외)
- Done / Not done: 한 일과 못 한 일
- Developer changes: checkpoint 이후 발견한 개발자 변경과 반영 방법 (없으면 "없음")
- Needs your attention: 개발자의 결정·리뷰·확인이 필요한 것 (없으면 "없음")
- Verification: 실행한 검증과 결과
Phase가 끝나 RESULT.md를 쓰면 그 Phase의 항목은 삭제한다(이력은 git log). 상세는 .ai/HANDOFF.md에 있다.
-->

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
