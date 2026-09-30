# iOS 학습 로드맵 (v3 · 8주 압축판)

> 이 문서는 AI 튜터(Claude 웹/앱, ChatGPT 등)에게 통째로 붙여넣어 학습 컨텍스트로 쓰기 위한 것이다.
> 새 대화를 시작할 때 이 문서를 첨부하고, 맨 아래 "튜터에게 요청하는 방식"의 문장으로 시작한다.

## 0. 목표와 운영 원칙

- **목표**: 8주 뒤(11/27) "테스트 가능한 구조로 짠 SwiftUI/TCA 앱 + UIKit/ReactorKit 경험 + 배포 자동화"를 포트폴리오로 보여줄 수 있는 상태. 4주차(`v3-tca` 태그)부터는 이 저장소를 들고 지원을 시작한다.
- **학습 시간**: 평일 오전 10:00–13:00 고정 (주 15시간). 오후는 앱 다작·백엔드, 저녁은 지원서. iOS 학습 블록은 다른 일로 대체하지 않는다.
- **하루 구성**: 개념 30분 → 직접 구현 2시간 → 기록 30분(막힌 것 / 해결한 것 / 내일 할 것).
- **주간 산출물**: 금요일까지 해당 주 GitHub Milestone의 이슈를 모두 닫는다. 닫히지 않은 이슈는 토요일 새벽 자동으로 8주차(버퍼)로 이월된다.
- **밀릴 때 규칙**: 기간은 늘리지 않고 범위를 줄인다. 줄이는 순서: ① Compositional Layout ② ReactorKit 직접 구현(읽기만) ③ Sentry. 테스트·클린·TCA는 줄이지 않는다.
- **위험 구간**: 3~4주차(TCA)와 5주차(UIKit). 이 두 구간에서 하루라도 빠지면 그 주 주말 오전에 메운다.

## 1. 나의 현재 상태

- 오랜만에 iOS 개발로 복귀했다.
- **익숙한 것**: SwiftUI, MVVM, `ObservableObject` 기반 ViewModel, async/await, Moya 네트워킹, 커스텀 Router + `NavigationStack`, 소셜 로그인과 결제 SDK 연동
- **써본 적 없는 것**: 테스트 코드, 클린 아키텍처, TCA, RxSwift/ReactorKit, Tuist, Fastlane, Sentry
- **오래돼서 기억이 흐린 것**: UIKit (프로젝트 1개 경험)
- **필요할 때마다 찾아 쓰는 수준인 것**: 카메라(AVFoundation), 햅틱

### 실습에 쓸 수 있는 코드

| 프로젝트 | 용도 |
|---|---|
| 연습용 앱 (아래 2장) | 테스트, 클린 아키텍처, TCA, UIKit, ReactorKit, Tuist, Fastlane, Sentry |
| `ProjectCCD` (개인 카메라 앱) | 카메라 권한, 촬영, 플래시 |
| `Squishy` (개인 앱) | 햅틱, 제스처 |

이전 회사 코드는 실습에 쓰지 않는다. 모든 실습은 위 세 곳에서만 한다.

## 2. 연습용 앱: 패치노트 (Patchnote)

앱스토어 앱을 검색하고, 상세 정보를 보고, 관심 앱을 저장해 버전·릴리스 노트 변화를 추적하는 앱. 경쟁 앱 리서치에 실제로 쓴다.

- **배포 방식**: App Store 심사 제출은 하지 않는다. TestFlight **내부 테스트**(심사 없음)로 내 기기에 설치해 쓴다. 7주차 `fastlane beta`의 목적지가 이것이다.
- 이유: 다른 앱을 App Store처럼 나열하는 앱은 App Review Guidelines 3.2.2(i)에서 명시적으로 거절 대상이고, iTunes Search API 약관도 스토어 콘텐츠 홍보 목적 사용을 전제로 한다.
- 순위 매기기, 앱 콘텐츠 캐싱·재배포는 하지 않는다. 상세 화면에는 App Store로 가는 링크를 둔다.
- **8주 이후 심사 제출을 시도한다면**: 검색·둘러보기 화면을 없애고 App Store 공유 시트(Share Extension)로 앱을 추가하는 "업데이트 알림 도구"로 바꾼다. 유료화는 Apple 데이터 자체가 아니라 내가 만든 기능(업데이트 푸시 알림, 변경 이력, 위젯)에만 건다. 먼저 무료로 통과시킨 뒤 유료 기능을 붙인다.

