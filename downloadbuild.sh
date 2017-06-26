#!/bin/sh

#默认是Release模式
branch="wsy_02_24"
userName="wangshengyuan"
userPwd="wangWANG1234"
shellpath=$(cd "$(dirname "$0")"; pwd)
projectName="tronker-ios"

PATHS=$shellpath/$projectName
echo "$PATHS";
if [ -e ${PATHS} ]; then
echo "******************************* 存在项目文件,更新 ****************************";
cd $PATHS
git pull
else
cd $shellpath
git clone \
-b "$branch" \
http://${userName}:${userPwd}@192.168.1.13/tronker-mobile-ios/tronker-ios.git
cd "$projectName"
fi

ppath=$(pwd)

echo $ppath

sh ${shellpath}/AutoBuild.sh $ppath
