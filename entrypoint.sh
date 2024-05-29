#!/usr/bin/bash
set -e

# 디렉토리 소유자 변경 (루트 권한으로 실행)
# sudo chown -R python:python /app
# sudo chmod -R 775 /app

# 파일 권한 설정 (예: discordbot.py)
chmod +x /app/discordbot.py

exec "$@"