- **API**: iTunes Search API (API 키·가입·승인 없음, 백엔드 불필요)
  - 검색: `https://itunes.apple.com/search?term={검색어}&entity=software&country=kr`
  - 단건 조회: `https://itunes.apple.com/lookup?id={앱ID}&country=kr`
- **화면 3개**: 검색 목록 → 상세(아이콘, 평점, 현재 버전, 릴리스 노트, 스크린샷) → 워치리스트(즐겨찾기, 로컬 저장)
- SwiftUI + MVVM, iOS 18+, 처음에는 외부 라이브러리 없이 `URLSession` 사용
- 처음에는 **일부러 평소 방식대로** 작성한다: ViewModel 안에서 네트워크 서비스를 직접 생성한다
- GitHub 공개 저장소로 만들고, 단계마다 태그를 남긴다: `v1-mvvm`, `v2-clean`, `v3-tca`, `v4-uikit-reactorkit`
- 호출 횟수 제한이 있으므로 검색은 debounce를 걸고, 테스트는 실제 네트워크를 쓰지 않는다

## 3. 학습 순서와 기간 (8주)

| 주차 | 기간 | 주제 | 핵심 산출물 | 지원 |
|---|---|---|---|---|
| 1 | 10/5–10/9 | 앱 v1 + 테스트 | 테스트 10개, 태그 `v1-mvvm` | |
| 2 | 10/12–10/16 | 클린 아키텍처 (DI + 계층) | 네트워크 없는 ViewModel 테스트, `v2-clean` | |
| 3 | 10/19–10/23 | TCA ① 튜토리얼 + 기능 하나 이식 | TestStore 테스트 3개 | |
| 4 | 10/26–10/30 | TCA ② 전체 이식 + Tuist | `v3-tca`, 모듈 분리, 비교표 | 주말: 이력서·포트폴리오 초안 |
| 5 | 11/2–11/6 | UIKit (연동 + 모던 컬렉션 뷰) | UIKit 목록 화면 | 3곳 |
| 6 | 11/9–11/13 | RxSwift + ReactorKit (+ RIBs 개념) | `v4-uikit-reactorkit` | 3곳 |
| 7 | 11/16–11/20 | Fastlane + CI + Sentry | `fastlane beta`, PR 자동 테스트 | 3곳 |
| 8 | 11/23–11/27 | 버퍼 + 면접 대비 | 이월 이슈 처리, 면접 답변 정리 | 3곳 |
| 병행 | 주말/필요 시 | 카메라(ProjectCCD), 햅틱(Squishy) | 메인 트랙과 분리 | |

### 1주차. 앱 v1 + 테스트

클린 아키텍처와 TCA의 장점은 대부분 "테스트하기 쉽다"이므로, 테스트를 써봐야 구조를 나누는 이유가 와닿는다.

- 월: 앱 v1을 평소 MVVM 방식으로 완성 (Claude Code 도움 허용, 단 코드는 전부 읽고 설명할 수 있어야 함)
- 화·수: Swift Testing 기본 (`@Test`, `#expect`, `#require`, `@Suite`, 파라미터화 테스트), 순수 로직 테스트 (평점·날짜 포맷, 정렬, DTO 디코딩)
- 목·금: ViewModel async·`@MainActor` 테스트를 시도하고, 네트워크를 바꿔 끼울 수 없어 막히는 지점을 README에 기록. Mock, Stub, Fake 차이 정리

**소스**: Apple 공식 문서 "Swift Testing", WWDC24 "Meet Swift Testing" / "Go further with Swift Testing"

**완료 기준**: 순수 로직 테스트 10개 이상 통과 / "이 ViewModel은 왜 테스트하기 어려운가"를 내 말로 설명할 수 있다

### 2주차. 클린 아키텍처 (가볍게)

책부터 읽지 않고, 1주차에 막힌 ViewModel을 고치는 리팩터링으로 배운다.

- 월·화: 네트워크 서비스를 protocol로 추상화하고 init으로 주입, Fake로 ViewModel 테스트 (성공, 실패, 빈 결과)
- 수·목: DTO ↔ Entity 분리, Repository·UseCase를 워치리스트 기능 하나에만 적용
- 금: "작은 앱에서 클린 아키텍처는 어디까지"를 글로 정리 (면접 답변용)

**소스**: GitHub `kudoleh/iOS-Clean-Architecture-MVVM` (구조 참고용, 통째로 따라 하지 않는다)

