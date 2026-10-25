# 패치노트 API 명세

iTunes Search API를 사용한다. 인증·API 키·가입이 없고, 백엔드도 없다. 앱이 직접 호출한다.

- 공식 문서: https://performance-partners.apple.com/search-api
- 호출 제한: **분당 약 20회** (Apple 공지 기준, 변경될 수 있음)
- 이 문서의 응답 필드는 2026-10-01에 `lookup`을 실제 호출해 확인했다. `search` 응답은 같은 결과 객체 구조를 쓴다 (공식 문서 기준).

## 0. 공통

| 항목 | 값 |
|---|---|
| Base URL | `https://itunes.apple.com` |
| Method | `GET` |
| 인증 | 없음 |
| 응답 형식 | JSON (`Content-Type`이 `text/javascript`로 올 수 있음. 헤더가 아니라 본문을 JSON으로 디코딩한다) |
| 공통 쿼리 | `country=kr` (한국 스토어). `lang=ko_kr`는 지역화 필드용으로 넣어 두되, 적용 여부는 직접 확인 |

### 응답 공통 구조 (envelope)

```json
{
  "resultCount": 1,
  "results": [ { /* App 객체 */ } ]
}
```

- 결과가 없어도 **HTTP 200 + `resultCount: 0`, `results: []`** 로 온다. "결과 없음"은 에러가 아니라 빈 상태로 처리한다.

## 1. 앱 검색 — 검색 화면

```
GET /search?term={검색어}&entity=software&country=kr&limit=25
```

| 파라미터 | 필수 | 설명 |
|---|---|---|
| `term` | ✅ | 검색어. **URL 인코딩 필수** (한글, 공백). `URLComponents` + `URLQueryItem`으로 만든다 |
| `entity` | ✅ | `software` (iPhone 앱). iPad 전용 앱까지 원하면 `iPadSoftware` |
| `country` | ✅ | `kr` |
| `limit` | | 기본 50, 최대 200. 이 앱은 **25** 사용 |
| `lang` | | `ko_kr` |

**호출 규칙**
- 입력 후 **0.4초 debounce**, 앞뒤 공백 제거 후 빈 문자열이면 호출하지 않는다.
- 새 검색이 시작되면 **이전 요청을 취소**한다 (`Task` 취소). 늦게 도착한 이전 결과가 화면을 덮어쓰면 안 된다.

## 2. 앱 단건·다건 조회 — 상세, 워치리스트 화면

```
GET /lookup?id={trackId}&country=kr
GET /lookup?id={trackId},{trackId},{trackId}&country=kr
```

| 파라미터 | 필수 | 설명 |
|---|---|---|
| `id` | ✅ | `trackId`. **쉼표로 여러 개를 한 번에** 조회할 수 있다 |
| `country` | ✅ | `kr` |

- 워치리스트는 저장된 ID를 **한 번의 요청으로 묶어서** 조회한다 (앱 10개 = 요청 1회).
- 해당 국가 스토어에서 내려간 앱은 결과에서 빠진다. 요청한 ID 수와 `resultCount`가 다를 수 있으니, **빠진 ID는 "스토어에서 찾을 수 없음"으로 표시**한다.
- `bundleId`로 조회하려면 `id` 대신 `bundleId=com.example.app`.

## 3. App 객체 — 이 앱에서 쓰는 필드

전체 응답에는 40개 이상의 필드가 있지만, **아래 필드만 모델에 정의한다.** 나머지는 디코딩 시 무시된다.

| 필드 | JSON 타입 | 예시 | 옵셔널 | 사용 화면 | 주의 |
|---|---|---|---|---|---|
| `trackId` | number | `284882215` | | 전체 | 식별자. 워치리스트 저장 키 |
| `trackName` | string | `"Facebook"` | | 전체 | 앱 이름 |
| `sellerName` | string | `"Meta Platforms, Inc."` | | 검색, 상세 | 개발자명. `artistName`과 거의 같음 |
| `artworkUrl100` | string(URL) | `https://is1-ssl.mzstatic.com/...` | | 검색, 워치리스트 | 목록 아이콘 |
| `artworkUrl512` | string(URL) | | | 상세 | 큰 아이콘 |
| `averageUserRating` | number | `4.14569` | ✅ | 검색, 상세 | 소수점이 매우 길게 옴 → **Double로 받고 화면에서 소수 1자리로 포맷**. 평가가 없는 신규 앱은 필드가 없을 수 있음 |
| `userRatingCount` | number | `276025` | ✅ | 검색, 상세 | "2.8만" 같은 축약 표기는 포맷터에서 |
| `version` | string | `"581.0.0"` | | 상세, 워치리스트 | **문자열 비교 금지**. 새 버전 판정은 "저장된 값과 다른가"로만 |
| `currentVersionReleaseDate` | string(ISO 8601) | `"2026-09-30T11:45:51Z"` | | 상세, 워치리스트 | `Date`로 디코딩 (`.iso8601`). "3일 전" 표시는 `RelativeDateTimeFormatter` |
| `releaseNotes` | string | `"• 버그 수정..."` | ✅ | 상세 | 줄바꿈 `\n` 포함. 없거나 빈 문자열일 수 있음 → "릴리스 노트 없음" |
| `primaryGenreName` | string | `"Social Networking"` | | 상세 | `country=kr`이어도 **영어로 올 수 있음**. 한글이 필요하면 `genres[0]` 사용 |
| `fileSizeBytes` | **string** | `"506663936"` | | 상세 | 숫자가 아니라 **문자열**. `Int64`로 변환 후 `ByteCountFormatter` |
| `minimumOsVersion` | string | `"15.1"` | | 상세 | |
| `trackViewUrl` | string(URL) | `https://apps.apple.com/kr/app/...` | | 상세 | App Store 링크. **반드시 노출** (API 사용 조건) |
| `formattedPrice` | string | `"무료"` | ✅ | (선택) 상세 | 이미 현지화된 문자열 |

