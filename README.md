# Mombaomusic.com

## Deploy

```bash
sudo dnf install docker docker-buildx && \
sudo usermod -aG docker $USER && \
sudo systemctl enable --now docker.socket
sudo reboot

# after reboot:
docker buildx build --tag mombaomusic-app --file Containerfile . --load
docker run \
  --rm \
  --detach \
  --name=mombaomusic-app \
  --publish=12200:8080 \
  mombaomusic-app

# now configure the web server
```doc