**완료 기준**: 기능 하나가 네트워크 없이 테스트로 검증된다 / 적정선에 대한 내 기준이 글로 있다

**하지 않는 것**: 앱 전체를 교과서식 계층으로 바꾸기, DI 프레임워크 도입

### 3~4주차. TCA

테스트와 DI를 끝낸 뒤라 문법 암기가 아니라 "이미 아는 개념의 TCA식 표현"으로 배운다. 시작일 기준 최신 1.x 버전으로 고정하고, 버전이 다른 블로그 글은 참고하지 않는다.

**3주차**
- 월·화: 공식 튜토리얼 "Meet the Composable Architecture" 완주 (State / Action / Reducer / Effect, `@ObservableState`)
- 수·목: 워치리스트 기능을 TCA로 이식, 2주차 protocol 주입을 `@Dependency`로 바꾸기
- 금: `TestStore`로 Action → State 변화 테스트 3개 이상

**4주차**
- 월·화: 검색 → 상세 네비게이션을 `StackState`로, 나머지 화면 전부 TCA로 전환
- 수·목: Tuist로 `App` / `FeatureSearch` / `FeatureDetail` / `FeatureWatchlist` / `Core` 모듈 분리
- 금: README에 MVVM vs 클린 vs TCA 비교표 (코드량, 테스트 난이도, 흐름 추적), 태그 `v3-tca`

**소스**: TCA 공식 GitHub 저장소 README·문서 내 튜토리얼, 저장소 `Examples` 폴더(CaseStudies, SyncUps), Tuist 공식 문서(tuist.dev)

**완료 기준**: 앱 전체가 TCA로 동작하고 핵심 기능마다 TestStore 테스트가 있다 / `tuist generate` 한 번으로 빌드된다 / "TCA를 언제 쓰고 언제 안 쓰는가"를 2분 안에 말할 수 있다

### 5주차. UIKit (이직 범위)

- 월: `UIViewController` 생명주기, delegate, 코드 기반 Auto Layout, `UINavigationController`
- 화: `UIViewRepresentable` / `UIViewControllerRepresentable` / Coordinator, `UIHostingController`
- 수~금: 검색 목록 화면을 `UICollectionView` Compositional Layout + Diffable DataSource로 새로 작성하고 SwiftUI 상세와 연결

**소스**: Apple 샘플 코드 "Implementing Modern Collection Views", WWDC 컬렉션 뷰 레이아웃·Diffable 관련 세션

**완료 기준**: UIKit 목록 화면과 SwiftUI 상세 화면이 양방향으로 값을 주고받는다 / 다른 사람의 UIKit 코드 흐름을 따라갈 수 있다

### 6주차. RxSwift + ReactorKit (+ RIBs 개념)

목표는 "읽을 수 있고, 화면 하나는 짤 수 있는" 수준이다.

- 월·화: RxSwift 핵심 (`Observable`, `Relay`, `map`/`flatMap`/`debounce`, `DisposeBag`, UI 바인딩)
- 수·목: 5주차 UIKit 목록 화면을 ReactorKit으로 바인딩 (Action → Mutation → State), 태그 `v4-uikit-reactorkit`
- 금: RIBs 공식 튜토리얼 1개를 읽고 Router/Interactor/Builder 역할만 정리

**소스**: RxSwift 공식 GitHub Documentation, ReactorKit README와 Examples(Counter, GitHubSearch), RIBs GitHub 위키 튜토리얼

**완료 기준**: 같은 검색 화면을 TCA 버전과 ReactorKit 버전으로 나란히 보여줄 수 있다 / RIBs가 대규모 팀에서 쓰이는 이유를 설명할 수 있다

### 7주차. 배포 자동화 + Sentry

- 월·화: Fastlane 설치, `match`로 인증서 관리, `beta` lane으로 TestFlight 업로드
- 수: GitHub Actions로 PR마다 테스트 자동 실행 (`ci.yml`)
- 목: Sentry (SDK 초기화, debug/release 구분, dSYM 업로드, breadcrumb, 개인정보 전송 차단)
- 금: velog 글 2편 (① 테스트가 아키텍처를 바꾼 이유 ② 같은 기능 MVVM vs TCA vs ReactorKit)

**소스**: Fastlane 공식 문서(docs.fastlane.tools)의 iOS 베타 배포 가이드와 match, Sentry Cocoa SDK 공식 문서

**완료 기준**: `fastlane beta` 한 줄로 TestFlight 업로드 / PR에서 테스트가 자동으로 돈다 / 일부러 낸 크래시가 Sentry에 읽을 수 있는 스택으로 보인다

