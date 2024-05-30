#!/bin/sh

# 필요한 디렉터리에 대한 권한 설정
chmod -R 755 /app

# 애플리케이션 실행
python3 /app/discordbot.py
