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

# Chrome 의존성 패키지 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libu2f-udev \
        libvulkan1 \
        && \
    rm -rf /var/lib/apt/lists/*

# Chrome 버전 125.0.6422.113 다운로드
RUN CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb" && \
    wget -q --continue -O /tmp/chrome.deb $CHROME_URL && \
    dpkg -i /tmp/chrome.deb && \
    rm /tmp/chrome.deb

# ChromeDriver 버전 114.0.5735.90 다운로드
RUN CHROMEDRIVER_URL="https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip" && \
    wget -q --continue -O /tmp/chromedriver.zip $CHROMEDRIVER_URL && \
    unzip /tmp/chromedriver.zip -d /opt/chromedriver && \
    chmod +x /opt/chromedriver/chromedriver && \
    rm /tmp/chromedriver.zip

# 임시 파일 삭제 (필요한 경우)
RUN if [ -f /tmp/chrome-linux64.zip ] && [ -f /tmp/chromedriver-linux64.zip ] && [ -f /tmp/versions.json ]; then \
        rm /tmp/chrome-linux64.zip /tmp/chromedriver-linux64.zip /tmp/versions.json; \
    fi

ENV CHROMEDRIVER_DIR /opt/chromedriver
ENV PATH $CHROMEDRIVER_DIR:$PATH

# RUN rm /tmp/chrome-linux64.zip /tmp/chromedriver-linux64.zip /tmp/versions.json

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

#작업 디렉터리 소유권 변경
RUN chown -R python:python /app

USER python

# 사용자 및 그룹 추가
# RUN groupadd -r python && useradd -r -g python python

# 권한 설정
# RUN chown -R python:python /app

# 애플리케이션 시작
ENTRYPOINT ["/app/entrypoint.sh"]
