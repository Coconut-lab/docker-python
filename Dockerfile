FROM python:3.9

# 시스템 패키지 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential libssl-dev python3-dev git curl imagemagick \
      default-libmysqlclient-dev libsqlite3-dev libpng-dev libpq-dev wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Chrome 및 ChromeDriver 설치
RUN apt-get update -y && apt-get install -y wget xvfb unzip jq
RUN apt-get install -y libxss1 libappindicator1 libgconf-2-4 \
  fonts-liberation libasound2 libnspr4 libnss3 libx11-xcb1 libxtst6 lsb-release xdg-utils \
  libgbm1 libnss3 libatk-bridge2.0-0 libgtk-3-0 libx11-xcb1 libxcb-dri3-0

RUN curl -s https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json > /tmp/versions.json

RUN CHROME_URL=$(jq -r '.channels.Stable.downloads.chrome[] | select(.platform=="linux64") | .url' /tmp/versions.json) && \
  wget -q --continue -O /tmp/chrome-linux64.zip $CHROME_URL && \
  unzip /tmp/chrome-linux64.zip -d /opt/chrome

RUN chmod +x /opt/chrome/chrome-linux64/chrome

RUN CHROMEDRIVER_URL=$(jq -r '.channels.Stable.downloads.chromedriver[] | select(.platform=="linux64") | .url' /tmp/versions.json) && \
  wget -q --continue -O /tmp/chromedriver-linux64.zip $CHROMEDRIVER_URL && \
  unzip /tmp/chromedriver-linux64.zip -d /opt/chromedriver && \
  chmod +x /opt/chromedriver/chromedriver-linux64/chromedriver

ENV CHROMEDRIVER_DIR /opt/chromedriver
ENV PATH $CHROMEDRIVER_DIR:$PATH

RUN rm /tmp/chrome-linux64.zip /tmp/chromedriver-linux64.zip /tmp/versions.json

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

# 사용자 및 그룹 추가
RUN groupadd -r python && useradd -r -g python python

# 권한 설정
RUN chown -R python:python /app

# entrypoint.sh 파일 복사
COPY entrypoint.sh .

# 애플리케이션 시작
ENTRYPOINT ["/app/entrypoint.sh"]
