#!/bin/bash
set -e

# 디렉토리 소유자 변경
chown -R python:python /app
chmod -R 775 /app

# 파일 권한 설정 (예: discordbot.py)
chmod +x /app/discordbot.py

exec "$@"
