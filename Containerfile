FROM openmamba/openmamba:latest

COPY . /srv

# workaround https://openmamba.org/en/forums/topic/docker-image-fails-to-update/#post-29474
RUN echo '%__transaction_unshare %{nil}' > /etc/rpm/macros.transaction_unshare && \
  dnf update --nogpgcheck --refresh --assumeyes && \
  dnf install --nogpgcheck --assumeyes git make gcc glibc-devel imagemagick && \
  git clone --depth=1 https://github.com/vlang/v /opt/v && \
  cd /opt/v && \
  make && \
  cd /srv && \
  /opt/v/v install && \
  /opt/v/v . -o mombaomusic && \
  rm -rf /opt/v && \
  rm -rf /root/.vmodules && \
  dnf remove --assumeyes git make gcc glibc-devel && \
  dnf clean all

WORKDIR /srv

CMD ["./mombaomusic"]

EXPOSE 8080