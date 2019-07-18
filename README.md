# protobuf-ue4
Build Protobuf for Unreal Engine 4 with Jenkins Pipeline.


备注：

（1）在windows、linux、mac、ios、android平台下都生成静态库。

（2）在windows平台下生成protoc.exe、include文件夹，所有平台共用windows平台生成的include文件夹。

（3）基于protobuf-3.6.1源码，修改stringstream、ostringstream、string使用unreal的内存分配，通过UNREAL_PROTOBUF_ALLOCATOR控制开关。