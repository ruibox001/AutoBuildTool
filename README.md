#AutoBuildTool
#自动编译打包工具

#使用方法
一、在AutoBuildTool目录下执行shell脚本可以完成编译和打包

如执行命令 [sh AutoBuildTool.sh xcodeproject path]
1.xcodeproject path -> iOS工程目录是iOS工程的根目录

二、编译时生成的App文件/ipa文件
编译时通过derivedDataPath目录制定编译的目标文件地址
app文件生成目录：工程目录/AutoBuildPath/Build/Products/Release-iphoneos/SofficeMoi.app
ipa文件生成目录：工程目录/AutoBuildPath/Build/Products/Release-iphoneos/ipa/SofficeMoi_20170110_1453.ipa

参数配置
可以在jenkins里的参数化构建过程中配置相应的编译项
1、ProjectName 参数是输出IPA的项目名称，如ProjectName=Soffice 该参数不填写时默认值是项目名称
2、config 是GCC预编译的选项 可以给程序编译时传入一些参数，多个参数使用空格分开 如：TestConfig=1 DEBUG=0这样在代码里通过#ifdef可以判断已经存在TestConfig和DEBUG了，如果不需要DEBUG怎不需要输入。
3、VersionNumber 参数配置该打包的版本号，如2.0.0
4、BuildNumber 参数是配置打包的构建版本，如100
5、CodeSign 参数配置证书名称, 如：iPhone Developer: liqiao deng (G8ZSSJ7T4J)
6、Profile 参数配置描述文件, 如：248e5acc-3ceb-4a4c-8e7d-70ef9b392408
7、exportConfig 配置编译是Adhoc或Appstore, 默认是Adhoc

