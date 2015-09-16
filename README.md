# u-boot-for-tplink-wr740n-v4

设定交叉工具链路径:
export PATH=$PATH:~/gcc-4.3.3/build_mips/staging_dir/usr/bin

编译命令:
make tplink_wr740n_v4

清理中间文件,不包括印映像文件:
make clean

清理所有编译生成的文件:
make clean_all