# Mombaomusic.com

## Deploy

```bash
sudo dnf install docker docker-buildx && \
sudo usermod -aG docker $USER && \
sudo reboot

# after reboot:
docker buildx build --tag mombaomusic-app --file Containerfile . --load
docker run \
  --rm \
  --detach \
  --name=mombaomusic-app \
  --publish=8080:12200 \
  mombaomusic-app

# now configure the web server
```doc