참고로 쓰지 않는 필드: `screenshotUrls`, `description`, `bundleId`, `genres`, `price`, `currency`, `releaseDate`(최초 출시일), `averageUserRatingForCurrentVersion` 등.

### 응답 예시 (lookup, 필요한 필드만 발췌)

```json
{
  "resultCount": 1,
  "results": [
    {
      "trackId": 284882215,
      "trackName": "Facebook",
      "sellerName": "Meta Platforms, Inc.",
      "artworkUrl100": "https://is1-ssl.mzstatic.com/image/thumb/.../100x100bb.jpg",
      "artworkUrl512": "https://is1-ssl.mzstatic.com/image/thumb/.../512x512bb.jpg",
      "averageUserRating": 4.14569,
      "userRatingCount": 276025,
      "version": "581.0.0",
      "currentVersionReleaseDate": "2026-09-30T11:45:51Z",
      "releaseNotes": "저희 팀은 ...",
      "primaryGenreName": "Social Networking",
      "fileSizeBytes": "506663936",
      "minimumOsVersion": "15.1",
      "trackViewUrl": "https://apps.apple.com/kr/app/facebook/id284882215",
      "formattedPrice": "무료"
    }
  ]
}
```

## 4. 모델 설계 지침

정답 코드는 주지 않는다. 아래 기준으로 직접 설계한다.

- **응답용 타입(DTO)과 화면용 타입을 처음부터 나눌지**는 1주차에는 자유. 2주차에 DTO ↔ Entity 분리를 하게 되므로, 1주차에 한 타입으로 짰다면 그 불편함을 기록해 둔다.
- 디코딩은 `JSONDecoder` + `dateDecodingStrategy = .iso8601`.
- 옵셔널 표시된 필드를 non-optional로 선언하면 **신규 앱 하나 때문에 검색 결과 전체 디코딩이 실패**한다. 이 케이스를 1주차 DTO 디코딩 테스트에 꼭 넣는다.
- `fileSizeBytes`처럼 타입이 어긋난 필드는 DTO에서는 원래 타입(String)으로 받고, 변환은 매핑 단계에서 한다.

## 5. 워치리스트 로컬 저장 (v1)

| 항목 | 값 |
|---|---|
| 저장소 | `UserDefaults` (v1). 2주차 이후 Repository 뒤로 숨김 |
| 저장 단위 | `trackId` + 저장 시점의 `version` + 저장 시각 |
| 새 버전 판정 | 조회한 `version` ≠ 저장된 `version` |
| 확인 처리 | 상세 화면을 열면 저장된 `version`을 최신으로 갱신 → 배지 사라짐 |

## 6. 에러 처리

| 상황 | 증상 | 화면 처리 |
|---|---|---|
| 결과 없음 | 200, `resultCount: 0` | 빈 상태 (`ContentUnavailableView.search`) |
| 오프라인·타임아웃 | `URLError` (`.notConnectedToInternet`, `.timedOut`) | "인터넷 연결을 확인해 주세요" + 다시 시도 |
| 요청 취소 | `URLError.cancelled` / `CancellationError` | **아무것도 표시하지 않음** (새 검색으로 대체된 것) |
| 호출 제한 초과 | 2xx가 아닌 상태 코드 (403 등으로 알려져 있음) | "잠시 후 다시 시도해 주세요" |
| 기타 비정상 상태 코드 | 2xx 외 | 일반 오류 메시지 |
| 디코딩 실패 | `DecodingError` | 일반 오류 메시지 + 디버그 로그에 원인 출력 |

- 상태 코드는 `HTTPURLResponse.statusCode`로 직접 확인한다. `URLSession`은 4xx/5xx를 에러로 던지지 않는다.

## 7. 테스트용 고정 응답 (fixtures)

테스트는 실제 네트워크를 쓰지 않는다 (CLAUDE.md 규칙).

1. 브라우저에서 아래 URL을 열어 응답을 저장한다.
   - `lookup?id=284882215&country=kr` → `lookup_single.json`
   - `lookup?id=284882215,{다른 ID}&country=kr` → `lookup_multiple.json`
   - `search?term=가계부&entity=software&country=kr&limit=3` → `search_kr.json`
2. 아래 두 개는 저장한 파일을 손으로 고쳐 만든다.
   - `lookup_missing_optionals.json`: `averageUserRating`, `userRatingCount`, `releaseNotes` 제거
   - `search_empty.json`: `{"resultCount":0,"results":[]}`
3. 테스트 타깃의 `Fixtures/` 폴더에 넣고 `Bundle.module` 또는 테스트 번들에서 읽는다.

## 8. 하지 않는 것

- 결과로 **순위를 매기거나** 카테고리 순위표 만들기
- 아이콘·스크린샷 이미지를 파일로 저장해 재배포 (화면 표시용 캐시는 `URLCache`/`AsyncImage` 기본 동작으로 충분)
- 검색 입력마다 즉시 호출 (debounce 없이)