### 8주차. 버퍼 + 면접 대비

- 이월된 이슈부터 처리
- 면접 답변 정리: 아키텍처 비교, 테스트 전략, 메모리 관리, Swift Concurrency, SwiftUI 상태 관리
- README 최종본, 이력서 기술 스택 갱신

### 병행 트랙. 카메라 · 햅틱 (메인 일정에 포함하지 않음)

**카메라 (ProjectCCD)** — Apple AVCam 샘플 코드를 교재로. 권한 → `AVCaptureSession` 입출력 → 프리뷰 레이어를 `UIViewRepresentable`로 → `AVCapturePhotoOutput` 촬영 → 플래시·토치·전환·줌·초점. 완료 기준: ProjectCCD의 카메라 코드를 한 줄씩 설명할 수 있다.

**햅틱 (Squishy)** — `.sensoryFeedback` → 피드백 제너레이터와 `prepare()` → 제스처 상태에 맞춘 햅틱 → 필요할 때만 Core Haptics. 완료 기준: 제스처 진행도에 따라 세기가 달라지는 햅틱을 하나 구현한다.

## 4. 이미 정리한 내용

다시 설명할 필요 없는 부분이다.

- `@StateObject`는 View가 객체를 소유할 때, `@ObservedObject`는 부모에게 받아 관찰만 할 때 쓴다. 직접 생성하는 객체에 `@ObservedObject`를 쓰면 View가 다시 만들어질 때 객체도 초기화된다.
- `@StateObject`의 init은 `@autoclosure`라서 부모 쪽에서 생성 코드를 넘겨도 최초 한 번만 실행된다.
- `.environmentObject`는 트리 위쪽에서 한 번만 주입하면 모든 하위 View에 전달된다. 다시 주입해야 하는 곳은 `UIHostingController` 경계와 `#Preview`뿐이다.
- iOS 17+의 `@Observable`에서는 `@StateObject` → `@State`, `@ObservedObject` → 일반 프로퍼티, `@EnvironmentObject` → `@Environment(Type.self)`로 바뀐다.
- RxSwift는 라이브러리, ReactorKit은 RxSwift 위의 화면 단위 단방향 아키텍처, RIBs는 앱 전체를 로직 트리로 나누는 구조다. TCA와 ReactorKit은 같은 단방향 계열이며, 클린 아키텍처는 이들과 함께 쓸 수 있는 계층 구조다.
- Tuist는 Xcode 프로젝트를 Swift 코드로 생성·모듈화하는 도구, Fastlane은 빌드·서명·배포 자동화 도구다.

## 5. 튜터에게 요청하는 방식

새 대화의 첫 메시지로 아래를 쓴다. 대괄호 부분만 바꾼다.

```
첨부한 문서는 내 iOS 학습 로드맵이야. 오늘은 [N주차 / 요일]을 진행할게. 오늘 쓸 수 있는 시간은 [N시간]이야.

진행 방식:
- 개념 설명은 짧게 하고, 바로 내가 직접 작성해볼 과제를 줘.
- 내가 코드를 붙여넣으면 정답을 바로 주지 말고 문제가 있는 부분을 먼저 짚어줘.
- 실습은 문서 1장에 적힌 프로젝트에서만 해.
- 한 번에 한 가지 주제만 다루고, 끝나면 완료 기준을 채웠는지 질문으로 확인해줘.
- TCA는 [고정한 버전] 기준으로만 설명해줘.
- 문서 4장의 내용은 이미 아니까 다시 설명하지 마.
- 마지막에 오늘 기록(막힌 것 / 해결한 것 / 내일 할 것)을 3줄로 정리해줘.
```

## 6. 진행 관리 (GitHub 자동화)

연습용 앱 저장소에서 진행을 관리한다. 설정 방법은 저장소의 `.github/` 파일들을 참고한다.

- 주차 = Milestone (금요일 23:59 KST 마감), 완료 기준·과제 = Issue, PR로 Issue를 닫는다
- 평일 09:50 KST: 이번 주 남은 이슈, 마감까지 남은 날, 지난 24시간 푸시 여부를 "진행 로그" 이슈에 댓글로 남기고 멘션 알림
- 토요일 00:30 KST: 지난주 달성률 리포트, 못 닫은 이슈는 8주차로 이월(`carried-over` 라벨), 해당 Milestone 종료
- 진행 기록표는 이 문서 대신 GitHub Milestones 화면이 대신한다
