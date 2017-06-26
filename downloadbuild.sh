#!/bin/sh

#默认是Release模式
#作者：王声远
branch="wsy_02_24"
userName="git用户名"
userPwd="git密码"
shellpath=$(cd "$(dirname "$0")"; pwd)
projectName="项目名称"

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
http://${userName}:${userPwd}@项目的git地址
cd "$projectName"
fi

ppath=$(pwd)

echo $ppath

sh ${shellpath}/AutoBuild.sh $ppath
