
echo "------------------------------开始构建编译镜像------------------------------"
docker build -t yuukoblogbuild -f src/YuukoBlog/dockerfile.build .
if [ $? != 0 ]
then
     echo "------------------------------构建编译镜像失败，错误code：$?，退出。------------------------------"
	 exit $?
 fi
echo "------------------------------构建编译镜像成功------------------------------" 

echo "------------------------------开始运行编译镜像------------------------------"
docker run -d --privileged=true --name yuukoblog -v ${JENKINS_HOME}/jobs/${JOB_NAME%/*}/builds/${BUILD_NUMBER}/:/appdata yuukoblogbuild
docker attach yuukoblog
run_result_code=$(docker wait yuukoblog)
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
    docker rm -vf yuukoblog
fi
docker rmi -f yuukoblogbuild
echo "------------------------------清理结束------------------------------"


echo "------------------------------开始发布------------------------------"
echo "------------------------------备份发布文件------------------------------"
ssh -vvv root@173.254.200.84 "rm -rf /root/project/yuukoblog/backup ; mv -f /root/project/yuukoblog/deploy /root/project/yuukoblog/backup"

echo "------------------------------上传发布文件------------------------------"
scp -r ${JENKINS_HOME}/jobs/${JOB_NAME%/*}/builds/${BUILD_NUMBER} root@173.254.200.84:/root/project/yuukoblog/deploy
if [ $? != 0 ]
then
	echo "------------------------------上传发布文件失败，错误code：$?，退出。------------------------------"
		exit $?
fi
echo "------------------------------执行发布脚本------------------------------"
ssh root@173.254.200.84 "chmod +x  /root/project/yuukoblog/deploy/deploy.sh ; /root/project/yuukoblog/deploy/deploy.sh"
echo "------------------------------发布结束------------------------------"