#!/bin/sh

#默认是Release模式
STATUS="Release"
shellpath=$(cd "$(dirname "$0")"; pwd)
#默认是打测试包的
adhocPlist="$shellpath/AdHocExportOptions.plist"
appstorePlist="$shellpath/AppStoreExportOptions.plist"
cPlist="Adhoc"
exportPlist=$adhocPlist

if [ -n "$exportConfig" ] && [ "$exportConfig" = "Appstore" ]; then
    exportPlist=$appstorePlist
    cPlist="Appstore"
    STATUS="Release"
fi

echo "\n******************************* 检测参数状态 *********************************";

if [ $# -eq 1 ]; then
    PROJECTPATH=$1;
    if [ ! -d $PROJECTPATH ]; then
    echo "\nError: [parameter '$PROJECTPATH' must be a valid directory]";
    echo "Usage: [sh $0 ProjectPath]\n"
    exit 1;
    fi
else
    echo "\nError: parameter error"
    echo "Usage: [sh $0 ProjectPath]\n"
exit 1;
fi

echo "******************************* $STATUS 状态 *********************************";
echo "******************************* $cPlist 状态 *********************************";
echo "******************************* 导出配置文件：$exportPlist";

cd $PROJECTPATH;

for file in *
do
    if [[ $file =~ ".xcodeproj" ]]; then
        temps=$file
        PROJECT_NAME=${temps%%.xcodeproj};
    fi
done

#判断项目目录是否有效
if [ ! -e ${PROJECTPATH}/${PROJECT_NAME}.xcodeproj ]; then
    echo "\nError: '$PROJECTPATH' not a xcode project path *******************************\n";
exit 1;
fi

#Info.plist文件的位置
Info_plist=./${PROJECT_NAME}/Info.plist

#修改版本号
if [ -n "$VersionNumber" ]; then
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VersionNumber" ${Info_plist}
echo "******************************* 修改版本号=$VersionNumber ******************************";
fi

#修改build号
if [ -n "$BuildNumber" ]; then
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BuildNumber" ${Info_plist}
echo "******************************* 修改构建号=$BuildNumber ******************************";
fi

echo "******************************* 检测参数合格 *********************************";
echo "******************************* 开始编译项目 *********************************";
DATE=$(date '+%Y%m%d-%H:%M')
echo "******************************* 编译日期：$DATE ****************************";

#删除上次配置的垃圾文件
PATHS=$shellpath/AutoBuildPath
if [ ! -e ${PATHS} ]; then
    mkdir $PATHS;
else
    echo "******************************* 删除垃圾文件 ****************************";
#    rm -rf ${PATHS}/*
fi

#判断证书是否输入
if [ ! -n "$CodeSign" ]; then
    CodeSign="iPhone Developer";
    echo "******************************* 证书使用默认 ****************************";
fi

if [ ! -n "$Profile" ]; then
    Profile="Automatic";
fi

echo "******************************* 编译配置信息：$config ******************************* ";
echo "************************ CodeSign：$CodeSign ******************** ";
echo "************************ Profile信息：$Profile ****************** ";
sleep 1

#判断项目是否为空
if [ ! -n "$ProjectName" ]; then
ProjectName=$PROJECT_NAME
echo "******************************* IPA使用项目名称：$ProjectName ***************************** \n";
else
echo "******************************* 输入的IPA指定名称：$ProjectName ******************************* \n";
fi

#当前工程目录
APPPATH=$PATHS/Build/Products/$STATUS-iphoneos/$PROJECT_NAME.app
IPAPATH=$PATHS/Build/Products/$STATUS-iphoneos/ipa
ARCHIVEPATH=$PATHS/Build/Products/$STATUS-iphoneos/${ProjectName}-${STATUS}.xcarchive
IPANAME=${ProjectName}-${STATUS}_${DATE}.ipa

echo $APPPATH
echo $IPAPATH
echo $ARCHIVEPATH
echo $IPANAME

#exit 1;

#判断当前工程是否使用CocoaPods
if [ -e ${PROJECTPATH}/${PROJECT_NAME}.xcworkspace ]; then
echo "\n该将要打包的项目使用了CocoaPods ******************************* 将要编译xcworkspace\n";
/usr/bin/xcodebuild archive \
-workspace $PROJECTPATH/$PROJECT_NAME.xcworkspace \
-scheme $PROJECT_NAME \
GCC_PREPROCESSOR_DEFINITIONS="$config" \
-configuration $STATUS \
build \
CODE_SIGN_IDENTITY="$CodeSign" \
PROVISIONING_PROFILE="$Profile" \
-derivedDataPath $PATHS \
-archivePath $ARCHIVEPATH
else
echo "\n该将要打包的项目不使用CocoaPods ******************************* 将要编译xcodeproj\n";
/usr/bin/xcodebuild archive \
-scheme $PROJECT_NAME \
GCC_PREPROCESSOR_DEFINITIONS="$config" \
-configuration $STATUS \
build \
CODE_SIGN_IDENTITY="$CodeSign" \
PROVISIONING_PROFILE="$Profile" \
-derivedDataPath $PATHS \
-archivePath $ARCHIVEPATH
fi

#判断编译状态(通过app是否存在和大小判断的)
maxsize=$((1024))
if [ -e ${APPPATH} ]; then
    filesize=`du -s $APPPATH  | awk '{ print $1 }'`
    filesizes=`du -h -s $APPPATH  | awk '{ print $1 }'`
    echo "\n******************************* 生成APP文件大小 ${filesizes} *******************************\n"
    if [ $filesize -lt $maxsize ]; then
    echo "\n******************************* 编译失败 *******************************\n";
    exit 1;
    else
    echo "\n******************************* 编译成功 *******************************\n";
    fi
else
echo "\n******************************* 编译失败 *******************************\n";
exit 1;
fi

/usr/bin/xcodebuild -exportArchive -archivePath "$ARCHIVEPATH" \
-exportOptionsPlist "$exportPlist" \
-exportPath "$IPAPATH" \
CODE_SIGN_IDENTITY="$CodeSign" \
PROVISIONING_PROFILE="$Profile"

if [ -e ${IPAPATH}/${PROJECT_NAME}.ipa ]; then
mv ${IPAPATH}/${PROJECT_NAME}.ipa ${IPAPATH}/${IPANAME}
echo "\n******************************* 打包成功 *******************************\n";
else
echo "\n******************************* 打包失败 *******************************\n";
exit 1;
fi

echo "\n编译成功 >> 目标路径: $IPAPATH\n";
