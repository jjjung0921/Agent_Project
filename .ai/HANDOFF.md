# Handoff

<!--
세션 종료 또는 Agent 교체 시 작성한다. 이전 내용은 덮어쓴다(이력은 git log로 본다).
대화 내용을 옮기지 말고, 다음 Agent가 재개하는 데 필요한 최소 정보만 적는다. 모든 항목을 채운다(없으면 "없음").
-->

- From: Claude (Cowork) — 템플릿 생성 세션
- Date: 2026-08-29
- Phase / Task: 01-project-setup / 시작 전

## Goal

여러 AI Agent가 교대로 작업할 수 있는 재사용 프로젝트 템플릿을 생성한다.

## Work Completed

- 저장소 구조와 모든 템플릿 문서 생성 (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `README.md`, `docs/`, `.ai/`)
- ADR-0001 작성 (저장소를 Agent 간 공유 메모리로 사용)
- Phase 01 (project-setup) PLAN 작성

## Work In Progress

- 없음

## Files Changed

- 전체 신규 생성 (초기 커밋 참조)

## Decisions Made

- 문서 언어: 한국어 본문 + 영어 헤더·파일명
- 특정 기술 스택에 의존하지 않는다. 명령·컨벤션은 placeholder로 두고 초기화 시 채운다.
- Claude Code·Gemini CLI 진입점은 `AGENTS.md`를 import만 한다 (규칙 중복 금지) — ADR-0001

## Tests Executed

- N/A (코드 없음). 문서 상호 참조와 `docs/api/openapi.yaml` 파싱만 확인.

## Test Results

- N/A

## Known Problems

- 없음

## Unverified Assumptions

- 프로젝트 설명이 아직 없다. 스택, 배포 형태, API 유무는 미정이며 `.ai/BOOTSTRAP.md` 수행 시 결정한다.
- `docs/api/openapi.yaml`은 REST API가 있다고 가정한 스켈레톤이다. API가 없으면 삭제한다.

## Exact Next Action

`.ai/BOOTSTRAP.md`의 Project Description을 채운 뒤, AI Agent에게 `.ai/BOOTSTRAP.md`를 수행하도록 지시한다.
