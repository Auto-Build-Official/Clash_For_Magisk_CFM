#!/system/bin/sh

# 请不要硬编码/magisk/modname/...;相反，请使用$MODDIR/...
# 这将使您的脚本兼容，即使Magisk以后改变挂载点
MODDIR=${0%/*}

# 此脚本将在post-fs-data模式下执行

linux_root='/data/00AA_Linux_App'
crontabs_file='/system/etc/00AA_Linux_App/template'
crontabs_dir='/data/00AA_Linux_App/var/spool/cron/crontabs'
log_dir='/data/00AA_Linux_App/LOG'
customize_dir='/data/00AA_Linux_App/customize'

appid_file="/data/00AA_Linux_App/Clash/appid.list"


initialization(){

########目录########

#挂载系统可写
mount -o remount,rw /

#创建定时器目录(/var)
if [ ! -d ${crontabs_dir} ];then
mkdir -p ${crontabs_dir} 2>/dev/null
fi

#挂载系统可写
#mount -o remount,rw /
#将位于/data的定时器目录链接到根目录(/var)
rm -rf /var
ln -s ${linux_root}/var /var
#恢复系统只读
#mount -o remount,ro /

#创建LOG目录
if [ ! -d ${log_dir} ];then
mkdir -p ${log_dir} 2>/dev/null
fi
#创建自定义目录
if [ ! -d ${customize_dir}/cron ];then
mkdir -p ${customize_dir}/cron 2>/dev/null
fi

#创建Clash目录
if [ ! -d ${linux_root}/Clash ];then
mkdir -p ${linux_root}/Clash 2>/dev/null
fi
if [ ! -d ${linux_root}/Clash/template ];then
mkdir -p ${linux_root}/Clash/template 2>/dev/null
fi
if [ ! -d ${linux_root}/Clash/tmp ];then
mkdir -p ${linux_root}/Clash/tmp 2>/dev/null
fi
if [ ! -d ${linux_root}/Clash/download ];then
mkdir -p ${linux_root}/Clash/download 2>/dev/null
fi




########文件########

#创建自定义定时器文件
if [ ! -f ${customize_dir}/cron/crontabs.txt ];then
touch ${customize_dir}/cron/crontabs.txt 2>/dev/null
fi
#创建Clash appid.list
if [ ! -f ${appid_file} ];then
touch ${appid_file} 2>/dev/null
echo "ALL" > ${appid_file}
fi

}


initialization