# Day 계획 (40일)

> Claude Code에서 `Day N 시작`이라고 하면 이 문서의 Day N 항목과 CLAUDE.md의 Day 루틴을 따라 진행한다.
> 기간: 2026-10-26(월) ~ 2026-12-18(금), 평일 10:00–13:00

## 매일 공통 순서

| 시간 | 단계 | 내가 할 일 | 모델 |
|---|---|---|---|
| 10:00 | 0. 시작 | 새 세션 열기 → `Day N 시작` 입력 → 오늘 범위 승인 | 그날 지정 모델 |
| 10:05 | 1. 구현 | Claude Code가 구현. 끝나면 "읽는 순서"를 받는다 | 그날 지정 모델 |
| 10:25 | 2. 읽기 | `/clear` 후 Sonnet으로 전환. 모든 줄을 읽고, 막히는 줄은 줄 번호로 질문 | Sonnet |
| 11:25 | 3. 설명 | PR 설명을 **내가** 쓴다 → 채점과 확인 질문 3개에 답한다 | Sonnet |
| 11:45 | 4. 다시 쓰기 | 지정된 부분을 지우고 보지 않고 다시 작성 → 테스트 통과 → 원본과 비교 | Sonnet |
| 12:45 | 5. 변형 과제 | 작은 과제를 혼자 구현 → 리뷰 → 3줄 기록 → PR 머지(`Closes #`) | Sonnet |

- 한 Day의 변경은 300줄 이하. 넘으면 다음 Day로 나눈다.
- 시간이 부족한 날은 5단계부터 뺀다. 4단계는 빼지 않는다.
- **[직접]** 표시가 있는 Day는 1단계를 AI가 하지 않는다. 내가 쓰고 Claude는 케이스 목록·힌트·리뷰만 한다.
- **Opus** 표시가 있는 Day는 1단계만 Opus로 하고, 2단계부터 Sonnet으로 바꾼다.
- 금요일 마지막에는 새 세션의 Opus로 그 주 전체 리뷰(15분)를 받는다.

---

## W1 · 앱 v1 + 테스트 (10/26–10/30)

**Day 1 (10/26 월) · v1 ① 검색 화면 + 네트워크** — Sonnet
- 구현: 평소 MVVM 방식. ViewModel 안에서 `URLSession`을 직접 호출. 검색 debounce, 이전 요청 취소. 탭바 뼈대
- 읽기 포인트: `URLComponents` 인코딩, `Task` 취소 흐름, `@MainActor` 위치
- 다시 쓰기: 검색 결과 디코딩 모델(DTO)
- 변형: 검색 결과 개수를 화면에 표시

**Day 2 (10/27 화) · v1 ② 상세 + 워치리스트** — Sonnet
- 구현: 상세 화면(lookup), 워치리스트(UserDefaults에 `trackId` + `version`), "새 버전" 배지
- 읽기 포인트: 다건 lookup으로 한 번에 조회하는 부분, 저장 형식
- 다시 쓰기: 새 버전 판정 로직
- 변형: 워치리스트 정렬을 "최근 업데이트순 ↔ 이름순"으로 바꾸기
- 마무리: 태그는 아직 달지 않는다

**Day 3 (10/28 수) · Swift Testing ① 순수 로직 [직접]** — Sonnet
- Claude: 테스트할 순수 로직 목록과 Swift Testing 문법 요점만 준다
- 내가: 평점·날짜·용량 포맷, 정렬 로직 테스트 작성. 파라미터화 테스트 1개 이상
- 변형: 경계값(평점 없음, 0, 5.0) 케이스 추가

**Day 4 (10/29 목) · Swift Testing ② 디코딩 [직접]** — Sonnet
- 내가: `docs/API.md` 7장대로 fixture JSON 만들기 → DTO 디코딩 테스트 (옵셔널 필드 누락 케이스 필수)
- 목표: 테스트 누적 10개 이상
- 변형: `fileSizeBytes`가 숫자가 아닌 문자열일 때의 처리 테스트

**Day 5 (10/30 금) · ViewModel 테스트 시도 [직접]** — Sonnet, 마지막에 Opus 리뷰
- 내가: 검색 ViewModel 테스트를 시도하다 막히는 지점을 README에 기록
- Claude: 정답을 주지 않고 "왜 어려운가"를 질문으로 유도. Mock / Stub / Fake 차이 정리
- 마무리: 태그 `v1-mvvm`, 주간 Opus 리뷰

## W2 · 클린 아키텍처 (11/2–11/6)

**Day 6 (11/2 월) · 네트워크 추상화 + 주입** — **Opus**
- 구현: API 클라이언트를 protocol로 추상화, ViewModel init 주입, 엔드포인트 enum
- 읽기 포인트: 의존성 방향, 기본값 주입을 쓴 이유
- 다시 쓰기: 엔드포인트 enum과 요청 생성
- 변형: 요청에 `lang` 파라미터 추가

