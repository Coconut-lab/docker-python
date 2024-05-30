#!/bin/sh

# 필요한 디렉터리에 대한 권한 설정
chmod -R 777 /app

# 애플리케이션 실행
su -c "python3 /app/discordbot.py" python
