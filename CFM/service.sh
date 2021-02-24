#!/system/bin/sh
# 请不要硬编码/magisk/modname/...;相反，请使用$MODDIR/...
# 这将使您的脚本兼容，即使Magisk以后改变挂载点
MODDIR=${0%/*}

linux_root='/data/00AA_Linux_App'
crontabs_file='/system/etc/00AA_Linux_App/template'
crontabs_dir='/data/00AA_Linux_App/var/spool/cron/crontabs'
log_dir='/data/00AA_Linux_App/LOG'
customize_dir='/data/00AA_Linux_App/customize'

clash_data_dir="/data/00AA_Linux_App/Clash"
conf_file="${clash_data_dir}/config.yaml"
geoip_file="${clash_data_dir}/Country.mmdb"


initialization(){

########文件########

#链接定时器默认文件
if [ ! -f ${crontabs_dir}/root ];then
#把自带定时任务和自定义任务合并
cat ${crontabs_file}/crontabs.txt ${customize_dir}/cron/crontabs.txt > ${crontabs_dir}/root
chmod 0777 ${crontabs_dir}/root
#把合并的任务文件链接到system目录
ln -s ${crontabs_dir}/root /system/etc/cron.d/root 2>/dev/null
else
rm -rf ${crontabs_dir}/root
rm -rf /system/etc/cron.d/root
cat ${crontabs_file}/crontabs.txt ${customize_dir}/cron/crontabs.txt > ${crontabs_dir}/root
chmod 0777 ${crontabs_dir}/root
ln -s ${crontabs_dir}/root /system/etc/cron.d/root 2>/dev/null
fi

if [ ! -f /data/00AA_Linux_App/Clash/template/template_config.yaml ];then
ln -s /system/etc/00AA_Linux_App/template/Clash/template_config.yaml /data/00AA_Linux_App/Clash/template/template_config.yaml
else
rm -rf /data/00AA_Linux_App/Clash/template/template_config.yaml
ln -s /system/etc/00AA_Linux_App/template/Clash/template_config.yaml /data/00AA_Linux_App/Clash/template/template_config.yaml
fi


}

start_service(){

#启动定时器
crond -c ${crontabs_dir} -l 0 -L ${log_dir}/crond_status.log

#启动Clash
wait_count=0
until [ $(getprop sys.boot_completed) -eq 1 ] && [ -d ${clash_data_dir} ]; do
  sleep 2
  wait_count=$((${wait_count} + 1))
  if [ ${wait_count} -ge 100 ] ; then
    exit 0
  fi
done

if [ -f ${linux_root}/Clash/clash.pid ];then
    rm -rf ${linux_root}/Clash/clash.pid
fi

flag=false
if [ ! -f ${geoip_file} ];then
    echo "$(date "+%Y-%m-%d %H:%M:%S") : 没有启动Clash,无法找到'Country.mmdb'文件. >>: ${geoip_file}\n已经尝试自动下载." > ${log_dir}/clash_service.log
    #cp /system/etc/00AA_Linux_App/template/Clash/Country.mmdb ${geoip_file}
    upgeoip
fi

if [ ! -f ${conf_file} ];then
    echo "$(date "+%Y-%m-%d %H:%M:%S") : 没有启动Clash,无法找到'config.yaml'文件. >>: ${conf_file}\n请设置订阅地址." > ${log_dir}/clash_service.log
    #cp /system/etc/00AA_Linux_App/template/Clash/config.yaml ${conf_file}
else
flag=true

fi

if ${flag};then
    clash_control enable
    echo "$(date "+%Y-%m-%d %H:%M:%S") : Clash已经启动." > ${log_dir}/clash_service.log
fi
# default disable ipv6 accept_ra
# echo 0 > /proc/sys/net/ipv6/conf/all/accept_ra
# echo 0 > /proc/sys/net/ipv6/conf/wlan0/accept_ra
# echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
# echo 1 > /proc/sys/net/ipv6/conf/wlan0/disable_ipv6

}

initialization
start_service



