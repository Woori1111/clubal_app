# Clubal 관리자 웹

Clubal 서비스 관리자 전용 웹 애플리케이션입니다.

## 요구사항

- Node.js 18+
- npm 또는 yarn

## 설치

```bash
cd clubal-admin-web
npm install
```

## 환경 설정

`.env.example`을 복사하여 `.env.local`을 만들고 Firebase 설정을 입력하세요.

```bash
cp .env.example .env.local
```

`.env.local` 예시:

```
NEXT_PUBLIC_FIREBASE_API_KEY=...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-app.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-app.firebasestorage.app
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=...
NEXT_PUBLIC_FIREBASE_APP_ID=...
```

## 실행

```bash
# 개발 모드 (http://localhost:3000)
npm run dev

# 프로덕션 빌드
npm run build

# 프로덕션 실행
npm start
```

## 프로젝트 구조

```
clubal-admin-web/
├── src/
│   ├── app/
│   │   ├── login/          # 관리자 로그인 (Firebase Auth)
│   │   ├── (admin)/        # 관리자 전용 페이지 (인증 필요)
│   │   │   ├── dashboard/  # 대시보드
│   │   │   ├── users/      # 유저 관리
│   │   │   ├── announcements/ # 공지 관리
│   │   │   ├── inquiries/  # 문의 관리 (고객 문의)
│   │   │   ├── logs/       # 관리자 로그
│   │   │   ├── reports/    # 제보 관리
│   │   │   └── search/     # 통합 검색
│   │   └── layout.tsx
│   ├── components/
│   │   └── layout/         # AdminSidebar, AdminLayout
│   ├── contexts/
│   │   └── AuthContext.tsx # Firebase 인증 상태 관리
│   └── lib/
│       └── firebase.ts     # Firebase 초기화
├── package.json
└── next.config.js
```

## 인증

- **Firebase Authentication**: `signInWithEmailAndPassword`로 로그인
- **Firestore 역할 검증**: `admins/{uid}` 문서의 `role` 필드 또는 `users/{uid}`의 `role === 'ADMIN'` 확인
- ADMIN이 아닐 경우 즉시 로그아웃 후 접근 차단
- Firebase ID Token은 AuthContext에서 관리

## Firestore 구조 (고도화 버전)

### admins 컬렉션
- 경로: `admins/{uid}`
- 필드: `role` (`super` | `editor` | `support`), `email`, `displayName`, `createdAt`(선택)
- 역할별 권한:
  - **super**: 전체 메뉴 (공지, 유저, 문의, 로그)
  - **editor**: 공지, 문의, 로그 (유저 관리 제외)
  - **support**: 문의 관리만

### announcements 컬렉션
- 필드: `title`, `content`, `createdBy`, `createdAt`, `updatedAt`, `viewCount`, `isPinned`, `isActive`

### support_tickets 컬렉션
- 필드: `userId`, `userEmail`, `userName`, `subject`, `message`, `status`(open|in_progress|closed), `priority`, `reply`, `repliedBy`, `repliedAt`, `createdAt`, `updatedAt`

### admin_logs 컬렉션
- 액션: `announcement_create`, `announcement_update`, `announcement_delete`, `ticket_status_change`, `ticket_reply`

## Firestore 인덱스

복합 쿼리 사용 시 인덱스가 필요합니다. Firebase Console에서 오류 메시지 링크로 생성하거나:

```bash
firebase deploy --only firestore:indexes
```

`firestore.indexes.json` 파일이 프로젝트 루트에 포함되어 있습니다.
