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
│   │   │   ├── inquiries/  # 문의 관리
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
- **Firestore 역할 검증**: `users/{uid}` 또는 `admins/{uid}`에서 `role === 'ADMIN'` 확인
- ADMIN이 아닐 경우 즉시 로그아웃 후 접근 차단
- Firebase ID Token은 AuthContext에서 관리
