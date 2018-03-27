
docker build -t yuukoblogbuild -f /root/project/yuukoblog/deploy/dockerfile.deploy /root/project/yuukoblog/deploy
docker rm -f yuukoblog
docker run -d --name yuukoblog -p 5000:5000  -v /root/docker-volumes/blog/sqlite:/dotnetapp/sqlite yuukoblogbuild