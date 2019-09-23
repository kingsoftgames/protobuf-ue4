# protobuf-ue4
Build Protobuf for Unreal Engine 4 with Jenkins Pipeline.


备注：

（1）在windows、linux、mac、ios、android平台下都生成静态库。

（2）在windows平台下生成protoc.exe、include文件夹，所有平台共用windows平台生成的include文件夹。

（3）如果特定版本的include文件夹中有源码修改，则添加对应版本的Fix-VERSION.bat文件，参看Fix-3.6.1.bat。