**Day 7 (11/3 화) · Fake로 ViewModel 테스트 [직접]** — Sonnet
- 내가: Fake 클라이언트 작성 → 성공 / 실패 / 빈 결과 / 취소 테스트
- 비교: Day 5에 막혔던 지점이 왜 풀렸는지 README에 한 단락
- 변형: 상세 ViewModel 테스트도 같은 방식으로

**Day 8 (11/4 수) · DTO ↔ Entity 분리** — Sonnet
- 구현: 화면용 Entity와 매핑 함수 분리
- 다시 쓰기: 매핑 함수
- 변형: 매핑 테스트를 직접 작성 [직접]

**Day 9 (11/5 목) · 워치리스트 Repository · UseCase** — Sonnet
- 구현: 워치리스트에만 Repository protocol + 구현, UseCase 적용
- 읽기 포인트: 어디까지 나눴고 어디서 멈췄는지
- 다시 쓰기: UseCase
- 변형: 인메모리 Repository로 UseCase 테스트 [직접]

**Day 10 (11/6 금) · 정리** — Sonnet, 마지막에 Opus 리뷰
- 내가: 글 "작은 앱에서 클린 아키텍처는 어디까지" 작성 → Claude가 첨삭만
- 마무리: 태그 `v2-clean`, 주간 Opus 리뷰

## W3 · TCA ① (11/9–11/13)

**Day 11 (11/9 월) · 공식 튜토리얼** — Sonnet
- 1단계 대신: TCA 버전 고정, 공식 튜토리얼 "Meet the Composable Architecture"를 직접 따라 치기
- 고정한 버전을 CLAUDE.md `고정 버전` 칸에 적는다
- 읽기 단계: 튜토리얼에서 이해 안 된 줄만 질문

**Day 12 (11/10 화) · 워치리스트 Reducer** — **Opus**
- 구현: 워치리스트 기능을 TCA로 (State / Action / Reducer / View)
- 다시 쓰기: Reducer의 `body`
- 변형: "전체 삭제" Action 추가

**Day 13 (11/11 수) · `@Dependency` 클라이언트** — Sonnet
- 구현: W2 protocol 주입을 `@Dependency` 클라이언트로 전환
- 읽기 포인트: live / test / preview 값의 차이, W2 방식과 비교
- 다시 쓰기: 클라이언트 정의
- 변형: 저장소(UserDefaults)도 Dependency로

**Day 14 (11/12 목) · TestStore** — Sonnet
- 구현: 워치리스트 TestStore 테스트 3개 (이번 주부터 AI가 테스트도 작성)
- 다시 쓰기: 테스트 1개를 지우고 직접 작성
- 변형: 조회 실패 케이스 테스트 추가

**Day 15 (11/13 금) · 검색 Reducer** — Sonnet, 마지막에 Opus 리뷰
- 구현: 검색 기능 TCA. debounce와 취소를 Effect로
- 다시 쓰기: 검색 Effect 부분
- 마무리: 주간 Opus 리뷰

## W4 · TCA ② + Tuist (11/16–11/20)

**Day 16 (11/16 월) · StackState 네비게이션** — Sonnet
- 구현: 검색 → 상세를 `StackState`로
- 다시 쓰기: 경로(Path) Reducer
- 변형: 워치리스트에서도 상세로 이동

**Day 17 (11/17 화) · 상세 Reducer + 전체 전환** — Sonnet
- 구현: 상세 TCA, 앱 루트 TabView를 TCA로. MVVM 코드 제거
- 다시 쓰기: 상세 Reducer
- 변형: 상세에서 저장/해제 시 워치리스트에 반영되는지 TestStore로 확인

**Day 18 (11/18 수) · Tuist 모듈 설계** — **Opus**
- 구현: `Project.swift`, `App` / `FeatureSearch` / `FeatureDetail` / `FeatureWatchlist` / `Core` 구조
- 4단계 생략 (설정 파일). 대신 모듈 의존 그래프를 내가 직접 그려 설명

**Day 19 (11/19 목) · 모듈 분리 마무리** — Sonnet
- 구현: 코드를 모듈로 이동, `tuist generate` 한 번으로 빌드
- 변형: `FeatureDetail` 단독 실행용 예제 앱 타깃 추가

**Day 20 (11/20 금) · 비교와 정리** — Sonnet, 마지막에 Opus 리뷰
- 내가: README에 MVVM vs 클린 vs TCA 비교표 작성 (코드량, 테스트 난이도, 흐름 추적)
- 마무리: 태그 `v3-tca`, 주간 Opus 리뷰
- 주말: 이력서 · 포트폴리오 초안

## W5 · UIKit (11/23–11/27) · 지원 3곳

