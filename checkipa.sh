#!/bin/sh

#检查输入的文件是否是ipa文件
echo "******************************* 检测参数状态 *********************************";

if [ $# -eq 1 ] ; then
    IPA_PATH=$1;
    if [ ! -e $IPA_PATH ]; then
    echo "\nError: [parameter '$IPA_PATH' must be a valid ipa_file]";
    echo "Usage: [sh $0 ipa_path]\n";
    exit 1;
    fi
else
echo "\nUsage: [sh $0 ipa_path]\n";
exit 1;
fi

#输入Your Apple ID
echo "\nInut Your Apple ID:"
read uName

#输入Your Apple Password
echo "\nInut Your Apple Password:"
read -s uPwd

echo "\n******************************* 校验文件：$IPA_PATH *********************************";

#通过altool工具检查IPA是否合格
result=$(/Applications/Xcode.app/Contents/Applications/Application\ Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool \
--validate-app \
-f $IPA_PATH \
-t ios \
-u $uName \
-p $uPwd)

echo "输出的结果信息：$result"
echo "\n******************************* 执行完成 *******************************\n";
errors="No errors"
if [[ $result =~ $errors ]]; then
echo "校验文件成功了"
else
echo "校验文件出错了"
fi
