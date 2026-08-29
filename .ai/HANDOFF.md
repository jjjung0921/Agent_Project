# Handoff

<!--
다음 Agent를 위한 인수인계. 이전 내용은 덮어쓴다(이력은 git log로 본다).
- handoff-first: Task를 시작할 때 Goal·Work In Progress를 먼저 쓰고, 진행하며 갱신하고, 세션 종료 시 완성한다.
  세션이 중단되어도 이 파일과 CURRENT.md의 Progress만으로 재개할 수 있어야 한다.
- 대화 내용을 옮기지 말고, 재개에 필요한 최소 정보만 적는다. 모든 항목을 채운다(없으면 "없음").
-->

- From: claude-cowork — 템플릿 워크플로 확장 세션
- Date: 2026-08-29
- Phase / Task: 01-project-setup / 시작 전 (Task 밖 작업)

## Goal

개발자 개입 추적과 세션 중단(토큰 소진)에 대비하는 규칙·도구를 템플릿에 추가하고, 개발자 보고와 커밋 버전 기록 체계를 갖춘다.

## Work Completed

- `AGENTS.md` 개정: Change Tracking, Commit Policy, Start of Work(Resume), During Work, End of Work — 커밋 `b3db569`
- `.ai/CURRENT.md`에 Progress·Last Checkpoint, `.ai/LOG.md`(개발자 보고), `.ai/INBOX.md`(개발자 지시) 신설
- `scripts/ai-start.sh`, `scripts/ai-end.sh` 작성 및 시나리오 테스트
- ADR-0002 작성, Phase 템플릿·README·BOOTSTRAP 반영

## Work In Progress

- 없음

## Files Changed

- `b3db569` 참조 (`git show --stat b3db569`)

## Decisions Made

- checkpoint는 git ref가 아니라 `.ai/CURRENT.md`의 파일 값으로 둔다 (가시성·웹 채팅 Agent 접근) — ADR-0002
- Agent 커밋 식별은 author가 아니라 `Agent:` trailer로 한다 (모든 Agent가 같은 계정으로 커밋) — ADR-0002
- 세션 마지막은 `.ai/`·docs만 담은 close commit, checkpoint는 close commit 직전 HEAD

## Tests Executed

- `scripts/ai-start.sh`, `scripts/ai-start.sh --diff`, `scripts/ai-end.sh`, `scripts/ai-end.sh --set-checkpoint` — 임시 clone에서 개발자 커밋/Agent 커밋/INBOX/IN_PROGRESS/uncommitted 시나리오
- 문서 상호 참조 검사, `docs/api/openapi.yaml` YAML 파싱

## Test Results

- 모두 기대대로 동작 (개발자 커밋 구분, INBOX 항목 표시, IN_PROGRESS → Resume 안내, ai-end FAIL 3건 검출 후 수정 시 통과)
- 스크립트는 bash 3.2 호환 문법으로 작성했으나 실제 macOS bash 3.2에서는 미실행 (Linux bash 5에서만 실행)

## Known Problems

- 없음

## Unverified Assumptions

- 프로젝트 설명이 아직 없다. 스택, 배포 형태, API 유무는 `.ai/BOOTSTRAP.md` 수행 시 결정한다.
- `docs/api/openapi.yaml`은 REST API가 있다고 가정한 스켈레톤이다.
- 개발자가 사용하는 git이 `--trailer`(2.32+)와 `%(trailers:key=...)`(2.22+)를 지원한다고 가정한다.

## Exact Next Action

`.ai/BOOTSTRAP.md`의 Project Description을 채운 뒤 Agent에게 `.ai/BOOTSTRAP.md` 수행을 지시한다. Agent는 `scripts/ai-start.sh`로 시작한다.
