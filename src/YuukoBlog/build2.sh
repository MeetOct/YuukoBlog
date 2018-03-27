
echo "------------------------------开始构建编译镜像------------------------------"
docker build -t blogbuildimage -f src/YuukoBlog/dockerfile.build .
if [ $? != 0 ]
then
     echo "------------------------------构建编译镜像失败，错误code：$?，退出。------------------------------"
	 exit $?
 fi
echo "------------------------------构建编译镜像成功------------------------------" 

echo "------------------------------开始运行编译镜像------------------------------"
docker run -d --privileged=true --name blogbuild -v /root/project/yuukoblog/deploy/:/appdata blogbuildimage
docker attach blogbuild
run_result_code=$(docker wait blogbuild)
if [ "$run_result_code" != 0 ]
then
    echo "------------------------------运行编译镜像失败，错误code：$run_result_code，退出。------------------------------"
	exit $run_result_code
else
    echo "------------------------------运行编译镜像成功------------------------------"
fi

echo "------------------------------开始清理------------------------------"
if [ "$run_result_code" == 0 ]
then
    docker rm -vf blogbuild
fi
docker rmi -f blogbuildimage
echo "------------------------------清理结束------------------------------"

echo "------------------------------开始构建运行镜像------------------------------"
docker build -t blogimage -f /root/project/yuukoblog/deploy/dockerfile.deploy /root/project/yuukoblog/deploy/
if [ $? != 0 ]
then
     echo "------------------------------构建编译镜像失败，错误code：$?，退出。------------------------------"
	 exit $?
 fi
echo "------------------------------构建编译镜像成功------------------------------" 

echo "------------------------------开始运行编译镜像------------------------------"
docker run -d --name blog -p 5000:5000 -v /root/docker/volumes/blog/sqlite:/dotnetapp/sqlite blogimage
docker logs blog

echo "------------------------------开始清理------------------------------"
docker rmi -f blogimage
echo "------------------------------清理结束------------------------------"