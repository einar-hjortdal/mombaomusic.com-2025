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
  --env=TYPEKIT_CODE=xxxxxxx \
  --env=BANDSINTOWN_API_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  --env=CACHE_DURATION=43200 \
  mombaomusic-app

# now configure the web server
```