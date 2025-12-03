FROM openmamba/openmamba:latest

COPY . /srv

RUN dnf update --refresh --assumeyes && \
  dnf install -y git make gcc && \
  git clone --depth=1 https://github.com/vlang/v /usr/local/v && \
  cd /usr/local/v && \
  make && \
  cd /srv && \
  /usr/local/v/v -prod .

CMD ["/srv/mombaomusic"]

EXPOSE 8080