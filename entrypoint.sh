#!/usr/bin/bash
set -e

# 디렉토리 권한 설정
chmod -R python:python /app
chmod -R 775 /app

# 파일 권한 설정 (예: discordbot.py)
chmod +x /app/discordbot.py

exec "$@"
