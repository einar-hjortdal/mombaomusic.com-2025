FROM openmamba/openmamba:latest

COPY . /srv

# workaround https://openmamba.org/en/forums/topic/docker-image-fails-to-update/#post-29474
RUN echo '%__transaction_unshare %{nil}' > /etc/rpm/macros.transaction_unshare && \
  dnf update --nogpgcheck --refresh --assumeyes && \
  dnf install --nogpgcheck --assumeyes git make gcc glibc-devel && \
  git clone --depth=1 https://github.com/vlang/v /usr/local/v && \
  cd /usr/local/v && \
  make && \
  cd /srv && \
  /usr/local/v/v install && \
  /usr/local/v/v -prod . -o mombaomusic

WORKDIR /srv

CMD ["./mombaomusic"]

EXPOSE 8080