**Day 21 (11/23 월) · UIViewController 기초** — Sonnet
- 구현: 코드 Auto Layout으로 간단한 UIKit 화면 + `UINavigationController`
- 다시 쓰기: 제약조건 설정 부분
- 변형: 화면 회전 시 레이아웃 확인

**Day 22 (11/24 화) · SwiftUI ↔ UIKit 연결** — Sonnet
- 구현: `UIViewControllerRepresentable` + Coordinator, `UIHostingController`
- 다시 쓰기: Coordinator
- 변형: UIKit → SwiftUI 방향으로 값 전달

**Day 23 (11/25 수) · Compositional Layout** — Sonnet
- 구현: 검색 결과를 `UICollectionView` Compositional Layout으로
- 다시 쓰기: 레이아웃 정의
- 변형: 2열 그리드 전환 버튼

**Day 24 (11/26 목) · Diffable DataSource** — Sonnet
- 구현: Diffable + 셀 등록, 상세(SwiftUI)로 이동
- 다시 쓰기: snapshot 적용 부분
- 변형: 저장 여부 변경 시 해당 셀만 갱신

**Day 25 (11/27 금) · 정리** — Sonnet, 마지막에 Opus 리뷰
- 양방향 값 전달 마무리, 밀린 것 처리, 주간 Opus 리뷰

## W6 · RxSwift + ReactorKit (11/30–12/4) · 지원 3곳

**Day 26 (11/30 월) · RxSwift 기초** — Sonnet
- 1단계 대신: 플레이그라운드에서 `Observable`, `Relay`, `map`/`flatMap`/`debounce`, `DisposeBag` 예제를 Claude가 주고 내가 실행·변형
- 4단계: 예제 하나를 안 보고 다시 작성

**Day 27 (12/1 화) · RxCocoa 바인딩** — Sonnet
- 구현: UIKit 검색 화면을 RxCocoa로 바인딩 (검색어 → debounce → 결과)
- 다시 쓰기: 검색 스트림
- 변형: 로딩 인디케이터 바인딩

**Day 28 (12/2 수) · Reactor** — **Opus**
- 구현: 검색 Reactor (Action / Mutation / State), `mutate`에서만 비동기
- 다시 쓰기: `reduce`
- 변형: 정렬 Action 추가

**Day 29 (12/3 목) · View 바인딩 + 테스트** — Sonnet
- 구현: ViewController 바인딩, Reactor 테스트
- 다시 쓰기: `bind(reactor:)`
- 변형: 같은 기능의 TCA 버전과 나란히 비교 메모

**Day 30 (12/4 금) · RIBs 개념** — Sonnet, 마지막에 Opus 리뷰
- 1단계 대신: RIBs 공식 튜토리얼 1 읽기 → Router / Interactor / Builder 역할을 내 말로 정리
- 마무리: 태그 `v4-uikit-reactorkit`, 주간 Opus 리뷰

## W7 · 배포 자동화 (12/7–12/11) · 지원 3곳

**Day 31 (12/7 월) · Fastlane 설치 + match** — Sonnet
- 구현: `Gemfile`, `fastlane init`, match 저장소 연결 (4단계 생략)
- 읽기 포인트: 인증서와 프로비저닝 프로파일의 관계

**Day 32 (12/8 화) · beta lane** — Sonnet
- 구현: `beta` lane → TestFlight 내부 테스트 업로드
- 완료 기준: `bundle exec fastlane beta` 한 줄로 업로드

**Day 33 (12/9 수) · CI** — Sonnet
- 구현: `ci.yml`, PR마다 테스트 자동 실행
- 변형: 테스트 실패 시 PR에 표시되는지 일부러 실패시켜 확인

**Day 34 (12/10 목) · Sentry** — Sonnet
- 구현: SDK 초기화, debug/release 구분, dSYM 업로드, 개인정보 전송 차단
- 확인: 일부러 낸 크래시가 대시보드에 읽을 수 있는 스택으로 보이는지

**Day 35 (12/11 금) · 글쓰기** — Sonnet, 마지막에 Opus 리뷰
- 내가: velog 2편 (① 테스트가 아키텍처를 바꾼 이유 ② 같은 기능 MVVM vs TCA vs ReactorKit) → 첨삭만

## W8 · 버퍼 + 면접 (12/14–12/18) · 지원 3곳

**Day 36–37 (12/14–15)** — Sonnet
- `carried-over` 이슈부터 처리. 남은 게 없으면 Day 38로

**Day 38 (12/16 수) · 면접 ①** — **Opus**
- Opus가 면접관 역할: 아키텍처 비교, 테스트 전략. 내가 답하고 피드백

**Day 39 (12/17 목) · 면접 ②** — **Opus**
- 메모리 관리, Swift Concurrency, SwiftUI 상태 관리

**Day 40 (12/18 금) · 마무리** — Sonnet
- README 최종본, 이력서 기술 스택 갱신, 8주 회고
