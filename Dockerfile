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

# Chrome 및 ChromeDriver 버전 지정
ENV CHROME_VERSION="125.0.6422.112"
ENV CHROMEDRIVER_VERSION="125.0.6422.78"

# Chrome 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    google-chrome-stable=${CHROME_VERSION} \
    fonts-liberation && \
    rm -rf /var/lib/apt/lists/*

# ChromeDriver 설치
RUN CHROMEDRIVER_URL="https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip" && \
    wget -q --continue -O /tmp/chromedriver.zip $CHROMEDRIVER_URL && \
    unzip /tmp/chromedriver.zip -d /opt/chromedriver && \
    chmod +x /opt/chromedriver/chromedriver && \
    rm /tmp/chromedriver.zip

# Chrome 의존성 패키지 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libu2f-udev \
    libvulkan1 \
    && \
    rm -rf /var/lib/apt/lists/*

# 임시 파일 삭제 (필요한 경우)
RUN if [ -f /tmp/chrome-linux64.zip ] && [ -f /tmp/chromedriver-linux64.zip ] && [ -f /tmp/versions.json ]; then \
    rm /tmp/chrome-linux64.zip /tmp/chromedriver-linux64.zip /tmp/versions.json; \
fi

ENV CHROMEDRIVER_DIR /opt/chromedriver
ENV PATH $CHROMEDRIVER_DIR:$PATH

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

# entrypoint.sh 파일 복사 및 권한 설정
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# 사용자 추가
RUN adduser --disabled-password --gecos '' python

# 작업 디렉터리 소유권 변경
RUN chown -R python:python /app

USER python

# 애플리케이션 시작
ENTRYPOINT ["/app/entrypoint.sh"]
