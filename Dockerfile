FROM python:3.9

# 시스템 패키지 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential libssl-dev python3-dev git curl \
      libpng-dev wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Chrome 및 ChromeDriver 설치
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    sh -c 'echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' && \
    apt-get update && \
    apt-get install -y google-chrome-stable && \
    wget -O /tmp/chromedriver.zip https://chromedriver.storage.googleapis.com/$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ && \
    rm /tmp/chromedriver.zip

RUN groupadd -r python && useradd -r -g python python

# Python 환경 설정
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# pip 업그레이드 및 의존성 설치
RUN python -m pip install --upgrade pip

# 작업 디렉토리 설정
WORKDIR /app

# 의존성 파일 복사 및 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 파일 복사
COPY . .

# 권한 및 소유자 설정 (루트 사용자로 실행)
RUN chown -R python:python /app
RUN chmod +x /app/entrypoint.sh
RUN chmod +x /app/discordbot.py

# 사용자 전환
USER python

# 엔트리포인트 설정
ENTRYPOINT ["/app/entrypoint.sh"]

# 애플리케이션 시작
CMD ["python3", "discordbot.py"]
