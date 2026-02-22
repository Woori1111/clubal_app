#!/bin/bash
# Flutter 웹 빌드 (도메인 clubal.co.kr 적용)
# 사용: ./scripts/build_web.sh        → https://clubal.co.kr/
#       ./scripts/build_web.sh /app/  → 서브경로용

set -e
BASE_HREF="${1:-/}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "📦 Flutter web build for clubal.co.kr (base-href: $BASE_HREF)"
cd "$PROJECT_ROOT"
flutter build web --base-href "$BASE_HREF"
echo "✅ 빌드 완료: $PROJECT_ROOT/build/web"
echo "   배포: firebase deploy --only hosting"
