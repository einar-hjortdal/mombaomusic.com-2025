# Mombaomusic.com

## Deploy

```bash
sudo dnf install docker docker-buildx
docker buildx build --tag mombaomusic-app --file Containerfile . --load
```doc