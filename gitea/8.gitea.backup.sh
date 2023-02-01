set -x
YYYYMMDDhhmmss=$(date +%Y%m%d%H%M%S)
sudo tar zcvf gitea."${YYYYMMDDhhmmss}".tgz gitea
