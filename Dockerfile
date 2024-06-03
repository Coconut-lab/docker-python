FROM python:3.9

# 시스템 패키지 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential libssl-dev python3-dev git curl imagemagick \
    default-libmysqlclient-dev libsqlite3-dev libpng-dev libpq-dev wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Chrome 및 ChromeDriver 설치
RUN apt-get update && apt-get install -y wget xvfb unzip jq libxss1 libappindicator1 libgconf-2-4 \
    fonts-liberation libasound2 libnspr4 libnss3 libx11-xcb1 libxtst6 lsb-release xdg-utils \
    libgbm1 libnss3 libatk-bridge2.0-0 libgtk-3-0 libx11-xcb1 libxcb-dri3-0 \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && CHROMEDRIVER_URL="https://storage.googleapis.com/chrome-for-testing-public/125.0.6422.141/linux64/chrome-linux64.zip" \
    && wget -q -O /tmp/chromedriver.zip $CHROMEDRIVER_URL \
    && unzip /tmp/chromedriver.zip -d /opt/chromedriver \
    && chmod +x /opt/chromedriver/chromedriver \
    && rm /tmp/chromedriver.zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

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
